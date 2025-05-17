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

  Future<void> fetchUsers() async {
    isLoading = true;
    notifyListeners();

    final data = await _supabase.from('users').select();

    _users =
        data
            .map<TempUserClass>(
              (json) => TempUserClass.fromJson(json),
            )
            .toList();

    isLoading = false;
    notifyListeners();
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

  Future<void> addUser(TempUserClass user) async {
    await _supabase.from('users').insert({
      'user_id': user.userId,
      'created_at': user.createdAt?.toIso8601String(),
      'name': user.name,
      'email': user.email,
      'phone': user.phone,
      'role': user.role,
    });
    await fetchUsers();
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
      userId: 'user_001',
      createdAt: DateTime.now(),
      name: 'Alex Onyeka',
      email: 'alexonyekasm@gmail.com',
      phone: '08012345678',
      role: 'admin',
    ),
    TempUserClass(
      userId: 'user_002',
      createdAt: DateTime.now(),
      name: 'Chioma Eze',
      email: 'chioma@example.com',
      phone: '08123456789',
      role: 'manager',
    ),
    TempUserClass(
      userId: 'user_003',
      createdAt: DateTime.now(),
      name: 'Ahmed Musa',
      email: 'ahmed@example.com',
      phone: '09098765432',
      role: 'staff',
    ),
  ];

  TempUserClass currentUser(String userId) {
    return users.firstWhere(
      (element) => element.userId == userId,
    );
  }
}
