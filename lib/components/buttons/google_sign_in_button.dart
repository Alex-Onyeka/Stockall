import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/constants/google_auth_config.dart';
import 'package:stockall/pages/authentication/complete_details/complete_details_page.dart';
import 'package:stockall/pages/authentication/translations/general.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/auth_service.dart';
import 'package:stockall/services/google_auth/auth_routing.dart';
import 'package:stockall/services/google_auth/google_auth_service.dart';

/// "or" divider + "Continue with Google". Renders nothing on platforms where
/// Google sign-in is not offered (iOS, macOS, Linux).
class GoogleSignInButton extends StatefulWidget {
  final ThemeProvider theme;
  const GoogleSignInButton({super.key, required this.theme});

  @override
  State<GoogleSignInButton> createState() =>
      _GoogleSignInButtonState();
}

class _GoogleSignInButtonState
    extends State<GoogleSignInButton> {
  bool isLoading = false;
  bool waitingDialogOpen = false;

  void showInfo(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return InfoAlert(
          theme: widget.theme,
          message: message,
          title: title,
        );
      },
    );
  }

  // Windows: the user finishes in the browser, so give them a way to stop.
  void showWaitingDialog() {
    waitingDialogOpen = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Continue in your browser',
            style: TextStyle(
              fontSize: widget.theme.mobileTexts.h4.fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Choose your Google account in the browser window that just opened. You will come back here automatically.',
            style: widget.theme.mobileTexts.b1.textStyleNormal,
          ),
          actions: [
            TextButton(
              onPressed: () {
                waitingDialogOpen = false;
                Navigator.of(dialogContext).pop();
                GoogleAuthService().cancelPending();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    ).then((_) {
      waitingDialogOpen = false;
    });
  }

  void closeWaitingDialog() {
    if (waitingDialogOpen && mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  Future<void> continueWithGoogle() async {
    if (isLoading) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      isLoading = true;
    });
    if (isGoogleSignInWindows) showWaitingDialog();

    final outcome = await GoogleAuthService().signIn();
    closeWaitingDialog();
    if (!mounted) return;

    switch (outcome.status) {
      case GoogleAuthStatus.redirecting:
        // Web: the page is leaving; BasePage continues after the redirect.
        return;
      case GoogleAuthStatus.cancelled:
        setState(() {
          isLoading = false;
        });
        return;
      case GoogleAuthStatus.noNetwork:
        setState(() {
          isLoading = false;
        });
        showInfo(
          General().authenticationError,
          General().noInternetConnection,
        );
        return;
      case GoogleAuthStatus.error:
        setState(() {
          isLoading = false;
        });
        showInfo(
          General().authenticationError,
          outcome.message ??
              'Google sign-in failed. Please try again.',
        );
        return;
      case GoogleAuthStatus.success:
        break;
    }

    try {
      final destination =
          await AuthService().resolveSignedInUser();
      if (!mounted) return;
      switch (destination) {
        case AuthDestination.home:
          // Same as a normal login.
          Navigator.pushReplacementNamed(context, '/');
        case AuthDestination.completeDetails:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CompleteDetailsPage(),
            ),
          );
        case AuthDestination.authScreens:
          setState(() {
            isLoading = false;
          });
          showInfo(
            General().authenticationError,
            'Google sign-in failed. Please try again.',
          );
      }
    } on EmailInUseException catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      showInfo(
        'Email Already Registered',
        'The email ${e.email} is already used by another Stockall account. Please log in with your email and password.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isGoogleSignInSupported) return SizedBox.shrink();
    final theme = widget.theme;
    return Column(
      children: [
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: Divider(color: Colors.grey.shade300),
            ),
            Text(
              'or',
              style: TextStyle(
                color: Colors.grey,
                fontSize: theme.mobileTexts.b3.fontSize,
              ),
            ),
            Expanded(
              child: Divider(color: Colors.grey.shade300),
            ),
          ],
        ),
        SizedBox(height: 10),
        Material(
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: Colors.grey.shade400,
                width: 1,
              ),
            ),
            child: InkWell(
              mouseCursor: SystemMouseCursors.click,
              borderRadius: BorderRadius.circular(5),
              onTap: isLoading ? null : continueWithGoogle,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  spacing: 10,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    isLoading
                        ? SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color:
                                theme
                                    .lightModeColor
                                    .prColor300,
                          ),
                        )
                        : SvgPicture.asset(
                          'assets/svgs/google_logo.svg',
                          height: 18,
                          width: 18,
                        ),
                    Text(
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize:
                            theme.mobileTexts.b4.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      'Continue with Google',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
