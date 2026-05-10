import 'package:flutter/cupertino.dart';
import 'package:stockall/classes/utility_constants/utility_constants.dart';
import 'package:stockall/local_database/utility_constants/utility_constants_func.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UtilityConstantProvider extends ChangeNotifier {
  static final UtilityConstantProvider _instance =
      UtilityConstantProvider._internal();
  factory UtilityConstantProvider() => _instance;
  UtilityConstantProvider._internal();

  final SupabaseClient _client = Supabase.instance.client;

  final String tableName = 'utility_constants';

  UtilityConstants? utilityConstants;

  Future<UtilityConstants?> getUtilityConstants() async {
    bool isOnline = await ConnectivityProvider().isOnline();
    if (isOnline) {
      try {
        var res =
            await _client.from(tableName).select().single();

        utilityConstants = UtilityConstants.fromJson(res);

        print("💕💕👏${utilityConstants?.basicPlan}");
        print("💕💕👏${utilityConstants?.vat}");

        UtilityConstantsFunc().insertUtilityConstant(
          UtilityConstants.fromJson(res),
        );

        notifyListeners();

        print('Utility Constants gotten Successfully');

        return utilityConstants;
      } catch (e) {
        print(
          '❌Error Getting Utility Constants: ${e.toString()}',
        );
        return null;
      }
    } else {
      utilityConstants =
          UtilityConstantsFunc().getUtilityConstants();
      notifyListeners();
      print('Utility Constants gotten Offline');
      return utilityConstants;
    }
  }
}
