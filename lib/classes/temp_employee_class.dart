// class TempEmployeeClass {
//   String? id;
//   String employeeName;
//   int? shopId;
//   String email;
//   DateTime? createdDate;
//   String? phoneNumber;
//   String role;

//   TempEmployeeClass({
//     this.id,
//     required this.employeeName,
//     required this.email,
//     this.shopId,
//     this.createdDate,
//     this.phoneNumber,
//     required this.role,
//   });

//   factory TempEmployeeClass.fromJson(
//     Map<String, dynamic> json,
//   ) {
//     return TempEmployeeClass(
//       id: json['id'] as String?,
//       employeeName: json['employee_name'] as String,
//       email: json['email'] as String,
//       shopId: json['shop_id'] as int,
//       createdDate:
//           json['created_date'] != null
//               ? DateTime.parse(json['created_date'])
//               : null,
//       phoneNumber: json['phone_number'] as String?,
//       role: json['role'] as String,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'employee_name': employeeName,
//       'email': email,
//       'shop_id': shopId,
//       'phone_number': phoneNumber,
//       'role': role,
//     };
//   }
// }
