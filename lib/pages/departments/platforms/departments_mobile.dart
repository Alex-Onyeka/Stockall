import 'package:flutter/material.dart';
import 'package:stockall/components/buttons/floating_action_butto.dart';
import 'package:stockall/constants/subscription/expenses_auth.dart';
import 'package:stockall/main.dart';

class DepartmentsMobile extends StatefulWidget {
  const DepartmentsMobile({super.key});

  @override
  State<DepartmentsMobile> createState() =>
      _DepartmentsMobileState();
}

class _DepartmentsMobileState
    extends State<DepartmentsMobile> {
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
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
                            builder: (context) {
                              return Container();
                            },
                          ),
                        ).then((_) {
                          setState(() {});
                        });
                      },
                    );
              },
              color: theme.lightModeColor.secColor100,
              text: 'Add Department',
              theme: theme,
            ),
          );
        },
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(children: [Column(children: [
              ],
            )]),
      ),
    );
  }
}
