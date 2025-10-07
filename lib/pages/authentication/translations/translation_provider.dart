import 'package:flutter/material.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/translations/general.dart';

class TranslationProvider extends ChangeNotifier {
  String shopLanguage(BuildContext context) {
    return returnShopProvider(context).userShop!.language!;
  }

  String cancelText(BuildContext context) {
    if (shopLanguage(context) == 'ar') {
      return GeneralAr().cancelText;
    } else if (shopLanguage(context) == 'fr') {
      return GeneralFr().cancelText;
    } else if (shopLanguage(context) == 'esp') {
      return GeneralEs().cancelText;
    } else {
      return General().cancelText;
    }
  }

  String loadingText(BuildContext context) {
    if (shopLanguage(context) == 'ar') {
      return GeneralAr().loadingText;
    } else if (shopLanguage(context) == 'fr') {
      return GeneralFr().loadingText;
    } else if (shopLanguage(context) == 'esp') {
      return GeneralEs().loadingText;
    } else {
      return General().loadingText;
    }
  }

  String areYouSure(BuildContext context) {
    if (shopLanguage(context) == 'ar') {
      return GeneralAr().areYouSure;
    } else if (shopLanguage(context) == 'fr') {
      return GeneralFr().areYouSure;
    } else if (shopLanguage(context) == 'esp') {
      return GeneralEs().areYouSure;
    } else {
      return General().areYouSure;
    }
  }

  String proceed(BuildContext context) {
    if (shopLanguage(context) == 'ar') {
      return GeneralAr().proceed;
    } else if (shopLanguage(context) == 'fr') {
      return GeneralFr().proceed;
    } else if (shopLanguage(context) == 'esp') {
      return GeneralEs().proceed;
    } else {
      return General().proceed;
    }
  }

  String emptyFields(BuildContext context) {
    if (shopLanguage(context) == 'ar') {
      return GeneralAr().emptyFields;
    } else if (shopLanguage(context) == 'fr') {
      return GeneralFr().emptyFields;
    } else if (shopLanguage(context) == 'esp') {
      return GeneralEs().emptyFields;
    } else {
      return General().emptyFields;
    }
  }

  String emailIsBadlyFormatted(BuildContext context) {
    if (shopLanguage(context) == 'ar') {
      return GeneralAr().emailIsBadlyFormatted;
    } else if (shopLanguage(context) == 'fr') {
      return GeneralFr().emailIsBadlyFormatted;
    } else if (shopLanguage(context) == 'esp') {
      return GeneralEs().emailIsBadlyFormatted;
    } else {
      return General().emailIsBadlyFormatted;
    }
  }

  String invalidEmail(BuildContext context) {
    if (shopLanguage(context) == 'ar') {
      return GeneralAr().invalidEmail;
    } else if (shopLanguage(context) == 'fr') {
      return GeneralFr().invalidEmail;
    } else if (shopLanguage(context) == 'esp') {
      return GeneralEs().invalidEmail;
    } else {
      return General().invalidEmail;
    }
  }

  String emailAddress(BuildContext context) {
    if (shopLanguage(context) == 'ar') {
      return GeneralAr().emailAddress;
    } else if (shopLanguage(context) == 'fr') {
      return GeneralFr().emailAddress;
    } else if (shopLanguage(context) == 'esp') {
      return GeneralEs().emailAddress;
    } else {
      return General().emailAddress;
    }
  }

  String enterEmail(BuildContext context) {
    if (shopLanguage(context) == 'ar') {
      return GeneralAr().enterEmail;
    } else if (shopLanguage(context) == 'fr') {
      return GeneralFr().enterEmail;
    } else if (shopLanguage(context) == 'esp') {
      return GeneralEs().enterEmail;
    } else {
      return General().enterEmail;
    }
  }

  String password(BuildContext context) {
    if (shopLanguage(context) == 'ar') {
      return GeneralAr().password;
    } else if (shopLanguage(context) == 'fr') {
      return GeneralFr().password;
    } else if (shopLanguage(context) == 'esp') {
      return GeneralEs().password;
    } else {
      return General().password;
    }
  }

  String email(BuildContext context) {
    if (shopLanguage(context) == 'ar') {
      return GeneralAr().email;
    } else if (shopLanguage(context) == 'fr') {
      return GeneralFr().email;
    } else if (shopLanguage(context) == 'esp') {
      return GeneralEs().email;
    } else {
      return General().email;
    }
  }

