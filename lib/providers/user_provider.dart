import 'package:flutter/widgets.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/local_database/logged_in_user/logged_in_user_func.dart';
import 'package:stockall/local_database/users/user_func.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class UserProvider extends ChangeNotifier {
  //
  //
  //

  final SupabaseClient _supabase = Supabase.instance.client;

  List<TempUserClass> _users = [];
  List<TempUserClass> get usersMain => _users;

  void clearUsers() {
    usersMain.clear();
    notifyListeners();
  }

  bool isLoading = false;

  Future<List<TempUserClass>> fetchUsers() async {
    final authUser = _supabase.auth.currentUser;
    isLoading = true;
    bool isOnline = await ConnectivityProvider().isOnline();

    if (isOnline) {
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
      await UserFunc().insertAllUsers(_users);
    } else {
      _users = UserFunc().getUsers();
    }
    _users.sort(
      (a, b) => a.name.toLowerCase().compareTo(
        b.name.toLowerCase(),
      ),
    );
    notifyListeners();
    isLoading = false;
    return _users;
  }

  TempUserClass? _currentUser;
  TempUserClass? get currentUserMain => _currentUser;

  Future<TempUserClass?> fetchCurrentUser(
    BuildContext context,
  ) async {
    bool isOnline = await ConnectivityProvider().isOnline();
    if (isOnline) {
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
      await UserFunc().insertUser(_currentUser!);
    } else {
      _currentUser =
          LoggedInUserFunc()
              .getLoggedInUser()
              ?.loggedInUser;
    }

    notifyListeners();
    return _currentUser;
  }

  Future<TempUserClass> fetchUserById(String userId) async {
    bool isOnline = await ConnectivityProvider().isOnline();
    if (isOnline) {
      final data =
          await _supabase
              .from('users')
              .select()
              .eq('user_id', userId)
              .single();

      var user = TempUserClass.fromJson(data);
      notifyListeners();
      return user;
    } else {
      return UserFunc().getUser(userId)!;
    }
  }

  Future<void> updatePasswordInSupabase({
    required String userId,
    required String newPassword,
  }) async {
    try {
      await _supabase
          .from('users')
          .update({'password': newPassword})
          .eq('user_id', userId);

      print("✅ Password updated on Supabase");
    } catch (e) {
      print("❌ Failed to update password: $e");
    }
  }

  Future<void> updatePinInSupabase({
    required String userId,
    required String newPin,
  }) async {
    try {
      await _supabase
          .from('users')
          .update({'pin': newPin})
          .eq('user_id', userId);

      print("✅ Password updated on Supabase");
    } catch (e) {
      print("❌ Failed to update password: $e");
    }
  }

  Future<TempUserClass?> fetchUserByEmailAndAuthId(
    String email,
    String userId,
  ) async {
    bool isOnline = await ConnectivityProvider().isOnline();
    if (isOnline) {
      try {
        final data =
            await _supabase
                .from('users')
                .select()
                .eq('email', email.toLowerCase())
                .eq('user_id', userId)
                .maybeSingle();

        if (data == null) {
          print('User not found');
          return null;
        }

        var user = TempUserClass.fromJson(data);
        notifyListeners();
        print('User found');
        return user;
      } catch (e) {
        return null;
      }
    } else {
      return UserFunc().getUserByEmailandPassword(
        userId,
        email,
      );
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

    await fetchUsers();

    return updatedUser;
  }

  Future<String?> updateEmployeeRole({
    required String userId,
    required String newRole,
    required String authUserId,
  }) async {
    try {
      // Check if authUserId is a valid UUID
      final isValidUuid = Uuid.parse(authUserId).isNotEmpty;
      if (!isValidUuid) {
        return '121';
      }

      // Check if auth user exists
      final authUserResponse =
          await _supabase
              .from(
                'users',
              ) // Adjust if your actual auth table is different
              .select('user_id')
              .eq('user_id', userId)
              .maybeSingle();

      if (authUserResponse == null) {
        return '131';
      }

      // Proceed with updating the role
      await _supabase
          .from('users')
          .update({
            'role': newRole,
            'auth_user_id': authUserId,
          })
          .eq('user_id', userId);

      var user = usersMain.firstWhere(
        (user) => user.userId == userId,
      );
      user.role = newRole;
      notifyListeners();

      return null; // success
    } catch (e) {
      print('Error updating employee role: $e');
      return 'Error: ${e.toString()}';
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
