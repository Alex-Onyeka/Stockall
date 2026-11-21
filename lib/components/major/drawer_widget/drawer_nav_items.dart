import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stockall/classes/temp_notification/temp_notification.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/calculator_page/calculator_page.dart';
import 'package:stockall/pages/customers/customers_list/customer_list.dart';
import 'package:stockall/pages/dashboard/components/contact_us_float_widget.dart';
import 'package:stockall/pages/employees/employee_list/employee_list_page.dart';
import 'package:stockall/pages/expenses/expenses_page.dart';
import 'package:stockall/pages/home/home.dart';
import 'package:stockall/pages/invoices/invoice_list/invoice_list_page.dart';
import 'package:stockall/pages/notifications/notifications_page.dart';
import 'package:stockall/pages/orders/order_list/order_list_page.dart';
import 'package:stockall/pages/production/production_page.dart';
import 'package:stockall/pages/products/storage_page/storage_page.dart';
import 'package:stockall/pages/profile/profile_page.dart';
import 'package:stockall/pages/purchases/purchase_list/purchase_list.dart';
import 'package:stockall/pages/report/report_page.dart';
import 'package:stockall/pages/settings/settings_page.dart';
import 'package:stockall/pages/shop_setup/shop_page/shop_page.dart';
import 'package:stockall/pages/suppliers/supplier_list/supplier_list.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/auth_service.dart';

enum DrawerMode { mobile, tablet, desktop }

/// Single shared navigation items list used by Mobile, Tablet, and Desktop
/// drawers so new items (such as Storage) stay in sync across all platforms.
class DrawerNavItems extends StatelessWidget {
  final DrawerMode mode;
  final ThemeProvider theme;
  final List<TempNotification> notifications;
  final bool isHovered;
  final VoidCallback? onRefresh;
  final Widget Function({
    int? itemIndex,
    required double height,
    required VoidCallback action,
    required String title,
    IconData? icon,
    String? svg,
  })
  buildTile;

  const DrawerNavItems({
    super.key,
    required this.mode,
    required this.theme,
    required this.notifications,
    required this.buildTile,
    this.isHovered = true,
    this.onRefresh,
  });

