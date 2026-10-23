import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stockall/components/calculator_engine.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/subscription/calculator_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';

class MyCalculatorDesktop extends StatefulWidget {
  final bool? showHeader;
  const MyCalculatorDesktop({super.key, this.showHeader});

  @override
  State<MyCalculatorDesktop> createState() =>
      _MyCalculatorDesktopState();
}

class _MyCalculatorDesktopState
    extends State<MyCalculatorDesktop> {
  final CalculatorEngine _engine = CalculatorEngine();

  void action(String number) {
    setState(() {
      if (number == '.') {
        _engine.inputDot();
      } else {
        _engine.inputDigit(number);
      }
    });
  }

  void deleteAction() {
    setState(() {
      _engine.deleteAction();
    });
  }

  void setSign(String number) {
    setState(() {
      _engine.inputOperator(number);
    });
  }

  void inputLeftBracket() {
    setState(() {
      _engine.inputLeftBracket();
    });
  }

  void inputRightBracket() {
    setState(() {
      _engine.inputRightBracket();
    });
  }

  void inputSquare() {
    setState(() {
      _engine.inputSquare();
    });
  }

  void inputSquareRoot() {
    setState(() {
      _engine.inputSquareRoot();
    });
  }

  void clear() {
    setState(() {
      _engine.clear();
    });
  }

  void getResult() {
    setState(() {
      _engine.calculate();
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context, listen: false);
    return Material(
      child: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          children: [
            Visibility(
              visible:
                  widget.showHeader == null ||
                  widget.showHeader == true,
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5.0,
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Opacity(
                          opacity: 0,
                          child: IconButton(
                            mouseCursor:
                                SystemMouseCursors.click,
                            onPressed: () {},
                            icon: Icon(Icons.clear),
                          ),
                        ),
                        Text(
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b1
                                    .fontSize,
                          ),
                          'My Calculator',
                        ),
                        Opacity(
                          opacity: 0,
                          child: IconButton(
                            mouseCursor:
                                SystemMouseCursors.click,
                            onPressed: () {},
                            icon: Icon(Icons.clear),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                  bottom: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            reverse: true,
                            scrollDirection:
                                Axis.horizontal,
                            child: Text(
                              _engine.displayExpression.isEmpty
                                  ? '0'
                                  : _engine.displayExpression,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            reverse: true,
                            scrollDirection:
                                Axis.horizontal,
                            child: Text(
                              _engine.resultText,
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: _engine.errorMessage != null
                                    ? theme.lightModeColor.errorColor200
                                    : Colors.black,
                              ),
                            ),
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
              child: SubWrapper(
                x: 0.9,
                y: -0.9,
                isVisible:
                    !CalculatorAuthAction()
                        .useCalculatorAction(
                          context: context,
                        ),
                mainWidget: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    child: Column(
                      spacing: 10,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          spacing: 10,
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
                                inputSquare();
                              },
                              text: 'x²',
                              itemColor:
                                  theme
                                      .lightModeColor
                                      .secColor200,
                            ),
                          ],
                        ),
                        Row(
                          spacing: 10,
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            CalcButton(
                              theme: theme,
                              action: () {
                                inputLeftBracket();
                              },
                              text: '(',
                              itemColor:
                                  theme
                                      .lightModeColor
                                      .secColor200,
                            ),
                            CalcButton(
                              theme: theme,
                              action: () {
                                inputRightBracket();
                              },
                              text: ')',
                              itemColor:
                                  theme
                                      .lightModeColor
                                      .secColor200,
                            ),
                            CalcButton(
                              theme: theme,
                              action: () {
                                setSign('/');
                              },
                              svg: divideIconSvg,
                              height: 18,
                              itemColor:
                                  theme
                                      .lightModeColor
                                      .secColor200,
                            ),
                            CalcButton(
                              theme: theme,
                              action: () {
                                inputSquareRoot();
                              },
                              text: '√',
                              itemColor:
                                  theme
                                      .lightModeColor
                                      .secColor200,
                            ),
                          ],
                        ),
                        Row(
                          spacing: 10,
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
                          spacing: 10,
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
                                setSign('-');
                              },
                              icon: Icons.remove,
                              height: 22,
                              itemColor:
                                  theme
                                      .lightModeColor
                                      .secColor200,
                            ),
                          ],
                        ),
                        Row(
                          spacing: 10,
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
                                setSign('+');
                              },
                              icon: Icons.add,
                              height: 22,
                              itemColor:
                                  theme
                                      .lightModeColor
                                      .secColor200,
                            ),
                          ],
                        ),
                        Row(
                          spacing: 10,
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
            ),
          ],
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
  final double? buttonHeight;

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
    this.buttonHeight,
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
            mouseCursor: SystemMouseCursors.click,
            onTap: () {
              CalculatorAuthAction().useCalculatorAction(
                context: context,
                action: () {
                  action();
                },
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: EdgeInsets.all(10),
              height: buttonHeight ?? 50,
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Visibility(
                      visible: icon == null && svg == null,
                      child: Text(
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.h4.fontSize,
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
