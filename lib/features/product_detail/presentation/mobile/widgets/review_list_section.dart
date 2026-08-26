import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandalar_x/core/consts/app_font_style.dart';

class ReviewListSection extends ConsumerStatefulWidget {
  final List reviewList;
  const ReviewListSection({super.key, required this.reviewList});

  @override
  ConsumerState<ReviewListSection> createState() => _ReviewListSectionState();
}

class _ReviewListSectionState extends ConsumerState<ReviewListSection> {
  String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} mins ago';
    if (difference.inHours < 24) return '${difference.inHours} hours ago';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} week(s) ago';
    }
    return '${(difference.inDays / 30).floor()} month(s) ago';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        widget.reviewList.length > 2 ? 2 : widget.reviewList.length,
        (index) {
          final item = widget.reviewList[index];
          final userName = (item.userEmail ?? 'Anonymous').split('@')[0];
          final timeText = timeAgo(item.createdAt);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: 22,
                      width: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: AppFontStyle.caption.copyWith(
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            timeText,
                            style: AppFontStyle.caption.copyWith(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.more_vert, size: 16, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.reviews,
                  style: AppFontStyle.caption.copyWith(color: Colors.black87),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Divider(height: 1, color: Colors.grey.shade300),
              ],
            ),
          );
        },
      ),
    );
  }
}