import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:storrec/providers/theme_provider.dart';

class ButtonTab extends StatelessWidget {
  final String title;
  final String icon;
  final Function()? action;

  final ThemeProvider theme;

  const ButtonTab({
    super.key,
    required this.title,
    required this.icon,
    this.action,
    required this.theme,
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
            borderRadius: BorderRadius.circular(10),
            onTap: action,
            child: Container(
              padding: EdgeInsets.all(15),
              child: Center(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      icon,
                      height: 23,
                      width: 23,
                    ),
                    SizedBox(height: 10),
                    Text(
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
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
