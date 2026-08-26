import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandalar_x/core/consts/app_colors.dart';
import 'package:mandalar_x/core/consts/app_font_style.dart';
import 'package:mandalar_x/features/home/data/product_list_notifier.dart';
import 'package:mandalar_x/features/review/data/product_review_notifier.dart';

class ReviewPageMobile extends ConsumerStatefulWidget {
  final String? productId;
  const ReviewPageMobile({super.key, this.productId});

  @override
  ConsumerState<ReviewPageMobile> createState() => _ReviewPageMobileState();
}

class _ReviewPageMobileState extends ConsumerState<ReviewPageMobile> {
  final TextEditingController reviewController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productListNotifierProvider.notifier).fetchProductList(page: 0);
      if (widget.productId != null) {
        ref
            .read(productReviewNotifierProvider.notifier)
            .fetchReviews(int.parse(widget.productId!));
      }
    });
  }

  void submitReview() {
    ref
        .read(productReviewNotifierProvider.notifier)
        .addReview(
          productId: widget.productId!,
          reviewText: reviewController.text,
        );
    reviewController.clear();
  }

  String timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    }
    final months = (diff.inDays / 30).floor();
    return '$months month${months > 1 ? 's' : ''} ago';
  }

  @override
  Widget build(BuildContext context) {
    final reviewsAsync = ref.watch(productReviewNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      resizeToAvoidBottomInset: true,

      appBar: AppBar(
        backgroundColor: Colors.red,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Customer Reviews',
          style: AppFontStyle.label.copyWith(color: Colors.white),
        ),
      ),

      /// -------------------- BODY --------------------
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: reviewsAsync.when(
          data: (data) {
            if (data.isEmpty) {
              return Center(
                child: Text(
                  'Be the first to review this item',
                  style: AppFontStyle.caption,
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 90),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                final userName = (item.userEmail ?? 'Anonymous').split('@')[0];
                final timeText = timeAgo(item.createdAt);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Header
                      Row(
                        children: [
                          Container(
                            height: 22,
                            width: 22,
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
                          const Icon(
                            Icons.more_vert,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      /// Review
                      Text(
                        item.reviews,
                        style: AppFontStyle.caption.copyWith(
                          color: Colors.black87,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),
                      Divider(height: 1, color: Colors.grey.shade300),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(e.toString())),
        ),
      ),

      /// -------------------- INPUT BAR --------------------
      bottomNavigationBar: AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          top: false,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: reviewController,
                    style: AppFontStyle.caption,
                    decoration: InputDecoration(
                      hintText: 'Write a review…',
                      hintStyle: AppFontStyle.caption.copyWith(
                        color: Colors.grey,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.send, size: 20, color: Colors.red),
                  onPressed: submitReview,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