  String enterPassword(BuildContext context) {
    if (shopLanguage(context) == 'ar') {
      return GeneralAr().enterPassword;
    } else if (shopLanguage(context) == 'fr') {
      return GeneralFr().enterPassword;
    } else if (shopLanguage(context) == 'esp') {
      return GeneralEs().enterPassword;
    } else {
      return General().enterPassword;
    }
  }

  String login(BuildContext context) {
    if (shopLanguage(context) == 'ar') {
      return GeneralAr().login;
    } else if (shopLanguage(context) == 'fr') {
      return GeneralFr().login;
    } else if (shopLanguage(context) == 'esp') {
      return GeneralEs().login;
    } else {
      return General().login;
    }
  }

  String noInternetConnection(BuildContext context) {
    if (shopLanguage(context) == 'ar') {
      return GeneralAr().noInternetConnection;
    } else if (shopLanguage(context) == 'fr') {
      return GeneralFr().noInternetConnection;
    } else if (shopLanguage(context) == 'esp') {
      return GeneralEs().noInternetConnection;
    } else {
      return General().noInternetConnection;
    }
  }

  String authenticationError(BuildContext context) {
    if (shopLanguage(context) == 'ar') {
      return GeneralAr().authenticationError;
    } else if (shopLanguage(context) == 'fr') {
      return GeneralFr().authenticationError;
    } else if (shopLanguage(context) == 'esp') {
      return GeneralEs().authenticationError;
    } else {
      return General().authenticationError;
    }
  }

  String invalidEmailOrPassword(BuildContext context) {
    if (shopLanguage(context) == 'ar') {
      return GeneralAr().invalidEmailOrPassword;
    } else if (shopLanguage(context) == 'fr') {
      return GeneralFr().invalidEmailOrPassword;
    } else if (shopLanguage(context) == 'esp') {
      return GeneralEs().invalidEmailOrPassword;
    } else {
      return General().invalidEmailOrPassword;
    }
  }

  String anErrorOccured(BuildContext context) {
    if (shopLanguage(context) == 'ar') {
      return GeneralAr().anErrorOccured;
    } else if (shopLanguage(context) == 'fr') {
      return GeneralFr().anErrorOccured;
    } else if (shopLanguage(context) == 'esp') {
      return GeneralEs().anErrorOccured;
    } else {
      return General().anErrorOccured;
    }
  }

  String unexpectedError(BuildContext context) {
    if (shopLanguage(context) == 'ar') {
      return GeneralAr().unexpectedError;
    } else if (shopLanguage(context) == 'fr') {
      return GeneralFr().unexpectedError;
    } else if (shopLanguage(context) == 'esp') {
      return GeneralEs().unexpectedError;
    } else {
      return General().unexpectedError;
    }
  }

  String userNotFound(BuildContext context) {
    if (shopLanguage(context) == 'ar') {
      return GeneralAr().userNotFound;
    } else if (shopLanguage(context) == 'fr') {
      return GeneralFr().userNotFound;
    } else if (shopLanguage(context) == 'esp') {
      return GeneralEs().userNotFound;
    } else {
      return General().userNotFound;
    }
  }

  String anErrorOccuredOnTheServer(BuildContext context) {
    if (shopLanguage(context) == 'ar') {
      return GeneralAr().anErrorOccuredOnTheServer;
    } else if (shopLanguage(context) == 'fr') {
      return GeneralFr().anErrorOccuredOnTheServer;
    } else if (shopLanguage(context) == 'esp') {
      return GeneralEs().anErrorOccuredOnTheServer;
    } else {
      return General().anErrorOccuredOnTheServer;
    }
  }

  String welcomeBack(BuildContext context) {
    if (shopLanguage(context) == 'ar') {
      return GeneralAr().welcomeBack;
    } else if (shopLanguage(context) == 'fr') {
      return GeneralFr().welcomeBack;
    } else if (shopLanguage(context) == 'esp') {
      return GeneralEs().welcomeBack;
    } else {
      return General().welcomeBack;
    }
  }

  String welcome(BuildContext context) {
    if (shopLanguage(context) == 'ar') {
      return GeneralAr().welcome;
    } else if (shopLanguage(context) == 'fr') {
      return GeneralFr().welcome;
    } else if (shopLanguage(context) == 'esp') {
      return GeneralEs().welcome;
    } else {
      return General().welcome;
    }
  }

  String successfully(BuildContext context) {
    if (shopLanguage(context) == 'ar') {
      return GeneralAr().successfully;
    } else if (shopLanguage(context) == 'fr') {
      return GeneralFr().successfully;
    } else if (shopLanguage(context) == 'esp') {
      return GeneralEs().successfully;
    } else {
      return General().successfully;
    }
  }
}
