import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class UrlLauncherService {
  
  /// Make a phone call
  static Future<void> makePhoneCall(String phoneNumber) async {
    try {
      // Try direct call first
      bool? res = await FlutterPhoneDirectCaller.callNumber(phoneNumber);
      if (res != true) {
        // Fallback to standard launcher if direct call fails/returns false
        final Uri launchUri = Uri(
          scheme: 'tel',
          path: phoneNumber,
        );
        if (await canLaunchUrl(launchUri)) {
          await launchUrl(launchUri);
        } else {
          debugPrint("Could not launch phone call to $phoneNumber");
        }
      }
    } catch (e) {
      debugPrint("Error launching phone call: $e");
      // Fallback attempt in case of error
      try {
        final Uri launchUri = Uri(
          scheme: 'tel',
          path: phoneNumber,
        );
        if (await canLaunchUrl(launchUri)) {
          await launchUrl(launchUri);
        }
      } catch (e2) {
        debugPrint("Fallback error: $e2");
      }
    }
  }

  /// Send an SMS
  static Future<void> sendSms(String phoneNumber, {String body = ''}) async {
    final Uri launchUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: body.isNotEmpty ? {'body': body} : null,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        debugPrint("Could not launch SMS to $phoneNumber");
      }
    } catch (e) {
      debugPrint("Error launching SMS: $e");
    }
  }

  /// Open a web URL
  static Future<void> openLink(String url) async {
    final Uri launchUri = Uri.parse(url);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint("Could not launch URL: $url");
      }
    } catch (e) {
      debugPrint("Error launching URL: $e");
    }
  }
}
