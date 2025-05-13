class TempEmployeeClass {
  String id;
  String employeeName;
  String? email;
  DateTime createdDate;
  String? phoneNumber;
  String role;
  String address;

  TempEmployeeClass({
    required this.createdDate,
    this.email,
    required this.employeeName,
    required this.id,
    required this.role,
    this.phoneNumber,
    required this.address,
  });
}
