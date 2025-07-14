import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';

class MyCalculator extends StatefulWidget {
  const MyCalculator({super.key});

  @override
  State<MyCalculator> createState() => _MyCalculatorState();
}

class _MyCalculatorState extends State<MyCalculator> {
  List<String> leftNumbers = [];
  List<String> rightNumbers = [];
  String? sign;
  double mainResult = 0;

  void action(String number) {
    if (mainResult == 0) {
      if (sign == null) {
        if (number == '.') {
          if (leftNumbers.isNotEmpty) {
            if (!leftNumbers.contains('.')) {
              setState(() {
                leftNumbers.add(number);
              });
            }
          }
        } else if (number == '0') {
          if (leftNumbers.isEmpty) {
            setState(() {
              leftNumbers.add(number);
            });
          } else {
            if (leftNumbers.length > 1 &&
                leftNumbers.first == '0' &&
                leftNumbers[1] != '0') {
              setState(() {
                leftNumbers.add(number);
              });
            }
          }
        } else {
          setState(() {
            leftNumbers.add(number);
          });
        }
      } else {
        if (number == '.') {
          if (rightNumbers.isNotEmpty) {
            if (!rightNumbers.contains('.')) {
              setState(() {
                rightNumbers.add(number);
              });
            }
          }
        } else if (number == '0') {
          if (rightNumbers.isEmpty) {
            setState(() {
              rightNumbers.add(number);
            });
          } else {
            if (rightNumbers.length > 1 &&
                rightNumbers.first == '0' &&
                rightNumbers[1] != '0') {
              setState(() {
                rightNumbers.add(number);
              });
            }
          }
        } else {
          setState(() {
            rightNumbers.add(number);
          });
        }
      }
    } else {
      setState(() {
        mainResult = 0;
        rightNumbers.clear();
        sign = null;
        leftNumbers = [number];
      });
    }
  }

  void deleteAction() {
    setState(() {
      if (rightNumbers.isNotEmpty) {
        rightNumbers.removeLast();
      } else if (rightNumbers.isEmpty && sign != null) {
        sign = null;
      } else {
        leftNumbers.removeLast();
      }
    });
  }

  void setSign(String number) {
    if (mainResult == 0) {
      if (leftNumbers.isNotEmpty && rightNumbers.isEmpty) {
        setState(() {
          sign = number;
        });
      }
    } else {
      var beans = mainResult.toString().split('.');
      var first = beans[0].split('');
      var second = beans[1].split('').first;

      first.add('.');
      first.add(second);
      var third = first;
      setState(() {
        mainResult = 0;
        rightNumbers.clear();
        sign = number;
        leftNumbers = third;
      });
    }
  }

  void clear() {
    setState(() {
      leftNumbers.clear();
      rightNumbers.clear();
      sign = null;
      mainResult = 0;
    });
  }

