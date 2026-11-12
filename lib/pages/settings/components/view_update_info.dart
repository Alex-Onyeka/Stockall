import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stockall/components/major/drawer_widget/platforms/my_drawer_widget_desktop.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/new_feature_pop_action.dart';
import 'package:stockall/helpers/clean_up_url/clean_up_url.dart';
import 'package:stockall/main.dart';

/// Displays either a "New Update Available" notification with an Update button
/// (when a newer app version is available) or the "View Update Features Info"
/// tile (when the app is up to date).
class ViewUpdateInfoWidget extends StatefulWidget {
  const ViewUpdateInfoWidget({super.key});

  @override
  State<ViewUpdateInfoWidget> createState() => _ViewUpdateInfoWidgetState();
}

class _ViewUpdateInfoWidgetState extends State<ViewUpdateInfoWidget> {
  bool _isUpdating = false;

  Future<void> _handleUpdate(BuildContext context) async {
    if (_isUpdating) return;
    setState(() => _isUpdating = true);
    try {
      if (kIsWeb && Theme.of(context).platform == TargetPlatform.iOS) {
        performRestart();
      } else {
        await downloadApkFromApp(context: context);
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    final appVersionP = returnAppVersionProvider(context);
    final hasUpdate = appVersionP.hasAvailableUpdate(context);

    if (!hasUpdate) {
      return NavListTileDesktopAlt(
        height: 18,
        action: () async {
          newFeaturesUpdatePopUpAction(
            context: context,
            isFromSettingPage: true,
          );
        },
        title: 'View Update Features Info',
        icon: Icons.lightbulb_outlined,
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.lightModeColor.secColor200.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.lightModeColor.secColor200.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        spacing: 12,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.lightModeColor.secColor200.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.system_update_rounded,
              color: theme.lightModeColor.secColor200,
              size: 20,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New Update Available',
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                    fontWeight: FontWeight.bold,
                    color: theme.lightModeColor.prColor300,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'A new version of Stockall is ready. Update to get the latest features.',
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b4.fontSize,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: Ink(
              decoration: BoxDecoration(
                color: theme.lightModeColor.prColor300,
                borderRadius: BorderRadius.circular(6),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                mouseCursor: SystemMouseCursors.click,
                onTap: _isUpdating ? null : () => _handleUpdate(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  child:
                      _isUpdating
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : Text(
                            'Update',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: theme.mobileTexts.b4.fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
