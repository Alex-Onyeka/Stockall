import 'package:flutter/material.dart';
import 'package:stockall/main.dart';

class ProductionPageListTileWidget extends StatelessWidget {
  final String title;
  final String subText;
  final Function() action;
  final IconData icon;
  final bool isActive;

  const ProductionPageListTileWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.subText,
    required this.action,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Material(
      type: MaterialType.transparency,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 20,
        ),
        child: Ink(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color:
                    isActive
                        ? const Color.fromARGB(22, 0, 0, 0)
                        : Colors.transparent,
                blurRadius: 10,
              ),
            ],
            borderRadius: BorderRadius.circular(5),
            color:
                isActive
                    ? Colors.white
                    : Colors.grey.shade100,
          ),
          child: InkWell(
            mouseCursor: SystemMouseCursors.click,
            borderRadius: BorderRadius.circular(5),
            onTap: action,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      spacing: 10,
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                          child: Icon(
                            size: 20,
                            color:
                                theme
                                    .lightModeColor
                                    .prColor250,
                            icon,
                          ),
                        ),
                        Flexible(
                          child: Column(
                            spacing: 5,
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b2
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                                title,
                              ),
                              Text(
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b3
                                          .fontSize,
                                  color: Colors.grey,
                                ),
                                subText,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    color: Colors.grey.shade400,
                    size: 20,
                    Icons.arrow_forward_ios_rounded,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
