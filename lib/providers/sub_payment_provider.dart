import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

class SubPaymentProvider extends ChangeNotifier {
  // final SupabaseClient _client = Supabase.instance.client;
  final String tableName = 'subscription_payments';

  int currentDuration = 6;

  void selectDuration(int duration) {
    currentDuration = duration;
    if (duration == 6) {
      discount = 0.08;
    } else if (duration == 12) {
      discount = 0.12;
    } else {
      discount = null;
    }
    notifyListeners();
  }

  double? discount;

  // Future<TempSubPaymentClass> createSubPayment()async{
  //   try
  // }
}
