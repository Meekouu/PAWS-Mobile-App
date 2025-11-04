import 'package:flutter/material.dart';
import 'package:paws/themes/themes.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:paws/pages/news/article_model.dart';

class ArticleDetailsPage extends StatelessWidget {
  final Article article;

  const ArticleDetailsPage({super.key, required this.article});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          article.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  article.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 180,
                    color: Colors.grey[300],
                    child: const Center(child: Icon(Icons.broken_image, size: 50)),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Text(
              article.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Published: ${article.publishedAt}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const Divider(height: 24),
            Text(
              article.content.isNotEmpty
              ? article.content.replaceAll(RegExp(r'\s*\[\+\d+\schars\]'), '…')
              : article.description,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 24),
            if (article.url.isNotEmpty)
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => _launchURL(article.url),
                  icon: const Icon(Icons.open_in_browser, color: Colors.white),
                  label: const Text("Read Full Article",
                  style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
