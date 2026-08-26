import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandalar_x/core/consts/app_font_style.dart';
import 'package:mandalar_x/features/home/data/product_list_notifier.dart';

// Holds the current random search hint
final randomSearchHintProvider = StateProvider<String?>((ref) => '');

// Widget that shows and animates random product names as search hint
class AnimatedRandomSearchHint extends ConsumerStatefulWidget {
  const AnimatedRandomSearchHint({super.key});

  @override
  ConsumerState<AnimatedRandomSearchHint> createState() =>
      _AnimatedRandomSearchHintState();
}

class _AnimatedRandomSearchHintState
    extends ConsumerState<AnimatedRandomSearchHint>
    with SingleTickerProviderStateMixin {
  List<String> _names = [];
  int _index = 0;
  bool _started = false;

  void _startRotation() {
    if (_names.isEmpty || _started) return;
    _started = true;

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return false;

      setState(() {
        _index = (_index + 1) % _names.length;
      });

      // Update provider with the current hint
      ref.read(randomSearchHintProvider.notifier).state = _names[_index];

      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productListNotifierProvider);

    return productAsync.when(
      data: (products) {
        // Only initialize once when we have data
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_names.isNotEmpty) return;
          if (products.isEmpty) return;

          final names = products
              .map((e) => e.productName ?? '')
              .where((e) => e.isNotEmpty)
              .toList();

          if (names.isEmpty) return;

          names.shuffle();

          setState(() {
            _names = names;
            _index = 0;
          });

          // Set initial value for outside use
          ref.read(randomSearchHintProvider.notifier).state = _names.first;

          // Start rotation
          _startRotation();
        });

        if (_names.isEmpty) {
          // Nothing to show yet
          return const SizedBox.shrink();
        }

        return SizedBox(
          height: 20,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, animation) {
              final slide = Tween<Offset>(
                begin: const Offset(0, 0.6),
                end: Offset.zero,
              ).animate(animation);

              return SlideTransition(
                position: slide,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: Text(
              _names[_index],
              key: ValueKey(_names[_index]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFontStyle.caption.copyWith(color: Colors.red),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
