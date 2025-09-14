import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  String currentLang = 'en';

  final Map<String, Map<String, String>> _localizedValues = {
    'en': {
     'welcome': 'Welcome',
  'Admin Details': 'Admin Details',
  'Profile Picture': 'Profile Picture',
  'Full Name': 'Full Name',
  'Guard ID / Employee ID': 'Guard ID / Employee ID',
  'Phone Number': 'Enter Phone Number',
  'send otp' : 'Send Otp',
  'pin' : '4 Digit Pin',
  'gatenum' : 'Gate Number/Name',
  'save' : 'Save Details',
  'preference' : 'Choose Your Preference',
  'admin' : 'Admin Access',
  'resident' : 'Residential Access',
  'reslogin' : 'Resident Login',
  'nameplz' : 'Enter your name',
  'room' : 'Enter Room No./Name',

    },
    'hi': {
     'welcome': 'स्वागत है',
  'Admin Details': 'प्रशासक विवरण',
  'Profile Picture': 'प्रोफ़ाइल चित्र',
  'Full Name': 'पूरा नाम',
  'Guard ID / Employee ID': 'गार्ड आईडी / कर्मचारी आईडी',
  'Phone Number': 'फ़ोन नंबर',
  'send otp' : 'ओटीपी भेजें',
  'pin' : '4 अंकों का पिन',
  'gatenum' : 'गेट नंबर/नाम',
  'save' : 'विवरण सहेजें',
  'preference' : 'अपनी पसंद चुनें',
  'admin' : 'व्यवस्थापक पहुँच',
  'resident' : 'आवासीय प्रवेश',
  'reslogin' : 'निवासी लॉगिन',
  'nameplz' : 'अपना नाम दर्ज करें',
  'room' : 'कमरा नंबर/नाम दर्ज करें',
    },
  };

  String getText(String key) {
    return _localizedValues[currentLang]?[key] ?? key;
  }

  void changeLanguage(String lang) {
    currentLang = lang;
    notifyListeners();
  }
}
