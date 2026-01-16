import 'package:flutter/material.dart';
import 'package:stockall/providers/theme_provider.dart';

class MyToggleButton extends StatelessWidget {
  final bool boolValue;
  final Function() toggle;
  final bool? isSmall;
  const MyToggleButton({
    super.key,
    required this.theme,
    required this.toggle,
    required this.boolValue,
    this.isSmall,
  });

  final ThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: toggle,
      child: Container(
        height: 16,
        width: isSmall != null && isSmall == true ? 35 : 50,
        padding: EdgeInsets.symmetric(
          horizontal:
              isSmall != null && isSmall == true ? 6 : 10,
          vertical:
              isSmall != null && isSmall == true ? 2.5 : 5,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                boolValue
                    ? theme.lightModeColor.prColor250
                    : Colors.grey,
          ),
          color:
              boolValue
                  ? theme.lightModeColor.prColor250
                  : Colors.grey.shade200,
        ),
        child: Row(
          mainAxisAlignment:
              boolValue
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(
                isSmall != null && isSmall == true
                    ? 3.5
                    : 5,
              ),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    boolValue
                        ? Colors.white
                        : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
