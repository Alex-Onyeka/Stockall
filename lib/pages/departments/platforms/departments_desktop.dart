import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/buttons/floating_action_butto.dart';
import 'package:stockall/components/major/desktop_page_container.dart';
import 'package:stockall/components/major/drawer_widget/platforms/my_drawer_widget_desktop.dart';
import 'package:stockall/components/major/drawer_widget/my_drawer_widget.dart';
import 'package:stockall/components/major/right_side_bar.dart';
import 'package:stockall/constants/subscription/expenses_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/services/auth_service.dart';

class DepartmentsDesktop extends StatefulWidget {
  const DepartmentsDesktop({super.key});

  @override
  State<DepartmentsDesktop> createState() =>
      _DepartmentsDesktopState();
}

class _DepartmentsDesktopState
    extends State<DepartmentsDesktop> {
  late Future<List<TempExpensesClass>> expensesFuture;
  bool isLoading = false;

  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      key: _scaffoldKey,
      drawer: MyDrawerWidgetDesktopMain(
        action: () {
          var safeContext = context;
          showDialog(
            context: context,
            builder: (context) {
              return ConfirmationAlert(
                theme: theme,
                message: 'You are about to Logout',
                title: 'Are you Sure?',
                action: () async {
                  Navigator.of(context).pop();
                  setState(() {
                    isLoading = true;
                  });
                  if (safeContext.mounted) {
                    await AuthService().signOut(
                      safeContext,
                    );
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
        globalKey: _scaffoldKey,
      ),
      body: Stack(
        children: [
          Row(
            spacing: 15,
            children: [
              MyDrawerWidget(
                globalKey: _scaffoldKey,
                action: () {
                  var safeContext = context;
                  showDialog(
                    context: context,
                    builder: (context) {
                      return ConfirmationAlert(
                        theme: theme,
                        message: 'You are about to Logout',
                        title: 'Are you Sure?',
                        action: () async {
                          Navigator.of(context).pop();
                          setState(() {
                            isLoading = true;
                          });
                          if (safeContext.mounted) {
                            await AuthService().signOut(
                              safeContext,
                            );
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
                  widget: Scaffold(
                    floatingActionButton: Builder(
                      builder: (context) {
                        return Visibility(
                          visible: true,
                          child: FloatingActionButtonMain(
                            action: () {
                              ExpensesAuthAction()
                                  .numberOfDailyExpensesAction(
                                    context: context,
                                    action: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (
                                            context,
                                          ) {
                                            return Container();
                                          },
                                        ),
                                      ).then((_) {
                                        setState(() {});
                                      });
                                    },
                                  );
                            },
                            color:
                                theme
                                    .lightModeColor
                                    .secColor100,
                            text: 'Add Department',
                            theme: theme,
                          ),
                        );
                      },
                    ),
                    body: SizedBox(
                      width:
                          MediaQuery.of(context).size.width,
                      height:
                          MediaQuery.of(
                            context,
                          ).size.height,
                      child: Stack(
                        children: [Column(children: [
                            ],
                          )],
                      ),
                    ),
                  ),
                ),
              ),
              RightSideBar(theme: theme),
            ],
          ),
          Visibility(
            visible: isLoading,
            child: returnCompProvider(
              context,
              listen: false,
            ).showLoader(message: 'Logging Out...'),
          ),
        ],
      ),
    );
  }
}
