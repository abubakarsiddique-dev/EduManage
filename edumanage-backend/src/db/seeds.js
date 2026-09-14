const bcrypt = require('bcryptjs');
const db = require('./store');

let seedPromise = null;

const seedDatabase = async () => {
  if (seedPromise) return seedPromise;

  seedPromise = (async () => {
    const usersCol = db.collection('users');
    const classesCol = db.collection('classes');
    const studentsCol = db.collection('students');
    const teachersCol = db.collection('teachers');
    const parentsCol = db.collection('parents');
    const parentChildrenCol = db.collection('parent_children');

    // Check if already seeded
    if (usersCol.findOne((u) => u.email === 'admin@edumanage.edu')) {
      return;
    }

    const insertUser = (u) => {
      if (!usersCol.findOne((item) => item.email === u.email || item.id === u.id)) {
        usersCol.insert(u);
      }
    };
    const insertClass = (c) => {
      if (!classesCol.findById(c.id)) classesCol.insert(c);
    };
    const insertTeacher = (t) => {
      if (!teachersCol.findById(t.id)) teachersCol.insert(t);
    };
    const insertStudent = (s) => {
      if (!studentsCol.findById(s.id)) studentsCol.insert(s);
    };
    const insertParent = (p) => {
      if (!parentsCol.findById(p.id)) parentsCol.insert(p);
    };
    const insertParentChild = (pc) => {
      if (!parentChildrenCol.findById(pc.id)) parentChildrenCol.insert(pc);
    };

    console.log('[EduManage Seeds] Seeding initial database records...');

    const passwordHash = await bcrypt.hash('Password@123', 10);

    // 1. Admin User
    insertUser({
      id: 'admin_001',
      uid: 'admin_001',
      name: 'System Administrator',
      email: 'admin@edumanage.edu',
      password: passwordHash,
      role: 'admin',
      approved: true,
      photoUrl: '',
    });

    // 2. Classes
    insertClass({
      id: 'class_9a',
      name: 'Grade 9 - A',
      capacity: 35,
      teacherId: 'teacher_001',
      teacherName: 'Prof. John Smith',
    });

    insertClass({
      id: 'class_10b',
      name: 'Grade 10 - B',
      capacity: 30,
      teacherId: 'teacher_002',
      teacherName: 'Dr. Sarah Connor',
    });

    // 3. Teachers
    insertUser({
      id: 'teacher_001',
      uid: 'teacher_001',
      name: 'Prof. John Smith',
      email: 'john.smith@edumanage.edu',
      password: passwordHash,
      role: 'teacher',
      approved: true,
      photoUrl: '',
    });

    insertTeacher({
      id: 'teacher_001',
      uid: 'teacher_001',
      name: 'Prof. John Smith',
      email: 'john.smith@edumanage.edu',
      phone: '+1-555-0101',
      subject: 'Mathematics',
      qualification: 'M.Sc Mathematics',
      classes: ['Grade 9 - A'],
      approved: true,
    });

    insertUser({
      id: 'teacher_002',
      uid: 'teacher_002',
      name: 'Dr. Sarah Connor',
      email: 'sarah.connor@edumanage.edu',
      password: passwordHash,
      role: 'teacher',
      approved: true,
      photoUrl: '',
    });

    insertTeacher({
      id: 'teacher_002',
      uid: 'teacher_002',
      name: 'Dr. Sarah Connor',
      email: 'sarah.connor@edumanage.edu',
      phone: '+1-555-0102',
      subject: 'Physics',
      qualification: 'Ph.D Physics',
      classes: ['Grade 10 - B'],
      approved: true,
    });

    // 4. Students
    insertUser({
      id: 'student_001',
      uid: 'student_001',
      name: 'Alex Johnson',
      email: 'alex.johnson@edumanage.edu',
      password: passwordHash,
      role: 'student',
      approved: true,
      photoUrl: '',
    });

    insertStudent({
      id: 'student_001',
      uid: 'student_001',
      name: 'Alex Johnson',
      email: 'alex.johnson@edumanage.edu',
      rollNo: 'S9A-001',
      class: 'Grade 9 - A',
      section: 'A',
      contact: '+1-555-0201',
      approved: true,
    });

    insertUser({
      id: 'student_002',
      uid: 'student_002',
      name: 'Emma Watson',
      email: 'emma.watson@edumanage.edu',
      password: passwordHash,
      role: 'student',
      approved: true,
      photoUrl: '',
    });

    insertStudent({
      id: 'student_002',
      uid: 'student_002',
      name: 'Emma Watson',
      email: 'emma.watson@edumanage.edu',
      rollNo: 'S10B-001',
      class: 'Grade 10 - B',
      section: 'B',
      contact: '+1-555-0202',
      approved: true,
    });

    // 5. Parents
    insertUser({
      id: 'parent_001',
      uid: 'parent_001',
      name: 'Robert Johnson',
      email: 'robert.johnson@edumanage.edu',
      password: passwordHash,
      role: 'parent',
      approved: true,
      photoUrl: '',
    });

    insertParent({
      id: 'parent_001',
      uid: 'parent_001',
      name: 'Robert Johnson',
      email: 'robert.johnson@edumanage.edu',
      approved: true,
    });

    // Link parent to student
    insertParentChild({
      id: 'pc_001',
      parentId: 'parent_001',
      studentId: 'student_001',
      studentName: 'Alex Johnson',
      studentRollNo: 'S9A-001',
      className: 'Grade 9 - A',
    });

    console.log('[EduManage Seeds] Database seeded successfully.');
  })();

  return seedPromise;
};

module.exports = seedDatabase;
