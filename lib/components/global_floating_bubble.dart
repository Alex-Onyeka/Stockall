import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/my_calculator.dart';
import 'package:stockall/components/my_calculator_desktop.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/dashboard/components/total_sales_banner.dart';
import 'package:stockall/services/auth_service.dart';
import 'package:stockall/services/navigation_service.dart';

class GlobalFloatingBubble extends StatefulWidget {
  final Widget child;
  final Widget bubble;
  final double bubbleSize;
  final BuildContext newContext;

  const GlobalFloatingBubble({
    super.key,
    required this.child,
    required this.bubble,
    this.bubbleSize = 55,
    required this.newContext,
  });

  @override
  State<GlobalFloatingBubble> createState() =>
      _GlobalFloatingBubbleState();
}

class _GlobalFloatingBubbleState
    extends State<GlobalFloatingBubble>
    with SingleTickerProviderStateMixin {
  late double top;
  late double left;

  bool initialized = false;
  bool expanded = false;

  late AnimationController controller;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    scaleAnimation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void initializePosition(Size size) {
    top = size.height * 0.75;
    left = size.width - widget.bubbleSize - 80;
    initialized = true;
  }

  void toggleExpanded() {
    setState(() {
      expanded = !expanded;

      if (expanded) {
        controller.forward();
      } else {
        controller.reverse();
      }
    });
  }

  void snapToEdge(Size size) {
    final middle = size.width / 2;

    setState(() {
      if (left < middle) {
        left = 18;
      } else {
        left = size.width - widget.bubbleSize - 80;
      }
    });
  }

  String setName() {
    if (returnDepartmentProvider().currentDepartment() !=
        null) {
      return cutLongText(
        returnDepartmentProvider()
            .currentDepartment()!
            .name,
        10,
      );
    } else {
      return 'Set Dept.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (!initialized) {
      initializePosition(size);
    }

    return Scaffold(
      body: Stack(
        children: [
          widget.child,

          /// DARK BACKDROP
          if (expanded)
            GestureDetector(
              onTap: toggleExpanded,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: expanded ? 1 : 0,
                child: Container(
                  color: const Color.fromARGB(20, 0, 0, 0),
                ),
              ),
            ),

          /// FLOATING BUBBLE
          AnimatedPositioned(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            top: top,
            left: left,
            child: Visibility(
              visible:
                  returnUtilityWidgetProvider(
                    context: widget.newContext,
                  ).getVisibility(),
              // FloatingButtonVisibilityBox()
              //     .getDataVisibility(),
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    left += details.delta.dx;
                    top += details.delta.dy;

                    left = left.clamp(
                      0.0,
                      size.width - widget.bubbleSize,
                    );

                    top = top.clamp(
                      0.0,
                      size.height - widget.bubbleSize,
                    );
                  });
                },

                onPanEnd: (_) {
                  snapToEdge(size);
                },

                onTap: toggleExpanded,

                child: Column(
                  crossAxisAlignment:
                      left < size.width / 2
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.end,
                  children: [
                    /// EXPANDED MENU
                    SizeTransition(
                      sizeFactor: scaleAnimation,
                      axis: Axis.vertical,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: 12,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              left < size.width / 2
                                  ? CrossAxisAlignment.start
                                  : CrossAxisAlignment.end,
                          children: [
                            floatingMenuButton(
                              icon:
                                  Icons.hide_source_rounded,
                              label:
                                  returnUtilityWidgetProvider()
                                          .getVisibility()
                                      ? "Hide"
                                      : 'Show',
                              onTap: () {
                                toggleExpanded();
                                var context =
                                    navigatorKey
                                        .currentContext ??
                                    widget.newContext;
                                showDialog(
                                  context: context,
                                  builder: (
                                    confirmContext,
                                  ) {
                                    return ConfirmationAlert(
                                      theme: returnTheme(
                                        context,
                                      ),
                                      message:
                                          'You are about to ${returnUtilityWidgetProvider().getVisibility() ? "Hide" : 'Show'} this Utility Button. Are you sure you want to continue?',
                                      title:
                                          '${returnUtilityWidgetProvider().getVisibility() ? "Hide" : 'Show'} Utility Button',
                                      action: () async {
                                        await returnUtilityWidgetProvider()
                                            .toggleVisibility();
                                        if (confirmContext
                                            .mounted) {
                                          Navigator.of(
                                            confirmContext,
                                          ).pop();
                                        }
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                            Visibility(
                              visible:
                                  returnShopProvider()
                                          .userShop()
                                          ?.manageDepartments ==
                                      true &&
                                  AuthService()
                                          .currentUserAuth !=
                                      null,
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  floatingMenuButton(
                                    icon: Icons.keyboard,
                                    label: setName(),
                                    onTap: () {
                                      toggleExpanded();
                                      var context =
                                          navigatorKey
                                              .currentContext ??
                                          widget.newContext;
                                      setDepartment(
                                        context: context,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                const SizedBox(height: 10),

                                floatingMenuButton(
                                  icon: Icons.point_of_sale,
                                  label: 'Calculator',
                                  onTap: () {
                                    toggleExpanded();
                                    showCalculator(
                                      widget.newContext,
                                    );
                                  },
                                ),
                              ],
                            ),
                            Visibility(
                              visible:
                                  !kIsWeb &&
                                  screenWidth(context) >
                                      mobileScreen,
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  floatingMenuButton(
                                    icon: Icons.keyboard,
                                    label: 'Keyboard',
                                    onTap: () async {
                                      try {
                                        if (Platform
                                            .isWindows) {
                                          await Process.start(
                                            'cmd',
                                            [
                                              '/c',
                                              'start',
                                              '',
                                              'osk',
                                            ],
                                            mode:
                                                ProcessStartMode
                                                    .detached,
                                          );
                                          toggleExpanded();
                                        }
                                      } catch (e) {
                                        await mainLocalLog(
                                          'Error Opening Keyboard: ${e.toString()}',
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    /// MAIN BUBBLE
                    AnimatedContainer(
                      duration: const Duration(
                        milliseconds: 180,
                      ),
                      width: widget.bubbleSize,
                      height: widget.bubbleSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            returnTheme(
                              context,
                            ).lightModeColor.prColor300,
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(
                              24,
                              0,
                              0,
                              0,
                            ),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          mouseCursor:
                              SystemMouseCursors.click,
                          borderRadius:
                              BorderRadius.circular(999),
                          onTap: toggleExpanded,
                          child: AnimatedRotation(
                            turns: expanded ? 0.125 : 0,
                            duration: const Duration(
                              milliseconds: 220,
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget floatingMenuButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        borderRadius: BorderRadius.circular(5),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(15, 0, 0, 0),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Colors.black87),

              const SizedBox(width: 8),

              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize:
                      returnTheme(
                        context,
                      ).mobileTexts.b3.fontSize,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showCalculator(BuildContext newContext) {
  var context = navigatorKey.currentContext ?? newContext;
  showDialog(
    context: context,
    builder: (calcContext) {
      if (screenWidth(context) < mobileScreen) {
        return MyCalculator();
      } else {
        return AlertDialog(
          backgroundColor: Colors.white,
          constraints: BoxConstraints(maxWidth: 600),
          contentPadding: EdgeInsets.all(20),
          insetPadding: EdgeInsets.all(40),
          content: Stack(
            alignment: AlignmentGeometry.xy(1, -1),
            children: [
              Container(
                width: 800,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: MyCalculatorDesktop(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  0,
                  10,
                  10,
                  0,
                ),
                child: IconButton(
                  mouseCursor: SystemMouseCursors.click,
                  onPressed: () {
                    Navigator.of(calcContext).pop();
                  },
                  icon: Icon(size: 22, Icons.clear),
                ),
              ),
            ],
          ),
        );
      }
    },
  );
}
