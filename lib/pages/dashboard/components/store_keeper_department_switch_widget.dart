import 'package:flutter/material.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/dashboard/components/total_sales_banner.dart';

class StoreKeeperDepartmentSwitchWidget
    extends StatefulWidget {
  const StoreKeeperDepartmentSwitchWidget({super.key});

  @override
  State<StoreKeeperDepartmentSwitchWidget> createState() =>
      _StoreKeeperDepartmentSwitchWidgetState();
}

class _StoreKeeperDepartmentSwitchWidgetState
    extends State<StoreKeeperDepartmentSwitchWidget> {
  String setName() {
    if (returnDepartmentProvider().currentDepartment() !=
        null) {
      return cutLongText(
        returnDepartmentProvider()
            .currentDepartment()!
            .name,
        22,
      );
    } else {
      return 'Department Not Set';
    }
  }

  String setNameUser() {
    if (returnUserProvider(context).currentUserMain !=
        null) {
      return '${cutLongText(returnUserProvider(context).currentUserMain!.name.toUpperCase(), 15)} (${returnUserProvider(context).currentUserMain!.role})';
    } else {
      return 'Not Set';
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Visibility(
      visible: isStoreKeeper(),
      child: Container(
        margin: EdgeInsets.only(bottom: 15),
        padding: EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 15,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(20, 0, 0, 0),
              blurRadius: 10,
            ),
          ],
          color: Colors.white,
        ),
        child: Builder(
          builder: (context) {
            if (returnShopProvider(
                  context: context,
                ).userShop()?.manageDepartments ==
                true) {
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  mouseCursor: SystemMouseCursors.click,
                  borderRadius: BorderRadius.circular(5),
                  onTap: () {
                    setDepartment(context: context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.center,
                      children: [
                        Icon(
                          size: 14,
                          color:
                              theme
                                  .lightModeColor
                                  .prColor300,
                          Icons.width_normal_outlined,
                        ),
                        SizedBox(width: 5),
                        Text(
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                theme
                                    .lightModeColor
                                    .prColor300,
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b4
                                    .fontSize,
                          ),

                          setName(),
                        ),
                        Icon(
                          color:
                              theme
                                  .lightModeColor
                                  .prColor300,
                          Icons.keyboard_arrow_down_rounded,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return Row(
                spacing: 5,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              theme
                                  .lightModeColor
                                  .prColor300,
                          fontSize:
                              theme.mobileTexts.b4.fontSize,
                        ),
                        setNameUser(),
                      ),
                    ],
                  ),
                  Icon(
                    size: 14,
                    color: theme.lightModeColor.prColor300,
                    Icons.person,
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
