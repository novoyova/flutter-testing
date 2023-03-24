import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:testing/article.dart';
import 'package:testing/news_change_notifier.dart';
import 'package:testing/news_service.dart';

// This is not how you should make your mock classes
class BadMockNewsService implements NewsService {
  bool getArticlesCalled = false;

  @override
  Future<List<Article>> getArticles() async {
    getArticlesCalled = true;
    return [
      Article(title: 'Test 1', content: 'Test 1 content'),
      Article(title: 'Test 2', content: 'Test 2 content'),
      Article(title: 'Test 3', content: 'Test 3 content'),
    ];
  }
}

// Allow us to make self implementation of individual test
class MockNewsService extends Mock implements NewsService {}

void main() {
  late NewsChangeNotifier sut; // system under test
  late MockNewsService mockNewsService;

  setUp(() {
    mockNewsService = MockNewsService();
    sut = NewsChangeNotifier(mockNewsService);
  });

  // Testing variables
  test(
    'Initial values are correct',
    () {
      expect(sut.articles, []);
      expect(sut.isLoading, false);
    },
  );

  // When testing method, it is recommended to use group
  group('getArticles', () {
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

    test(
      "gets articles using NewsService",
      () async {
        // Arrange
        arrangeNewsServiceReturns3Articles();
        // Act
        await sut.getArticles();
        // Assert
        verify(() => mockNewsService.getArticles()).called(1);
      },
    );

    test(
      """Indicates loading of data, 
      sets articles to the ones from the service, 
      indicates that data is not being loaded anymore""",
      () async {
        // Arrange
        arrangeNewsServiceReturns3Articles();
        // Act
        final future = sut.getArticles();
        expect(sut.isLoading, true);
        await future;
        expect(sut.articles, articlesFromService);
        expect(sut.isLoading, false);
        // Assert
      },
    );
  });
}
