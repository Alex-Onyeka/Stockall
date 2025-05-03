import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockitt/components/major/top_banner.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/pages/dashboard/components/main_bottom_nav.dart';
import 'package:stockitt/providers/nav_provider.dart';
import 'package:stockitt/providers/theme_provider.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<NavProvider>(
      context,
      listen: false,
    ).navigate(1);
  }

  bool isFocus = false;

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          body: Column(
            children: [
              TopBanner(
                subTitle: 'Data of All Product Records',
                title: 'Products',
                theme: theme,
                bottomSpace: 50,
                topSpace: 30,
                iconSvg: productIconSvg,
              ),
              SizedBox(height: 20),
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color.fromARGB(
                    255,
                    244,
                    244,
                    244,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              style: TextStyle(
                                color: Colors.black,
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b1
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              'Product Record',
                            ),
                            Text(
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b2
                                        .fontSize,
                              ),
                              'Total Info',
                            ),
                            SizedBox(height: 10),
                            SizedBox(
                              width: 300,
                              child: TextFormField(
                                onTap:
                                    () => setState(() {
                                      isFocus = true;
                                    }),
                                onTapOutside:
                                    (event) => setState(() {
                                      isFocus = false;
                                    }),
                                decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                  prefixIcon: Icon(
                                    size: 25,
                                    color:
                                        isFocus
                                            ? Colors.amber
                                            : Colors.grey,
                                    Icons.search_rounded,
                                  ),
                                  hintText:
                                      'Search Product name',
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.w500,
                                  ),
                                  enabledBorder:
                                      OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(
                                              30,
                                            ),
                                        borderSide: BorderSide(
                                          color:
                                              Colors
                                                  .grey
                                                  .shade500,
                                          width: 1,
                                        ),
                                      ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                          30,
                                        ),
                                    borderSide: BorderSide(
                                      color:
                                          theme
                                              .lightModeColor
                                              .prColor300,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                ProductSummaryTab(
                                  color: Colors.green,
                                  title: 'In Stock',
                                  value: 0,
                                  theme: theme,
                                ),
                                ProductSummaryTab(
                                  color: Colors.amber,
                                  title: 'Out of Stock',
                                  value: 0,
                                  theme: theme,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SizedBox(
                  child: SingleChildScrollView(
                    child: Column(),
                  ),
                ),
              ),
              MainBottomNav(),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductSummaryTab extends StatelessWidget {
  final String title;
  final int value;
  final ThemeProvider theme;
  final Color color;

  const ProductSummaryTab({
    super.key,
    required this.title,
    required this.value,
    required this.theme,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.grey.shade200,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 8,
            children: [
              Container(
                height: 11,
                width: 11,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
              Text(
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: theme.mobileTexts.b2.fontSize,
                  fontWeight: FontWeight.bold,
                ),
                title,
              ),
            ],
          ),
          Text(
            style: TextStyle(
              fontSize: theme.mobileTexts.h3.fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
            value.toString(),
          ),
        ],
      ),
    );
  }
}
