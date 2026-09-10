enum AppLanguage { english, hindi, punjabi, marathi }

class AppLocale {
  static const Map<String, Map<AppLanguage, String>> _strings = {
    // Brand & App Bar
    'app_title': {
      AppLanguage.english: 'Kisan Setu',
      AppLanguage.hindi: 'किसान सेतु',
      AppLanguage.punjabi: 'ਕਿਸਾਨ ਸੇਤੂ',
      AppLanguage.marathi: 'किसान सेतू',
    },
    'app_title_bilingual': {
      AppLanguage.english: 'Kisan Setu | किसान सेतु',
      AppLanguage.hindi: 'किसान सेतु | Kisan Setu',
      AppLanguage.punjabi: 'ਕਿਸਾਨ ਸੇਤੂ | Kisan Setu',
      AppLanguage.marathi: 'किसान सेतू | Kisan Setu',
    },
    'lang_button': {
      AppLanguage.english: 'EN/हि',
      AppLanguage.hindi: 'हि/EN',
      AppLanguage.punjabi: 'ਪੰ/EN',
      AppLanguage.marathi: 'म/EN',
    },

    // Navigation Tabs
    'nav_home': {
      AppLanguage.english: 'Home\nहोम',
      AppLanguage.hindi: 'होम\nHome',
      AppLanguage.punjabi: 'ਘਰ\nHome',
      AppLanguage.marathi: 'मुख्यपृष्ठ\nHome',
    },
    'nav_track': {
      AppLanguage.english: 'Track\nट्रैक',
      AppLanguage.hindi: 'ट्रैक\nTrack',
      AppLanguage.punjabi: 'ਟਰੈਕ\nTrack',
      AppLanguage.marathi: 'ट्रॅक\nTrack',
    },
    'nav_mandis': {
      AppLanguage.english: 'Mandis\nमंडियां',
      AppLanguage.hindi: 'मंडियां\nMandis',
      AppLanguage.punjabi: 'ਮੰਡੀਆਂ\nMandis',
      AppLanguage.marathi: 'मंडया\nMandis',
    },
    'nav_quality': {
      AppLanguage.english: 'Quality\nगुणवत्ता',
      AppLanguage.hindi: 'गुणवत्ता\nQuality',
      AppLanguage.punjabi: 'ਗੁਣਵੱਤਾ\nQuality',
      AppLanguage.marathi: 'गुणवत्ता\nQuality',
    },
    'nav_payments': {
      AppLanguage.english: 'Payments\nभुगतान',
      AppLanguage.hindi: 'भुगतान\nPayments',
      AppLanguage.punjabi: 'ਭੁਗਤਾਨ\nPayments',
      AppLanguage.marathi: 'पेमेंट्स\nPayments',
    },

    // Login & OTP
    'welcome_back': {
      AppLanguage.english: 'Welcome Back / स्वागत है',
      AppLanguage.hindi: 'स्वागत है / Welcome Back',
    },
    'enter_mobile_sub': {
      AppLanguage.english: 'Enter your 10-digit mobile number to login.\nलॉगिन करने के लिए अपना 10 अंकों का मोबाइल नंबर दर्ज करें।',
      AppLanguage.hindi: 'लॉगिन करने के लिए अपना 10 अंकों का मोबाइल नंबर दर्ज करें।\nEnter your 10-digit mobile number to login.',
    },
    'mobile_number': {
      AppLanguage.english: 'Mobile Number',
      AppLanguage.hindi: 'मोबाइल नंबर',
    },
    'send_otp': {
      AppLanguage.english: 'Send OTP',
      AppLanguage.hindi: 'ओटीपी भेजें (Send OTP)',
    },
    'otp_hint': {
      AppLanguage.english: 'We will send an OTP for verification.',
      AppLanguage.hindi: 'हम सत्यापन के लिए एक ओटीपी भेजेंगे।',
    },
    'verify_otp_title': {
      AppLanguage.english: 'Verify OTP',
      AppLanguage.hindi: 'ओटीपी सत्यापन',
    },
    'verify_otp_sub': {
      AppLanguage.english: 'Please enter the 6-digit verification code sent to',
      AppLanguage.hindi: 'कृपया इस नंबर पर भेजा गया 6 अंकों का सत्यापन कोड दर्ज करें:',
    },
    'resend_otp': {
      AppLanguage.english: 'Resend OTP',
      AppLanguage.hindi: 'ओटीपी पुनः भेजें',
    },
    'verify_login': {
      AppLanguage.english: 'Verify & Login',
      AppLanguage.hindi: 'सत्यापित करें और लॉगिन करें',
    },

    // Dashboard
    'step_progress': {
      AppLanguage.english: 'Step 1: Your Progress',
      AppLanguage.hindi: 'चरण 1: आपकी प्रगति',
    },
    'step_reg': {
      AppLanguage.english: 'Registration\nपंजीकरण',
      AppLanguage.hindi: 'पंजीकरण\nRegistration',
    },
    'step_crop': {
      AppLanguage.english: 'Crop\nफसल',
      AppLanguage.hindi: 'फसल\nCrop',
    },
    'step_booking': {
      AppLanguage.english: 'Booking\nबुकिंग',
      AppLanguage.hindi: 'बुकिंग\nBooking',
    },
    'step_token': {
      AppLanguage.english: 'Token\nटोकन',
      AppLanguage.hindi: 'टोकन\nToken',
    },
    'step_queue': {
      AppLanguage.english: 'Queue\nकतार',
      AppLanguage.hindi: 'कतार\nQueue',
    },
    'live_tracker_card': {
      AppLanguage.english: 'Live Queue Tracker\nलाइव कतार ट्रैकर',
      AppLanguage.hindi: 'लाइव कतार ट्रैकर\nLive Queue Tracker',
    },
    'vehicles_ahead': {
      AppLanguage.english: 'vehicles ahead / 3 वाहन आगे',
      AppLanguage.hindi: 'वाहन आगे / vehicles ahead',
    },
    'est_wait': {
      AppLanguage.english: 'Est. Wait: 45 mins / अनुमानित प्रतीक्षा: 45 मिनट',
      AppLanguage.hindi: 'अनुमानित प्रतीक्षा: 45 मिनट / Est. Wait: 45 mins',
    },
    'smart_booking': {
      AppLanguage.english: 'Smart Booking\nस्मार्ट बुकिंग',
      AppLanguage.hindi: 'स्मार्ट बुकिंग\nSmart Booking',
    },
    'nearby_mandis': {
      AppLanguage.english: 'Nearby Mandis\nआसपास की मंडियां',
      AppLanguage.hindi: 'आसपास की मंडियां\nNearby Mandis',
    },
    'quality_check': {
      AppLanguage.english: 'Quality Check\nगुणवत्ता जांच',
      AppLanguage.hindi: 'गुणवत्ता जांच\nQuality Check',
    },
    'dbt_payments': {
      AppLanguage.english: 'DBT Payments\nडीबीटी भुगतान',
      AppLanguage.hindi: 'डीबीटी भुगतान\nDBT Payments',
    },
    'recent_activity': {
      AppLanguage.english: 'Recent Activity / हाल की गतिविधि',
      AppLanguage.hindi: 'हाल की गतिविधि / Recent Activity',
    },

    // Booking
    'select_center': {
      AppLanguage.english: '1. Select Center / केंद्र चुनें',
      AppLanguage.hindi: '1. केंद्र चुनें / Select Center',
    },
    'select_date': {
      AppLanguage.english: '2. Select Date / तिथि चुनें',
      AppLanguage.hindi: '2. तिथि चुनें / Select Date',
    },
    'select_crop_qty': {
      AppLanguage.english: 'Select Crop & Estimated Quantity / फसल और मात्रा',
      AppLanguage.hindi: 'फसल और अनुमानित मात्रा चुनें / Select Crop',
    },
    'select_time': {
      AppLanguage.english: '3. Select Time / समय चुनें',
      AppLanguage.hindi: '3. समय चुनें / Select Time',
    },
    'confirm_booking': {
      AppLanguage.english: 'Confirm Booking / बुकिंग की पुष्टि करें',
      AppLanguage.hindi: 'बुकिंग की पुष्टि करें / Confirm Booking',
    },
  };

  static String get(String key, AppLanguage lang) {
    if (_strings.containsKey(key)) {
      final map = _strings[key]!;
      return map[lang] ?? map[AppLanguage.english] ?? key;
    }
    return key;
  }
}
