/// Hierarchical administrative clearance gates and capabilities for campus operations.
class SecurityClearanceLevels {
  SecurityClearanceLevels._();

  static const int guest = 0;
  static const int student = 1;
  static const int parent = 1;
  static const int teacher = 2;
  static const int departmentHead = 3;
  static const int principal = 4;
  static const int superAdmin = 5;

  /// Returns numeric clearance weight based on role name.
  static int getClearance(String role) {
    switch (role.toLowerCase().trim()) {
      case 'superadmin':
      case 'super_admin':
        return superAdmin;
      case 'principal':
      case 'director':
        return principal;
      case 'head':
      case 'department_head':
        return departmentHead;
      case 'teacher':
        return teacher;
      case 'student':
        return student;
      case 'parent':
        return parent;
      default:
        return guest;
    }
  }

  /// Checks if a user has sufficient authorization level for a target clearance gate.
  static bool hasClearance(String userRole, int requiredClearance) {
    return getClearance(userRole) >= requiredClearance;
  }
}
