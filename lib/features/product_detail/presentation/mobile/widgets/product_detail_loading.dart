
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProductDetailLoading extends StatelessWidget {
  const ProductDetailLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.white;
    final highlightColor = Colors.grey[100];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor!,
            child: Container(
              height: 300,
              width: double.infinity,
              color: baseColor,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  child: Container(height: 14, width: 120, color: baseColor),
                ),
                const SizedBox(height: 8),
                Shimmer.fromColors(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  child: Container(
                    height: 20,
                    width: double.infinity,
                    color: baseColor,
                  ),
                ),
                const SizedBox(height: 8),
                Shimmer.fromColors(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  child: Container(height: 18, width: 100, color: baseColor),
                ),
                const SizedBox(height: 12),
                Shimmer.fromColors(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  child: Container(
                    height: 60,
                    width: double.infinity,
                    color: baseColor,
                  ),
                ),
                const SizedBox(height: 16),
                for (int i = 0; i < 2; i++) ...[
                  Shimmer.fromColors(
                    baseColor: baseColor,
                    highlightColor: highlightColor,
                    child: Container(
                      height: 60,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      color: baseColor,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                for (int i = 0; i < 2; i++) ...[
                  Shimmer.fromColors(
                    baseColor: baseColor,
                    highlightColor: highlightColor,
                    child: Container(
                      height: 120,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      color: baseColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
