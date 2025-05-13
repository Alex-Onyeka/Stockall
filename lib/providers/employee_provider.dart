import 'package:flutter/material.dart';
import 'package:stockitt/classes/temp_employee_class.dart';

class EmployeeProvider extends ChangeNotifier {
  List<TempEmployeeClass> employeeList = [
    TempEmployeeClass(
      id: '1',
      employeeName: 'Johnson Alice',
      email: 'alice.johnson@example.com',
      createdDate: DateTime.now(),
      phoneNumber: '123-456-7890',
      role: 'Manager',
      address: 'Wuse 2 Abuja',
    ),
    TempEmployeeClass(
      id: '2',
      employeeName: 'John Smith',
      email: 'bob.smith@example.com',
      createdDate: DateTime.now(),
      phoneNumber: '987-654-3210',
      role: 'Developer',
      address: 'Close to Berger Junction',
    ),
  ];

  TempEmployeeClass returnEmployee(String employeeId) {
    return employeeList.firstWhere(
      (employee) => employee.id == employeeId,
    );
  }
}
