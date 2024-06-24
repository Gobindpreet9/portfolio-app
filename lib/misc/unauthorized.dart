import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:portfolio_app/common/common.dart';
import 'package:portfolio_app/common/common_const.dart';
import 'package:portfolio_app/services/authentication.dart';
import 'package:portfolio_app/styles/styles.dart';

class Unauthorized extends StatefulWidget {
  final BuildContext context;

  const Unauthorized({Key? key, required this.context}) : super(key: key);

  @override
  _UnauthorizedState createState() => _UnauthorizedState();
}

class _UnauthorizedState extends State<Unauthorized> {
  final pageFont = 'DancingScript';
  late bool isLoggedIn;

  @override
  void initState() {
    isLoggedIn = ModalRoute.of(widget.context)!.settings.arguments
        as bool; // parameter using navigator.namedRoute
    print(isLoggedIn);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 1,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: pureWhite.withOpacity(0.5),
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          getKeyValue(englishLanguage, 'aboutMe'),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: pureWhite, fontSize: 40, fontStyle: FontStyle.italic),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    getKeyValue(englishLanguage, 'unauthorizedText'),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        !.copyWith(fontFamily: pageFont),
                  ),
                  SizedBox(
                    height: size.height / 40,
                  ),
                  getContactLinks(email, context,
                      iconColor: getTitleColor(context),
                      textColor: Theme.of(context).colorScheme.secondary,
                      textFont: pageFont),
                  getContactLinks(phone, context,
                      iconColor: getTitleColor(context),
                      textColor: Theme.of(context).colorScheme.secondary,
                      textFont: pageFont),
                ],
              ),
            ),
            isLoggedIn
                ? SizedBox()
                : Container(
                    decoration: BoxDecoration(
                      gradient: appGradient,
                    ),
                    child: TextButton.icon(
                      icon: Icon(
                        FontAwesomeIcons.google,
                        color: pureWhite,
                      ),
                      label: Container(
                        width: 150,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(containerBorderRadius),
                        ),
                        child: Center(
                          child: Text(
                            getKeyValue(englishLanguage, 'signInWithGoogle'),
                            style: whiteText,
                          ),
                        ),
                      ),
                      onPressed: () async {
                        if (await AuthService().signInWithGoogle() != null) {
                          setState(() {
                            isLoggedIn = true;
                          });
                        } else {
                          Fluttertoast.showToast(
                              msg: getKeyValue(englishLanguage, 'signInError'),
                              timeInSecForIosWeb: 1,
                              fontSize: 14.0);
                        }
                      },
                    ),
                  ),
          ],
        )),
      ),
    );
  }
}
