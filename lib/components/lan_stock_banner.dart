import 'package:flutter/material.dart';
import 'package:stockall/services/remote/remote_client.dart';

/// The sales pages' notice while the store server can't be reached:
/// stock isn't being held, sales still go through. Shown above
/// [child] only on [LanRoute.lanDown]; elsewhere [child] alone.
class LanStockBanner extends StatefulWidget {
  const LanStockBanner({super.key, required this.child});

  final Widget child;

  static const String text =
      "Store server unreachable — stock isn't being held. Sales are saved "
      "and will sync when it's back.";

  /// Sales pages on screen (each has a banner): "Go to Cart" in the
  /// conflict dialog opens the sales page only when none is.
  static int salesPagesOpen = 0;

  @override
  State<LanStockBanner> createState() => _LanStockBannerState();
}

class _LanStockBannerState extends State<LanStockBanner> {
  @override
  void initState() {
    super.initState();
    LanStockBanner.salesPagesOpen++;
    RemoteRouter.addListener(_routeChanged);
  }

  @override
  void dispose() {
    RemoteRouter.removeListener(_routeChanged);
    LanStockBanner.salesPagesOpen--;
    super.dispose();
  }

  void _routeChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final down = RemoteRouter.route == LanRoute.lanDown;
    // The same tree either way, so the page under it keeps its state
    // when the banner comes and goes.
    return Column(
      children: [
        if (!down)
          const SizedBox.shrink()
        else
          Material(
            color: Colors.orange.shade100,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                spacing: 10,
                children: [
                  Icon(Icons.wifi_off_rounded, color: Colors.orange.shade900),
                  Expanded(
                    child: Text(
                      LanStockBanner.text,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        Expanded(child: widget.child),
      ],
    );
  }
}
