const String kAppleAppGroupId = 'group.dmytrowidget';
const String iOSWidgetName = 'WeatherWidgets';
const String androidWidgetName = 'WeatherWidget';
const String developerDomain = 'turskyi.com';
const String developerUrl = 'https://$developerDomain';
const String kDomain = 'weather-fit.com';

const String kResendEmailDomain = kDomain;
const String supportEmail = 'support@$kDomain';
const String imagePath = 'assets/images/';
const String outfitImagePath = '${imagePath}outfits/';
const String kAppName = 'WeatherFit';
const String kAndroidPackageName = 'com.turskyi.weather_fit';
const String kDeviceMethodChannel = '$kAndroidPackageName/device';
const String kSharedContainerMethodChannel =
    '$kAndroidPackageName/shared_container';
const String kGooglePlayUrl =
    'https://play.google.com/store/apps/details?id=$kAndroidPackageName';
const String kAppStoreUrl =
    'https://apps.apple.com/ca/app/weatherfit/id6743688355';
const String itunesLookupUrl = 'https://itunes.apple.com/lookup?bundleId=';
const String developerName = 'Dmytro Turskyi';
const double appStoreBadgeHeight = 80.0;
const double appStoreBadgeWidth = 140.0;
const String countryFlagsBaseUrl =
    'https://open-meteo.com/images/country-flags/';
const String artistInstagramUrl = 'https://www.instagram.com/anartistart/';
const String telegramUrl = 'https://t.me/+J3nrwxVrxVE2MDdi';
const String developerSupportUrl = '$developerUrl/#/support';
const String mailToScheme = 'mailto';
const String subjectParameter = 'subject';
const String bodyParameter = 'body';
const String playStoreBadgePath = '${imagePath}play_store_badge.png';
const String appStoreBadgeAssetPath =
    '${imagePath}Download_on_the_App_Store_Badge.png';
const String feedbackTypeProperty = 'feedback_type';
const String feedbackTextProperty = 'feedback_text';
const String ratingProperty = 'rating';
const String screenSizeProperty = 'screenSize';
const String searchError = 'searchError';

/// Blur intensity constant.
const double blurSigma = 8;

const String doNotReplySenderName = 'Do Not Reply';
const String feedbackEmailSender =
    '$doNotReplySenderName $kAppName <no-reply@$kResendEmailDomain>';
const String feedbackScreenshotFileName = 'feedback.png';

const String remoteOutfitBaseUrl =
    'https://raw.githubusercontent.com/Turskyi/weather_fit/refs/heads/master/outfits/';

/// The minimum width threshold to switch to a multi-column layout on
/// Web/Desktop.
const double kWideLayoutBreakpoint = 1000.0;

/// Shared logical-pixel size threshold for Wear compact layouts.
/// XL Watch emulator shortest side is 240dp, so Wear-specific layouts should
/// still activate at this size.
const double kWearCompactLayoutSize = 240.0;

const String kMacOSLocationServicesSettingsUrl =
    'x-apple.systempreferences:com.apple.preference.security?'
    'Privacy_LocationServices';

const int kIosDefaultMinutesFrequency = 180;
const int kAndroidDefaultMinutesFrequency = 120;
const String kBackgroundUniqueName = 'weatherfit_background_update';
const String kBackgroundTaskName = 'updateWidgetTask';
