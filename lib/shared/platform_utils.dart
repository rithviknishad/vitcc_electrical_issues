import 'package:flutter/foundation.dart';

/// Whether the app is running in web in iOS / Android.
final isWebMobile = kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android);

/// Whether the app is running in web in Desktop.
final isWebDesktop = kIsWeb &&
    !(defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android);
