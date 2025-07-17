import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'news_article.dart';
import 'news_card.dart';
import 'saved_articles_page.dart';

class GNewsFeedPage extends StatefulWidget {
  @override
  _GNewsFeedPageState createState() => _GNewsFeedPageState();
}

class _GNewsFeedPageState extends State<GNewsFeedPage> {
  List<NewsArticle> _articles = [];
  bool _isLoading = false;
  bool _hasMore = true;

  int _page = 1;
  int _totalPages = 10;

  String _query = "pet+care";
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  final String _apiKey = 'd2d4e3b8c474009c41ca7f7f361e37e5';
  final List<String> _categories = [
    'All', 'Pets', 'Dog', 'Cat', 'Animal Health', 'Veterinary', 'Pet Nutrition'
  ];

  Future<void> fetchNews({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _page = 1;
        _articles.clear();
      });
    }

    setState(() {
      _isLoading = true;
    });

    final query = _query.isEmpty
        ? (_selectedCategory == 'All' ? 'pets' : _selectedCategory)
        : _query;

    final url =
        'https://gnews.io/api/v4/search?q=$query&lang=en&max=5&page=$_page&apikey=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List articles = data['articles'];

        setState(() {
          _articles = articles.map((json) => NewsArticle.fromJson(json)).toList();
          _hasMore = _page < _totalPages;
        });
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      print('❌ Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearch() {
    setState(() {
      _query = _searchController.text.trim().replaceAll(' ', '+');
      _page = 1;
    });
    fetchNews(refresh: true);
  }

  void _showCategoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: _categories.map((category) {
            return ListTile(
              title: Text(category),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedCategory = category;
                  _query = '';
                  _searchController.clear();
                  _page = 1;
                });
                fetchNews(refresh: true);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _goToNextPage() {
    if (_hasMore) {
      setState(() {
        _page++;
      });
      fetchNews();
    }
  }

  void _goToPreviousPage() {
    if (_page > 1) {
      setState(() {
        _page--;
      });
      fetchNews();
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F9FC),
      appBar: AppBar(
        title: Text("Vet News"),
        backgroundColor: Color(0xFF4A90E2),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SavedArticlesPage()),
            ),
          )
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (value) => _onSearch(),
                    decoration: InputDecoration(
                      hintText: 'Search news...',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.filter_alt_rounded, color: Colors.white),
                  onPressed: _showCategoryBottomSheet,
                ),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => fetchNews(refresh: true),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _articles.isEmpty
                ? Center(child: Text("No news articles found."))
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: _articles.length,
                          itemBuilder: (context, index) {
                            return NewsCard(post: _articles[index]);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_back_ios_new),
                              onPressed: _page > 1 ? _goToPreviousPage : null,
                            ),
                            Text('Page $_page'),
                            IconButton(
                              icon: Icon(Icons.arrow_forward_ios),
                              onPressed: _hasMore ? _goToNextPage : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          }
