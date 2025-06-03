import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storrec/main.dart';
import 'package:storrec/providers/nav_provider.dart';

class NavButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final int index;
  final int currentPage;

  const NavButton({
    super.key,
    required this.title,
    required this.icon,
    required this.currentPage,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Provider.of<NavProvider>(
          context,
          listen: false,
        ).navigate(index);
        returnExpensesProvider(
          context,
          listen: false,
        ).clearExpenseDate();
        returnReceiptProvider(
          context,
          listen: false,
        ).clearReceiptDate();
        returnData(context, listen: false).clearFields();
      },
      child: SizedBox(
        height: 42,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              color:
                  index == currentPage
                      ? const Color.fromARGB(
                        255,
                        4,
                        49,
                        199,
                      )
                      : Colors.grey,
              size: index == currentPage ? 22 : 18,
              icon,
            ),
            Text(
              style: TextStyle(
                color:
                    index == currentPage
                        ? const Color.fromARGB(
                          255,
                          4,
                          49,
                          199,
                        )
                        : Colors.grey,
                fontSize: index == currentPage ? 12 : 11,
                fontWeight:
                    index == currentPage
                        ? FontWeight.bold
                        : FontWeight.normal,
              ),
              title,
            ),
          ],
        ),
      ),
    );
  }
}
