import 'package:hive/hive.dart';
part 'app_version.g.dart';

@HiveType(typeId: 32)
class AppVersion extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String mobileVersion;

  @HiveField(2)
  final String desktopVersion;

  AppVersion({
    required this.id,
    required this.mobileVersion,
    required this.desktopVersion,
  });

  factory AppVersion.fromJson(Map<String, dynamic> json) {
    return AppVersion(
      id: json['id'] as int,
      mobileVersion: json['mobile_version'] as String,
      desktopVersion: json['desktop_version'] as String,
    );
  }
}
