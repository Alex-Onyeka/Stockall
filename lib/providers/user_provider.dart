import 'package:flutter/widgets.dart';
import 'package:stockall/classes/temp_user_class.dart';
import 'package:stockall/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProvider extends ChangeNotifier {
  //
  //
  //

  final SupabaseClient _supabase = Supabase.instance.client;

  List<TempUserClass> _users = [];
  List<TempUserClass> get usersMain => _users;

  bool isLoading = false;

  Future<List<TempUserClass>> fetchUsers() async {
    final authUser = _supabase.auth.currentUser;
    isLoading = true;

    // if (authUser == null) {
    //   _currentUser = null;
    //   return null;
    // }

    final data = await _supabase
        .from('users')
        .select()
        .eq('auth_user_id', authUser!.id);

    _users =
        data
            .map<TempUserClass>(
              (json) => TempUserClass.fromJson(json),
            )
            .toList();

    _users.sort(
      (a, b) => a.name.toLowerCase().compareTo(
        b.name.toLowerCase(),
      ),
    );

    isLoading = false;
    return _users;
  }

  TempUserClass? _currentUser;
  TempUserClass? get currentUserMain => _currentUser;

  Future<TempUserClass?> fetchCurrentUser(
    BuildContext context,
  ) async {
    final authUser = _supabase.auth.currentUser;

    if (authUser == null) {
      _currentUser = null;
      return null;
    }

    final data =
        await _supabase
            .from('users')
            .select()
            .eq('user_id', authUser.id)
            .single();

    _currentUser = TempUserClass.fromJson(data);

    if (context.mounted) {
      await returnLocalDatabase(
        context,
        listen: false,
      ).insertUser(_currentUser!);
    }
    notifyListeners();
    return _currentUser;
  }

  Future<TempUserClass> fetchUserById(String userId) async {
    final data =
        await _supabase
            .from('users')
            .select()
            .eq('user_id', userId)
            .single();

    var user = TempUserClass.fromJson(data);
    notifyListeners();
    return user;
  }

  Future<void> updatePasswordInSupabase({
    required String userId,
    required String newPassword,
  }) async {
    try {
      await _supabase
          .from('users')
          .update({'password': newPassword})
          .eq('auth_user_id', userId)
          .single();

      print("✅ Password updated on Supabase");
    } catch (e) {
      print("❌ Failed to update password: $e");
    }
  }

  // TempUserClass? currentUserEmp;

  // void setEmployee(TempUserClass user) {
  //   currentUserEmp = user;
  //   notifyListeners();
  // }

  // void logoutCurrentEmployee() {
  //   currentUserEmp = null;
  //   notifyListeners();
  // }

  Future<TempUserClass?> fetchUserByEmailAndAuthId(
    String email,
    String authId,
  ) async {
    try {
      final data =
          await _supabase
              .from('users')
              .select()
              .eq('email', email.toLowerCase())
              .eq('auth_user_id', authId)
              .maybeSingle();

      if (data == null) {
        return null;
      }

      var user = TempUserClass.fromJson(data);
      notifyListeners();
      return user;
    } catch (e) {
      return null;
    }
  }

  Future<void> addUser(
    TempUserClass user,
    BuildContext context,
  ) async {
    try {
      await _supabase
          .from('users')
          .insert(user.toJson(includeUserId: true));
      await fetchUsers();
      if (context.mounted) {
        await fetchCurrentUser(context);
      }
    } catch (e, st) {
      debugPrint('Error adding main user: $e\n$st');
    }
  }

  Future<void> addEmployee(TempUserClass employee) async {
    try {
      await _supabase
          .from('users')
          .insert(employee.toJson(includeUserId: false));
      await fetchUsers();
    } catch (e, st) {
      debugPrint('Error adding employee: $e\n$st');
    }
  }

  Future<TempUserClass> updateUser(
    TempUserClass user,
    BuildContext context,
  ) async {
    if (user.userId == null) {
      throw Exception('User ID is required for update.');
    }

    final updatedRows =
        await _supabase
            .from('users')
            .update({
              'name': user.name,
              'email': user.email,
              'phone': user.phone,
              'role': user.role,
              'password': user.password,
            })
            .eq('user_id', user.userId!)
            .select()
            .single();
    final updatedUser = TempUserClass.fromJson(updatedRows);
    // if (context.mounted) {
    //   await returnLocalDatabase(
    //     context,
    //     listen: false,
    //   ).deleteUser();
    // }
    // if (context.mounted) {
    //   returnLocalDatabase(
    //     context,
    //     listen: false,
    //   ).insertUser(updatedUser);
    // }

    await fetchUsers();

    return updatedUser;
  }

  Future<void> updateEmployeeRole({
    required String userId,
    required String newRole,
    required String authUserId,
  }) async {
    final supabase = Supabase.instance.client;

    final response = await supabase
        .from('users') // use your actual table name
        .update({
          'role': newRole,
          'auth_user_id': authUserId,
        })
        .eq('user_id', userId);

    if (response != null) {
      throw Exception('Failed to update role: $response');
    }
  }

  Future<void> deleteUser(String userId) async {
    await _supabase
        .from('users')
        .delete()
        .eq('user_id', userId);
    await fetchUsers();
  }

  //
  //
  //
  //

  final List<TempUserClass> users = [
    TempUserClass(
      authUserId: '',
      userId: 'user_001',
      createdAt: DateTime.now(),
      name: 'Alex Onyeka',
      email: 'alexonyekasm@gmail.com',
      phone: '08012345678',
      role: 'admin',
      password: '',
    ),
    TempUserClass(
      password: '',
      authUserId: '',
      userId: 'user_002',
      createdAt: DateTime.now(),
      name: 'Chioma Eze',
      email: 'chioma@example.com',
      phone: '08123456789',
      role: 'manager',
    ),
    TempUserClass(
      authUserId: '',
      userId: 'user_003',
      createdAt: DateTime.now(),
      name: 'Ahmed Musa',
      email: 'ahmed@example.com',
      phone: '09098765432',
      role: 'staff',
      password: '',
    ),
  ];

  TempUserClass currentUser(String userId) {
    return users.firstWhere(
      (element) => element.userId == userId,
    );
  }
}