  void _navigateHomeTab(
    BuildContext context,
    int tabIndex,
  ) {
    final safeContext = context;
    returnNavProvider(
      safeContext,
      listen: false,
    ).navigate(tabIndex);
    if (tabIndex == 0 || Navigator.of(context).canPop()) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Home()),
        (_) => false,
      );
    }
    returnExpensesProvider(
      safeContext,
      listen: false,
    ).clearDate();
    returnReceiptProvider(
      safeContext,
      listen: false,
    ).clearDate();
    returnData().clearFields();
  }

  void _preparePush(BuildContext context) {
    if (mode == DrawerMode.mobile) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      return;
    }
    final nav = returnNavProvider(context, listen: false);
    if (nav.currentIndex != 0 ||
        nav.currentIndex != 1 ||
        nav.currentIndex != 2) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  void _pushPage(BuildContext context, Widget page) {
    _preparePush(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    ).then((_) => onRefresh?.call());
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = mode == DrawerMode.mobile;
    final isCompactTablet =
        mode == DrawerMode.tablet && !isHovered;
    final unreadCount =
        notifications
            .where((notif) => !notif.isViewed)
            .length;
    final manageStorage =
        returnShopProvider(
          context: context,
        ).userShop()?.manageInventoryStorage ==
        true;

    return Column(
      children: [
        if (isMobile) ...[
          buildTile(
            height: 17,
            action:
                () =>
                    _pushPage(context, const ProfilePage()),
            title: 'Profile',
            icon: Icons.person,
          ),
          Visibility(
            visible: authorization(
              authorized: Authorizations().manageShop,
            ),
            child: buildTile(
              height: 17,
              action:
                  () =>
                      _pushPage(context, const ShopPage()),
              title: 'Manage Shop',
              icon: Icons.home_filled,
            ),
          ),
        ] else ...[
          buildTile(
            itemIndex: 0,
            height: 16,
            action: () => _navigateHomeTab(context, 0),
            title: 'Dashboard',
            icon: Icons.dashboard_rounded,
          ),
        ],
        buildTile(
          itemIndex: 1,
          height: 16,
          action: () => _navigateHomeTab(context, 1),
          title: 'Items',
          icon: Icons.book,
        ),
        Visibility(
          visible: manageStorage,
          child: buildTile(
            itemIndex: -1,
            height: 14,
            action: () {
              ItemsAuthAction()
                  .manageInventoryStorageAction(
                    context: context,
                    action:
                        () => _pushPage(
                          context,
                          const StoragePage(),
                        ),
                  );
            },
            title: 'Storage',
            icon: Icons.warehouse_outlined,
          ),
        ),
        Visibility(
          visible: !isStoreKeeper(),
          child: buildTile(
            itemIndex: 2,
            height: 16,
            action: () => _navigateHomeTab(context, 2),
            title: 'Sales',
            icon: Icons.menu_book_rounded,
          ),
        ),
        Visibility(
          visible: !isStoreKeeper(),
          child: buildTile(
            itemIndex: 3,
            height: 14,
            action:
                () => _pushPage(
                  context,
                  const CustomerList(),
                ),
            title: 'Customers',
            svg: custBookIconSvg,
          ),
        ),
        Visibility(
          visible: !isStoreKeeper(),
          child: buildTile(
            itemIndex: 4,
            height: 14,
            action:
                () => _pushPage(
                  context,
                  const SupplierList(),
                ),
            title: 'Suppliers',
            icon: Icons.person,
          ),
        ),
        Visibility(
          visible:
              !isStoreKeeper() &&
              authorization(
                authorized:
                    Authorizations().managePurchases,
              ),
          child: buildTile(
            itemIndex: 5,
            height: 14,
            action:
                () => _pushPage(
                  context,
                  const PurchaseList(),
                ),
            title: 'Purchases',
            icon: Icons.account_balance_wallet_outlined,
          ),
        ),
        Visibility(
          visible: !isStoreKeeper(),
          child: buildTile(
            itemIndex: 6,
            height: 14,
            action:
                () => _pushPage(
                  context,
                  ExpensesPage(
                    isMain: true,
                    turnOnBackNavButton: isMobile,
                  ),
                ),
            title: 'Expenses',
            svg: expensesIconSvg,
          ),
        ),
        Visibility(
          visible: !isStoreKeeper(),
          child: buildTile(
            itemIndex: 7,
            height: isMobile ? 16 : 14,
            action:
                () => _pushPage(
                  context,
                  const InvoiceListPage(),
                ),
            title: 'Invoices',
            icon: Icons.all_inclusive_sharp,
          ),
        ),
        buildTile(
          itemIndex: 8,
          height: 14,
          action:
              () => _pushPage(context, const ReportPage()),
          title: 'Report',
          svg: reportIconSvg,
        ),
        buildTile(
          itemIndex: 9,
          height: 14,
          action:
              () => _pushPage(
                context,
                EmployeeListPage(
                  empId: AuthService().currentUser!,
                ),
              ),
          title: 'Staffs',
          svg: employeesIconSvg,
        ),
        Visibility(
          visible:
              authorization(
                authorized:
                    Authorizations().viewProductions,
              ) &&
              returnShopProvider()
                      .userShop()
                      ?.manageProductions ==
                  true,
          child: buildTile(
            itemIndex: -1,
            height: 14,
            action:
                () => _pushPage(
                  context,
                  const ProductionPage(),
                ),
            title: 'Production',
            icon: Icons.view_in_ar_rounded,
          ),
        ),
        Visibility(
          visible: authorization(
            authorized: Authorizations().manageOrders,
          ),
          child: buildTile(
            itemIndex: 10,
            height: 14,
            action:
                () => _pushPage(
                  context,
                  const OrderListPage(),
                ),
            title: 'Orders',
            icon: Icons.article_outlined,
          ),
        ),
        const SizedBox(height: 5),
        Divider(
          height:
              MediaQuery.of(context).size.height < 680
                  ? 15
                  : 20,
          color: Colors.grey.shade200,
        ),
        Visibility(
          visible: authorization(
            authorized: Authorizations().contactStockall,
          ),
          child: buildTile(
            itemIndex: -1,
            height: 18,
            action: () => contactUsAction(context: context),
            title: 'Contact Support',
            icon: Icons.manage_accounts_outlined,
          ),
        ),
        Visibility(
          visible: !isStoreKeeper(),
          child: _buildNotificationsTile(
            context: context,
            isCompactTablet: isCompactTablet,
            unreadCount: unreadCount,
            isMobile: isMobile,
          ),
        ),
        buildTile(
          itemIndex: 12,
          height: 18,
          action:
              () => _pushPage(
                context,
                const CalculatorPage(),
              ),
          title: 'Open Calculator',
          icon: Icons.calculate_outlined,
        ),
        buildTile(
          itemIndex: -1,
          height: 18,
          action:
              () =>
                  _pushPage(context, const SettingsPage()),
          title: 'General Settings',
          icon: Icons.settings,
        ),
        Visibility(
          visible:
              (kIsWeb &&
                  Theme.of(context).platform ==
                      TargetPlatform.android) ||
              (kIsWeb &&
                  screenWidth(context) > tabletScreenSmall),
          child: buildTile(
            itemIndex: -1,
            height: 18,
            action: () {
              showDialog(
                context: context,
                builder: (dialogCtx) {
                  return ConfirmationAlert(
                    theme: theme,
                    message:
                        'You are about to download and install our official Native application, for better experience.',
                    title:
                        screenWidth(context) > tabletScreen
                            ? 'Proceed to Download Desktop App'
                            : 'Proceed to Download Mobile App',
                    action: () async {
                      Navigator.of(dialogCtx).pop();
                      await downloadApkFromApp(
                        context: context,
                      );
                    },
                  );
                },
              );
            },
            title:
                screenWidth(context) > tabletScreen
                    ? 'Download Desktop App'
                    : 'Download Mobile App',
            icon: Icons.download,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsTile({
    required BuildContext context,
    required bool isCompactTablet,
    required int unreadCount,
    required bool isMobile,
  }) {
    final isSelected =
        returnNavProvider(context).currentIndex == 11;
    return InkWell(
      mouseCursor: SystemMouseCursors.click,
      onTap:
          () => _pushPage(
            context,
            NotificationsPage(turnOn: isMobile),
          ),
      child: Container(
        color:
            isSelected
                ? const Color.fromARGB(255, 241, 241, 241)
                : Colors.transparent,
        padding: EdgeInsets.symmetric(
          horizontal: 10,
          vertical:
              MediaQuery.of(context).size.height < 680
                  ? 2
                  : 5,
        ),
        child: Row(
          mainAxisAlignment:
              isCompactTablet
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.spaceBetween,
          children: [
            if (!isCompactTablet)
              Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    color:
                        isSelected
                            ? theme
                                .lightModeColor
                                .prColor300
                            : Colors.grey.shade400,
                    size: 20,
                    Icons.notifications_on_outlined,
                  ),
                  Text(
                    'Notifications',
                    style: TextStyle(
                      color:
                          isSelected
                              ? theme
                                  .lightModeColor
                                  .prColor300
                              : Colors.grey.shade900,
                      fontSize:
                          isMobile
                              ? theme.mobileTexts.b3.fontSize
                              : theme.mobileTexts.b2.fontSize,
                      fontWeight:
                          isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(
                          208,
                          245,
                          245,
                          245,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        height: 22,
                        width: 22,
                        notifIconSvg,
                        colorFilter:
                            unreadCount > 0
                                ? null
                                : ColorFilter.mode(
                                  Colors.grey.shade500,
                                  BlendMode.srcIn,
                                ),
                      ),
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        bottom: 18,
                        left: 26,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient:
                                theme
                                    .lightModeColor
                                    .secGradient,
                          ),
                          child: Center(
                            child: Text(
                              '$unreadCount',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                if (isSelected && !isCompactTablet) ...[
                  const SizedBox(width: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                    ),
                    child: Container(
                      width: 4,
                      height: 15,
                      decoration: BoxDecoration(
                        color:
                            theme
                                .lightModeColor
                                .secColor200,
                        borderRadius: BorderRadius.circular(
                          20,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
