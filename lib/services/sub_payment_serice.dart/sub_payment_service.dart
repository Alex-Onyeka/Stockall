import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';

class PaymentInitResponse {
  final String authorizationUrl;
  final String reference;

  PaymentInitResponse({
    required this.authorizationUrl,
    required this.reference,
  });
}

class PaymentService {
  final String functionUrl;

  PaymentService(this.functionUrl);

  Future<PaymentInitResponse?> initiatePayment({
    required String userId,
    required String email,
    required int plan,
    required double amount,
    required int duration,
    required Uri callbackUrl,
  }) async {
    await mainLocalLog('About to Initiate Payment Process');
    final res = await http.post(
      Uri.parse(functionUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $supabaseAnonKey',
      },

      body: jsonEncode({
        'user_id': userId,
        'email': email,
        'plan': plan,
        'amount': amount,
        'duration': duration,
        'callback_url': callbackUrl.toString(),
      }),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return PaymentInitResponse(
        authorizationUrl:
            data['authorization_url'] as String,
        reference: data['reference'] as String,
      );
    } else {
      await mainLocalLog('Error: ${res.body}');
      return null;
    }
  }

  Future<bool> verifyPayment(String reference) async {
    final res = await http.post(
      Uri.parse(
        'https://jlwizkdhjazpbllpvtgo.functions.supabase.co/verify-subscription-payment',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $supabaseAnonKey',
      },
      body: jsonEncode({'reference': reference}),
    );

    if (res.statusCode == 200) {
      await mainLocalLog(
        'Payment verified and subscription updated',
      );
      return true;
    } else {
      await mainLocalLog(
        'Verification failed: ${res.body}',
      );
      return false;
    }
  }
}
