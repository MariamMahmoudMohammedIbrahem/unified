import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

class LocalizationService {

  late final Locale locale;
  static late Locale currentLocale;

  LocalizationService(this.locale){
    currentLocale = locale;
  }

  static LocalizationService? of(BuildContext context){
    return Localizations.of<LocalizationService>(context, LocalizationService);
  }

  late Map<String, String> _localizedString;

  Future<void> load() async {
    final jsonString = await rootBundle.loadString('lang/${locale.languageCode}.json');

    Map<String, dynamic> jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;

    _localizedString = jsonMap.map((String key,dynamic value) => MapEntry(key, value.toString()));
  }

  String? translate(String key){
    return _localizedString[key];
  }

  static const supportedLocales = [
    Locale('en', 'US'),
    Locale('ar', 'AR')
  ];

  static Locale? localeResolutionCallBack(Locale? locale, Iterable<Locale>? supportedLocales){
    if(supportedLocales != null && locale != null){
      return supportedLocales.firstWhere((element) =>
      element.languageCode == locale.languageCode,
          orElse: ()=> supportedLocales.first);
    }

    return null;
  }

  static const LocalizationsDelegate<LocalizationService> _delegate = _LocalizationServiceDelegate();

  static const localizationsDelegate = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    _delegate
  ];


}

class _LocalizationServiceDelegate extends LocalizationsDelegate<LocalizationService> {
  const _LocalizationServiceDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<LocalizationService> load(Locale locale) async{
    LocalizationService service = LocalizationService(locale);
    await service.load();
    return service;
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<LocalizationService> old) {
    return false;
  }
}

class LocalizationController extends GetxController{
  // String currentLanguage = ''.obs.toString();

  late String currentLanguage;

  // Add an optional parameter to set the initial language
  LocalizationController({String initialLanguage = ''}) {
    currentLanguage = initialLanguage.isNotEmpty ? initialLanguage : 'en';
  }
  void toggleLanguage(String lang) {
    if(lang == 'ara'){
      currentLanguage ='ar';
    }else{
      currentLanguage = 'en';
    }
    update();
  }
}

class FallbackCupertinoLocalisationsDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalisationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      DefaultCupertinoLocalizations.load(locale);

  @override
  bool shouldReload(FallbackCupertinoLocalisationsDelegate old) => false;
}
