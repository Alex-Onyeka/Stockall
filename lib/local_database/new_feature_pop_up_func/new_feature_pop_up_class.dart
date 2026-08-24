import 'package:hive/hive.dart';

part 'new_feature_pop_up_class.g.dart';

@HiveType(typeId: 132)
class NewFeaturePopUpClass extends HiveObject {
  @HiveField(0)
  String uuid;

  @HiveField(1)
  String oldNewFeatureMobile;

  @HiveField(2)
  String oldNewFeatureDesktop;

  @HiveField(3)
  int numberViewed;

  NewFeaturePopUpClass({
    required this.uuid,
    required this.oldNewFeatureMobile,
    required this.oldNewFeatureDesktop,
    required this.numberViewed,
  });

  NewFeaturePopUpClass copyWith({
    String? uuid,
    String? oldNewFeatureMobile,
    String? oldNewFeatureDesktop,
    int? numberViewed,
  }) {
    return NewFeaturePopUpClass(
      uuid: uuid ?? this.uuid,
      oldNewFeatureMobile:
          oldNewFeatureMobile ?? this.oldNewFeatureMobile,
      oldNewFeatureDesktop:
          oldNewFeatureDesktop ?? this.oldNewFeatureDesktop,
      numberViewed: numberViewed ?? this.numberViewed,
    );
  }
}
