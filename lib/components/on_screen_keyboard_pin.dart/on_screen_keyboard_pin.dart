import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/dashboard/employee_auth_page/emp_auth.dart';

class OnScreenKeyboardPin extends StatefulWidget {
  final Function(String value) action;
  const OnScreenKeyboardPin({
    super.key,
    required this.action,
  });

  @override
  State<OnScreenKeyboardPin> createState() =>
      _OnScreenKeyboardPinState();
}

class _OnScreenKeyboardPinState
    extends State<OnScreenKeyboardPin> {
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Container(
      width:
          screenWidth(context) < mobileScreenSmall
              ? screenWidth(context) * 0.95
              : mobileScreen - 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(31, 0, 0, 0),
            blurRadius: 5,
          ),
        ],
      ),
      padding: EdgeInsetsDirectional.symmetric(
        horizontal:
            screenWidth(context) < mobileScreenSmall
                ? 10
                : 20,
        vertical: 20,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 0,
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                  ),
                  child: Column(
                    spacing: 10,
                    children: [
                      Row(
                        spacing: 10,
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          CalcButtonPin(
                            theme: theme,
                            action: () {
                              widget.action('1');
                            },
                            text: '1',
                          ),
                          CalcButtonPin(
                            theme: theme,
                            action: () {
                              widget.action('2');
                            },
                            text: '2',
                          ),
                          CalcButtonPin(
                            theme: theme,
                            action: () {
                              widget.action('3');
                            },
                            text: '3',
                          ),
                        ],
                      ),
                      Row(
                        spacing: 10,
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          CalcButtonPin(
                            theme: theme,
                            action: () {
                              widget.action('4');
                            },
                            text: '4',
                          ),
                          CalcButtonPin(
                            theme: theme,
                            action: () {
                              widget.action('5');
                            },
                            text: '5',
                          ),
                          CalcButtonPin(
                            theme: theme,
                            action: () {
                              widget.action('6');
                            },
                            text: '6',
                          ),
                        ],
                      ),
                      Row(
                        spacing: 10,
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          CalcButtonPin(
                            theme: theme,
                            action: () {
                              widget.action('7');
                            },
                            text: '7',
                          ),
                          CalcButtonPin(
                            theme: theme,
                            action: () {
                              widget.action('8');
                              // widget.controller.text = '2';
                            },
                            text: '8',
                          ),
                          CalcButtonPin(
                            theme: theme,
                            action: () {
                              widget.action('9');
                            },
                            text: '9',
                          ),
                        ],
                      ),
                      Row(
                        spacing: 10,
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          CalcButtonPin(
                            theme: theme,
                            action: () {
                              widget.action('0');
                            },
                            text: '0',
                          ),
                          CalcButtonPin(
                            theme: theme,
                            action: () {
                              widget.action('00');
                            },
                            // text:
                            //     '<=',
                            icon: Icons.backspace_outlined,
                            height: 20,
                          ),
                          CalcButtonPin(
                            theme: theme,
                            action: () {
                              widget.action('.');
                            },
                            // text: '.',
                            icon: Icons.square,
                            itemColor: Colors.black,
                            height: 11,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15),
              ],
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
