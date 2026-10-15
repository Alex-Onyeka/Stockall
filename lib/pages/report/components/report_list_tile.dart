import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/providers/theme_provider.dart';

class ReportListTile extends StatelessWidget {
  final ThemeProvider theme;
  final String title;
  final String subText;
  final Function() action;
  final bool isActive;

  const ReportListTile({
    super.key,
    required this.theme,
    required this.title,
    required this.subText,
    required this.action,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Ink(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? const Color.fromARGB(22, 0, 0, 0)
                  : Colors.transparent,
              blurRadius: 10,
            ),
          ],
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
        child: InkWell(
          mouseCursor: SystemMouseCursors.click,
          borderRadius: BorderRadius.circular(5),
          onTap: action,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 20,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    spacing: 10,
                    children: [
                      SvgPicture.asset(receiptIconSvg),
                      Flexible(
                        child: Column(
                          spacing: 5,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: theme.mobileTexts.b2.fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              subText,
                              style: TextStyle(
                                fontSize: theme.mobileTexts.b3.fontSize,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

