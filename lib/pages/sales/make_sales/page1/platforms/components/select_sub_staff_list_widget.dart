import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_sub_staff/temp_sub_staff.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/sub_staffs/sub_staffs_page.dart';

class SelectSubStaffListWidget extends StatefulWidget {
  final TempSubStaff? staff;
  const SelectSubStaffListWidget({super.key, this.staff});

  @override
  State<SelectSubStaffListWidget> createState() =>
      _SelectSubStaffListWidgetState();
}

class _SelectSubStaffListWidgetState
    extends State<SelectSubStaffListWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.staff != null) {
        returnSalesProvider().selectSubStaff(
          staff: widget.staff,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return SizedBox(
      height: 300,
      width: 400,
      child: Builder(
        builder: (context) {
          if (returnSubStaffProvider().subStaffs.isEmpty) {
            return Center(
              child: EmptyWidgetDisplayOnly(
                title: 'No Sub Staff',
                subText:
                    'Sub Staffs cannot be found. Please proceed to create a new Sub staff',
                theme: theme,
                height: 25,
                altAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return SubStaffsPage();
                      },
                    ),
                  );
                },
                altActionText: 'Create Sub Staff',
                altIcon: Icons.add,
                icon: Icons.clear,
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () {
              return returnSubStaffProvider()
                  .getSubStaffs();
            },
            backgroundColor: Colors.white,
            color: theme.lightModeColor.secColor200,
            displacement: 10,
            child: ListView(
              // shrinkWrap: true,
              children:
                  returnSubStaffProvider().subStaffs
                      .where((st) {
                        var beans =
                            returnSalesProviderContext(
                              context,
                            ).mainCartQueue.where(
                              (c) =>
                                  c.subStaff?.uuid ==
                                  st.uuid,
                            );
                        if (beans.isEmpty) {
                          return true;
                        } else {
                          return false;
                        }
                      })
                      .map(
                        (staff) => Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 2,
                          ),
                          child: InkWell(
                            onTap: () {
                              returnSalesProvider()
                                  .selectSubStaff(
                                    staff: staff,
                                  );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 15,
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color:
                                        Colors
                                            .grey
                                            .shade200,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                children: [
                                  Row(
                                    spacing: 10,
                                    children: [
                                      Icon(
                                        size: 18,
                                        color: Colors.grey,
                                        Icons.person,
                                      ),
                                      Text(
                                        style: TextStyle(
                                          fontSize:
                                              theme
                                                  .mobileTexts
                                                  .b3
                                                  .fontSize,
                                          fontWeight:
                                              returnSalesProviderContext(
                                                        context,
                                                      ).selectedSubStaff?.uuid ==
                                                      staff
                                                          .uuid
                                                  ? FontWeight
                                                      .bold
                                                  : null,
                                        ),
                                        staff.staffName ??
                                            "Name",
                                      ),
                                    ],
                                  ),
                                  Visibility(
                                    visible:
                                        returnSalesProviderContext(
                                              context,
                                            )
                                            .selectedSubStaff
                                            ?.uuid ==
                                        staff.uuid,
                                    child: Icon(
                                      size: 20,
                                      color:
                                          theme
                                              .lightModeColor
                                              .secColor200,
                                      Icons.check,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          );
        },
      ),
    );
  }
}
