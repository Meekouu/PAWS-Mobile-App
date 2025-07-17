class NewsArticle {
  final String title;
  final String description;
  final String imageUrl;
  final String publishedAt;
  final String url;

  NewsArticle({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.publishedAt,
    required this.url,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      imageUrl: json['image'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
      url: json['url'] ?? '',
    );
  }
}
