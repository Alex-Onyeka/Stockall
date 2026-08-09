import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stockall/providers/theme_provider.dart';

class ButtonTab extends StatelessWidget {
  final String title;
  final Color? iconColor;
  final String? icon;
  final Function()? action;
  final ThemeProvider theme;
  final Icon? iconWidget;

  const ButtonTab({
    super.key,
    required this.title,
    this.icon,
    this.action,
    required this.theme,
    this.iconWidget,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: const Color.fromARGB(15, 0, 0, 0),
              spreadRadius: 3,
            ),
          ],
        ),
        child: Material(
          color:
              Colors
                  .white, // Match the container's background
          borderRadius: BorderRadius.circular(10),
          elevation: 0, // Optional: add shadow if needed
          child: InkWell(
            mouseCursor: SystemMouseCursors.click,
            borderRadius: BorderRadius.circular(10),
            onTap: action,
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 5,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Builder(
                      builder: (context) {
                        if (iconWidget == null) {
                          return SvgPicture.asset(
                            icon ?? '',
                            color: iconColor,
                            height: 20,
                            width: 20,
                          );
                        } else {
                          return iconWidget ?? Container();
                        }
                      },
                    ),
                    SizedBox(height: 10),
                    Text(
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize:
                            theme.mobileTexts.b4.fontSize,
                        fontWeight: FontWeight.w600,
                      ),
                      title,
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
