import 'package:url_launcher/url_launcher.dart';

void openWhatsApp() async {
  final phone = '2347048507587'; // your number
  final message = Uri.encodeComponent(
    "Hello, Stockall Solutions; ",
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
    path: '+2347048507587',
  );
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch +2347048507587';
  }
}

bool isValidEmail(String email) {
  final emailRegex = RegExp(
    r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
  );
  return emailRegex.hasMatch(email);
}
