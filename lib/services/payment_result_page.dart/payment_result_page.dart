import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polygon_clipper/flutter_polygon_clipper.dart';
import 'package:lottie/lottie.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/base_page/base_page.dart';
import 'package:stockall/services/sub_payment_serice.dart/sub_payment_service.dart';

class PaymentResultPage extends StatefulWidget {
  final PaymentInitResponse? response;
  const PaymentResultPage({super.key, this.response});

  @override
  State<PaymentResultPage> createState() =>
      _PaymentResultPageState();
}

class _PaymentResultPageState
    extends State<PaymentResultPage> {
  bool isLoading = true;
  bool? isVerified;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => isLoading = true);

      if (kIsWeb) {
        final uri = Uri.base;
        final reference = uri.queryParameters['reference'];
        if (reference == null || reference.isEmpty) {
          print('Reference is Empty');
          setState(() {
            isVerified = false;
            isLoading = true;
          });
          return;
        }

        final paymentService = PaymentService(
          'https://jlwizkdhjazpbllpvtgo.functions.supabase.co/verify-subscription-payment',
        );

        final verified = await paymentService.verifyPayment(
          reference,
        );

        setState(() {
          isVerified = verified;
          isLoading = false;
        });
      } else {
        String? reference;
        reference = widget.response?.reference;
        if (reference == null) {
          setState(() {
            isVerified = false;
            isLoading = true;
          });
          return;
        }

        final paymentService = PaymentService(
          'https://jlwizkdhjazpbllpvtgo.functions.supabase.co/verify-subscription-payment',
        );

        final verified = await paymentService.verifyPayment(
          reference,
        );

        setState(() {
          isVerified = verified;
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(20),
              constraints: BoxConstraints(maxWidth: 500),
              height: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(
                      29,
                      0,
                      0,
                      0,
                    ),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Builder(
                      builder: (context) {
                        if (isVerified ?? true) {
                          return LottieBuilder.asset(
                            height: 200,
                            fit: BoxFit.cover,
                            successAnim,
                          );
                        } else {
                          return SizedBox(
                            height: 90,
                            width: 90,
                            child: FlutterClipPolygon(
                              sides: 8,
                              borderRadius: 10,
                              rotate: 0.0,
                              boxShadows: [
                                PolygonBoxShadow(
                                  color:
                                      const Color.fromARGB(
                                        101,
                                        0,
                                        0,
                                        0,
                                      ),
                                  elevation: 1.0,
                                ),
                                PolygonBoxShadow(
                                  color:
                                      const Color.fromARGB(
                                        129,
                                        158,
                                        158,
                                        158,
                                      ),
                                  elevation: 3.0,
                                ),
                              ],
                              child: Container(
                                color:
                                    theme
                                        .lightModeColor
                                        .errorColor200,
                                child: Center(
                                  child: Icon(
                                    color: Colors.white,
                                    size: 50,
                                    Icons.clear_rounded,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    Visibility(
                      visible: !(isVerified ?? false),
                      child: SizedBox(height: 20),
                    ),
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.h3.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      (isVerified ?? true)
                          ? 'Payment Successful'
                          : 'Payment Failed',
                    ),
                    SizedBox(height: 20),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 450,
                      ),
                      child: MainButtonP(
                        themeProvider: theme,
                        action: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return BasePage();
                              },
                            ),
                          );
                        },
                        text: 'Return Home',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Visibility(
            visible: isLoading,
            child: returnCompProvider(
              context,
            ).showLoader(message: 'Loading'),
          ),
        ],
      ),
    );
  }
}
