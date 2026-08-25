/// Campus spatial zoning, building codes, and wing metadata.
class CampusBuildingInfo {
  final String buildingCode;
  final String buildingName;
  final int totalFloors;
  final List<String> departments;

  const CampusBuildingInfo({
    required this.buildingCode,
    required this.buildingName,
    required this.totalFloors,
    required this.departments,
  });
}

class CampusBuildingMap {
  CampusBuildingMap._();

  static const List<CampusBuildingInfo> buildings = [
    CampusBuildingInfo(
      buildingCode: 'ADM',
      buildingName: 'Administration Complex',
      totalFloors: 3,
      departments: ['Principal Office', 'Accounts', 'Admissions', 'HR'],
    ),
    CampusBuildingInfo(
      buildingCode: 'SCI',
      buildingName: 'Ibn-e-Sina Science Block',
      totalFloors: 4,
      departments: ['Physics Lab', 'Chemistry Lab', 'Biology Lab', 'Lecture Theaters'],
    ),
    CampusBuildingInfo(
      buildingCode: 'ITB',
      buildingName: 'Al-Khwarizmi IT Center',
      totalFloors: 3,
      departments: ['Computer Labs', 'Robotics Center', 'Server Room'],
    ),
    CampusBuildingInfo(
      buildingCode: 'LIB',
      buildingName: 'Central Library & Media Center',
      totalFloors: 2,
      departments: ['Reading Halls', 'Digital Archives', 'Discussion Rooms'],
    ),
  ];

  static CampusBuildingInfo? findByCode(String code) {
    for (final b in buildings) {
      if (b.buildingCode.toUpperCase() == code.trim().toUpperCase()) {
        return b;
      }
    }
    return null;
  }
}
