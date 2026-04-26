const String kAppleAppGroupId = 'group.dmytrowidget';
const String kIosWidgetName = 'WeatherWidgets';
const String kAndroidWidgetName = 'WeatherWidget';
const String kDeveloperDomain = 'turskyi.com';
const String kDeveloperUrl = 'https://$kDeveloperDomain';
const String kDomain = 'weather-fit.com';

const String kResendEmailDomain = kDomain;
const String kSupportEmail = 'support@$kDomain';
const String kImagePath = 'assets/images/';
const String kOutfitImagePath = '${kImagePath}outfits/';
const String kAppName = 'WeatherFit';
const String kAndroidPackageName = 'com.turskyi.weather_fit';
const String kQualifiedAndroidWidgetName =
    '$kAndroidPackageName.$kAndroidWidgetName';
const String kDeviceMethodChannel = '$kAndroidPackageName/device';
const String kSharedContainerMethodChannel =
    '$kAndroidPackageName/shared_container';
const String kGooglePlayUrl =
    'https://play.google.com/store/apps/details?id=$kAndroidPackageName';
const String kAppStoreUrl =
    'https://apps.apple.com/ca/app/weatherfit/id6743688355';
const String kItunesLookupUrl = 'https://itunes.apple.com/lookup?bundleId=';
const String kDeveloperName = 'Dmytro Turskyi';
const double kAppStoreBadgeHeight = 80.0;
const double kAppStoreBadgeWidth = 140.0;
const double kPageArrowBackgroundAlpha = 0.44;
const double kPageArrowIconAlpha = 0.54;
const String kCountryFlagsBaseUrl =
    'https://open-meteo.com/images/country-flags/';
const String kArtistInstagramUrl = 'https://www.instagram.com/anartistart/';
const String kTelegramUrl = 'https://t.me/+J3nrwxVrxVE2MDdi';
const String kDeveloperSupportUrl = '$kDeveloperUrl/#/support';
const String kMailToScheme = 'mailto';
const String kSubjectParameter = 'subject';
const String kBodyParameter = 'body';
const String kPlayStoreBadgePath = '${kImagePath}play_store_badge.png';
const String kAppStoreBadgeAssetPath =
    '${kImagePath}Download_on_the_App_Store_Badge.png';
const String kFeedbackTypeProperty = 'feedback_type';
const String kFeedbackTextProperty = 'feedback_text';
const String kRatingProperty = 'rating';
const String kScreenSizeProperty = 'screenSize';
const String kSearchError = 'searchError';

/// Blur intensity constant.
const double kBlurSigma = 8;
const double kBlurSigmaSmall = 1;

const String kDoNotReplySenderName = 'Do Not Reply';
const String kFeedbackEmailSender =
    '$kDoNotReplySenderName $kAppName <no-reply@$kResendEmailDomain>';
const String kFeedbackScreenshotFileName = 'feedback.png';

const String kRemoteOutfitBaseUrl =
    'https://raw.githubusercontent.com/Turskyi/weather_fit/refs/heads/master/outfits/';

/// The minimum width threshold to switch to a multi-column layout on
/// Web/Desktop.
const double kWideLayoutBreakpoint = 1000.0;

/// Shared logical-pixel size threshold for Wear compact layouts.
/// XL Watch emulator shortest side is 240dp, so Wear-specific layouts should
/// still activate at this size.
const double kWearCompactLayoutSize = 244.0;

const String kMacOSLocationServicesSettingsUrl =
    'x-apple.systempreferences:com.apple.preference.security?'
    'Privacy_LocationServices';

const int kIosDefaultMinutesFrequency = 180;
const int kAndroidDefaultMinutesFrequency = 120;
const String kBackgroundUniqueName = 'weatherfit_background_update';
const String kBackgroundTaskName = 'updateWidgetTask';

const String kWeatherFitScheme = 'weatherfit';
const String kWeatherFitHost = 'open';
const String kDebugWeatherProviderKey = 'debug_weather_provider_openweathermap';
const String kOpenRemoteInputMethod = 'openRemoteInput';
