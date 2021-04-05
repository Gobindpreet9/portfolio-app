import 'package:flutter/material.dart';
import 'package:gobind/about_me/about_me.dart';
import 'package:gobind/books/books.dart';
import 'package:gobind/intro/intro.dart';
import 'package:gobind/misc/unauthorized.dart';
import 'package:gobind/resume/resume.dart';

Map<String, Widget Function(BuildContext)> routes = {
  '/': (context) => Intro(),
  '/aboutMe': (context) => AboutMe(),
  '/books': (context) => Books(),
  '/resume': (context) => Resume(context: context,),
  '/unauthorized': (context) => Unauthorized(context: context,),
};