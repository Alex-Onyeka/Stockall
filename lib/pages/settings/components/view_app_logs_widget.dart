import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/major/drawer_widget/platforms/my_drawer_widget_desktop.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';

class ViewAppLogsWidget extends StatelessWidget {
  const ViewAppLogsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return NavListTileDesktopAlt(
      height: 18,
      action: () {
        showDialog(
          context: context,
          builder:
              (dialogContext) => const _AppLogsDialog(),
        );
      },
      title: 'App Logs & Diagnostics',
      icon: Icons.terminal_rounded,
    );
  }
}

class _AppLogsDialog extends StatefulWidget {
  const _AppLogsDialog();

  @override
  State<_AppLogsDialog> createState() =>
      _AppLogsDialogState();
}

class _AppLogsDialogState extends State<_AppLogsDialog> {
  // String? _dirPath;
  // String? _filePath;
  String _logContent = 'Loading logs...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    // final dir = await getMainLogDirectoryPath();
    // final file = await getMainLogFilePath();
    final content = await readMainLogContent();
    if (mounted) {
      setState(() {
        // _dirPath = dir;
        // _filePath = file;
        _logContent = content;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    final isMobile = screenWidth(context) < mobileScreen;
    // final isDesktopPlatform =
    //     !kIsWeb &&
    //     (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

    final contentHeight =
        isMobile
            ? (screenHeight(context) * 0.7).clamp(
              320.0,
              480.0,
            )
            : (screenHeight(context) * 0.8).clamp(
              320.0,
              480.0,
            );

    return DialogTemplate(
      theme: theme,
      title: 'App Logs & Diagnostics',
      message:
          'Inspect or share diagnostic logs recorded on this device for troubleshooting.',
      actionButtonText: 'Close',
      showBottomActionButtons: true,
      showMainBottomActionButton: false,
      action: () => Navigator.of(context).pop(),
      widget: SizedBox(
        width: 500,
        height: contentHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Storage Location Card
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            //   decoration: BoxDecoration(
            //     color: Colors.grey.shade100,
            //     borderRadius: BorderRadius.circular(6),
            //     border: Border.all(color: Colors.grey.shade300),
            //   ),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Row(
            //         children: [
            //           Icon(
            //             Icons.folder_outlined,
            //             size: 15,
            //             color: theme.lightModeColor.prColor,
            //           ),
            //           const SizedBox(width: 6),
            //           Text(
            //             'Storage Location:',
            //             style: TextStyle(
            //               fontSize: 11,
            //               fontWeight: FontWeight.bold,
            //               color: Colors.grey.shade800,
            //             ),
            //           ),
            //         ],
            //       ),
            //       const SizedBox(height: 3),
            //       SelectableText(
            //         _dirPath ??
            //             (_isLoading
            //                 ? 'Determining path...'
            //                 : 'Not available on this platform'),
            //         style: const TextStyle(
            //           fontFamily: 'Courier',
            //           fontSize: 11,
            //           color: Colors.black87,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // const SizedBox(height: 8),

            // // Action Buttons Bar
            // Wrap(
            //   spacing: 6,
            //   runSpacing: 6,
            //   children: [
            //     if (isDesktopPlatform && _dirPath != null)
            //       ElevatedButton.icon(
            //         style: ElevatedButton.styleFrom(
            //           backgroundColor: theme.lightModeColor.prColor,
            //           foregroundColor: Colors.white,
            //           padding: const EdgeInsets.symmetric(
            //             horizontal: 10,
            //             vertical: 6,
            //           ),
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(5),
            //           ),
            //         ),
            //         onPressed: () async {
            //           final opened = await openLogDirectory();
            //           if (!opened && context.mounted) {
            //             await copyToClipboard(
            //               context: context,
            //               text: _dirPath!,
            //               message:
            //                   'Could not launch Explorer. Path copied instead.',
            //             );
            //           }
            //         },
            //         icon: const Icon(Icons.folder_open_rounded, size: 14),
            //         label: const Text(
            //           'Open Folder',
            //           style: TextStyle(fontSize: 11),
            //         ),
            //       ),
            //     OutlinedButton.icon(
            //       style: OutlinedButton.styleFrom(
            //         foregroundColor: Colors.black87,
            //         padding: const EdgeInsets.symmetric(
            //           horizontal: 10,
            //           vertical: 6,
            //         ),
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(5),
            //         ),
            //       ),
            //       onPressed: () async {
            //         if (_filePath != null) {
            //           await copyToClipboard(
            //             context: context,
            //             text: _filePath!,
            //             message: 'Log file path copied to clipboard',
            //           );
            //         }
            //       },
            //       icon: const Icon(Icons.content_copy_rounded, size: 14),
            //       label: const Text(
            //         'Copy Path',
            //         style: TextStyle(fontSize: 11),
            //       ),
            //     ),
            //     OutlinedButton.icon(
            //       style: OutlinedButton.styleFrom(
            //         foregroundColor: Colors.black87,
            //         padding: const EdgeInsets.symmetric(
            //           horizontal: 10,
            //           vertical: 6,
            //         ),
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(5),
            //         ),
            //       ),
            //       onPressed: () async {
            //         await copyToClipboard(
            //           context: context,
            //           text: _logContent,
            //           message: 'Full log content copied to clipboard',
            //         );
            //       },
            //       icon: const Icon(Icons.copy_all_rounded, size: 14),
            //       label: const Text(
            //         'Copy Log Content',
            //         style: TextStyle(fontSize: 11),
            //       ),
            //     ),
            //     IconButton(
            //       tooltip: 'Refresh Logs',
            //       onPressed: _loadLogs,
            //       icon: const Icon(Icons.refresh_rounded, size: 18),
            //       padding: EdgeInsets.zero,
            //       constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 8),

            // Log Console Preview Box
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.grey.shade400,
                  ),
                ),
                child:
                    _isLoading
                        ? const Center(
                          child:
                              CircularProgressIndicator(),
                        )
                        : SingleChildScrollView(
                          reverse: true,
                          child: SelectableText(
                            _logContent,
                            style: TextStyle(
                              color: Colors.grey.shade900,
                              fontFamily: 'Courier',
                              fontSize: 11,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
