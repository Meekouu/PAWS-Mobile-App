import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GNewsFeedPage extends StatefulWidget {
  const GNewsFeedPage({super.key});

  @override
  State<GNewsFeedPage> createState() => _GNewsFeedPageState();
}

class _GNewsFeedPageState extends State<GNewsFeedPage> {
  final String apiKey = 'd2d4e3b8c474009c41ca7f7f361e37e5';
  final String apiUrl = 'https://gnews.io/api/v4/search';

  List articles = [];
  List<String> recentSearches = [];
  List<String> likedArticles = [];
  List bookmarkedArticles = [];
  int page = 1;
  String query = 'veterinary';
  String category = 'pets';
  bool isLoading = false;
  int totalPages = 1;
  final List<String> categories = [
    'veterinary',
    'pet health',
    'animal welfare',
    'animal nutrition',
    'pet care',
    'vaccine',
    'zoonotic disease'
  ];

  @override
  void initState() {
    super.initState();
    fetchArticles();
    loadRecentSearches();
    loadBookmarks();
  }

  Future<void> fetchArticles({bool refresh = false}) async {
    if (refresh) page = 1;
    setState(() => isLoading = true);
    final response = await http.get(Uri.parse(
        '$apiUrl?q=$query&lang=en&token=$apiKey&max=5&page=$page'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        totalPages = (data['totalArticles'] / 5).ceil();
        if (refresh) {
          articles = data['articles'];
        } else {
          articles.addAll(data['articles']);
        }
      });
    }
    setState(() => isLoading = false);
  }

  Future<void> loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => recentSearches = prefs.getStringList('recentSearches') ?? []);
  }

  Future<void> saveRecentSearch(String search) async {
    final prefs = await SharedPreferences.getInstance();
    if (!recentSearches.contains(search)) {
      recentSearches.insert(0, search);
      if (recentSearches.length > 10) recentSearches = recentSearches.sublist(0, 10);
      await prefs.setStringList('recentSearches', recentSearches);
    }
  }

  Future<void> loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => bookmarkedArticles = jsonDecode(prefs.getString('bookmarkedArticles') ?? '[]'));
  }

  Future<void> toggleBookmark(article) async {
    final prefs = await SharedPreferences.getInstance();
    if (bookmarkedArticles.any((a) => a['url'] == article['url'])) {
      bookmarkedArticles.removeWhere((a) => a['url'] == article['url']);
    } else {
      bookmarkedArticles.add(article);
    }
    await prefs.setString('bookmarkedArticles', jsonEncode(bookmarkedArticles));
    setState(() {});
  }

  bool isBookmarked(article) => bookmarkedArticles.any((a) => a['url'] == article['url']);

  void openDetails(article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(article['title'])),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (article['image'] != null)
                    Image.network(article['image'], errorBuilder: (_, __, ___) => const SizedBox()),
                  const SizedBox(height: 10),
                  Text(
                    article['content'] ?? article['description'] ?? '',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: const InputDecoration(hintText: 'Search veterinary news'),
            onSubmitted: (value) {
              setState(() => query = value);
              saveRecentSearch(value);
              fetchArticles(refresh: true);
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () async {
            final selected = await showDialog<String>(
              context: context,
              builder: (context) => SimpleDialog(
                title: const Text('Select Category'),
                children: categories.map((c) => SimpleDialogOption(
                      child: Text(c),
                      onPressed: () => Navigator.pop(context, c),
                    )).toList(),
              ),
            );
            if (selected != null) {
              setState(() {
                query = selected;
                saveRecentSearch(selected);
              });
              fetchArticles(refresh: true);
            }
          },
        )
      ],
    );
  }

  Widget buildArticleCard(article) {
    return Dismissible(
      key: Key(article['url']),
      onDismissed: (_) => setState(() => articles.remove(article)),
      background: Container(color: Colors.red),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: InkWell(
          onTap: () => openDetails(article),
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
                    onPressed: () => toggleBookmark(article),
                  ),
                  IconButton(
                    icon: Icon(
                      likedArticles.contains(article['url'])
                          ? Icons.thumb_up_alt
                          : Icons.thumb_up_alt_outlined,
                      color: likedArticles.contains(article['url']) ? Colors.teal : null,
                    ),
                    onPressed: () => toggleLike(article['url']),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void toggleLike(String url) {
    setState(() {
      if (likedArticles.contains(url)) {
        likedArticles.remove(url);
      } else {
        likedArticles.add(url);
      }
    });
  }

  Widget buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: page > 1
              ? () {
                  setState(() => page--);
                  fetchArticles();
                }
              : null,
        ),
        Text('Page $page of $totalPages'),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: page < totalPages
              ? () {
                  setState(() => page++);
                  fetchArticles();
                }
              : null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Veterinary News'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmarks),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Scaffold(
                  appBar: AppBar(title: const Text('Saved Articles')),
                  body: ListView(
                    children: bookmarkedArticles.map(buildArticleCard).toList(),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => fetchArticles(refresh: true),
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: [
            buildSearchBar(),
            Wrap(
              spacing: 8,
              children: recentSearches
                  .map((s) => ActionChip(
                        label: Text(s),
                        onPressed: () {
                          setState(() => query = s);
                          fetchArticles(refresh: true);
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(height: 10),
            ...articles.map(buildArticleCard),
            if (isLoading) const Center(child: CircularProgressIndicator()),
            if (!isLoading) buildPagination(),
          ],
        ),
      ),
    );
  }
}
