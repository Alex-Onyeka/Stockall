import 'package:flutter/cupertino.dart';
import 'package:stockall/classes/utility_constants/utility_constants.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/local_database/utility_constants/utility_constants_func.dart';
import 'package:stockall/main.dart';
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

  bool hasViewedUpdate = false;

  void closeUpdate() {
    hasViewedUpdate = true;
    notifyListeners();
  }
}

class UpdateInformationWidget extends StatefulWidget {
  const UpdateInformationWidget({super.key});

  @override
  State<UpdateInformationWidget> createState() =>
      _UpdateInformationWidgetState();
}

class _UpdateInformationWidgetState
    extends State<UpdateInformationWidget> {
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return DialogTemplate(
      theme: theme,
      message:
          'Go through the List below to find out information about each Update and how to use them.',
      title: 'New Update 📢',
      action: () {},
      widget: Container(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: screenHeight(context) - 100,
        ),
      ),
    );
  }
}
