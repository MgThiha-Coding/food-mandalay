import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandalar_x/core/consts/app_font_style.dart';
import 'package:mandalar_x/core/consts/app_images.dart';
import 'package:mandalar_x/features/home/model/restaurant_list_model.dart';
import 'package:mandalar_x/features/home/presentation/mobile/pages/restaurant_menu_page_mobile.dart';

class RestaurantListSection extends ConsumerWidget {
  final List<RestaurantListModel> restaurants;

  const RestaurantListSection({super.key, required this.restaurants});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (restaurants.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text('No Restaurants', style: AppFontStyle.subtitle),
        ),
      );
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      itemCount: restaurants.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final restaurant = restaurants[index];
        return _RestaurantListCard(restaurant: restaurant);
      },
    );
  }
}

class _RestaurantListCard extends ConsumerWidget {
  final RestaurantListModel restaurant;
  const _RestaurantListCard({required this.restaurant});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final img = restaurant.image ?? '';
    final name = restaurant.name ?? '';
    final merchantId = restaurant.ownerId;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                RestaurantMenuPageMobile(merchantId: merchantId!),
          ),
        );
      },
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: AspectRatio(
                  aspectRatio: 2.8,
                  child: img.isEmpty
                      ? SizedBox.expand(
                          child: Image.asset(AppImages.emptyImage),
                        )
                      : Image.network(
                          img,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              SizedBox.expand(
                                child: Image.asset(AppImages.emptyImage),
                              ),
                        ),
                ),
              ),
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.45),
                  ),
                  child: Icon(
                    Icons.favorite_outline,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    name,
                    style: AppFontStyle.label.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Row(
                    children: [
                      Text(
                        '25-30 mins',
                        style: AppFontStyle.caption.copyWith(color: Colors.red),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.delivery_dining, size: 20, color: Colors.red),
                    ],
                  ),
                ],
              ),

              TextButton(
                onPressed: () {},
                child: Text('Explore Menu', style: AppFontStyle.caption),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
