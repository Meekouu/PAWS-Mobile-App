import 'package:flutter/material.dart';

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
        title: const Text("Vet News & Updates"),
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
                  icon: const Icon(Icons.notifications_none),
                  tooltip: "Notifications",
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
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
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.pinkAccent,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
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

  const NewsCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(post['avatar']!),
                  radius: 22,
                ),
                const SizedBox(width: 12),
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
                      const SizedBox(height: 2),
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

          if (post['image'] != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(0)),
              child: Image.asset(
                post['image']!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
              ),
            ),

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
