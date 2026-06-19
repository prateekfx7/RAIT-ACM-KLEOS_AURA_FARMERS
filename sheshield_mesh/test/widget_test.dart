import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheshield_mesh/main.dart';

void main() {
  testWidgets('SheShield Mesh app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SheShieldMeshApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
