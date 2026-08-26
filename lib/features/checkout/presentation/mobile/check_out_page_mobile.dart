import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:latlong2/latlong.dart';
import 'package:mandalar_x/core/consts/app_colors.dart';
import 'package:mandalar_x/core/consts/app_font_style.dart';
import 'package:mandalar_x/features/cart/data/cart_notifier.dart';
import 'package:mandalar_x/features/home/data/product_list_notifier.dart';
import 'package:mandalar_x/features/location/data/save_locatoin_notifier.dart';
import 'package:mandalar_x/features/location/presentation/mobile/save_location_page_mobile.dart';
import 'package:mandalar_x/features/order_history/data/order_notifier.dart';
import 'package:geocoding/geocoding.dart';
import 'package:mandalar_x/features/orderflow/order_flow_demo_page.dart';
import 'package:mandalar_x/shared/app_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final selectedLocationWithAddressProvider =
    StateProvider<Map<String, dynamic>?>((ref) => null);

class CheckOutPageMobile extends ConsumerStatefulWidget {
  final LatLng? selectedLocation;
  const CheckOutPageMobile({super.key, this.selectedLocation});

  @override
  ConsumerState<CheckOutPageMobile> createState() => _CheckOutPageMobileState();
}

class _CheckOutPageMobileState extends ConsumerState<CheckOutPageMobile> {
  final TextEditingController _deliveryInstructionsController =
      TextEditingController();

