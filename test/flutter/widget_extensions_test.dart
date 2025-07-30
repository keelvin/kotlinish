import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kotlinish/src/flutter/widget_extensions.dart';

void main() {
  group('Widget Extensions', () {
    testWidgets('padding should wrap widget with Padding', (tester) async {
      const testWidget = Text('Test');
      final paddedWidget = testWidget.padding(16.0);

      expect(paddedWidget, isA<Padding>());

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: paddedWidget)),
      );

      final paddingWidget = tester.widget<Padding>(find.byType(Padding));
      expect(paddingWidget.padding, equals(const EdgeInsets.all(16.0)));
    });

    testWidgets('paddingSymmetric should work correctly', (tester) async {
      const testWidget = Text('Test');
      final paddedWidget = testWidget.paddingSymmetric(
        horizontal: 16.0,
        vertical: 8.0,
      );

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: paddedWidget)),
      );

      final paddingWidget = tester.widget<Padding>(find.byType(Padding));
      expect(
        paddingWidget.padding,
        equals(const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0)),
      );
    });

    testWidgets('center should wrap widget with Center', (tester) async {
      const testWidget = Text('Test');
      final centeredWidget = testWidget.center();

      expect(centeredWidget, isA<Center>());

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: centeredWidget)),
      );

      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('expanded should wrap widget with Expanded', (tester) async {
      const testWidget = Text('Test');
      final expandedWidget = testWidget.expanded(flex: 2);

      expect(expandedWidget, isA<Expanded>());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(children: [expandedWidget]),
          ),
        ),
      );

      final expanded = tester.widget<Expanded>(find.byType(Expanded));
      expect(expanded.flex, equals(2));
    });

    testWidgets('container should create Container with properties', (tester) async {
      const testWidget = Text('Test');
      final containerWidget = testWidget.container(
        color: Colors.red,
        width: 100,
        height: 50,
      );

      expect(containerWidget, isA<Container>());

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: containerWidget)),
      );

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.color, equals(Colors.red));
      expect(container.constraints?.maxWidth, equals(100));
      expect(container.constraints?.maxHeight, equals(50));
    });

    testWidgets('opacity should wrap widget with Opacity', (tester) async {
      const testWidget = Text('Test');
      final opacityWidget = testWidget.opacity(0.5);

      expect(opacityWidget, isA<Opacity>());

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: opacityWidget)),
      );

      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, equals(0.5));
    });

    testWidgets('visible should wrap widget with Visibility', (tester) async {
      const testWidget = Text('Test');
      final visibleWidget = testWidget.visible(false);

      expect(visibleWidget, isA<Visibility>());

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: visibleWidget)),
      );

      final visibility = tester.widget<Visibility>(find.byType(Visibility));
      expect(visibility.visible, equals(false));
    });

    testWidgets('onTap should wrap widget with GestureDetector', (tester) async {
      bool tapped = false;
      const testWidget = Text('Test');
      final tappableWidget = testWidget.onTap(() => tapped = true);

      expect(tappableWidget, isA<GestureDetector>());

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: tappableWidget)),
      );

      await tester.tap(find.byType(Text));
      expect(tapped, isTrue);
    });

    testWidgets('rounded should create Container with border radius', (tester) async {
      const testWidget = Text('Test');
      final roundedWidget = testWidget.rounded(radius: 12.0, color: Colors.blue);

      expect(roundedWidget, isA<Container>());

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: roundedWidget)),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.blue));
      expect(decoration.borderRadius, equals(BorderRadius.circular(12.0)));
    });

    testWidgets('scale should wrap widget with Transform.scale', (tester) async {
      const testWidget = Text('Test');
      final scaledWidget = testWidget.scale(1.5);

      expect(scaledWidget, isA<Transform>());

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: scaledWidget)),
      );

      // Flutter may add multiple Transform widgets, so we just check that our scaled widget exists
      final transforms = find.byType(Transform);
      expect(transforms, findsAtLeastNWidgets(1));

      // Verify our text is still there
      expect(find.text('Test'), findsOneWidget);
    });
  });

  group('Widget List Extensions', () {
    testWidgets('column should create Column from widget list', (tester) async {
      final widgets = [
        const Text('A'),
        const Text('B'),
        const Text('C'),
      ];
      final columnWidget = widgets.column();

      expect(columnWidget, isA<Column>());

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: columnWidget)),
      );

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.children.length, equals(3));
      expect(column.mainAxisAlignment, equals(MainAxisAlignment.start));
      expect(column.crossAxisAlignment, equals(CrossAxisAlignment.center));
    });

    testWidgets('row should create Row from widget list', (tester) async {
      final widgets = [
        const Icon(Icons.star),
        const Text('Rating'),
      ];
      final rowWidget = widgets.row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      );

      expect(rowWidget, isA<Row>());

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: rowWidget)),
      );

      final row = tester.widget<Row>(find.byType(Row));
      expect(row.children.length, equals(2));
      expect(row.mainAxisAlignment, equals(MainAxisAlignment.spaceBetween));
    });

    testWidgets('wrap should create Wrap from widget list', (tester) async {
      final widgets = [
        const Chip(label: Text('Tag 1')),
        const Chip(label: Text('Tag 2')),
        const Chip(label: Text('Tag 3')),
      ];
      final wrapWidget = widgets.wrap(spacing: 8.0);

      expect(wrapWidget, isA<Wrap>());

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: wrapWidget)),
      );

      final wrap = tester.widget<Wrap>(find.byType(Wrap));
      expect(wrap.children.length, equals(3));
      expect(wrap.spacing, equals(8.0));
    });

    testWidgets('stack should create Stack from widget list', (tester) async {
      final widgets = [
        Container(color: Colors.red, width: 100, height: 100),
        Container(color: Colors.blue, width: 50, height: 50),
      ];
      final stackWidget = widgets.stack();

      expect(stackWidget, isA<Stack>());

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: stackWidget)),
      );

      // Find our specific stack by looking for one that contains both containers
      final stacks = find.byType(Stack);
      expect(stacks, findsAtLeastNWidgets(1));

      // Verify both containers are present
      final redContainers = find.byWidgetPredicate(
            (widget) => widget is Container && widget.color == Colors.red,
      );
      final blueContainers = find.byWidgetPredicate(
            (widget) => widget is Container && widget.color == Colors.blue,
      );

      expect(redContainers, findsOneWidget);
      expect(blueContainers, findsOneWidget);
    });

    test('separated should add separators between widgets', () {
      final widgets = [
        const Text('A'),
        const Text('B'),
        const Text('C'),
      ];
      const separator = Divider();

      final result = widgets.separated(separator);

      expect(result.length, equals(5)); // 3 widgets + 2 separators
      expect(result[0], equals(widgets[0]));
      expect(result[1], equals(separator));
      expect(result[2], equals(widgets[1]));
      expect(result[3], equals(separator));
      expect(result[4], equals(widgets[2]));
    });

    test('separated should handle empty list', () {
      final widgets = <Widget>[];
      const separator = Divider();

      final result = widgets.separated(separator);

      expect(result, isEmpty);
    });

    test('separated should handle single widget', () {
      final widgets = [const Text('A')];
      const separator = Divider();

      final result = widgets.separated(separator);

      expect(result.length, equals(1));
      expect(result[0], equals(widgets[0]));
    });

    test('spaced should add SizedBox between widgets', () {
      final widgets = [
        const Text('A'),
        const Text('B'),
      ];

      final result = widgets.spaced(16.0);

      expect(result.length, equals(3)); // 2 widgets + 1 spacer
      expect(result[0], equals(widgets[0]));
      expect(result[1], isA<SizedBox>());
      expect(result[2], equals(widgets[1]));

      final spacer = result[1] as SizedBox;
      expect(spacer.height, equals(16.0));
      expect(spacer.width, equals(16.0));
    });
  });
}