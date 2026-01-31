import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/events_log/platforms/events_log_desktop.dart';
import 'package:stockall/pages/report/events_log/platforms/events_log_mobile.dart';

class EventsLog extends StatefulWidget {
  const EventsLog({super.key});

  @override
  State<EventsLog> createState() => _EventsLogState();
}

class _EventsLogState extends State<EventsLog> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return EventsLogMobile();
        } else {
          return EventsLogDesktop();
        }
      },
    );
  }
}
