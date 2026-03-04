import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

class ChannelLinkHandler {
  static final AppLinks _appLinks = AppLinks();

  static void init(BuildContext context) {
    _appLinks.uriLinkStream.listen((uri) {

      final segments = uri.pathSegments;

      if (segments.isEmpty) return;

      // ✅ PUBLIC CHANNEL
      if (segments.first == "c" && segments.length > 1) {
        Navigator.pushNamed(
          context,
          "/join",
          arguments: {
            "code": segments[1],
            "isPublic": true,
          },
        );
      }

      // ✅ PRIVATE CHANNEL
      if (segments.first == "invite" && segments.length > 1) {
        Navigator.pushNamed(
          context,
          "/join",
          arguments: {
            "code": segments[1],
            "isPublic": false,
          },
        );
      }
    });
  }
}