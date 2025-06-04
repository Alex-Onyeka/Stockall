import 'package:url_launcher/url_launcher.dart';

void openWhatsApp() async {
  final phone = '2347036301628'; // your number
  final message = Uri.encodeComponent(
    "Hello, Please I want to enquire about: ",
  );
  final url = 'https://wa.me/$phone?text=$message';

  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  } else {
    print('Could not launch $url');
  }
}

void phoneCall() async {
  final Uri uri = Uri(
    scheme: 'tel',
    path: '+2347036301628',
  );
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch +2347036301628';
  }
}
