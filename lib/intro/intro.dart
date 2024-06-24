import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:portfolio_app/services/authentication.dart';
import 'package:portfolio_app/services/firestore.dart';
import 'package:provider/provider.dart';
import 'package:portfolio_app/common/common.dart';
import 'package:portfolio_app/common/common_const.dart';
import 'package:portfolio_app/styles/styles.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class Intro extends StatefulWidget {
  @override
  _IntroState createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  late DateTime currentBackPressTime;
  late Stream<User?> userStatusStream;
  bool isLoggedIn = false;

  @override
  initState() {
    userStatusStream = AuthService().onAuthStateChanged;
    userStatusStream.listen((event) {
      if (event != null)
        setState(() {
          isLoggedIn = true;
        });
    });
    super.initState();
  }

  Widget footer(Size size) {
    return Material(
      elevation: 10,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        width: size.width,
        height: 350,
        color: Theme.of(context).primaryColor == defaultThemeData.primaryColor
            ? indigoDye
            : richBlack,
        child: Column(
          children: [
            SizedBox(
              height: size.height / 20,
            ),
            Text(
              getKeyValue(englishLanguage, 'contactMe'),
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: pureWhite,
                  fontSize: 50,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1),
            ),
            SizedBox(
              height: size.height / 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                getSocialMediaLinks('gitHub'),
                getSocialMediaLinks('linkedIn'),
                getSocialMediaLinks('instagram'),
              ],
            ),
            SizedBox(
              height: size.height / 40,
            ),
            getContactLinks(email, context),
            SizedBox(
              height: size.height / 40,
            ),
            getContactLinks(phone, context),
          ],
        ),
      ),
    );
  }

  IconButton getSocialMediaLinks(String platform) {
    Icon icon = getIcon(platform);
    return IconButton(
      icon: icon,
      onPressed: () async {
        await launch('http:$platform');
      },
    );
  }

  Icon getIcon(String platform) {
    switch (platform) {
      case 'gitHub':
        return Icon(
          FontAwesomeIcons.github,
          size: Theme.of(context).iconTheme.size,
        );
        break;
      case 'instagram':
        return Icon(
          FontAwesomeIcons.instagram,
          size: Theme.of(context).iconTheme.size,
        );
        break;
      case 'linkedIn':
        return Icon(
          FontAwesomeIcons.linkedin,
          size: Theme.of(context).iconTheme.size,
        );
        break;
      default:
        return Icon(
          FontAwesomeIcons.cloud,
          size: Theme.of(context).iconTheme.size,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: WillPopScope(
        onWillPop: () {
          return willPop(currentBackPressTime);
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: Container(
                  constraints: BoxConstraints(minHeight: size.height),
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.topRight,
                        child: Switch(
                          value: Provider.of<AppStateNotifier>(context, listen: false)
                              .isDarkMode,
                          onChanged: (boolVal) {
                            Provider.of<AppStateNotifier>(context, listen: false)
                                .updateTheme(boolVal);
                          },
                          inactiveThumbImage: AssetImage(sunIcon),
                          activeThumbImage: AssetImage(sunDarkIcon),
                        ),
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        backgroundImage: AssetImage(intro_pic),
                        radius:
                            size.width / 3.3 < 150 ? size.width / 3.3 : 150,
                      ),
                      SizedBox(
                        height: size.height / 40,
                      ),
                      Container(
                        child: Text(
                          full_name,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      SizedBox(
                        height: size.height / 40,
                      ),
                      Divider(
                        color: indigoDye,
                      ),
                      SizedBox(
                        height: size.height / 40,
                      ),
                      Container(
                        constraints: BoxConstraints(maxWidth: 600),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          getKeyValue(englishLanguage, 'main_bio'),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      SizedBox(
                        height: size.height / 20,
                      ),
                      TextButton(
                        child: Container(
                          width: 150,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: appGradient,
                            borderRadius: BorderRadius.circular(
                                containerBorderRadius),
                          ),
                          child: Center(
                            child: Text(
                              getKeyValue(englishLanguage, 'checkMyResume'),
                              style: whiteText,
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/resume');
                        },
                      ),
                      SizedBox(
                        height: size.height / 20,
                      ),
                    ],
                  ),
                ),
              ),
              Material(
                elevation: 5,
                child: GestureDetector(
                  onTap: () async {
                    if (isLoggedIn) {
                      if (await FirestoreService()
                          .isAuthorized(AuthService().currentUser()))
                        Navigator.pushNamed(context, '/aboutMe');
                      else
                        Navigator.pushNamed(context, '/unauthorized',
                            arguments: isLoggedIn);
                    } else
                      Navigator.pushNamed(context, '/unauthorized',
                          arguments: isLoggedIn);
                  },
                  child: Container(
                    color: Theme.of(context).primaryColor ==
                            defaultThemeData.primaryColor
                        ? yaleBlue
                        : jet,
                    height: 150,
                    child: Center(
                      child: Text(
                        getKeyValue(englishLanguage, 'moreAboutMe'),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            !.copyWith(color: pureWhite),
                      ),
                    ),
                  ),
                ),
              ),
              footer(size),
            ],
          ),
        ),
      ),
    );
  }
}
