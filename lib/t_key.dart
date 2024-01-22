import 'package:flutter/cupertino.dart';

import 'localization_service.dart';

enum TKeys{
  //login
  email,
  password,
  emailError,
  forgetPassword,
  login,
  noAccount,
  error,
  loginError,
  ok,
  //signin
  userName,
  userNameError,
  signUp,
  accountAvailable,
  weakPassword,
  accountExist,
  //register
  sheikhName,
  phone,
  phoneError1,
  phoneError2,
  other,
  area,
  selectArea,
  mosque,
  selectMosque,
  register,
  problemOccurred,
  resetPassword,
  //device_list
  skip,
  confirmSkipping,
  scan,
  scanning,
  notFound,
  connect,
  confirmLogOutTitle,
  confirmLogOutHeadline,
  bleStatusTitle,
  bleStatusHeadline,
  //scan
  yes,
  no,
  confirmExitTitle,
  confirmExitHeadline,
  dashboard,
  accountDetails,
  changePassword,
  complain,
  settings,
  logout,
  dateTime,
  prayTimes,
  fajr,
  duhr,
  asr,
  maghreb,
  isha,
  settingOptions,
  settingPrayerTimes,
  restart,
  //settings
  longitudeLatitude,
  unitData,
  longitude,
  latitude,
  storedData,
  zone,
  currentZone,
  settingUnitLocation,
  settingUnitZone,
  testMode,
  soundOptions,
  selectSound,
  //feedback
  help,
  azaanTime,
  leds,
  noise,
  note,
  submit,
  hello,
  //account edit
  editProfile,
  update,
}

//Tkeys.device
extension TKeysExtention on TKeys{
  String get _string => toString().split('.')[1];
  String translate(BuildContext context){
    return LocalizationService.of(context)?.translate(_string)??'';
  }
}