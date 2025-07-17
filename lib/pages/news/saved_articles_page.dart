import 'package:flutter/material.dart';

class SavedArticlesPage extends StatelessWidget {
  final List savedArticles;
  final Function(dynamic) onToggleBookmark;
  final bool Function(dynamic) isBookmarked;

  const SavedArticlesPage({
    super.key,
    required this.savedArticles,
    required this.onToggleBookmark,
    required this.isBookmarked,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Articles')),
      body: savedArticles.isEmpty
          ? const Center(child: Text("No saved articles yet."))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: savedArticles.length,
              itemBuilder: (context, index) {
                final article = savedArticles[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Scaffold(
                            appBar: AppBar(title: Text(article['title'])),
                            body: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.network(
                                    article['image'] ?? '',
                                    errorBuilder: (_, __, ___) => const SizedBox(),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(article['description'] ?? '', style: const TextStyle(fontSize: 16)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (article['image'] != null)
                          Image.network(
                            article['image'],
                            errorBuilder: (_, __, ___) => Container(
                              height: 100,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(8),
                              child: Text(article['title'] ?? '', style: const TextStyle(fontSize: 16)),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            article['title'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        ButtonBar(
                          alignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(
                                isBookmarked(article) ? Icons.bookmark : Icons.bookmark_border,
                              ),
                              onPressed: () => onToggleBookmark(article),
                            ),
                            IconButton(
                              icon: const Icon(Icons.thumb_up_alt_outlined),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
