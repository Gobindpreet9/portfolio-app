import 'package:flutter/material.dart';
import 'package:portfolio_app/about_me/about_me.dart';
import 'package:portfolio_app/books/books.dart';
import 'package:portfolio_app/intro/intro.dart';
import 'package:portfolio_app/misc/unauthorized.dart';
import 'package:portfolio_app/resume/resume.dart';

Map<String, Widget Function(BuildContext)> routes = {
  '/': (context) => Intro(),
  '/aboutMe': (context) => AboutMe(),
  '/books': (context) => Books(),
  '/resume': (context) => const Resume(), // Removed context
  '/unauthorized': (context) => const Unauthorized(), // Removed context
};