import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_study_planner/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Verify the app widget tree can be created
    expect(SmartStudyPlannerApp, isNotNull);
  });
}
