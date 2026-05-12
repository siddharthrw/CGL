import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_lab/theme.dart';

void main() {
  group('Theme Unit Tests', () {
    test('Color constants are properly defined', () {
      expect(bg, equals(const Color(0xff030303)));
      expect(card, equals(const Color(0xff111111)));
      expect(green, equals(const Color(0xff00ff88)));
    });
  });
}
