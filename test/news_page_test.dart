import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:testing/article.dart';
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

  void arrangeNewsServiceReturns3ArticlesAfter2SecondDelay() {
    when(() => mockNewsService.getArticles()).thenAnswer(
      (_) async {
        await Future.delayed(const Duration(seconds: 2));
        return articlesFromService;
      },
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

  testWidgets(
    "Title is displayed",
    (WidgetTester tester) async {
      // Arrange articles
      arrangeNewsServiceReturns3Articles();

      // Act: Create invisible widget so that it can be used within the test
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert: Ensure that there is one title 'News' somewhere on the news page
      // Static
      expect(find.text('News'), findsOneWidget);
    },
  );

  testWidgets(
    "Loading indicator is displayed while waiting for articles",
    (WidgetTester tester) async {
      // Arrange articles with delay
      arrangeNewsServiceReturns3ArticlesAfter2SecondDelay();

      // Act: Create invisible widget so that it can be used within the test
      await tester.pumpWidget(createWidgetUnderTest());

      // pump() forces widget rebuild,
      // so the build function inside of the widget is going to run
      await tester.pump(const Duration(milliseconds: 500));

      // Assert: Ensure CircularProgressIndicator is displayed
      // Dynamic
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // expect(find.byKey(const Key('progress-indicator')), findsOneWidget);

      // Wait until there are no more rebuild happening
      // like animation (CircularProgessIndicator)
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    "Articles are displayed",
    (WidgetTester tester) async {
      // Arrange articles with delay
      arrangeNewsServiceReturns3Articles();

      // Act: Create invisible widget so that it can be used within the test
      await tester.pumpWidget(createWidgetUnderTest());
      // rebuild widget
      await tester.pump();

      // Assert: Ensure articles are displayed correctly
      for (final article in articlesFromService) {
        expect(find.text(article.title), findsOneWidget);
        expect(find.text(article.content), findsOneWidget);
      }
    },
  );
}
