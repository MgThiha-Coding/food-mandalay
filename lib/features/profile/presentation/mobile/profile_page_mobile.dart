import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandalar_x/core/consts/app_colors.dart';
import 'package:mandalar_x/core/consts/app_font_style.dart';
import 'package:mandalar_x/core/consts/app_storage.dart';
import 'package:mandalar_x/features/auth/data/sign_out_notifier.dart';
import 'package:mandalar_x/features/auth/presentation/continue_with_google_page.dart';
import 'package:mandalar_x/features/favourites/presentation/favourite_page.dart';
import 'package:mandalar_x/features/order_history/presentation/order_history_page.dart';
import 'package:mandalar_x/shared/app_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePageMobile extends ConsumerStatefulWidget {
  const ProfilePageMobile({super.key});

  @override
  ConsumerState<ProfilePageMobile> createState() => _ProfilePageMobileState();
}

class _ProfilePageMobileState extends ConsumerState<ProfilePageMobile> {
  bool _navigated = false;
  User? user;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      setState(() {
        user = Supabase.instance.client.auth.currentUser;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final signOutState = ref.watch(signOutNotifierProvider);

    ref.listen<AsyncValue>(signOutNotifierProvider, (previous, next) {
      next.when(
        data: (_) {
          if (!_navigated) {
            _navigated = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                AppStorage.setLoggedIn(false);
                AppStorage.clearLoggedIn();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ContinueWithGooglePage(),
                  ),
                );
              }
            });
          }
        },
        error: (error, stack) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error.toString(), style: AppFontStyle.body),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        loading: () {},
      );
    });

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const SizedBox(height: 25),

            /// User Info
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.red,
                  child: const Icon(
                    Icons.person,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.email ?? 'Guest', style: AppFontStyle.label),
                      const SizedBox(height: 4),
                      Text('Member since 2026', style: AppFontStyle.caption),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Divider(),

            Expanded(
              child: GridView(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2.3,
                ),
                children: [
                  // Edit Profile Button
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {},
                    child: DottedBorder(
                      options: RoundedRectDottedBorderOptions(
                        color: Colors.grey,
                        dashPattern: const [8, 4],
                        strokeWidth: 1.5,
                        radius: const Radius.circular(10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.edit,
                              size: 18,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Edit Profile',
                              style: AppFontStyle.subtitle.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Orders History Button
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderHistoryPage(),
                        ),
                      );
                    },
                    child: DottedBorder(
                      options: RoundedRectDottedBorderOptions(
                        color: Colors.grey,
                        dashPattern: const [8, 4],
                        strokeWidth: 1.5,
                        radius: const Radius.circular(10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.history,
                              size: 18,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Order History',
                              style: AppFontStyle.subtitle.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FavouritePage(),
                        ),
                      );
                    },
                    child: DottedBorder(
                      options: RoundedRectDottedBorderOptions(
                        color: Colors.grey,
                        dashPattern: const [8, 4],
                        strokeWidth: 1.5,
                        radius: const Radius.circular(10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.favorite,
                              size: 18,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Favourites',
                              style: AppFontStyle.subtitle.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {},
                    child: DottedBorder(
                      options: RoundedRectDottedBorderOptions(
                        color: Colors.grey,
                        dashPattern: const [8, 4],
                        strokeWidth: 1.5,
                        radius: const Radius.circular(10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.language,
                              size: 18,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Language',
                              style: AppFontStyle.subtitle.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Spacer(),

            /// Sign Out
            SizedBox(
              height: 50,
              width: double.infinity,
              child: AppButton(
                title: "Sign Out",
                isLoading: signOutState.isLoading,
                onTap: () {
                  ref.read(signOutNotifierProvider.notifier).signOut();
                },
                backgroundColor: AppColors.primaryColor,
                labelColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
