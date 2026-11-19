// Department rule shared by the report scopes, matching
// `DepartmentProvider.departmentRecordVisible`. A record in no
// department has a null or blank department uuid.

/// True when [departmentUuid] is null or blank (no department).
bool isUnassignedDepartment(String? departmentUuid) =>
    departmentUuid == null || departmentUuid.trim().isEmpty;

/// Whether a record in [recordDepartmentUuid] belongs to the user's
/// current department, for a report that restricts by department.
/// With no current department (staff assigned to no department and
/// without "view all departments") only records in no department
/// match. Blank uuids count as no department.
bool reportDepartmentMatches(
  String? recordDepartmentUuid,
  String? currentDepartmentUuid,
) {
  if (isUnassignedDepartment(currentDepartmentUuid)) {
    return isUnassignedDepartment(recordDepartmentUuid);
  }
  return recordDepartmentUuid?.trim() == currentDepartmentUuid!.trim();
}
