import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icons.dart';
import 'package:mandalar_x/core/consts/app_colors.dart';
import 'package:mandalar_x/core/consts/app_font_style.dart';
import 'package:mandalar_x/features/location/data/save_locatoin_notifier.dart';
import 'package:mandalar_x/features/location/presentation/mobile/save_location_page_mobile.dart';
import 'package:mandalar_x/features/message/presentation/mobile/customer_message_page.dart';
import 'package:mandalar_x/features/message/presentation/mobile/chat_page.dart';

class AppBarSearch extends ConsumerWidget {
  const AppBarSearch({super.key});

  static const String customerRoomId = 'customer_support_room';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedLocation = ref.watch(savedLocationProvider);
    final scale = MediaQuery.of(context).size.width / 375;

    // Watch the state, not the notifier
    final chatState = ref.watch(chatProvider(customerRoomId));

    // Get message count safely
    final int messageCount = chatState.messages.value?.length ?? 0;

    return SizedBox(
      height: 40 * scale,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6 * scale),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// LOCATION
            Flexible(
              flex: 2,
              child: InkWell(
                borderRadius: BorderRadius.circular(8 * scale),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SaveLocationPageMobile(),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Icon(
                      LineIcons.mapMarker,
                      color: AppColors.appPrimaryTextColor,
                      size: 24 * scale,
                    ),
                    SizedBox(width: 4 * scale),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            savedLocation == null
                                ? 'Set Address'
                                : _extractStreet(savedLocation.address),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFontStyle.caption.copyWith(
                              fontSize: 12 * scale,
                              fontVariations: const [
                                FontVariation('wght', 600),
                              ],
                            ),
                          ),
                          Text(
                            savedLocation == null
                                ? 'Tap to choose Location'
                                : _extractTownship(savedLocation.address),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14 * scale,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(width: 8 * scale),

            /// MESSENGER WITH BADGE
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const CustomerMessagePage(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.easeInOut;

                          final tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));

                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  icon: const Icon(LineIcons.bell),
                ),

                if (messageCount > 0)
                  Positioned(
                    right: -4,
                    top: -3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        messageCount > 99 ? '99+' : messageCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _extractStreet(String address) {
    final parts = address.split(',');
    return parts.isNotEmpty ? parts.first.trim() : 'Your location';
  }

  String _extractTownship(String address) {
    final parts = address.split(',');
    return parts.length >= 2 ? parts[1].trim() : '';
  }
}
