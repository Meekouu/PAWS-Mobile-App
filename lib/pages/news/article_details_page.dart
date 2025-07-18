import 'package:flutter/material.dart';
import 'package:paws/pages/news/article_model.dart';

class ArticleDetailsPage extends StatelessWidget {
  final Article article;

  const ArticleDetailsPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(article.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(article.imageUrl),
              ),
            const SizedBox(height: 12),
            Text(article.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(article.publishedAt, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            Text(article.content.isNotEmpty ? article.content : article.description),
          ],
        ),
      ),
    );
  }
}
