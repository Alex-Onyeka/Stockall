// class TempReferralClass {
//   final String id;
//   final DateTime createdDate;
//   final String name;
//   final String email;
//   final String phone;
//   final String state;
//   final String refCode;
//   final bool isAdmin;
//   String? accountName;
//   String? accountNumber;
//   String? bankName;
//   String password;

//   TempReferralClass({
//     required this.id,
//     required this.createdDate,
//     required this.name,
//     required this.email,
//     required this.phone,
//     required this.state,
//     required this.refCode,
//     required this.isAdmin,
//     this.accountName,
//     this.accountNumber,
//     this.bankName,
//     required this.password,
//   });

//   // 🔁 Factory method to create an instance from JSON
//   factory TempReferralClass.fromJson(
//     Map<String, dynamic> json,
//   ) {
//     return TempReferralClass(
//       id: json['id'],
//       createdDate: DateTime.parse(json['created_at']),
//       name: json['name'],
//       email: json['email'],
//       phone: json['phone'],
//       state: json['state'],
//       refCode: json['ref_code'],
//       isAdmin: json['is_admin'],
//       accountName: json['account_name'] as String?,
//       accountNumber: json['account_number'] as String?,
//       bankName: json['bank_name'] as String?,
//       password: json['password'] as String,
//     );
//   }

//   // 🔁 Method to convert an instance to JSON
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'created_at': createdDate.toIso8601String(),
//       'name': name,
//       'email': email,
//       'phone': phone,
//       'state': state,
//       'ref_code': refCode,
//       'account_name': accountName,
//       'account_number': accountNumber,
//       'bank_name': bankName,
//       'password': password,
//     };
//   }
// }
