const String mobileNumberExtension = '267';
const String apiHomeUrl = 'https://bonako.telcoflo.dev/api/v1';  //  'http://41.190.244.101/api/v1';  //  'http://167.99.252.212/api/v1'; // 'http://165.232.179.255/api/v1'; //  
const String errorDebugMessage = 'Make sure you have an internet connection (WIFI) or mobile data, otherwise try closing and reopening this mobile app. If the issue continues, then search for an update of this mobile app on the Google Play Store and Apple App Store. \n\nSorry for the inconvinience :(';

/// OpenAI API URL
const String openaiApiUrl = 'https://api.openai.com/v1/chat/completions';

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