import 'package:hive/hive.dart';

part 'temp_shop_logos.g.dart';

@HiveType(typeId: 29)
class TempShopLogos {
  @HiveField(1)
  final String logoPath;
  final String imageName;
  final int imageHeight;
  final int imageWidth;

  TempShopLogos({
    required this.logoPath,
    required this.imageName,
    required this.imageHeight,
    required this.imageWidth,
  });
}
