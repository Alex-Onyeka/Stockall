// import 'package:flutter/material.dart';
// import 'package:stockitt/classes/temp_employee_class.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class EmployeeProvider extends ChangeNotifier {
//   final SupabaseClient supabase = Supabase.instance.client;

//   Future<void> createEmployee(
//     TempEmployeeClass employee,
//   ) async {
//     await supabase
//         .from('employees')
//         .insert(employee.toJson());
//   }

//   // READ (all)
//   Future<List<TempEmployeeClass>> fetchEmployeesByShop(
//     int shopId,
//   ) async {
//     final response = await supabase
//         .from('employees')
//         .select()
//         .eq('shop_id', shopId)
//         .order(
//           'employee_name',
//           ascending: true,
//         ); // Sort by name

//     final data = response as List<dynamic>;
//     return data
//         .map((e) => TempEmployeeClass.fromJson(e))
//         .toList();
//   }

//   Future<TempEmployeeClass?> fetchEmployeeById(
//     String id,
//   ) async {
//     final response =
//         await supabase
//             .from('employees')
//             .select()
//             .eq('id', id)
//             .single();

//     return TempEmployeeClass.fromJson(response);
//   }

//   // UPDATE
//   Future<void> updateEmployee(
//     TempEmployeeClass employee,
//   ) async {
//     await supabase
//         .from('employees')
//         .update(employee.toJson())
//         .eq('id', employee.id!);
//   }

//   // DELETE
//   Future<void> deleteEmployee(String id) async {
//     await supabase.from('employees').delete().eq('id', id);
//   }

//   List<TempEmployeeClass> employeeList = [
//     TempEmployeeClass(
//       shopId: 1,
//       id: '1',
//       employeeName: 'Johnson Alice',
//       email: 'alice.johnson@example.com',
//       createdDate: DateTime.now(),
//       phoneNumber: '123-456-7890',
//       role: 'Manager',
//     ),
//     TempEmployeeClass(
//       shopId: 2,
//       id: '2',
//       employeeName: 'John Smith',
//       email: 'bob.smith@example.com',
//       createdDate: DateTime.now(),
//       phoneNumber: '987-654-3210',
//       role: 'Developer',
//     ),
//   ];

//   TempEmployeeClass returnEmployee(String employeeId) {
//     return employeeList.firstWhere(
//       (employee) => employee.id == employeeId,
//     );
//   }
// }
