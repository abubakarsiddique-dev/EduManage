const db = require('../../db/store');
const { AppError } = require('../../middleware/error.middleware');

const BadRequestError = (msg) => new AppError(msg, 400);
const NotFoundError = (msg) => new AppError(msg, 404);

function computeLetter(score, maxScore) {
  const pct = maxScore > 0 ? (score / maxScore) * 100 : 0;
  if (pct >= 90) return 'A+';
  if (pct >= 85) return 'A';
  if (pct >= 80) return 'A-';
  if (pct >= 75) return 'B+';
  if (pct >= 70) return 'B';
  if (pct >= 65) return 'B-';
  if (pct >= 60) return 'C+';
  if (pct >= 55) return 'C';
  if (pct >= 50) return 'C-';
  if (pct >= 40) return 'D';
  return 'F';
}

class ExamService {
  get collection() {
    return db.collection('exams');
  }

  async getAll(query = {}) {
    return this.collection.find((item) => {
      if (query.classId && item.classId !== query.classId) return false;
      if (query.subject && item.subject.toLowerCase() !== query.subject.toLowerCase()) return false;
      if (query.term && item.term !== query.term) return false;
      return true;
    });
  }

  async getById(id) {
    const exam = this.collection.findById(id);
    if (!exam) throw NotFoundError('Exam not found');
    return exam;
  }

  async create(data) {
    if (!data.title || !data.classId || !data.subject || data.maxScore === undefined) {
      throw BadRequestError('title, classId, subject, and maxScore are required');
    }
    const maxScore = Number(data.maxScore);
    if (isNaN(maxScore) || maxScore <= 0) {
      throw BadRequestError('maxScore must be a positive number');
    }

    const exam = {
      title: data.title.trim(),
      classId: data.classId,
      subject: data.subject.trim(),
      term: data.term || 'First Term',
      date: data.date || new Date().toISOString().split('T')[0],
      startTime: data.startTime || '09:00',
      durationMinutes: Number(data.durationMinutes) || 60,
      maxScore,
      passingScore: Number(data.passingScore) || Math.round(maxScore * 0.4),
      grades: [],
      status: 'scheduled',
    };

    return this.collection.insert(exam);
  }

  async submitGrades(id, gradesList) {
    const exam = await this.getById(id);
    if (!Array.isArray(gradesList) || gradesList.length === 0) {
      throw BadRequestError('grades must be a non-empty array');
    }

    const processed = [];
    for (const item of gradesList) {
      if (!item.studentId) {
        throw BadRequestError('Each grade entry requires a studentId');
      }
      const score = Number(item.score);
      if (isNaN(score) || score < 0 || score > exam.maxScore) {
        throw BadRequestError(
          `Invalid score ${item.score} for student ${item.studentId}. Must be between 0 and ${exam.maxScore}`
        );
      }

      processed.push({
        studentId: item.studentId,
        studentName: item.studentName || 'Student',
        score,
        percentage: Math.round((score / exam.maxScore) * 1000) / 10,
        letterGrade: computeLetter(score, exam.maxScore),
        remarks: item.remarks || '',
        submittedAt: new Date().toISOString(),
      });
    }

    const updated = this.collection.update(id, {
      grades: processed,
      status: 'evaluated',
      updatedAt: new Date().toISOString(),
    });
    return updated;
  }

  async curveExam(id, { strategy = 'anchorToMax', targetMax = 100, linearBoost = 5 }) {
    const exam = await this.getById(id);
    if (!exam.grades || exam.grades.length === 0) {
      throw BadRequestError('Cannot curve exam with no submitted grades');
    }

    const rawPercentages = exam.grades.map(g => g.percentage);
    const topPercentage = Math.max(...rawPercentages);
    const mean = rawPercentages.reduce((a, b) => a + b, 0) / rawPercentages.length;

    let varianceSum = 0;
    for (const p of rawPercentages) {
      varianceSum += Math.pow(p - mean, 2);
    }
    const stdDev = Math.sqrt(rawPercentages.length > 1 ? varianceSum / (rawPercentages.length - 1) : 0);

    const curvedGrades = exam.grades.map(g => {
      let curvedPct = g.percentage;

      if (strategy === 'anchorToMax') {
        const factor = topPercentage > 0 ? (targetMax / topPercentage) : 1;
        curvedPct = Math.min(targetMax, g.percentage * factor);
      } else if (strategy === 'linearBoost') {
        curvedPct = Math.min(100, g.percentage + Number(linearBoost));
      } else if (strategy === 'squareRoot') {
        curvedPct = Math.min(100, 10 * Math.sqrt(g.percentage));
      } else if (strategy === 'bellCurve') {
        const z = stdDev > 0 ? (g.percentage - mean) / stdDev : 0;
        let bellGrade = 'C';
        if (z >= 1.5) bellGrade = 'A';
        else if (z >= 0.5) bellGrade = 'B';
        else if (z >= -0.5) bellGrade = 'C';
        else if (z >= -1.5) bellGrade = 'D';
        else bellGrade = 'F';

        return {
          studentId: g.studentId,
          studentName: g.studentName,
          rawScore: g.score,
          rawPercentage: g.percentage,
          curvedPercentage: g.percentage,
          letterGrade: bellGrade,
          zScore: Math.round(z * 100) / 100,
        };
      }

      curvedPct = Math.round(curvedPct * 10) / 10;
      const curvedScore = Math.round(((curvedPct / 100) * exam.maxScore) * 10) / 10;

      return {
        studentId: g.studentId,
        studentName: g.studentName,
        rawScore: g.score,
        curvedScore,
        rawPercentage: g.percentage,
        curvedPercentage: curvedPct,
        letterGrade: computeLetter(curvedScore, exam.maxScore),
      };
    });

    return {
      examId: exam.id,
      title: exam.title,
      strategy,
      totalStudents: exam.grades.length,
      originalTop: topPercentage,
      curvedGrades,
    };
  }

  async getStatistics(id) {
    const exam = await this.getById(id);
    const grades = exam.grades || [];
    if (grades.length === 0) {
      return {
        examId: exam.id,
        title: exam.title,
        totalSubmissions: 0,
        averageScore: 0,
        medianScore: 0,
        highestScore: 0,
        lowestScore: 0,
        passingCount: 0,
        passingRate: 0,
        distribution: { A: 0, B: 0, C: 0, D: 0, F: 0 },
      };
    }

    const scores = grades.map(g => g.score).sort((a, b) => a - b);
    const count = scores.length;
    const sum = scores.reduce((a, b) => a + b, 0);
    const avg = Math.round((sum / count) * 100) / 100;
    const median = count % 2 === 1
      ? scores[Math.floor(count / 2)]
      : (scores[count / 2 - 1] + scores[count / 2]) / 2;

    const passing = scores.filter(s => s >= exam.passingScore).length;
    const distribution = { A: 0, B: 0, C: 0, D: 0, F: 0 };
    for (const g of grades) {
      const letter = (g.letterGrade || 'F')[0];
      if (distribution[letter] !== undefined) {
        distribution[letter]++;
      } else {
        distribution.F++;
      }
    }

    return {
      examId: exam.id,
      title: exam.title,
      maxScore: exam.maxScore,
      passingScore: exam.passingScore,
      totalSubmissions: count,
      averageScore: avg,
      medianScore: median,
      highestScore: scores[scores.length - 1],
      lowestScore: scores[0],
      passingCount: passing,
      passingRate: Math.round((passing / count) * 1000) / 10,
      distribution,
    };
  }

  async delete(id) {
    await this.getById(id);
    return this.collection.delete(id);
  }
}

module.exports = new ExamService();
