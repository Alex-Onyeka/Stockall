// import 'package:flutter/material.dart';
// import 'package:stockall/classes/temp_referral_class.dart';
// import 'package:stockall/main.dart';
// import 'package:stockall/services/auth_service.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class UserProvider with ChangeNotifier {
//   final supabase = Supabase.instance.client;

//   int currentIndex = 0;

//   void navigate(int index) {
//     currentIndex = index;
//     notifyListeners();
//   }

//   List<TempReferralClass> _referrees = [];

//   List<TempReferralClass> get referrees => _referrees;

//   /// Create new referree
//   Future<void> addReferree(TempReferralClass newReferree) async {
//     final response =
//         await supabase
//             .from('referrees')
//             .insert(newReferree.toJson())
//             .select()
//             .single();

//     final added = TempReferralClass.fromJson(response);
//     _referrees.add(added);
//     notifyListeners();
//   }

//   /// Fetch all referree
//   Future<void> fetchReferrees() async {
//     final data = await supabase.from('referrees').select();
//     _referrees =
//         data
//             .map<TempReferralClass>(
//               (json) => TempReferralClass.fromJson(json),
//             )
//             .toList();
//     notifyListeners();
//   }

//   /// Update referree
//   Future<void> updateReferree(TempReferralClass update) async {
//     await supabase
//         .from('referrees')
//         .update(update.toJson())
//         .eq('id', update.id);
//     await fetchReferrees();
//   }

//   /// Delete referree
//   Future<void> deleteReferree(String id) async {
//     await supabase.from('referrees').delete().eq('id', id);
//     _referrees.removeWhere((ref) => ref.id == id);
//     notifyListeners();
//   }

//   /// Optional: Get referree by ID
//   TempReferralClass? currentReferree;
//   Future<void> getCurrentReferree() async {
//     try {
//       final res =
//           await supabase
//               .from('referrees')
//               .select()
//               .eq('id', AuthService().currentUser!.id)
//               .single();

//       currentReferree = TempReferralClass.fromJson(res);
//       notifyListeners();
//     } catch (e) {
//       print('Error getting referree: $e');
//       currentReferree = null;
//     }
//   }

//   void clearCache(BuildContext context) {
//     currentReferree = null;
//     returnShopProvider(context, listen: false).clearShops();
//     notifyListeners();
//   }

//   // Future<void> getReferreeById(String id) async {
//   //   try {
//   //     final res =
//   //         await supabase
//   //             .from('referrees')
//   //             .select()
//   //             .eq('id', id)
//   //             .single();

//   //     currentReferree = Referree.fromJson(res);
//   //     notifyListeners();
//   //   } catch (e) {
//   //     print('Error getting referree: $e');
//   //     currentReferree = null;
//   //   }
//   // }
// }
