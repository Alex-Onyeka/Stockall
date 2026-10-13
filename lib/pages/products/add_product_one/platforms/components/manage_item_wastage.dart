import 'package:flutter/material.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';

class ManageItemWastage extends StatelessWidget {
  const ManageItemWastage({super.key, required this.theme});

  final ThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      mouseCursor: SystemMouseCursors.click,
      onTap: () {
        returnData().toggleManageWastage();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b2.fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                  'Manage Sales Wastage?',
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        style: TextStyle(fontSize: 10),
                        'Turn this on if you want to enter wastage amount during sales of this item.',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Checkbox(
            activeColor: theme.lightModeColor.secColor100,
            value:
                returnData(context: context).manageWastage,
            onChanged: (value) {
              returnData().toggleManageWastage();
              FocusManager.instance.primaryFocus?.unfocus();
            },
          ),
        ],
      ),
    );
  }
}
