import 'package:flutter/widgets.dart';
import 'package:stockall/classes/temp_logged_in_user/logged_in_user.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/local_database/logged_in_user/logged_in_user_func.dart';
import 'package:stockall/local_database/users/user_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:stockall/services/auth_service.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class UserProvider extends ChangeNotifier {
  //
  //
  //

  // final SupabaseClient _supabase = Supabase.instance.client;
  final AuthService _supabase = AuthService();

  static final UserProvider _instance =
      UserProvider._internal();
  factory UserProvider() => _instance;
  UserProvider._internal();

  List<TempUserClass> _users = [];
  List<TempUserClass> get usersMain => _users;

  void clearUsers() {
    usersMain.clear();
    print('📍📍📍Users Cleared');
    notifyListeners();
  }

  bool isLoading = false;

  Future<List<TempUserClass>> fetchUsersByShop(
    // BuildContext context,
  ) async {
    try {
      // final authUser = _supabase.currentUser;

      isLoading = true;
      bool isOnline =
          await ConnectivityProvider().isOnline();

      if (isOnline) {
        await returnShopProvider().getUserShops();
        var employees =
            returnShopProvider().userShop()!.employees ??
            [];
        final data = await _supabase.client
            .from('users')
            .select()
            .inFilter('user_id', employees);
        print('Users Gotten from Supabase: ${data.length}');

        _users =
            data
                .map<TempUserClass>(
                  (json) => TempUserClass.fromJson(json),
                )
                .toList();
        notifyListeners();
        await UserFunc().insertAllUsers(_users);
      } else {
        _users = UserFunc().getUsers();
        notifyListeners();
      }

      _users.sort(
        (a, b) => a.name.toLowerCase().compareTo(
          b.name.toLowerCase(),
        ),
      );
      notifyListeners();
      isLoading = false;
      return _users;
    } catch (e) {
      print('Error Fetching Users: ${e.toString()}');
      return [];
    }
  }

  TempUserClass? _currentUser;
  TempUserClass? get currentUserMain => _currentUser;

  Future<TempUserClass?> fetchCurrentUser(
    BuildContext context,
  ) async {
    bool isOnline = await ConnectivityProvider().isOnline();
    if (isOnline) {
      // ignore: use_build_context_synchronously
      if (returnData().isSynced() == 0) {
        await returnData(
          // ignore: use_build_context_synchronously
        ).syncData(context: context);
        final authUser = _supabase.currentUser;
        if (authUser == null) {
          _currentUser = null;
          print('No User Found');
          return null;
        }
        final data =
            await _supabase.client
                .from('users')
                .select()
                .eq('user_id', authUser)
                .single();

        _currentUser = TempUserClass.fromJson(data);
        // notifyListeners();
        print('User Found: ${_currentUser?.name}');
        await UserFunc().insertUser(_currentUser!);
        await LoggedInUserFunc().insertLoggedInUser(
          LoggedInUser(loggedInUser: _currentUser),
        );
      } else {
        final authUser = _supabase.currentUser;
        if (authUser == null) {
          _currentUser = null;
          print('No User Found');
          return null;
        }
        final data =
            await _supabase.client
                .from('users')
                .select()
                .eq('user_id', authUser)
                .single();
        _currentUser = TempUserClass.fromJson(data);
        print('User Found: ${_currentUser?.name}');
        await UserFunc().insertUser(_currentUser!);
        await LoggedInUserFunc().insertLoggedInUser(
          LoggedInUser(loggedInUser: _currentUser),
        );
      }
    } else {
      _currentUser =
          LoggedInUserFunc()
              .getLoggedInUser()
              ?.loggedInUser;
      print(
        'Current Logged In User: ${_currentUser?.name}',
      );
    }

    notifyListeners();
    return _currentUser;
  }

  Future<TempUserClass> fetchUserById(String userId) async {
    bool isOnline = await ConnectivityProvider().isOnline();
    if (isOnline) {
      final data =
          await _supabase.client
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
      await _supabase.client
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
      await _supabase.client
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
            await _supabase.client
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

  Future<TempUserClass> updateUser(
    TempUserClass user,
    BuildContext context,
  ) async {
    if (user.userId == null) {
      throw Exception('User ID is required for update.');
    }

    final updatedRows =
        await _supabase.client
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

    await fetchUsersByShop();

    return updatedUser;
  }

  Future<int> updateStaffAccess({
    required TempUserClass user,
    required List<String> newAccess,
  }) async {
    try {
      final updatedAccess = newAccess.toSet().toList();

      await _supabase.client
          .from('users')
          .update({'access': updatedAccess})
          .eq('user_id', user.userId!);
      await fetchUsersByShop();
      return 1;
    } catch (e) {
      print(
        'Failed to update user access: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> updateStaffDepartments({
    required TempUserClass user,
    required List<String> newDepartments,
  }) async {
    try {
      final updatedDepartments =
          newDepartments.toSet().toList();

      await _supabase.client
          .from('users')
          .update({'department_uuids': updatedDepartments})
          .eq('user_id', user.userId!);
      await fetchUsersByShop();
      return 1;
    } catch (e) {
      print(
        'Failed to update user Departments: ${e.toString()}',
      );
      return 0;
    }
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
          await _supabase.client
              .from('users')
              .select('user_id')
              .eq('user_id', userId)
              .maybeSingle();

      if (authUserResponse == null) {
        print("Auth Response is Null");
        return '131';
      }

      // Proceed with updating the role
      await _supabase.client
          .from('users')
          .update({
            'role': newRole,
            'auth_user_id': authUserId,
          })
          .eq('user_id', userId);

      var user = usersMain.where(
        (user) => user.userId == userId,
      );
      if (user.isEmpty) {
        print('User Not Found');
      } else {
        user.first.role = newRole;
      }

      if (newRole == 'Owner') {
        final response =
            await _supabase.client
                .from('shops')
                .select('employees')
                .eq(
                  'shop_id',
                  returnShopProvider()
                          .userShop()
                          ?.shopId! ??
                      0,
                )
                .maybeSingle();

        if (response == null) {
          print('Shop not found');
          // return;
        }

        List<String> currentEmployees = [];

        if (response!['employees'] != null) {
          currentEmployees = List<String>.from(
            response['employees'],
          );
        }

        if (currentEmployees.contains(userId)) {
          currentEmployees.remove(userId);
        } else {
          print(
            'Error Removing User Id From Shop Employees',
          );
        }

        // Step 3: Update the shop's employees field
        final updateResponse = await _supabase.client
            .from('shops')
            .update({'employees': currentEmployees})
            .eq(
              'shop_id',
              returnShopProvider().userShop()?.shopId! ?? 0,
            );

        if (updateResponse != null) {
          print('Failed to update shop: $updateResponse');
        } else {
          print('Employee added successfully.');
        }
      }
      notifyListeners();
      await fetchUsersByShop();
      return null; // success
    } catch (e) {
      print('❌❌ Error updating employee role: $e');
      return 'Error: ${e.toString()}';
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _supabase.client
          .from('users')
          .delete()
          .eq('user_id', userId);
      print('User Row Deleted Successfully');
    } catch (e) {
      print("User Row Deletiong Failed: ${e.toString()}");
    }
  }

  //
  //
  //
  //
}
