import 'package:url_launcher/url_launcher.dart';

class Utils{


static    Future<void> goToUrl(String url ) async {
      Uri _url = Uri.parse(url);
  if (!await launchUrl(_url)) {
    throw Exception('Could not launch $_url');
  }
}
      

}