  void getResult() {
    double leftValue =
        double.tryParse(leftNumbers.join()) ?? 0;
    double rightValue =
        double.tryParse(rightNumbers.join()) ?? 0;
    setState(() {
      if (sign != null &&
          leftNumbers.isNotEmpty &&
          rightNumbers.isNotEmpty) {
        if (sign == 'X') {
          mainResult = leftValue * rightValue;
        } else if (sign == '+') {
          mainResult = leftValue + rightValue;
        } else if (sign == '-') {
          mainResult = leftValue - rightValue;
        } else if (sign == '/') {
          mainResult = leftValue / rightValue;
        }
      } else if (sign == null &&
          leftNumbers.isEmpty &&
          rightNumbers.isEmpty) {
        mainResult = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context, listen: false);
    return SafeArea(
      child: Material(
        child: Container(
          decoration: BoxDecoration(color: Colors.white),
          child: Column(
            children: [
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Opacity(
                      opacity: 0,
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.clear),
                      ),
                    ),
                    Text(
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize:
                            theme.mobileTexts.b1.fontSize,
                      ),
                      'My Calculator',
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.clear),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.end,
                    children: [
                      Row(
                        spacing: 12,
                        mainAxisAlignment:
                            MainAxisAlignment.end,
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            children:
                                leftNumbers.map((item) {
                                  return Row(
                                    children: [
                                      SubResult(
                                        number: item,
                                        theme: theme,
                                      ),
                                    ],
                                  );
                                }).toList(),
                          ),
                          Text(
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                            sign ?? '',
                          ),
                          Row(
                            children:
                                rightNumbers.map((item) {
                                  return Row(
                                    children: [
                                      SubResult(
                                        number: item,
                                        theme: theme,
                                      ),
                                    ],
                                  );
                                }).toList(),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.end,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                            formatLargeNumberDoubleWidgetDecimal(
                              mainResult,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 30,
                    ),
                    child: Column(
                      spacing: 15,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          spacing: 15,
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            CalcButton(
                              flex: 2,
                              theme: theme,
                              action: () {
                                clear();
                              },
                              text: 'AC',
                            ),
                            CalcButton(
                              theme: theme,
                              action: () {
                                deleteAction();
                              },
                              icon:
                                  Icons.backspace_outlined,
                              itemColor:
                                  theme
                                      .lightModeColor
                                      .errorColor200,
                            ),
                            CalcButton(
                              theme: theme,
                              action: () {
                                setSign('+');
                              },
                              icon: Icons.add,
                              height: 30,
                              itemColor:
                                  theme
                                      .lightModeColor
                                      .secColor200,
                            ),
                          ],
                        ),
                        Row(
                          spacing: 15,
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            CalcButton(
                              theme: theme,
                              action: () {
                                action('7');
                              },
                              text: '7',
                            ),
                            CalcButton(
                              theme: theme,
                              action: () {
                                action('8');
                              },
                              text: '8',
                            ),
                            CalcButton(
                              theme: theme,
                              action: () {
                                action('9');
                              },
                              text: '9',
                            ),
                            CalcButton(
                              theme: theme,
                              action: () {
                                setSign('/');
                              },
                              icon: Icons.share,
                              itemColor:
                                  theme
                                      .lightModeColor
                                      .secColor200,
                            ),
                          ],
                        ),
                        Row(
                          spacing: 15,
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            CalcButton(
                              theme: theme,
                              action: () {
                                action('4');
                              },
                              text: '4',
                            ),
                            CalcButton(
                              theme: theme,
                              action: () {
                                action('5');
                              },
                              text: '5',
                            ),
                            CalcButton(
                              theme: theme,
                              action: () {
                                action('6');
                              },
                              text: '6',
                            ),
                            CalcButton(
                              theme: theme,
                              action: () {
                                setSign('X');
                              },
                              text: 'X',
                              itemColor:
                                  theme
                                      .lightModeColor
                                      .secColor200,
                            ),
                          ],
                        ),
                        Row(
                          spacing: 15,
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            CalcButton(
                              theme: theme,
                              action: () {
                                action('1');
                              },
                              text: '1',
                            ),
                            CalcButton(
                              theme: theme,
                              action: () {
                                action('2');
                              },
                              text: '2',
                            ),
                            CalcButton(
                              theme: theme,
                              action: () {
                                action('3');
                              },
                              text: '3',
                            ),
                            CalcButton(
                              theme: theme,
                              action: () {
                                setSign('-');
                              },
                              icon: Icons.remove,
                              height: 30,
                              itemColor:
                                  theme
                                      .lightModeColor
                                      .secColor200,
                            ),
                          ],
                        ),
                        Row(
                          spacing: 15,
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            CalcButton(
                              theme: theme,
                              action: () {
                                action('0');
                              },
                              text: '0',
                            ),
                            CalcButton(
                              theme: theme,
                              action: () {
                                action('.');
                              },
                              text: '.',
                            ),
                            CalcButton(
                              flex: 2,
                              theme: theme,
                              action: () {
                                getResult();
                              },
                              text: '=',
                              color:
                                  theme
                                      .lightModeColor
                                      .prColor300,
                              itemColor: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CalcButton extends StatelessWidget {
  final ThemeProvider theme;
  final String? text;
  final Color? color;
  final Function() action;
  final IconData? icon;
  final String? svg;
  final double? height;
  final Color? itemColor;
  final int? flex;

  const CalcButton({
    super.key,
    required this.theme,
    this.text,
    this.color,
    required this.action,
    this.icon,
    this.svg,
    this.height,
    this.itemColor,
    this.flex,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex ?? 1,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: color ?? Colors.white,
          ),
          child: InkWell(
            onTap: action,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: EdgeInsets.all(15),
              height: 60,
              child: Center(
                child: Stack(
                  children: [
                    Visibility(
                      visible: icon == null && svg == null,
                      child: Text(
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.h3.fontSize,
                          fontWeight: FontWeight.w600,
                          color: itemColor,
                        ),
                        text ?? '',
                      ),
                    ),
                    Visibility(
                      visible: icon != null,
                      child: Icon(
                        size: height,
                        color: itemColor,
                        icon,
                      ),
                    ),
                    Visibility(
                      visible: svg != null,
                      child: SvgPicture.asset(
                        height: height,
                        color: itemColor,
                        svg ?? '',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SubResult extends StatelessWidget {
  const SubResult({
    super.key,
    required this.theme,
    required this.number,
    this.color,
    this.size,
  });

  final ThemeProvider theme;
  final String number;
  final Color? color;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Text(
      style: TextStyle(
        height: 0,
        fontWeight: FontWeight.bold,
        fontSize: size ?? theme.mobileTexts.h3.fontSize,
        color: color ?? Colors.grey.shade700,
      ),
      number,
    );
  }
}
