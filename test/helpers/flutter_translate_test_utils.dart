import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mock translation data for tests.
const Map<String, Object?> _enTestTranslations = <String, Object?>{
  'title': 'WeatherFit',
  'submit': 'Submit',
  'app_id': 'App id',
  'app_version': 'App version',
  'build_number': 'Build number',
  'app_description':
      '«WeatherFit» helps you dress for the weather with carefully crafted '
      'outfit suggestions. Just enter a location, and the app will show '
      'you the current forecast along with a visual and text-based '
      'recommendation on what to wear.',
  'features': 'Features',
  'artwork': 'Artwork',
  'anna_turska': 'Anna Turska',
  'support_and_feedback': 'Support & Feedback',
  'telegram_group': 'Telegram Support Group',
  'developer_contact_form': 'Developer Contact Form',
  'privacy_policy': 'Privacy Policy',
  'last_updated': 'Last updated',
  'for': 'for',
  'android_app': 'Android Application',
  'location': 'Location Data',
  'third_party': 'Third-Party Services',
  'consent': 'Consent',
  'children_privacy': "Children's Privacy",
  'crashlytics': 'Crashlytics',
  'ai_content': 'AI-Generated Content',
  'updates_and_notifications': 'Updates and Notification',
  'contact_us': 'Contact Us',
  'platform_specific': 'Platform-Specific Features',
  'mobile': 'Mobile (Android/iOS)',
  'macos': 'macOS',
  'web': 'Web',
  'image_attribution_and_rights_title': 'Image Attribution & Rights',
  'never_updated': 'Never updated',
  'lat': 'Lat',
  'lon': 'Lon',
  'could_not_launch': 'Could not launch',
  'faq': 'Frequently Asked Questions',
  'legal_and_app_info_title': '📄 Legal & App Info',
  'developer': 'Developer',
  'developer_name': 'Dmytro Turskyi',
  'email': 'Email',
  'last_updated_on_label': 'Last Updated on',
  'no': 'No',
  'yes': 'Yes',
  'cancel': 'Cancel',
  'ukrainian': 'Ukrainian',
  'english': 'English',
  'en': 'EN',
  'uk': 'UK',
  'explore_weather_prompt': "Let's explore the weather! ",
  'platform': 'Platform',
  'android': 'Android',
  'ios': 'iOS',
  'windows': 'Windows',
  'linux': 'Linux',
  'unknown': 'Unknown',
  'feedback': <String, String>{
    'title': 'Feedback',
    'app_feedback': 'App Feedback',
    'what_kind': 'What kind of feedback do you want to give?',
    'what_is_your_feedback': 'What is your feedback?',
    'how_does_this_feel': 'How does this make you feel?',
    'sent': 'Your feedback has been sent successfully!',
    'bug_report': 'Bug report',
    'feature_request': 'Feature request',
    'type': 'Feedback Type',
    'rating': 'Rating',
    'bad': 'Bad',
    'neutral': 'Neutral',
    'good': 'Good',
  },
  'error': <String, String>{
    'please_check_internet':
        'An error occurred. Please check your internet connection and try '
        'again.',
    'unexpected_error': 'An unexpected error occurred. Please try again.',
    'oops': 'Oops! Something went wrong. Please try again later.',
    'cors':
        'Error: Local Environment Setup Required\nTo run this application '
        'locally on web, please use the following command:\nflutter run -d '
        'chrome --web-browser-flag "--disable-web-security"\nThis step is '
        'necessary to bypass CORS restrictions during local development. '
        'Please note that this flag should only be used in a development '
        'environment and never in production.',
    'launch_email_or_support_page': 'Could not launch email or support page.',
    'something_went_wrong': 'Something went wrong!',
    'searching_location': 'Error searching for location',
    'location_permission_denied': 'Location permissions are denied',
    'location_permission_permanently_denied_cannot_request':
        'Location permissions are permanently denied, we cannot request '
        'permissions.',
    'getting_weather_generic':
        'Could not get weather information. Please try again.',
    'launch_email_app_to_address':
        'Could not launch email app to send an email to {emailAddress}',
    'launch_email_failed': 'Could not launch the email application.',
    'save_asset_image_failed': 'Failed to save image to device storage',
  },
  'settings': <String, String>{
    'title': 'Settings',
    'language': 'Language',
    'temperature_units': 'Temperature Units',
    'temperature_units_subtitle_metric':
        'Use metric measurements for temperature units.',
    'temperature_units_subtitle_imperial':
        'Use imperial measurements for temperature units.',
    'about_app_subtitle': 'Learn more about «WeatherFit».',
    'feedback_subtitle':
        'Let us know your thoughts and suggestions. You can also report any '
        'issues with the app’s content.',
    'support_subtitle':
        'Visit our support page for help and frequently asked questions.',
  },
  'search': <String, String>{
    'city_or_country': 'City or country',
    'enter_location': 'Enter location',
    'enter_city_or_country': 'Enter city or country',
    'page_semantics_label': 'City or country search page',
    'page_app_bar_title': 'City or country search',
    'instructions':
        'Type the city or country name and tap "Submit" to see the weather.',
    'confirm_location_dialog_title': 'Is this your location?',
    'label': 'Search',
    'use_current_location_dialog_title': 'Use your current location?',
    'location_not_found_use_current_dialog_content':
        "We couldn't find the correct location. Would you like to use your "
        'current location instead?',
  },
  'about': <String, String>{
    'title': 'About',
    'feature_outfit_suggestions': '• Outfit suggestions based on weather',
    'feature_location_forecast': '• Location-based weather forecast',
    'feature_location_support_web':
        '• Approximate location support (browser permission required)',
    'feature_location_support_macos':
        '• Approximate location support (location permission required)',
    'feature_location_support_default':
        '• Approximate location support (no GPS required)',
    'feature_privacy_friendly': '• Privacy-friendly (no tracking, no accounts)',
    'feature_home_widgets': '• Home screen widgets for mobile devices',
    'outfit_illustrations_in': 'The outfit illustrations in',
    'were_created_by': 'were hand-drawn by artist',
    'artwork_artist_outro':
        ', whose style brings charm and personality to the app. In addition to '
        'being a talented illustrator, Anna is a professionally trained '
        'fashion designer. Every outfit reflects not just artistic vision '
        'but also real-world styling expertise - like receiving fashion '
        'guidance from a qualified stylist, built right into the app.',
    'privacy_title': 'Privacy & Data',
    'privacy_description':
        '«{appName}» does not collect or store any personal data. Your '
        'approximate location is used only to show the local weather and '
        'is never shared. Outfit suggestions are generated on-device based '
        'on the weather conditions. You can read the full privacy policy '
        'below.',
    'view_privacy_policy': 'View Privacy Policy',
    'support_description':
        'Having trouble? Need help or want to suggest a feature? Join the '
        'community or contact the developer directly.',
    'contact_support': 'Contact Support',
  },
  'privacy': <String, String>{
    'policy_intro':
        "Your privacy is important to us. It is {appName}'s policy to respect "
        'your privacy and comply with any applicable law and regulation '
        'regarding any personal information we may collect about you, '
        'including across our app, «{appName}», and its associated '
        'services.',
    'information_we_collect': 'Information We Collect',
    'no_personal_data_collection':
        'We do not collect any personal information such as name, email '
        'address, or phone number.',
    'location_access_request':
        "«{appName}» may optionally request access to your device's "
        'approximate location (coarse location). This access is only '
        'requested if the app cannot automatically determine your location '
        'based on your entered city name. You will be asked to grant '
        'permission before the app attempts to access your location.',
    'location_data_usage':
        'If you grant location permission, this data is used locally within '
        'the app to help find relevant weather information for your '
        'current location. This location data is not stored or transmitted '
        'anywhere outside of your device and is used only temporarily to '
        'find your current location. After finding weather for current '
        'location it is discarded. You can choose not to provide your '
        'location, in which case you can continue using the app by '
        'manually entering your city name.',
    'third_party_services_info':
        '«{appName}» uses third-party services that may collect information '
        'used to identify you. These services include Firebase Crashlytics '
        'and Google Analytics. The data collected by these services is '
        'used to improve app stability and user experience. You can find '
        'more information about their privacy practices at their '
        'respective websites.',
    'consent_agreement':
        'By using our services, you consent to the collection and use of your '
        'information as described in this privacy policy.',
    'security_measures': 'Security Measures',
    'security_measures_description':
        'We take reasonable measures to protect your information from '
        'unauthorized access, disclosure, or modification.',
    'children_description':
        'Our services are not directed towards children under the age of '
        '{age}. We do not knowingly collect personal information from '
        'children under {age}. While we strive to minimize data '
        'collection, third-party services we use (such as Firebase '
        'Crashlytics and Google Analytics) may collect some data. However, '
        'this data is collected anonymously and is not linked to any '
        'personal information. If you believe that a child under {age} has '
        'provided us with personal information, please contact us, and we '
        'will investigate the matter.',
    'crashlytics_description':
        '«{appName}» uses Firebase Crashlytics, a service by Google, to '
        'collect crash reports anonymously to help us improve app '
        'stability and fix bugs. The data collected by Crashlytics does '
        'not include any personal information.',
    'ai_content_description':
        '«{appName}» no longer uses artificial intelligence (AI) to generate '
        'outfit images in real time. Instead, all images are now pre-drawn '
        'and bundled with the app. While some images may have been '
        'assisted by AI tools during the design process, no user data is '
        'sent to external AI services during usage.\n\nIf you have '
        'concerns or wish to provide feedback on any content, please use '
        'the "Feedback" option in the app’s settings.',
    'outfit_illustrations_created_by': 'Outfit illustrations were created by',
    'artwork_creation_method':
        ', using a mix of hand-drawn elements and AI tools.',
    'updates_and_notifications_description':
        'This privacy policy may be updated periodically. Any changes to the '
        'policy will be communicated to you through app updates or '
        'notifications.',
    'contact_us_invitation':
        'For any questions or concerns regarding your privacy, you may contact '
        'us using the following details:',
    'platform_specific_intro':
        '«{appName}» offers different features depending on the platform you '
        'are using (mobile, macOS, or web). Please note the following '
        'platform-specific details:',
    'platform_mobile_description':
        'On mobile devices, «{appName}» provides visual outfit recommendations '
        'based on current weather conditions. These images are not '
        'generated in real time by AI, but instead are pre-drawn and '
        'stored locally within the app. No weather or user data is sent to '
        'external services to generate these outfits.',
    'platform_macos_description':
        'On macOS, the app uses approximate location (with permission) to '
        'provide local weather and corresponding outfit recommendations, '
        'similar to mobile.',
    'platform_image_generation_explanation':
        'On mobile and desktop platforms, outfit images are not generated in '
        'real time using AI. Instead, they are pre-drawn illustrations '
        'bundled with the app. Some of these assets may have been '
        'initially drafted or refined with the help of AI tools during the '
        'creative process, but no user data is shared with AI services '
        'during app usage.',
    'platform_web_description':
        'On the web, «{appName}» displays both text and visual outfit '
        'recommendations, just like on mobile and desktop platforms. '
        'However, home screen widgets are not available on the web due to '
        'current technical limitations.',
    'image_attribution_and_rights_description':
        'All outfit illustrations in «{appName}» were created and edited by '
        'artist Anna Turska, using a combination of original design work '
        'and AI-assisted drafts (e.g., Bing Image Creator). These images '
        'are bundled with the app and not fetched from any external source '
        'during use. All rights to the final images are reserved by the '
        'developer.',
  },
  'support': <String, String>{
    'title': 'Support',
    'intro_line':
        'Need help or want to give feedback? You’re in the right place.',
    'faq_hourly_forecast_q': '• Why is there no hourly forecast?',
    'faq_hourly_forecast_a':
        'Hourly weather is currently not supported, but may be added in the '
        'future.',
    'faq_change_location_q': '• Can I change my location later?',
    'faq_change_location_a':
        'Yes, the app lets you confirm and update your location during use.',
    'faq_theme_change_q': '• Why does the theme change at night?',
    'faq_theme_change_a':
        'The app automatically switches to a moon-themed dark mode at '
        'night. You can adjust day/night start times in Settings.',
    'contact_intro': 'If you’re experiencing issues or have suggestions:',
    'contact_us_via_email_button': 'Contact Us via Email',
    'join_telegram_support_button': 'Join Telegram Support Group',
    'visit_developer_support_website_button':
        "Visit Support Page on Developer's Website",
    'email_default_body': 'Hi, I need help with...',
  },
  'weather': <String, String>{
    'check_latest_button': 'Check Latest Weather',
    'code_0': 'Clear sky',
    'code_1': 'Mainly clear',
    'code_2': 'Partly cloudy',
    'code_3': 'Overcast',
    'code_45': 'Fog',
    'code_48': 'Depositing rime fog',
    'code_51': 'Light drizzle',
    'code_53': 'Moderate drizzle',
    'code_55': 'Dense drizzle',
    'code_56': 'Light freezing drizzle',
    'code_57': 'Dense freezing drizzle',
    'code_61': 'Slight rain',
    'code_63': 'Moderate rain',
    'code_65': 'Heavy rain',
    'code_66': 'Light freezing rain',
    'code_67': 'Heavy freezing rain',
    'code_71': 'Slight snow fall',
    'code_73': 'Moderate snow fall',
    'code_75': 'Heavy snow fall',
    'code_77': 'Snow grains',
    'code_80': 'Slight rain showers',
    'code_81': 'Moderate rain showers',
    'code_82': 'Violent rain showers',
    'code_85': 'Slight snow showers',
    'code_86': 'Heavy snow showers',
    'code_95': 'Thunderstorm',
    'code_96': 'Thunderstorm with slight hail',
    'code_99': 'Thunderstorm with heavy hail',
    'code_unknown': 'Unknown weather',
    'empty_search_prompt': 'Tap 🔍 to search for a city or country.',
    'loading_weather': 'Loading Weather',
  },
  'outfit': <String, String>{
    'oops': '🛑 Oops! No outfit suggestion available.',
    'could_not_pick': '🤷 Looks like we couldn’t pick an outfit this time.',
    'mix_and_match':
        '🎨 No recommendation? Time to mix & match your own style!',
    'fashion_instincts': '✨ Your fashion instincts take the lead today!',
    'pajama_day': '😴 No outfit picked—maybe today is a pajama day?',
    'unavailable_short': '👕 No outfit available.',
    'no_recommendation_short': '🚫 no recommendation.',
    'rainy': "🌧️\nIt's rainy! Consider wearing a waterproof jacket and boots.",
    'snowy':
        "❄️\nIt's snowy! Dress warmly with a heavy coat, hat, gloves, and "
        'scarf.',
    'cold':
        "🥶\nIt's cold! Wear a warm jacket, sweater, and consider a hat and "
        'gloves.',
    'cool': "🧥\nIt's cool. A light jacket or sweater should be comfortable.",
    'warm':
        "👕\nIt's warm. Shorts, t-shirts, and light dresses are great options.",
    'hot':
        "☀️\nIt's hot! Wear light, breathable clothing like tank tops and "
        'shorts.',
    'moderate':
        '🌤️\nThe weather is moderate. You can wear a variety of outfits.',
  },
};

