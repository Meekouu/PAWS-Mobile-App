import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:paws/pages/news/article_model.dart';

class NewsService {
  static const _apiKey = '2ba572d6e5184bb4b08d7b4851d781f5';

  static const _baseUrl = 'https://newsapi.org/v2/everything';

  static Future<List<Article>> fetchArticles() async {
    final uri = Uri.parse('$_baseUrl?q=veterinary+animals+pets&language=en&sortBy=publishedAt&pageSize=20&apiKey=$_apiKey');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List articles = data['articles'];
      return articles.map((e) => Article.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load articles. Status Code: ${response.statusCode}');
    }
  }
}
