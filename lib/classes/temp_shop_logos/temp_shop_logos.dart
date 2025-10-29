import 'package:hive/hive.dart';

part 'temp_shop_logos.g.dart';

@HiveType(typeId: 29)
class TempShopLogos {
  @HiveField(0)
  final String logoPath;

  @HiveField(1)
  final String imageName;

  @HiveField(2)
  final int imageHeight;

  @HiveField(3)
  final int imageWidth;

  TempShopLogos({
    required this.logoPath,
    required this.imageName,
    required this.imageHeight,
    required this.imageWidth,
  });
}
