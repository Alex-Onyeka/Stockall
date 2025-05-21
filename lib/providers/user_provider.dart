import 'package:flutter/widgets.dart';
import 'package:stockitt/classes/temp_user_class.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProvider extends ChangeNotifier {
  //
  //
  //

  final SupabaseClient _supabase = Supabase.instance.client;

  List<TempUserClass> _users = [];
  List<TempUserClass> get usersMain => _users;

  bool isLoading = false;

  Future<List<TempUserClass>?> fetchUsers() async {
    final authUser = _supabase.auth.currentUser;
    isLoading = true;
    notifyListeners();
    if (authUser == null) {
      _currentUser = null;
      return null;
    }

    final data = await _supabase
        .from('users')
        .select()
        .eq('auth_user_id', authUser.id);

    _users =
        data
            .map<TempUserClass>(
              (json) => TempUserClass.fromJson(json),
            )
            .toList();

    isLoading = false;
    notifyListeners();
    return _users;
  }

  TempUserClass? _currentUser;
  TempUserClass? get currentUserMain => _currentUser;

  Future<void> fetchCurrentUser() async {
    final authUser = _supabase.auth.currentUser;

    if (authUser == null) {
      _currentUser = null;
      return;
    }

    final data =
        await _supabase
            .from('users')
            .select()
            .eq('user_id', authUser.id)
            .single();

    _currentUser = TempUserClass.fromJson(data);
    notifyListeners();
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

  TempUserClass? currentUserEmp;

  void setEmployee(TempUserClass user) {
    currentUserEmp = user;
    notifyListeners();
  }

  void logoutCurrentEmployee() {
    currentUserEmp = null;
    notifyListeners();
  }

  Future<TempUserClass?> fetchUserByEmailAndAuthId(
    String email,
    String authId,
  ) async {
    try {
      final data =
          await _supabase
              .from('users')
              .select()
              .eq('email', email)
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

  Future<void> addUser(TempUserClass user) async {
    await _supabase.from('users').insert(user.toJson());

    await fetchUsers(); // still useful if you rely on the list
    await fetchCurrentUser(); // update the _currentUser right after insertion
  }

  Future<void> updateUser(TempUserClass user) async {
    if (user.userId == null) {
      throw Exception('User ID is required for update.');
    }

    await _supabase
        .from('users')
        .update({
          'name': user.name,
          'email': user.email,
          'phone': user.phone,
          'role': user.role,
        })
        .eq('user_id', user.userId!);

    await fetchUsers();
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
