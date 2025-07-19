import 'package:flutter/material.dart';
import 'package:paws/pages/news/article_model.dart';

class LikeBookmarkButtons extends StatefulWidget {
  final Article article;
  final VoidCallback? onUpdate;

  const LikeBookmarkButtons({super.key, required this.article, this.onUpdate});

  @override
  State<LikeBookmarkButtons> createState() => _LikeBookmarkButtonsState();
}

class _LikeBookmarkButtonsState extends State<LikeBookmarkButtons> {
  void _toggleBookmark() {
    setState(() {
      widget.article.isBookmarked = !widget.article.isBookmarked;
    });
    widget.onUpdate?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            widget.article.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            color: widget.article.isBookmarked ? Colors.blue : Colors.grey,
          ),
          onPressed: _toggleBookmark,
        ),
      ],
    );
  }
}
