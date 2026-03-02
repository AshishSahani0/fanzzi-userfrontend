import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

class ChannelLinkHandler {
  static final AppLinks _appLinks = AppLinks();

  static void init(BuildContext context) {
    _appLinks.uriLinkStream.listen((uri) {
      final path = uri.path;

      if (path.startsWith("/c/")) {
        final slug = uri.pathSegments.last;
        Navigator.pushNamed(context, "/join", arguments: slug);
      }

      if (path.startsWith("/invite/")) {
        final token = uri.pathSegments.last;
        Navigator.pushNamed(context, "/join", arguments: token);
      }
    });
  }
}
