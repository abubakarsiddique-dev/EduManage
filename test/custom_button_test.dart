import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_management_system/core/widgets/custom_button.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: child),
      ),
    );
  }

  group('CustomButton & CustomOutlineButton Tests', () {
    testWidgets('renders button label and handles tap event', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        buildTestableWidget(
          CustomButton(
            label: 'Submit Application',
            onPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.text('Submit Application'), findsOneWidget);
      await tester.tap(find.text('Submit Application'));
      expect(tapped, isTrue);
    });

    testWidgets('displays CircularProgressIndicator when isLoading is true', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const CustomButton(
            label: 'Saving Data',
            isLoading: true,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Saving Data'), findsNothing);
    });

    testWidgets('renders prefix and suffix icons properly', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const CustomButton(
            label: 'Download Report',
            icon: Icons.download,
            suffixIcon: Icons.arrow_forward,
          ),
        ),
      );

      expect(find.byIcon(Icons.download), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
      expect(find.text('Download Report'), findsOneWidget);
    });

    testWidgets('CustomOutlineButton displays label and responds to clicks', (tester) async {
      bool outlineTapped = false;

      await tester.pumpWidget(
        buildTestableWidget(
          CustomOutlineButton(
            label: 'Cancel',
            onPressed: () => outlineTapped = true,
          ),
        ),
      );

      expect(find.text('Cancel'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      expect(outlineTapped, isTrue);
    });
  });
}
