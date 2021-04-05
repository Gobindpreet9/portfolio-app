import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gobind/common/common_const.dart';
import 'package:flutter/material.dart';
import 'package:gobind/styles/styles.dart';
import 'package:url_launcher/url_launcher.dart';

Future<bool> willPop(currentBackPressTime) {
  DateTime now = DateTime.now();

  if (currentBackPressTime == null ||
      now.difference(currentBackPressTime) > Duration(seconds: 2)) {
    currentBackPressTime = now;
    Fluttertoast.showToast(
        msg: englishLanguage['exitWarning'],
        timeInSecForIosWeb: 1,
        fontSize: 14.0);
    return Future.value(false);
  }
  return Future.value(true);
}

progressIndicator(context, {Color color}) {
  if (color == null) color = Theme.of(context).primaryColor;
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
        color,
      ))),
    ],
  );
}

FlatButton getContactLinks(String type, BuildContext context,
    {Color iconColor = pureWhite,
    Color textColor = pureWhite,
    String textFont = 'PlayfairDisplay'}) {
  return FlatButton.icon(
    icon: type == email
        ? Icon(
            FontAwesomeIcons.envelope,
            color: iconColor,
          )
        : Icon(
            FontAwesomeIcons.phone,
            color: iconColor,
          ),
    label: Container(
      margin: EdgeInsets.only(left: 5),
      child: Text(
        type,
        style: Theme.of(context)
            .textTheme
            .bodyText1
            .copyWith(color: textColor, fontFamily: textFont),
      ),
    ),
    onPressed: () async {
      if (type == email) {
        await launch('mailto:$email?subject=News&body=New%20plugin');
      } else {
        await launch('tel:$phone');
      }
    },
  );
}
