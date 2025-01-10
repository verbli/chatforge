// lib/themes/syntax_theme.dart

import 'package:flutter/material.dart';
import 'package:flutter_highlighter/themes/androidstudio.dart';
import 'package:flutter_highlighter/themes/atom-one-dark.dart';
import 'package:flutter_highlighter/themes/atom-one-light.dart';
import 'package:flutter_highlighter/themes/github.dart';
import 'package:flutter_highlighter/themes/idea.dart';
import 'package:flutter_highlighter/themes/monokai.dart';
import 'package:flutter_highlighter/themes/nord.dart';
import 'package:flutter_highlighter/themes/solarized-dark.dart';
import 'package:flutter_highlighter/themes/vs.dart';
import 'package:flutter_highlighter/themes/vs2015.dart';
import 'package:flutter_highlighter/themes/solarized-light.dart';
import 'package:flutter_highlighter/themes/xcode.dart';

enum SyntaxTheme {
  github('GitHub', githubTheme, Brightness.light),
  vs('Visual Studio', vsTheme, Brightness.light),
  atomOneLight('Atom One', atomOneLightTheme, Brightness.light),
  solarizedLight('Solarized', solarizedLightTheme, Brightness.light),
  xcode('Xcode', xcodeTheme, Brightness.light),
  idea('IntelliJ IDEA', ideaTheme, Brightness.light),
  monokai('Monokai', monokaiTheme, Brightness.dark),
  vs2015('VS 2015', vs2015Theme, Brightness.dark),
  atomOneDark('Atom One Dark', atomOneDarkTheme, Brightness.dark),
  solarizedDark('Solarized', solarizedDarkTheme, Brightness.dark),
  nord('Nord', nordTheme, Brightness.dark),
  androidstudio('Android Studio', androidstudioTheme, Brightness.dark),
  ;

  final String displayName;
  final Map<String, TextStyle> theme;
  final Brightness brightness;

  const SyntaxTheme(this.displayName, this.theme, this.brightness);

  static List<SyntaxTheme> forBrightness(Brightness brightness) {
    return values.where((theme) => theme.brightness == brightness).toList();
  }

  static SyntaxTheme defaultForBrightness(Brightness brightness) {
    return brightness == Brightness.light ? idea : nord;
  }
}