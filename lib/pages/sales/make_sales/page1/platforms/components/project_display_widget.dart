import 'package:flutter/material.dart';
import 'package:stockall/main.dart';

class ProjectDisplayWidget extends StatelessWidget {
  const ProjectDisplayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Visibility(
      visible:
          !returnMultiDisplayProviderContext(
            context,
          ).checkIfWindowExists(
            returnSalesProviderContext(context).cartIdCache,
          ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Material(
                type: MaterialType.transparency,
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: theme.lightModeColor.prColor300,
                  ),
                  child: InkWell(
                    mouseCursor: SystemMouseCursors.click,
                    borderRadius: BorderRadius.circular(3),
                    onTap: () async {
                      returnSalesProvider().createWindow();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 7,
                      ),

                      child: Row(
                        spacing: 4,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b4
                                      .fontSize,
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                            ),
                            'Project',
                          ),
                          Icon(
                            size: 16,
                            color: Colors.white,
                            Icons.screen_share_outlined,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
