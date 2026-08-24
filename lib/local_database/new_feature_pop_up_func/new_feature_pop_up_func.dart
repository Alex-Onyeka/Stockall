import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/new_feature_pop_action.dart';
import 'package:stockall/local_database/new_feature_pop_up_func/new_feature_pop_up_class.dart';
import 'package:stockall/main.dart';

class NewFeaturePopUpFunc {
  static final NewFeaturePopUpFunc instance =
      NewFeaturePopUpFunc._internal();
  factory NewFeaturePopUpFunc() => instance;
  NewFeaturePopUpFunc._internal();
  late Box<NewFeaturePopUpClass> newFeaturePopUpBox;
  final String newFeaturePopUpBoxName =
      'newFeaturePopUpBoxStockall';

  Future<void> init() async {
    try {
      // await Hive.deleteBoxFromDisk(newFeaturePopUpBoxName);
      Hive.registerAdapter(NewFeaturePopUpClassAdapter());
      newFeaturePopUpBox = await Hive.openBox(
        newFeaturePopUpBoxName,
      );
      await mainLocalLog(
        '✅New Feature Pop Up Box Initialized',
      );
      if (getNewFeaturePopUp() == null) {
        NewFeaturePopUpClass newFeature =
            NewFeaturePopUpClass(
              uuid: uuidGen(),
              oldNewFeatureMobile: '',
              numberViewed: 0,
              oldNewFeatureDesktop: '',
            );
        await insertNewFeature(newFeature);
      }
    } catch (e, s) {
      await mainLocalLog(
        'Error Initializing New Feature Pop Ups Box: ${e.toString()}',
        error: e,
        stackTrace: s,
      );
    }
  }

  NewFeaturePopUpClass? getNewFeaturePopUp() {
    return newFeaturePopUpBox.values.isNotEmpty
        ? newFeaturePopUpBox.values.first
        : null;
  }

  Future<int> insertNewFeature(
    NewFeaturePopUpClass newFeature,
  ) async {
    try {
      await newFeaturePopUpBox.put(
        newFeature.uuid,
        newFeature,
      );
      await mainLocalLog('New Feature inserted Success');
      return 1;
    } catch (e) {
      await mainLocalLog(
        '❌❌ Insert New Feature Offline Error: ${e.toString()}',
      );
      return 0;
    }
  }

  bool isPopUpViewed() {
    if ((getNewFeaturePopUp()?.numberViewed ?? 0) < 2) {
      return false;
    } else {
      return true;
    }
  }

  Future<void> checkIfIsNew({
    required BuildContext context,
  }) async {
    if (getNewFeaturePopUp() != null) {
      if (screenWidth(context) > mobileScreen) {
        if (appVersionDesktop !=
            getNewFeaturePopUp()!.oldNewFeatureDesktop) {
          newFeaturesUpdatePopUpAction(
            context: context,
            isFromSettingPage: false,
          );
        }
      } else {
        if (appVersionMobile !=
            getNewFeaturePopUp()!.oldNewFeatureMobile) {
          newFeaturesUpdatePopUpAction(
            context: context,
            isFromSettingPage: false,
          );
        }
      }
    } else {
      NewFeaturePopUpClass newFeature =
          NewFeaturePopUpClass(
            uuid: uuidGen(),
            oldNewFeatureMobile: '',
            numberViewed: 0,
            oldNewFeatureDesktop: '',
          );
      await insertNewFeature(newFeature);
    }
  }

  Future<void> viewPopUpAction() async {
    try {
      NewFeaturePopUpClass newFeature =
          getNewFeaturePopUp()!.copyWith();

      if (newFeature.numberViewed < 2) {
        newFeature.numberViewed++;
      } else {
        newFeature.oldNewFeatureMobile = appVersionMobile;
        newFeature.oldNewFeatureDesktop = appVersionDesktop;
        newFeature.numberViewed = 0;
      }
      await insertNewFeature(newFeature);
      await mainLocalLog(
        'New Feature View Success: Desktop Version: ${newFeature.oldNewFeatureDesktop} | Mobile Version: ${newFeature.oldNewFeatureMobile} | Viewed Number: ${newFeature.numberViewed}',
      );
    } catch (e) {
      await mainLocalLog(
        'Error Viewing New Feature: ${e.toString()}',
      );
    }
  }

  Future clearNewFeatures() async {
    await newFeaturePopUpBox.clear();
    await mainLocalLog('Offline New Feature Cleared');
  }
}
