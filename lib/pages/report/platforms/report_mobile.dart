import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:storrec/components/major/top_banner.dart';
import 'package:storrec/constants/constants_main.dart';
import 'package:storrec/main.dart';
import 'package:storrec/pages/report/general_report/general_report_page.dart';
import 'package:storrec/providers/theme_provider.dart';

class ReportMobile extends StatelessWidget {
  const ReportMobile({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      body: Column(
        children: [
          TopBanner(
            subTitle: 'Manage your business from report',
            title: 'Reports',
            theme: theme,
            bottomSpace: 40,
            topSpace: 30,
            isMain: true,
            iconSvg: reportIconSvg,
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
            ),
            child: Column(
              children: [
                Row(children: [Text('Reports List:')]),
                SizedBox(height: 15),
                SingleChildScrollView(
                  child: Column(
                    spacing: 10,
                    children: [
                      ReportListTile(
                        theme: theme,
                        action: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return GeneralReportPage();
                              },
                            ),
                          );
                        },
                        subText:
                            'Veiw A Summary of your business Report',
                        title: 'General Overview',
                      ),
                      ReportListTile(
                        theme: theme,
                        action: () {},
                        subText:
                            'Veiw A Summary of your business Report',
                        title: 'Sales and Revenue',
                      ),
                      ReportListTile(
                        theme: theme,
                        action: () {},
                        subText:
                            'Veiw A Summary of your business Report',
                        title: 'General Overview',
                      ),
                      ReportListTile(
                        theme: theme,
                        action: () {},
                        subText:
                            'Veiw A Summary of your business Report',
                        title: 'General Overview',
                      ),
                      ReportListTile(
                        theme: theme,
                        action: () {},
                        subText:
                            'Veiw A Summary of your business Report',
                        title: 'General Overview',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReportListTile extends StatelessWidget {
  final ThemeProvider theme;
  final String title;
  final String subText;
  final Function() action;

  const ReportListTile({
    super.key,
    required this.theme,
    required this.title,
    required this.subText,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(22, 0, 0, 0),
            blurRadius: 10,
          ),
        ],
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
      ),
      child: InkWell(
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
              Row(
                spacing: 10,
                children: [
                  // Container(
                  //   padding: EdgeInsets.all(
                  //     10,
                  //   ),
                  //   decoration:
                  //       BoxDecoration(
                  //         shape:
                  //             BoxShape
                  //                 .circle,
                  //         color:
                  //             Colors
                  //                 .grey
                  //                 .shade100,
                  //       ),
                  //   child:
                  SvgPicture.asset(receiptIconSvg),
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b2.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        title,
                      ),
                      Text(
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b3.fontSize,
                          color: Colors.grey,
                          // fontWeight:
                          //     FontWeight.bold,
                        ),
                        subText,
                      ),
                    ],
                  ),
                ],
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
    );
  }
}
