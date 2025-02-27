import 'package:assignment/presentation/pages/user_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:assignment/data/models/user_model.dart';

void main() {
  // Test setup to mock user data
  final UserModel mockUser = UserModel(
    id: 1,
    first_name: 'John',
    last_name: 'Doe',
    avatar: 'https://example.com/avatar.jpg',
    email: 'john.doe@example.com',
  );

  testWidgets('UserDetailScreen displays the correct user name in the AppBar', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: UserDetailScreen(user: mockUser),
      ),
    );

    // Verify the AppBar displays the correct user name
     expect(find.byType(Image), findsNothing);
    expect(find.text('John Doe'), findsOneWidget);

  });

  testWidgets('UserDetailScreen displays the correct email', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: UserDetailScreen(user: mockUser),
      ),
    );

    // Verify that the email text is displayed correctly
    expect(find.byType(Image), findsNothing);
    expect(find.text('john.doe@example.com'), findsOneWidget);
  });

  testWidgets('Animations run correctly on UserDetailScreen', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: UserDetailScreen(user: mockUser),
      ),
    );

    final photoSlideAnimation = tester.widget<SlideTransition>(find.byType(SlideTransition).first);
    final emailSlideAnimation = tester.widget<SlideTransition>(find.byType(SlideTransition).last);

    // we expect the photo to be above and the email to be below
    expect(photoSlideAnimation.position, isNot(equals(Offset.zero)));
    expect(emailSlideAnimation.position, isNot(equals(Offset.zero)));

    await tester.pumpAndSettle();

    // verify the elements are in their final position
    expect(photoSlideAnimation.position, equals(Offset.zero));
    expect(emailSlideAnimation.position, equals(Offset.zero));
  });


}



