import 'package:flutter/material.dart';
import 'package:paws/pages/news/article_model.dart';
import 'package:paws/pages/news/article_details_page.dart';
import 'package:paws/pages/news/news_service.dart';
import 'package:paws/pages/news/like_bookmark_buttons.dart';
import 'package:paws/pages/news/all_news_page.dart';

class NewsCardCarousel extends StatefulWidget {
  @override
  _NewsCardCarouselState createState() => _NewsCardCarouselState();
}

class _NewsCardCarouselState extends State<NewsCardCarousel>
    with SingleTickerProviderStateMixin {
  List<Article> articles = [];
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat(reverse: true);
    _animation = Tween(begin: 0.5, end: 1.0).animate(_controller);
    fetchNews();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> fetchNews() async {
    try {
      final fetched = await NewsService.fetchArticles();
      setState(() {
        articles = fetched;
        isLoading = false;
      });
    } catch (e) {
      print("Failed to fetch articles: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header Row with "See All"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Veterinary News',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AllNewsPage(articles: articles),
                    ),
                  );
                },
                child: const Text(
                  'See All',
                  style: TextStyle(fontWeight: FontWeight.w600, decoration: TextDecoration.underline, color: Colors.black),
                ),
              ),
            ],
          ),
        ),

        SizedBox(
          height: 280, // Limit the total height to avoid overflow
          child: isLoading
              ? Center(
                  child: FadeTransition(
                    opacity: _animation,
                  ),
                )
              : articles.isEmpty
                  ? const Center(child: Text("No articles found."))
                  : ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20, right: 10, top: 10, bottom: 10),
            itemCount: articles.length > 4 ? 4 : articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArticleDetailsPage(article: article),
                    ),
                  );
                },
                child: Container(
                  width: 260,
                  margin: const EdgeInsets.only(right: 15),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (article.imageUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Image.network(
                            article.imageUrl,
                            height: 110,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 110,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 10, 8, 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                article.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              LikeBookmarkButtons(article: article),
                              const Spacer(), // Pushes the button to the bottom
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ArticleDetailsPage(article: article),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.article),
                                  label: const Text("See Full"),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.teal,
                                    side: const BorderSide(color: Colors.teal),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
