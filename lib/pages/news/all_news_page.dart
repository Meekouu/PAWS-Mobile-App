import 'package:flutter/material.dart';
import 'package:paws/pages/news/article_model.dart';
import 'package:paws/pages/news/article_details_page.dart';

class AllNewsPage extends StatelessWidget {
  final List<Article> articles;

  const AllNewsPage({super.key, required this.articles});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Veterinary News'),
      ),
      body: ListView.separated(
        itemCount: articles.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final article = articles[index];
          return ListTile(
            leading: article.imageUrl.isNotEmpty
                ? Image.network(
                    article.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.broken_image),
            title: Text(article.title),
            subtitle: Text(article.description ?? ''),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ArticleDetailsPage(article: article),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
