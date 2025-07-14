import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class NewsFeedPage extends StatelessWidget {
  final List<Map<String, String>> newsPosts = [
    {
      "title": "Lorem Ipsum",
      "time": "2 hours ago",
      "content": "Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit...",
      "image": "assets/images/cat1.jpeg",
      "avatar": "assets/images/avatar.jpg"
    },
    {
      "title": "Lorem Ipsum",
      "time": "5 hours ago",
      "content": "Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit...",
      "image": "assets/images/dog1.jpeg",
      "avatar": "assets/images/avatar.jpg"
    },
    {
      "title": "Lorem Ipsum",
      "time": "1 day ago",
      "content": "Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit...",
      "image": "assets/images/cat1.jpeg",
      "avatar": "assets/images/avatar.jpg"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Vet News & Updates"),
        backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  icon: Icon(Icons.notifications_none),
                  tooltip: "Notifications",
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("No new notifications."),
                        backgroundColor: Colors.teal,
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.pinkAccent,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(minWidth: 8, minHeight: 8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      body: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        itemCount: newsPosts.length,
        itemBuilder: (context, index) {
          return NewsCard(post: newsPosts[index]);
        },
      ),
    );
  }
}

class NewsCard extends StatelessWidget {
  final Map<String, String> post;

  const NewsCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(post['avatar']!),
                  radius: 22,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['title']!,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.teal[900],
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        post['time']!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.more_vert, color: Colors.grey[600]),
              ],
            ),
          ),

          // Image
          if (post['image'] != null)
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
              child: Image.asset(
                post['image']!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
              ),
            ),

          // Body Text
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Text(
              post['content']!,
              style: TextStyle(
                fontSize: 14.5,
                height: 1.4,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
