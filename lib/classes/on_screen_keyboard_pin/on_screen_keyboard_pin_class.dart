import 'package:hive/hive.dart';
part 'on_screen_keyboard_pin_class.g.dart';

@HiveType(typeId: 92)
class OnScreenKeyboardPinClass extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  bool isOn;

  OnScreenKeyboardPinClass({
    required this.id,
    required this.isOn,
  });

  factory OnScreenKeyboardPinClass.fromJson(
    Map<String, dynamic> json,
  ) {
    return OnScreenKeyboardPinClass(
      id: json['id'] as int,
      isOn: json['is_on'] as bool,
    );
  }
}
