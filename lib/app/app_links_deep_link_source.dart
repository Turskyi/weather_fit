import 'package:app_links/app_links.dart';
import 'package:weather_fit/app/deep_link_source.dart';

class AppLinksDeepLinkSource implements DeepLinkSource {
  AppLinksDeepLinkSource({AppLinks? appLinks})
    : _appLinks = appLinks ?? AppLinks();

  final AppLinks _appLinks;

  @override
  Stream<Uri> get uriLinkStream {
    return _appLinks.uriLinkStream;
  }

  @override
  Future<Uri?> getInitialLink() {
    return _appLinks.getInitialLink();
  }
}
