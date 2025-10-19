import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pathopredict_app/main.dart';

void main() {
  testWidgets('App builds', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartParkingSenseApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
