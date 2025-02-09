// test/widget_test/home_screen_test.dart
import 'package:acme/controller/task_controller.dart';
import 'package:acme/repositories/task_repository_impl.dart';
import 'package:acme/views/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

// Create a mock repository
class MockTaskRepository extends Mock implements TaskRepositoryImpl {}

void main() {
  late MockTaskRepository mockRepository;
  late TaskController taskController;

  setUp(() {
    mockRepository = MockTaskRepository();
    // Setup basic mock behavior
    taskController = TaskController(mockRepository);
  });

  testWidgets('HomeScreen shows AppBar and FloatingActionButton',
      (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<TaskController>.value(
          value: taskController,
          child: const HomeScreen(),
        ),
      ),
    );

    // Wait for any animations
    await tester.pumpAndSettle();

    // Test 1: Verify AppBar
    final appBarFinder = find.byType(AppBar);
    expect(appBarFinder, findsOneWidget, reason: 'AppBar should be present');

    // Test 2: Verify AppBar title
    final titleFinder = find.text('Tasks');
    expect(titleFinder, findsOneWidget,
        reason: 'AppBar should have "Tasks" title');

    // Test 3: Verify FloatingActionButton
    final fabFinder = find.byType(FloatingActionButton);
    expect(fabFinder, findsOneWidget,
        reason: 'FloatingActionButton should be present');

    // Test 4: Verify FloatingActionButton icon
    final addIconFinder = find.byIcon(Icons.add);
    expect(addIconFinder, findsOneWidget,
        reason: 'FloatingActionButton should have add icon');

    // Test 5: Verify FAB can be tapped and shows dialog
    await tester.tap(fabFinder);
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget,
        reason: 'Dialog should appear after tapping FAB');
  });
}
