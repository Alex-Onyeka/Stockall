import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/major/desktop_page_container.dart';
import 'package:stockall/components/major/my_drawer_widget.dart';
import 'package:stockall/components/major/right_side_bar.dart';
import 'package:stockall/components/my_calculator_desktop.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/auth_screens/auth_screens_page.dart';
import 'package:stockall/services/auth_service.dart';

class CalculatorPage extends StatelessWidget {
  const CalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Row(
      spacing: 15,
      children: [
        MyDrawerWidget(
          action: () {
            showDialog(
              context: context,
              builder: (context) {
                return ConfirmationAlert(
                  theme: theme,
                  message: 'You are about to Logout',
                  title: 'Are you Sure?',
                  action: () async {
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return AuthScreensPage();
                          },
                        ),
                      );
                      returnNavProvider(
                        context,
                        listen: false,
                      ).navigate(0);
                    }
                    if (context.mounted) {
                      await AuthService().signOut(context);
                    }
                  },
                );
              },
            );
          },
          theme: theme,
          notifications:
              returnNotificationProvider(
                    context,
                  ).notifications.isEmpty
                  ? []
                  : returnNotificationProvider(
                    context,
                  ).notifications,
        ),
        Expanded(
          child: DesktopPageContainer(
            widget: MyCalculatorDesktop(),
          ),
        ),
        RightSideBar(theme: theme),
      ],
    );
  }
}
