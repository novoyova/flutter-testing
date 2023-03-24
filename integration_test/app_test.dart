/*
Since integration test is expensive and slow to run,
they should be reserved for really testing the app overall,
testing the UI flow, testing what the user can do 
from a very user based perspective and from a higher level integration.

Tests should be used very sparingly,
you should definitely not have the same amount of integration tests 
as you have the amount tests or widget tests.

Integration test there should be few of them and be high quality.
*/

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:testing/article.dart';
import 'package:testing/article_page.dart';
import 'package:testing/news_change_notifier.dart';
import 'package:testing/news_page.dart';
import 'package:testing/news_service.dart';

class MockNewsService extends Mock implements NewsService {}

void main() {
  late MockNewsService mockNewsService;

  setUp(() {
    mockNewsService = MockNewsService();
  });

  final articlesFromService = [
    Article(title: 'Test 1', content: 'Test 1 content'),
    Article(title: 'Test 2', content: 'Test 2 content'),
    Article(title: 'Test 3', content: 'Test 3 content'),
  ];

  void arrangeNewsServiceReturns3Articles() {
    when(() => mockNewsService.getArticles()).thenAnswer(
      (_) async => articlesFromService,
    );
  }

  Widget createWidgetUnderTest() {
    return MaterialApp(
      title: 'News App',
      home: ChangeNotifierProvider(
        create: (_) => NewsChangeNotifier(mockNewsService),
        child: const NewsPage(),
      ),
    );
  }

  // Testing the whole app
  testWidgets(
    """Tapping on the first article excerpt opens the article page
    where the full article content is displayed""",
    (WidgetTester tester) async {
      // Arrange articles
      arrangeNewsServiceReturns3Articles();

      // Act: create invisible widget
      await tester.pumpWidget(createWidgetUnderTest());
      // for initialize and init state to run
      await tester.pump();
      // tap content in article which after tapping take us to article page
      await tester.tap(find.text('Test 1 content'));
      await tester.pumpAndSettle();

      // Assert: check if we are in article page and no longer in news page
      expect(find.byType(NewsPage), findsNothing);
      expect(find.byType(ArticlePage), findsOneWidget);
      // check if title and content displayed on article page
      expect(find.text('Test 1'), findsOneWidget);
      expect(find.text('Test 1 content'), findsOneWidget);
    },
  );
}