const Map<String, Object?> _ukTestTranslations = <String, Object?>{
  'title': 'WeatherFit',
  'submit': 'Відправити',
  'app_id': 'Ідентифікатор програми',
  'app_version': 'Версія програми',
  'build_number': 'Номер збірки',
  'app_description':
      '«WeatherFit» допоможе вам одягнутися по погоді за '
      'допомогою ретельно підібраних рекомендацій щодо одягу. Просто введіть '
      'місцезнаходження, і програма покаже поточний прогноз разом із '
      'візуальною та текстовою рекомендацією, що одягнути.',
  'features': 'Можливості (Функції)',
  'artwork': 'Ілюстрації',
  'anna_turska': 'Анна Турська',
  'support_and_feedback': 'Підтримка та відгук',
  'telegram_group': 'Группа в Телеграмі',
  'developer_contact_form': "Зв'яжіться з розробником",
  'privacy_policy': 'Політика конфіденційності',
  'for': 'для',
  'android_app': 'Андроїд додатку',
  'last_update': 'Останнє оновлення',
  'location': 'Дані про місцезнаходження',
  'third_party': 'Внутрішні бібліотеки',
  'consent': 'Погодження',
  'children_privacy': 'Політика конфіденційності для дітей',
  'crashlytics': 'Крашлітика',
  'ai_content': 'Контент, сгенерований нейронними мережами',
  'updates_and_notifications': 'Оновлення та сповіщення',
  'contact_us': "Зв'яжіться з нами",
  'platform_specific_features': 'Функції, специфічні для платформи',
  'mobile': 'Мобільні пристрої (Андроїд, Айос)',
  'macos': 'Макось',
  'web': 'Веб (Інтернет)',
  'image_attribution_and_rights_title':
      'Зазначення авторства та права на '
      'зображення',
  'never_updated': 'Ніколи не оновлювався',
  'lat': 'Широта',
  'lon': 'Довгота',
  'could_not_launch': 'Не вдалося відкрити',
  'faq': 'Часті запитання',
  'contact_support': 'Звернутися до служби підтримки',
  'legal_and_app_info_title':
      '📄 Правова інформація та інформація про '
      'програму',
  'developer': 'Розробник',
  'developer_name': 'Дмитро Турський',
  'email': 'Електронна пошта',
  'last_updated_on_label': 'Востаннє оновлено',
  'no': 'Ні',
  'yes': 'Так',
  'cancel': 'Скасувати',
  'ukrainian': 'Українська',
  'english': 'Англійська',
  'en': 'АН',
  'uk': 'УК',
  'explore_weather_prompt': 'Давайте дослідимо погоду! ',
  'platform': 'Платформа',
  'android': 'Андроїд',
  'ios': 'Айос',
  'windows': 'Віндовс',
  'linux': 'Лінукс',
  'unknown': 'Невідомо',
  'feedback': <String, String>{
    'title': 'Відгук',
    'app_feedback': 'Відгук про додаток',
    'what_kind': 'Який тип відгуку ви хочете надіслати?',
    'what_is_your_feedback': 'Який ваш відгук?',
    'how_does_this_feel': 'Які це викликає у вас почуття?',
    'sent': 'Ваш відгук успішно надіслано!',
    'bug_report': 'Повідомлення про помилку',
    'feature_request': 'Запропонувати покращення',
    'type': 'Тип відгуку',
    'rating': 'Рейтинг',
    'bad': 'Погано',
    'neutral': 'Нейтральний',
    'good': 'Добре',
  },
  'error': <String, String>{
    'please_check_internet':
        'Виникла помилка. Будьласка, перевірте '
        'підключення до Інтернету та спробуйте ще раз.',
    'unexpected_error':
        'Виникла неочікувана помилка. Будь ласка, спробуйте ще '
        'раз.',
    'oops': 'Ой лишенько! Щось пішло не так. Будь ласка, спробуйте пізніше.',
    'cors':
        'Помилка: Необхідне налаштування локального середовища\nДля '
        'локального запуску цього веб додатку в браузері, будь ласка, '
        'використовуйте наступну команду:\n'
        'flutter run -d chrome --web-browser-flag "--disable-web-security"\n'
        'Цей крок необхідний для обходу обмежень CORS під час локальної '
        'розробки. Зверніть увагу, що цей прапорець слід використовувати '
        'тільки в середовищі розробки і ніколи в продакшні.',
    'launch_email_or_support_page':
        'Не вдалося запустити електронну пошту або '
        'сторінку підтримки.',
    'something_went_wrong': 'Щось пішло не так!',
    'searching_location': 'Помилка пошуку місцезнаходження',
    'location_permission_denied':
        'Дозволи на доступ до місцезнаходження '
        'відхилено',
    'location_permission_permanently_denied_cannot_request':
        'Дозволи на '
        'доступ до місцезнаходження відхилено назавжди, ми не можемо '
        'запитувати дозволи.',
    'getting_weather_generic':
        'Не вдалося отримати інформацію про погоду. '
        'Будь ласка, спробуйте ще раз.',
    'launch_email_app_to_address':
        'Не вдалося запустити поштовий клієнт, щоб '
        'надіслати листа на адресу {emailAddress}',
    'launch_email_failed': 'Не вдалося запустити поштову програму.',
    'save_asset_image_failed':
        'Не вдалося зберегти зображення у сховищі '
        'пристрою',
  },
  'settings': <String, String>{
    'title': 'Налаштування',
    'language': 'Мова',
    'temperature_units': 'Одиниці вимірювання температури',
    'temperature_units_subtitle_metric':
        'Використовувати метричну систему для '
        'одиниць температури.',
    'temperature_units_subtitle_imperial':
        'Використовувати імперську систему '
        'для одиниць температури.',
    'about_app_subtitle': 'Дізнайтеся більше про «WeatherFit».',
    'feedback_subtitle':
        'Поділіться своїми думками та пропозиціями. Ви також '
        'можете повідомити про будь-які проблеми з вмістом програми.',
    'support_subtitle':
        'Відвідайте нашу сторінку підтримки для допомоги та '
        'поширених запитань.',
  },
  'search': <String, String>{
    'city_or_country': 'Місто або країна',
    'enter_city_or_country': 'Введіть місто або країну',
    'page_semantics_label': 'Сторінка пошуку міста або країни',
    'page_app_bar_title': 'Пошук міста або країни',
    'instructions':
        'Введіть назву міста чи країни та натисніть "Відправити", '
        'щоб побачити погоду.',
    'confirm_location_dialog_title': 'Це ваше місцезнаходження?',
    'label': 'Пошук',
    'use_current_location_dialog_title':
        'Використати ваше поточне '
        'місцезнаходження?',
    'location_not_found_use_current_dialog_content':
        'Нам не вдалося знайти '
        'правильне місцезнаходження. Бажаєте натомість використати ваше '
        'поточне місцезнаходження?',
  },
  'about': <String, String>{
    'title': 'Про застосунок',
    'feature_outfit_suggestions': '• Пропозиції одягу відповідно до погоди',
    'feature_location_forecast': '• Прогноз погоди на основі місцезнаходження',
    'feature_location_support_web':
        '• Підтримка приблизного місцезнаходження '
        '(потрібен дозвіл браузера)',
    'feature_location_support_macos':
        '• Підтримка приблизного '
        'місцезнаходження (потрібен дозвіл на доступ до геопозиції)',
    'feature_location_support_default':
        '• Підтримка приблизного '
        'місцезнаходження (GPS не потрібен)',
    'feature_privacy_friendly':
        '• Дбайливе ставлення до приватності '
        '(без відстеження, без облікових записів)',
    'feature_home_widgets':
        '• Віджети головного екрана для мобільних '
        'пристроїв',
    'outfit_illustrations_in': 'Ілюстрації одягу в',
    'were_created_by': 'були намальовані вручну художницею',
    'artwork_artist_outro':
        ', чий стиль додає шарму та індивідуальності '
        'додатку. Кожен образ у додатку - це не просто гарна картинка, а й '
        'продумана стилізація від професійної дизайнерки одягу. Це наче '
        'безкоштовна порада від стиліста - просто у вас під рукою.',
    'privacy_title': 'Приватність і дані',
    'privacy_description':
        '«{appName}» не збирає та не зберігає жодних '
        'персональних даних. Ваше приблизне місцезнаходження використовується '
        'лише для відображення місцевої погоди та ніколи не передається іншим. '
        'Пропозиції щодо одягу генеруються на пристрої на основі погодних '
        'умов. Ви можете ознайомитися з повною політикою конфіденційності '
        'нижче.',
    'view_privacy_policy': 'Переглянути Політику конфіденційності',
    'support_description':
        'Виникли проблеми? Потрібна допомога або хочете '
        "запропонувати нову функцію? Приєднуйтесь до спільноти або зв'яжіться "
        'з розробником напряму.',
  },
  'privacy': <String, String>{
    'policy_intro':
        'Ваша конфіденційність важлива для нас. Політика {appName} '
        'полягає в повазі до вашої конфіденційності та дотриманні всіх чинних '
        'законів і нормативних актів щодо будь-якої особистої інформації, яку '
        'ми можемо збирати про вас, у тому числі в нашому додатку «{appName}» '
        "та пов'язаних з ним сервісах.",
    'information_we_collect': 'Ми збираємо такі дані',
    'no_personal_data_collection':
        'Ми не збираємо жодної особистої '
        "інформації, такої як ім'я, адреса електронної пошти або номер "
        'телефону.',
    'location_access_request':
        '«{appName}» може додатково запитувати доступ '
        'до приблизного місцезнаходження вашого пристрою '
        '(приблизне місцезнаходження). Цей доступ запитується лише в тому '
        'випадку, якщо програма не може автоматично визначити ваше '
        'місцезнаходження на основі введеної назви міста. Перш ніж програма '
        'спробує отримати доступ до вашого місцезнаходження, вам буде '
        'запропоновано надати дозвіл.',
    'location_data_usage':
        'Якщо ви надаєте дозвіл на доступ до '
        'місцезнаходження, ці дані використовуються локально в додатку для '
        'пошуку відповідної інформації про погоду для вашого поточного '
        'місцезнаходження. Дані про місцезнаходження не зберігаються та не '
        'передаються за межі вашого пристрою, а використовуються лише '
        'тимчасово для визначення вашого поточного місцезнаходження. Після '
        'визначення погоди для поточного місцезнаходження вони видаляються. Ви '
        'можете не надавати своє місцезнаходження, у такому випадку ви зможете '
        'продовжувати користуватися додатком, вводячи назву міста вручну.',
    'third_party_services_info':
        '«{appName}» використовує сторонні сервіси, '
        'які можуть збирати інформацію, що використовується для вашої '
        'ідентифікації. До таких сервісів належать Firebase Crashlytics та '
        'Google Analytics. Дані, зібрані цими сервісами, використовуються для '
        'покращення стабільності програми та взаємодії з користувачем. Більше '
        'інформації про їхню політику конфіденційності ви можете знайти на '
        'їхніх відповідних веб-сайтах.',
    'consent_agreement':
        'Використовуючи наші сервіси, ви погоджуєтеся на збір '
        'та використання вашої інформації, як описано в цій політиці '
        'конфіденційності.',
    'security_measures': 'Заходи безпеки',
    'security_measures_description':
        'Ми вживаємо розумних заходів для захисту '
        'вашої інформації від несанкціонованого доступу, розголошення або '
        'зміни.',
    'children_description':
        'Наші послуги не призначені для дітей віком до '
        '{age} років. Ми свідомо не збираємо особисту інформацію від дітей '
        'віком до {age} років. Хоча ми прагнемо мінімізувати збір даних, '
        'сторонні сервіси, які ми використовуємо (наприклад, Firebase '
        'Crashlytics та Google Analytics), можуть збирати деякі дані. Однак ці '
        "дані збираються анонімно та не пов'язані з жодною особистою "
        'інформацією. Якщо ви вважаєте, що дитина віком до {age} років надала '
        "нам особисту інформацію, будь ласка, зв'яжіться з нами, і ми "
        'розслідуємо це питання.',
    'crashlytics_description':
        '«{appName}» використовує Firebase Crashlytics, '
        'сервіс від Google, для анонімного збору звітів про збої, що допомагає '
        'нам покращувати стабільність програми та виправляти помилки. Дані, '
        'зібрані Crashlytics, не містять жодної особистої інформації.',
    'ai_content_description':
        '«{appName}» більше не використовує штучний інтелект (ШІ) для '
        'генерації зображень одягу в реальному часі. Натомість, усі '
        'зображення тепер попередньо намальовані та входять до комплекту '
        'програми. Хоча деякі зображення могли бути створені за допомогою '
        'інструментів ШІ під час процесу дизайну, жодні дані користувача '
        'не надсилаються до зовнішніх сервісів ШІ під час використання.\n\n'
        'Якщо у вас є занепокоєння або ви бажаєте надати відгук щодо '
        'будь-якого вмісту, будь ласка, скористайтеся опцією «Відгук» у '
        'налаштуваннях програми.',
    'outfit_illustrations_created_by': 'Ілюстрації одягу створила',
    'artwork_creation_method':
        ', з використанням поєднання мальованих вручну елементів та '
        'інструментів ШІ.',
    'updates_and_notifications_description':
        'Ця політика конфіденційності може періодично оновлюватися. Про '
        'будь-які зміни в політиці вам буде повідомлено через оновлення '
        'програми або сповіщення.',
    'contact_us_invitation':
        'З будь-яких питань або занепокоєнь щодо вашої конфіденційності, ви '
        "можете зв'язатися з нами за наступними контактними даними:",
    'platform_specific_intro':
        '«{appName}» пропонує різні функції залежно від платформи, яку ви '
        'використовуєте (мобільна, macOS або веб). Будь ласка, зверніть '
        'увагу на наступні деталі, специфічні для платформи:',
    'platform_mobile_description':
        'На мобільних пристроях «{appName}» надає візуальні рекомендації щодо '
        'одягу на основі поточних погодних умов. Ці зображення не '
        'генеруються штучним інтелектом у реальному часі, а натомість є '
        'попередньо намальованими та зберігаються локально в додатку. '
        'Жодні дані про погоду або користувача не надсилаються до '
        'зовнішніх сервісів для генерації цього одягу.',
    'platform_macos_description':
        'У macOS програма використовує приблизне місцезнаходження (з дозволу) '
        'для надання місцевої погоди та відповідних рекомендацій щодо '
        'одягу, подібно до мобільної версії.',
    'platform_image_generation_explanation':
        'На мобільних та настільних платформах зображення одягу не генеруються '
        'в реальному часі за допомогою ШІ. Замість цього, це попередньо '
        'намальовані ілюстрації, що входять до комплекту програми. Деякі з '
        'цих ресурсів могли бути спочатку створені або вдосконалені за '
        'допомогою інструментів ШІ під час творчого процесу, але жодні '
        'дані користувача не передаються сервісам ШІ під час використання '
        'програми.',
    'platform_web_description':
        'У веб-версії «{appName}» відображає як текстові, так і візуальні '
        'рекомендації щодо одягу, так само як на мобільних та настільних '
        'платформах. Однак віджети головного екрана недоступні у '
        'веб-версії через поточні технічні обмеження.',
    'image_attribution_and_rights_description':
        'Усі ілюстрації одягу в «{appName}» були створені та відредаговані '
        'художницею Анною Турською з використанням поєднання оригінальної '
        'дизайнерської роботи та чернеток, створених за допомогою ШІ '
        '(наприклад, Bing Image Creator). Ці зображення входять до '
        'комплекту програми та не завантажуються з будь-яких зовнішніх '
        'джерел під час використання. Усі права на кінцеві зображення '
        'належать розробнику.',
  },
  'support': <String, String>{
    'title': 'Підтримка',
    'intro_line':
        'Потрібна допомога або бажаєте залишити відгук? Ви у правильному '
        'місці.',
    'faq_hourly_forecast_q': '• Чому немає погодинного прогнозу?',
    'faq_hourly_forecast_a':
        'Погодинний прогноз наразі не підтримується, але може бути доданий у '
        'майбутньому.',
    'faq_change_location_q':
        '• Чи можу я змінити своє місцезнаходження пізніше?',
    'faq_change_location_a':
        'Так, програма дозволяє підтверджувати та оновлювати ваше '
        'місцезнаходження під час використання.',
    'faq_theme_change_q': '• Чому тема змінюється вночі?',
    'faq_theme_change_a':
        'Програма автоматично перемикається на темний режим уночі. Час '
        'початку дня та ночі можна змінити в налаштуваннях.',
    'contact_intro': 'Якщо у вас виникають проблеми або є пропозиції:',
    'contact_us_via_email_button': "Зв'язатися з нами електронною поштою",
    'join_telegram_support_button': 'Приєднатися до групи підтримки в Telegram',
    'visit_developer_support_website_button':
        'Відвідати сторінку підтримки на сайті розробника',
    'email_default_body': 'Привіт, мені потрібна допомога з...',
  },
  'weather': <String, String>{
    'check_latest_button': 'Перевірити останню погоду',
    'code_0': 'Чисте небо',
    'code_1': 'Переважно ясно',
    'code_2': 'Мінлива хмарність',
    'code_3': 'Похмуро',
    'code_45': 'Туман',
    'code_48': 'Паморозь',
    'code_51': 'Легка мряка',
    'code_53': 'Помірна мряка',
    'code_55': 'Сильна мряка',
    'code_56': 'Легкий крижаний дощ',
    'code_57': 'Сильний крижаний дощ',
    'code_61': 'Невеликий дощ',
    'code_63': 'Помірний дощ',
    'code_65': 'Сильний дощ',
    'code_66': 'Легкий крижаний дощ',
    'code_67': 'Сильний крижаний дощ',
    'code_71': 'Невеликий сніг',
    'code_73': 'Помірний сніг',
    'code_75': 'Сильний сніг',
    'code_77': 'Снігові зерна',
    'code_80': 'Невеликі зливи',
    'code_81': 'Помірні зливи',
    'code_82': 'Сильні зливи',
    'code_85': 'Невеликий сніг з дощем',
    'code_86': 'Сильний сніг з дощем',
    'code_95': 'Гроза',
    'code_96': 'Гроза з невеликим градом',
    'code_99': 'Гроза з сильним градом',
    'code_unknown': 'Невідома погода',
    'empty_search_prompt': 'Торкніться 🔍, щоб знайти місто чи країну.',
    'loading_weather': 'Завантаження погоди',
  },
  'outfit': <String, String>{
    'oops': '🛑 Ой! Немає пропозицій щодо одягу.',
    'could_not_pick': '🤷 Схоже, цього разу ми не змогли підібрати одяг.',
    'mix_and_match':
        '🎨 Немає рекомендацій? Час поєднувати свій власний стиль!',
    'fashion_instincts': '✨ Сьогодні ваші модні інстинкти беруть верх!',
    'pajama_day': '😴 Одяг не підібрано — можливо, сьогодні день для піжами?',
    'unavailable_short': '👕 Одяг недоступний.',
    'no_recommendation_short': '🚫 немає рекомендацій.',
    'rainy': '🌧️\nДощить! Подумайте про водонепроникну куртку та черевики.',
    'snowy':
        '❄️\nСніжно! Одягніться тепло: важке пальто, шапка, рукавички та шарф.',
    'cold':
        '🥶\nХолодно! Одягніть теплу куртку, светр, а також подумайте про '
        'шапку та рукавички.',
    'cool': '🧥\nПрохолодно. Легка куртка або светр будуть комфортними.',
    'warm': '👕\nТепло. Шорти, футболки та легкі сукні – чудові варіанти.',
    'hot':
        '☀️\nСпекотно! Носіть легкий, дихаючий одяг, наприклад, майки та '
        'шорти.',
    'moderate': '🌤️\nПогода помірна. Ви можете носити різноманітний одяг.',
  },
};

