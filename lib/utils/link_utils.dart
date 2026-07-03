import 'package:flutter/material.dart';

class LinkUtils {
  static bool isEmailLink(String link) {
    return link.startsWith('mailto:') ||
        (!link.startsWith('http') &&
            link.contains('@') &&
            link.contains('.'));
  }

  static String normalizeLink(String link) {
    if (isEmailLink(link) && !link.startsWith('mailto:')) {
      return 'mailto:$link';
    }
    return link;
  }

  static String displayLink(String link) {
    return link.replaceFirst('mailto:', '');
  }

  static IconData linkIcon(String link) {
    if (isEmailLink(link)) {
      return Icons.email_outlined;
    }
    if (link.contains('drive.google.com') ||
        link.contains('docs.google.com')) {
      return Icons.folder_outlined;
    }
    if (link.contains('github.com')) {
      return Icons.code;
    }
    return Icons.link;
  }

  static String linkLabel(String link) {
    if (isEmailLink(link)) {
      return 'EMAIL APPLICATION';
    }
    if (link.contains('drive.google.com')) {
      return 'GOOGLE DRIVE';
    }
    if (link.contains('docs.google.com')) {
      return 'GOOGLE DOCS';
    }
    return 'APPLICATION LINK';
  }
}
