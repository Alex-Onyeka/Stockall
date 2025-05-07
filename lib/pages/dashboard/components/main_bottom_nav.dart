import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/pages/dashboard/components/nav_button.dart';
import 'package:stockitt/pages/sales/make_sales/make_sales_page.dart';
import 'package:stockitt/providers/nav_provider.dart';

class MainBottomNav extends StatelessWidget {
  const MainBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment(-0.03, -2),
      children: [
        Container(
          height: 80,
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              NavButton(
                currentPage:
                    Provider.of<NavProvider>(
                      context,
                    ).currentPage,
                index: 0,
                icon: Icons.home_filled,
                title: 'Home',
              ),
              Expanded(
                child: NavButton(
                  currentPage:
                      Provider.of<NavProvider>(
                        context,
                      ).currentPage,
                  index: 1,
                  icon: Icons.book,
                  title: 'Products',
                ),
              ),
              SizedBox(width: 60),
              Expanded(
                child: NavButton(
                  currentPage:
                      Provider.of<NavProvider>(
                        context,
                      ).currentPage,
                  index: 2,
                  icon: Icons.menu_book_rounded,
                  title: 'Sales',
                ),
              ),
              NavButton(
                currentPage:
                    Provider.of<NavProvider>(
                      context,
                    ).currentPage,
                index: 3,
                icon: Icons.settings,
                title: 'Settings',
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return MakeSalesPage();
                },
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(55, 0, 0, 0),
                  blurRadius: 5,
                  offset: Offset(0, -1),
                ),
              ],
            ),
            child: SvgPicture.asset(makeSalesIconSvg),
          ),
        ),
      ],
    );
  }
}
