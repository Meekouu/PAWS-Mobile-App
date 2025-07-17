import 'package:flutter/material.dart';
import 'news_article.dart';

class NewsDetailPage extends StatelessWidget {
  final NewsArticle article;
  const NewsDetailPage({required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('News Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(article.title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(article.publishedAt.substring(0, 10), style: TextStyle(color: Colors.grey)),
            SizedBox(height: 16),
            if (article.imageUrl.isNotEmpty)
              Image.network(article.imageUrl),
            SizedBox(height: 16),
            Text(article.description, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
