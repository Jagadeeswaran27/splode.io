import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client/presentation/core/utils/responsive_layout.dart';
import 'package:client/presentation/core/widgets/responsive_content_container.dart';

void main() {
  group('ResponsiveLayout Utilities & ResponsiveContentContainer', () {
    testWidgets('reports correct breakpoint flags based on viewport width',
        (tester) async {
      late bool isCompact;
      late bool isMedium;
      late bool isExpanded;
      late bool isShort;

      Widget buildTest(Size size) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        return MaterialApp(
          home: Builder(
            builder: (context) {
              isCompact = context.isCompact;
              isMedium = context.isMedium;
              isExpanded = context.isExpanded;
              isShort = context.isShortScreen;
              return const SizedBox();
            },
          ),
        );
      }

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Test compact mobile portrait (390 x 844)
      await tester.pumpWidget(buildTest(const Size(390, 844)));
      expect(isCompact, isTrue);
      expect(isMedium, isFalse);
      expect(isExpanded, isFalse);
      expect(isShort, isFalse);

      // Test short landscape phone (720 x 360)
      await tester.pumpWidget(buildTest(const Size(720, 360)));
      expect(isCompact, isFalse);
      expect(isMedium, isTrue);
      expect(isExpanded, isFalse);
      expect(isShort, isTrue);

      // Test expanded desktop (1280 x 800)
      await tester.pumpWidget(buildTest(const Size(1280, 800)));
      expect(isCompact, isFalse);
      expect(isMedium, isFalse);
      expect(isExpanded, isTrue);
      expect(isShort, isFalse);
    });

    testWidgets('constrains child width to maxWidth on large screens',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveContentContainer(
              maxWidth: 400,
              child: SizedBox(
                width: double.infinity,
                height: 100,
                key: Key('child_box'),
              ),
            ),
          ),
        ),
      );

      final childBox = tester.getRect(find.byKey(const Key('child_box')));
      expect(childBox.width, equals(400.0));
      // Child should be horizontally centered within the 1200px viewport
      expect(childBox.left, equals(400.0));
      expect(childBox.right, equals(800.0));
    });

    testWidgets('allows child to fill available width when screen is smaller than maxWidth',
        (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveContentContainer(
              maxWidth: 500,
              child: SizedBox(
                width: double.infinity,
                height: 100,
                key: Key('child_box'),
              ),
            ),
          ),
        ),
      );

      final childBox = tester.getRect(find.byKey(const Key('child_box')));
      expect(childBox.width, equals(360.0));
    });
  });
}

