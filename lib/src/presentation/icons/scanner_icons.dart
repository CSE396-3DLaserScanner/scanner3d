// Place fonts/scanner.ttf in your fonts/ directory and
// add the following to your pubspec.yaml
// flutter:
//   fonts:
//    - family: scanner
//      fonts:
//       - asset: fonts/scanner.ttf
import 'package:flutter/widgets.dart';

class Scanner {
  Scanner._();

  static const String _fontFamily = 'scanner';

  static const IconData svg = IconData(0xe900, fontFamily: _fontFamily);
}
