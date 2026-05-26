// // GENERATED CODE - DO NOT MODIFY BY HAND

// part of 'on_screen_keyboard_pin.dart';

// // **************************************************************************
// // TypeAdapterGenerator
// // **************************************************************************

// class OnScreenKeyboardPinAdapter extends TypeAdapter<OnScreenKeyboardPin> {
//   @override
//   final int typeId = 92;

//   @override
//   OnScreenKeyboardPin read(BinaryReader reader) {
//     final numOfFields = reader.readByte();
//     final fields = <int, dynamic>{
//       for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
//     };
//     return OnScreenKeyboardPin(
//       id: fields[0] as int,
//       isOn: fields[1] as bool,
//     );
//   }

//   @override
//   void write(BinaryWriter writer, OnScreenKeyboardPin obj) {
//     writer
//       ..writeByte(2)
//       ..writeByte(0)
//       ..write(obj.id)
//       ..writeByte(1)
//       ..write(obj.isOn);
//   }

//   @override
//   int get hashCode => typeId.hashCode;

//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is OnScreenKeyboardPinAdapter &&
//           runtimeType == other.runtimeType &&
//           typeId == other.typeId;
// }