  @override
  void dispose() {
    _deliveryInstructionsController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(productListNotifierProvider.notifier).fetchProductList();
      ref.read(cartNotifierProvider.notifier).fetchCartItems();

      if (widget.selectedLocation != null) {
        await _getAddressFromLatLng(widget.selectedLocation!);
      }
    });
  }

  Future<void> _getAddressFromLatLng(LatLng location) async {
    setState(() {});

    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final address = [
          if (placemark.street != null && placemark.street!.isNotEmpty)
            placemark.street,
          if (placemark.subLocality != null &&
              placemark.subLocality!.isNotEmpty)
            placemark.subLocality,
          if (placemark.locality != null && placemark.locality!.isNotEmpty)
            placemark.locality,
          if (placemark.subAdministrativeArea != null &&
              placemark.subAdministrativeArea!.isNotEmpty)
            placemark.subAdministrativeArea,
          if (placemark.administrativeArea != null &&
              placemark.administrativeArea!.isNotEmpty)
            placemark.administrativeArea,
          if (placemark.country != null && placemark.country!.isNotEmpty)
            placemark.country,
        ].where((element) => element != null && element.isNotEmpty).join(', ');

        setState(() {});

        ref.read(selectedLocationWithAddressProvider.notifier).state = {
          'lat': location.latitude,
          'lng': location.longitude,
          'address': address,
          'street': placemark.street ?? "",
          'locality': placemark.locality ?? "",
          'area': placemark.subLocality ?? placemark.locality ?? "",
        };
      } else {
        setState(() {});
      }
    } catch (e) {
      setState(() {});
    } finally {
      setState(() {});
    }
  }

  String getFormattedPrice(double? price) {
    if (price == null) return '';
    return price.truncateToDouble() == price
        ? price.toInt().toString()
        : price.toString();
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartNotifierProvider);
    final selectedLocation = ref.watch(selectedLocationWithAddressProvider);
    final savedLocation = ref.watch(savedLocationProvider);

    final totalPrice = cartState.when(
      data: (data) {
        if (data.isEmpty) return 0.0;

        return data.fold<double>(
          0.0,
          (sum, e) => sum + (e.finalPrice * e.itemCount),
        );
      },
      loading: () => 0.0,
      error: (_, __) => 0.0,
    );
    final deliveryFee = (selectedLocation != null || savedLocation != null) &&
        cartState.value != null
      ? cartState.value!
          .map((item) => item.ownerId ?? 'unknown')
          .toSet()
          .length * deliveryFeePerRestaurant
      : 0.0;

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Check Out',
          style: AppFontStyle.title.copyWith(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Column(
                children: [
                  SizedBox(
                    height: 150,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 100,
                        height: 200,
                        child: savedLocation != null
                            ? FlutterMap(
                                options: MapOptions(
                                  initialCenter: LatLng(
                                    savedLocation.lat,
                                    savedLocation.lng,
                                  ),
                                  initialZoom: 19,
                                  interactionOptions: const InteractionOptions(
                                    flags: InteractiveFlag.none,
                                  ),
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://cartodb-basemaps-a.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'com.mandalarx.app',
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: LatLng(
                                          savedLocation.lat,
                                          savedLocation.lng,
                                        ),
                                        width: 30,
                                        height: 30,
                                        child: const Icon(
                                          Icons.location_pin,
                                          color: Colors.red,
                                          size: 30,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : Container(
                                color: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.map_outlined,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                    ),
                  ),

                  /// LOCATION SELECT / EDIT
                  SizedBox(
                    height: 80,
                    width: double.infinity,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: Colors.red.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                savedLocation != null
                                    ? savedLocation.address.split(',').first
                                    : 'Delivery Address',
                                style: AppFontStyle.caption.copyWith(
                                  color: savedLocation != null
                                      ? Colors.black
                                      : Colors.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                savedLocation != null
                                    ? savedLocation.address
                                    : 'Tap to select delivery location',
                                style: AppFontStyle.label.copyWith(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    height: 40,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: AppColors.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const SaveLocationPageMobile(),
                          ),
                        );

                        if (result != null && result is LatLng) {
                          await _getAddressFromLatLng(result);
                        }
                      },
                      child: Text(
                        savedLocation != null
                            ? 'Edit Location'
                            : 'Select Location',
                        style: AppFontStyle.label.copyWith(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// DELIVERY INSTRUCTIONS (UNCHANGED)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Delivery Instructions (Optional)',
                            style: AppFontStyle.label.copyWith(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _deliveryInstructionsController,
                          maxLength: 60,
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: "Note to riders - eg. landmark",
                            hintStyle: AppFontStyle.label.copyWith(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 8,
                            ),
                            border: const UnderlineInputBorder(),
                            focusedBorder: const UnderlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.summarize_outlined, color: Colors.red),
                  const SizedBox(width: 6),
                  Text(
                    'Order Summary',
                    style: AppFontStyle.label.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal',
                    style: AppFontStyle.label.copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${getFormattedPrice(totalPrice)}Ks',
                    style: AppFontStyle.label.copyWith(color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Delivery Fee',
                    style: AppFontStyle.label.copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${getFormattedPrice(deliveryFee)}Ks',
                    style: AppFontStyle.label.copyWith(color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              /*
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Discount',
                    style: AppFontStyle.label.copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '0 %',
                    style: AppFontStyle.label.copyWith(color: Colors.green),
                  ),
                ],
              ),
              */
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: AppFontStyle.label.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'MMK ${getFormattedPrice(totalPrice + deliveryFee)}',
                    style: AppFontStyle.label.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              SizedBox(
                height: 50,
                width: double.infinity,
                child: Consumer(
                  builder: (context, ref, _) {
                    final savedLocation = ref.watch(savedLocationProvider);
                    final selectedLocation = ref.watch(
                      selectedLocationWithAddressProvider,
                    );
                    final cartState = ref.watch(cartNotifierProvider);
                    final orderState = ref.watch(orderNotifierProvider);
                    final location = savedLocation ?? selectedLocation;
                    final isLocationSelected = location != null;
                    final cartReady =
                        cartState is AsyncData &&
                        cartState.value != null &&
                        cartState.value!.isNotEmpty;

                    final isLoading = orderState is AsyncLoading;

                    final canPlaceOrder =
                        isLocationSelected && cartReady && !isLoading;

                    String buttonText;
                    Color buttonColor;

                    if (!isLocationSelected) {
                      buttonText = 'Select Location First';
                      buttonColor = Colors.grey.shade400;
                    } else if (isLoading) {
                      buttonText = 'Loading';
                      buttonColor = AppColors.primaryColor;
                    } else {
                      buttonText = 'Please fill Phone Number';
                      buttonColor = canPlaceOrder
                          ? AppColors.primaryColor
                          : Colors.grey.shade400;
                    }

                    return AppButton(
                      title: buttonText,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VerifyPhoneNumber(
                              deliveryInstructions:
                                  _deliveryInstructionsController.text.trim(),
                            ),
                          ),
                        );
                      },

                      //canPlaceOrder ? _placeOrder : () {},
                      backgroundColor: buttonColor,
                      labelColor: Colors.white,
                      isLoading: isLoading,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VerifyPhoneNumber extends ConsumerStatefulWidget {
  final String? deliveryInstructions;
  const VerifyPhoneNumber({super.key, this.deliveryInstructions});

  @override
  ConsumerState<VerifyPhoneNumber> createState() => _VerifyPhoneNumberState();
}

class _VerifyPhoneNumberState extends ConsumerState<VerifyPhoneNumber> {
  final TextEditingController phoneNumberController = TextEditingController();
  bool isPhoneFilled = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    phoneNumberController.addListener(() {
      setState(() {
        isPhoneFilled = phoneNumberController.text.trim().length >= 9;
      });
    });
  }

  void _placeOrderWithoutOtp() async {
    if (!isPhoneFilled || isLoading) return;

    setState(() => isLoading = true);

    try {
      final cartState = ref.read(cartNotifierProvider);
      final savedLocation = ref.read(savedLocationProvider);
      final selectedLocation = ref.read(selectedLocationWithAddressProvider);
      final locationMap = savedLocation != null
          ? {
              'lat': savedLocation.lat,
              'lng': savedLocation.lng,
              'address': savedLocation.address,
            }
          : selectedLocation;

      if (cartState is AsyncData &&
          cartState.value != null &&
          cartState.value!.isNotEmpty &&
          locationMap != null) {
        final success = await ref
            .read(orderNotifierProvider.notifier)
            .placeOrder(
              cartItems: cartState.value!,
              deliveryLocation: locationMap,
              userName: _customerName(),
              userPhone: phoneNumberController.text,
              deliveryInstructions: widget.deliveryInstructions ?? "",
            );

        if (!success) {
          Fluttertoast.showToast(
            msg: "Something went wrong. Your cart was kept.",
            backgroundColor: Colors.red,
          );
          return;
        }

        await ref.read(cartNotifierProvider.notifier).clearCart();

        if (!mounted) return;

        Fluttertoast.showToast(
          msg: "Order placed successfully!",
          backgroundColor: Colors.black87,
          textColor: Colors.white,
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OrderFlowDemoPage()),
        );
      } else {
        Fluttertoast.showToast(
          msg: "Cannot place order. Check cart or location.",
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Something went wrong!",
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  String _customerName() {
    final user = Supabase.instance.client.auth.currentUser;
    final metadata = user?.userMetadata;
    return (metadata?['full_name'] ??
            metadata?['name'] ??
            user?.email ??
            'Customer')
        .toString();
  }

  @override
  void dispose() {
    phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        backgroundColor: AppColors.appBackground,
        elevation: 0,
        title: Text("Verify Phone", style: AppFontStyle.label),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              ' Please enter your mobile number\n to place the order.',
              style: AppFontStyle.label.copyWith(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 20),
            TextFormField(
              keyboardType: TextInputType.number,
              controller: phoneNumberController,
              decoration: InputDecoration(
                hintText: "Enter your mobile number",
                labelText: "Mobile Number",
                labelStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // BUTTON AREA
            SizedBox(
              width: double.infinity,
              height: 50,
              child: AppButton(
                title: "Place Order",
                onTap: isPhoneFilled ? _placeOrderWithoutOtp : () {},
                backgroundColor: isPhoneFilled
                    ? Colors.red
                    // ignore: deprecated_member_use
                    : Colors.grey.withOpacity(0.4),
                labelColor: Colors.white,
                isLoading: isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
