import 'package:flutter/material.dart';

const String appName = 'Perfect Order';
const String mobileNumberExtension = '267';
const String appAiName = 'Perfect Assistant';
const String errorDebugMessage = 'Try closing and reopening this mobile app. If the issue continues, then search for an update of this mobile app on the Google Play Store or Apple App Store.';

/// ANDROID SIMULATOR IMPORTANT NOTE:
/// ---------------------------------
/// Whenever we run the application using the Android simulator, we cannot run the 
/// Android simulator while the API host is running on http://127.0.0.1:8000. We
/// should run the API on our local machine IP address. This means we need to
/// find out local machine IP address and serve our API over this IP address. 
/// We can get this IP address by following this articles:
/// 
/// Macbook: https://www.security.org/vpn/find-mac-ip-address/
/// Windows: https://networking.grok.lsu.edu/article.aspx?articleid=14842
/// 
/// After getting the local machine IP address e.g "192.168.88.5", we need to
/// then run the local application API using this specified IP Address. This
/// means that instead of running:
/// 
/// [php artisan serve]
/// 
/// We should run:
/// 
/// [php artisan serve --host=192.168.88.5 --port=8000]
/// 
/// This allows our application to run on port 8000 of our local machine allowing
/// our API to tbe discoverable by the Android simulator. We should then make
/// sure that we update this constants.dart file "apiHomeUrl" to match the
/// same e.g
/// 
/// apiHomeUrl = 'http://192.168.88.5:8000/api/v1';
/// 
/// We can also run:
/// 
/// php artisan serve --host=$(ipconfig getifaddr en0) --port=8000
/// 
/// where $(ipconfig getifaddr en0) will return the current IP Address 
/// that is being used at that given point in time.
/// 
/// For the IOS simulator, it doesn't matter if we run  the API over the localhost
/// ip address which is http://127.0.0.1:8000.
/// ------------------------------------------------------------------------------

const String apiHomeUrl = 'https://app.perfectorderbotswana.com/api/v1'; //  'http://bonako.telcoflo.dev/api/v1';  //  'http://105.235.242.226/api/v1';  //  'http://192.168.5.3:8000/api/v1'; //  'http://127.0.0.1:8000/api/v1'; //  

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

/// OneSignal configurations
const oneSignalApiKey = "3ebd1384-b5ac-4214-818f-e2f36c4733c0";