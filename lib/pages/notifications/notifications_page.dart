import 'package:flutter/material.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/notifications/platforms/notifications_desktop.dart';
import 'package:stockall/pages/notifications/platforms/notifications_mobile.dart';
import 'package:stockall/pages/shop_setup/banner_screen/shop_banner_screen.dart';
import 'package:stockall/services/auth_service.dart';

class NotificationsPage extends StatefulWidget {
  final bool? turnOn;
  const NotificationsPage({super.key, this.turnOn});

  @override
  State<NotificationsPage> createState() =>
      _NotificationsPageState();
}

class _NotificationsPageState
    extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    returnNavProvider(context, listen: false).navigate(8);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userShop = await returnShopProvider(
        context,
        listen: false,
      ).getUserShop(AuthService().currentUser!.id);
      if (context.mounted && userShop == null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => ShopBannerScreen(),
          ),
          (route) => false,
        );
      } else {
        if (context.mounted) {
          final provider = returnUserProvider(
            context,
            listen: false,
          );

          await provider.fetchCurrentUser(context);
        }
      }

      setState(() {
        // stillLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 550) {
          return NotificationsMobile();
        } else {
          return NotificationsDesktop(
            turnOn: widget.turnOn,
          );
        }
      },
    );
  }
}
