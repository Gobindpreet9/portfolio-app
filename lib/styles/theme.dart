part of 'styles.dart';

const Color aliceBlue = Color(0xffECF4FE);
const Color yaleBlue = Color(0xff084A9B);
const Color littleBlueBoy = Color(0xff539BF3);
const Color jet = Color(0xff292929);
const Color cultured = Color(0xffF4F2F3);
const Color indigoDye = Color(0xff073874);
const Color oxfordBlue = Color(0xff04254E);
const appGradient = LinearGradient(colors: [yaleBlue, indigoDye]);

// const Color salmon = Color(0xffF37F68);
// const Color Sapphire = Color(0xff0B54AD);

final ThemeData defaultThemeData = ThemeData(
  primarySwatch: Colors.blue,
  primaryColor: aliceBlue,
  scaffoldBackgroundColor: cultured,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  fontFamily: 'PlayfairDisplay',
  iconTheme: const IconThemeData(color: pureWhite, size: 30),
  textTheme: const TextTheme(
    titleLarge: TextStyle(fontSize: 45, color: jet, fontWeight: FontWeight.w900),
    titleMedium: TextStyle(fontSize: 24, color: jet, fontWeight: FontWeight.w700),
    titleSmall: TextStyle(fontSize: 18, color: jet, fontWeight: FontWeight.w600),
    bodyMedium: TextStyle(fontSize: 15, color: jet, fontWeight: FontWeight.w500),
  ),
  colorScheme: ColorScheme.fromSwatch().copyWith(
    secondary: indigoDye,
    primary: aliceBlue,
    surface: cultured,
  ),
);

final whiteText = defaultThemeData.textTheme.bodyMedium!.copyWith(color: pureWhite);

const richBlack = Color(0xff121212);
const pureWhite = Color(0xffffffff);

final ThemeData blackTheme = ThemeData(
  primarySwatch: Colors.blue,
  primaryColor: richBlack,
  scaffoldBackgroundColor: richBlack,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  fontFamily: 'PlayfairDisplay',
  iconTheme: const IconThemeData(color: pureWhite, size: 30),
  textTheme: const TextTheme(
    titleLarge: TextStyle(fontSize: 45, color: pureWhite, fontWeight: FontWeight.w900),
    titleMedium: TextStyle(fontSize: 24, color: pureWhite, fontWeight: FontWeight.w700),
    titleSmall: TextStyle(fontSize: 18, color: pureWhite, fontWeight: FontWeight.w600),
    bodyMedium: TextStyle(fontSize: 15, color: pureWhite, fontWeight: FontWeight.w500),
  ),
  colorScheme: ColorScheme.fromSwatch().copyWith(
    secondary: littleBlueBoy,
    primary: richBlack,
    surface: richBlack,
  ),
);

getHeadingsColor(context){
  if(Theme.of(context).primaryColor == defaultThemeData.primaryColor)
    return oxfordBlue;
  else
    return
        littleBlueBoy;
}

getTitleColor(context){
  if(Theme.of(context).primaryColor == defaultThemeData.primaryColor)
    return jet;
  else
    return
      aliceBlue;
}

class AppStateNotifier extends ChangeNotifier {
  //
  bool isDarkMode = false;

  void updateTheme(bool isDarkMode) {
    this.isDarkMode = isDarkMode;
    notifyListeners();
  }
}