Future<LocalizationDelegate> setUpFlutterTranslateForTests({
  Locale startLocale = const Locale('en'),
}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});

  final LocalizationDelegate delegate = await LocalizationDelegate.create(
    fallbackLocale: 'en',
    supportedLocales: <String>['en', 'uk'],
  );

  // Manually load translations for the starting locale into the static
  // Localization instance.
  // This is the key to bypassing the file loading for the actual translation
  // content.
  if (startLocale.languageCode == 'en') {
    Localization.load(_enTestTranslations);
  } else if (startLocale.languageCode == 'uk') {
    Localization.load(_ukTestTranslations);
  } else {
    // Load fallback or throw error if startLocale is not one of your test
    // locales.
    Localization.load(_enTestTranslations);
  }

  // Ensure the delegate's internal state reflects this locale.
  // The call to Localization.load above primes the static instance.
  // The changeLocale method in the delegate will use this primed instance
  // if its internal logic calls Localization.instance.
  // Or, more directly, it also calls Localization.load itself.
  await delegate.changeLocale(startLocale);

  return delegate;
}

// Helper to wrap a widget with necessary providers for testing
Widget prepareWidgetForTesting(
  Widget child,
  LocalizationDelegate localizationDelegate,
) {
  return MaterialApp(
    localizationsDelegates: <LocalizationsDelegate<Object?>>[
      localizationDelegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: localizationDelegate.supportedLocales,
    locale: localizationDelegate.currentLocale,
    home: Material(child: child),
  );
}
