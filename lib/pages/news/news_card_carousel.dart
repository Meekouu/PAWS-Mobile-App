import 'package:flutter/material.dart';
import 'package:paws/pages/news/article_model.dart';
import 'package:paws/pages/news/article_details_page.dart';
import 'package:paws/pages/news/news_service.dart';
import 'package:paws/pages/news/all_news_page.dart';
import 'package:paws/themes/themes.dart';

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
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  final carouselHeight = screenHeight * 0.36;
  final imageHeight = carouselHeight * 0.45;

  PageController pageController = PageController(viewportFraction: 0.85);
  int currentPage = 0;

  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "What's New?",
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
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
      SizedBox(
        height: carouselHeight,
        child: isLoading
            ? Center(child: FadeTransition(opacity: _animation))
            : articles.isEmpty
                ? const Center(child: Text("No articles found."))
                : StatefulBuilder(
                    builder: (context, setState) => Column(
                      children: [
                        Expanded(
                          child: PageView.builder(
                            controller: pageController,
                            itemCount: articles.length > 4 ? 4 : articles.length,
                            onPageChanged: (index) {
                              setState(() => currentPage = index);
                            },
                            itemBuilder: (context, index) {
                              final article = articles[index];
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: EdgeInsets.symmetric(
                                    horizontal: index == currentPage ? 4 : 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: secondaryColor,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ArticleDetailsPage(article: article),
                                        ),
                                      );
                                    },
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
                                              height: imageHeight.clamp(80.0, 140.0),
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (context, child, loadingProgress) {
                                                if (loadingProgress == null) return child;
                                                return Container(
                                                  height: imageHeight.clamp(80.0, 140.0),
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
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              children: [
                                                  Column(
                                                  children: [
                                                    article.imageUrl.isEmpty
                                                        ? Center(
                                                            child: Text(
                                                              article.title,
                                                              maxLines: 2,
                                                              overflow: TextOverflow.ellipsis,
                                                              style: const TextStyle(
                                                                fontWeight: FontWeight.w600,
                                                                fontSize: 14,
                                                              ),
                                                              textAlign: TextAlign.center,
                                                            ),
                                                          )
                                                        : Text(
                                                            article.title,
                                                            maxLines: 2,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: const TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 18,
                                                            ),
                                                          ),
                                                    const SizedBox(height: 8),
                                                  ],
                                                ),
                                                  Center(
                                                  child: SizedBox(
                                                    width: double.infinity,
                                                    child: OutlinedButton.icon(
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (_) => ArticleDetailsPage(article: article),
                                                          ),
                                                        );
                                                      },
                                                      icon: const Icon(Icons.article),
                                                      label: const Text("See Full"),
                                                      style: OutlinedButton.styleFrom(
                                                        foregroundColor: primaryColor,
                                                        side: const BorderSide(color: primaryColor),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                        padding: const EdgeInsets.symmetric(vertical: 6),
                                                      ),
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
                                ),
                              );
                            },
                          ),
                        ),
                        // Indicator dots
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            articles.length > 4 ? 4 : articles.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                              width: currentPage == index ? 18 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: currentPage == index ? secondaryColor : Colors.grey[400],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    ],
  );
}
}