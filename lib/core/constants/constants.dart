import 'package:flutter/material.dart';

const String appName = 'Perfect Order';
const String mobileNumberExtension = '267';
const String appAiName = 'Perfect Assistant';
const String apiHomeUrl = 'http://127.0.0.1:8000/api/v1'; //  'https://bonako.telcoflo.dev/api/v1'; 
const String errorDebugMessage = 'Try closing and reopening this mobile app. If the issue continues, then search for an update of this mobile app on the Google Play Store or Apple App Store.';

/// Seven colors
List<Color> rainbowColors = const [
  Color(0xFFFF1D7E), // Pink
  Color(0xFFFF831C), // Orange
  Color(0xFFFFC110), // Yellow
  Color(0xFF2BCBFC), // Light Blue
  Color(0xFFA460F0), // Purple
  Color(0xFFEA70FF), // Magenta
  Color(0xFFFF1D7E), // Pink (repeated to complete the circle)
];

/// The maximum number of adverts that each store can have
const maximumAdvertsPerStore = 5;

/// The maximum number of products that each store can have
const maximumProductsPerStore = 5;

/// The minimum number of products that each store can preview
const minimumProductsPerStoreOnPreview = 2;

/// The currency symbol
const currencySymbol = 'P';

/// Pusher configurations
const pusherWSPort = 6001;
const pusherCluster = "eu";
const pusherAppId = "1632353";
const pusherHostName = apiHomeUrl;
const pusherKey = "52e318a79b75dd4dc78c";
const pusherSecret = "ae3936577e5d8767874a";
const pusherAuthHostName = '$apiHomeUrl/broadcasting/auth';