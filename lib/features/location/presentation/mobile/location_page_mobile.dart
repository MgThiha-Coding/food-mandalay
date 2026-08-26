import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mandalar_x/core/consts/app_font_style.dart';
import 'package:mandalar_x/features/checkout/presentation/mobile/check_out_page_mobile.dart';

final selectedLocationProvider = StateProvider<LatLng?>((ref) => null);
final currentLocationProvider = StateProvider<LatLng?>((ref) => null);
final addressProvider = StateProvider<String>((ref) => 'Finding address...');
final loadingProvider = StateProvider<bool>((ref) => true);
final locationDetailsProvider = StateProvider<Placemark?>((ref) => null);

class LocationPageMobile extends ConsumerStatefulWidget {
  const LocationPageMobile({super.key});

  @override
  ConsumerState<LocationPageMobile> createState() => _LocationPageMobileState();
}

class _LocationPageMobileState extends ConsumerState<LocationPageMobile>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final MapController _mapController = MapController();
  LatLng _mapCenter = const LatLng(21.9162, 95.9558);
  Timer? _debounceTimer;
  late AnimationController _revealController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _revealController, curve: Curves.easeOut),
    )..addListener(() => setState(() {}));

    WidgetsBinding.instance.addPostFrameCallback((_) => _checkGpsAndInit());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounceTimer?.cancel();
    _revealController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkGpsAndInit();
  }

  Future<void> _checkGpsAndInit() async {
    ref.read(loadingProvider.notifier).state = true;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ref.read(loadingProvider.notifier).state = false;
      await _showLocation();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        ref.read(loadingProvider.notifier).state = false;
        return;
      }
    }

    await _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      ref.read(loadingProvider.notifier).state = true;

      Position? lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        final latLng = LatLng(lastKnown.latitude, lastKnown.longitude);
        _mapCenter = latLng;
        _mapController.move(latLng, 16);
        ref.read(currentLocationProvider.notifier).state = latLng;
        ref.read(selectedLocationProvider.notifier).state = latLng;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
      final latLng = LatLng(position.latitude, position.longitude);

      _mapCenter = latLng;
      _mapController.move(latLng, 18);
      ref.read(currentLocationProvider.notifier).state = latLng;
      ref.read(selectedLocationProvider.notifier).state = latLng;

      await _reverseGeocodeNearestStreet(latLng);

      _revealController.forward();
    } catch (_) {
      ref.read(addressProvider.notifier).state = 'Finding your location...';
    } finally {
      ref.read(loadingProvider.notifier).state = false;
    }
  }

  Future<void> _reverseGeocodeNearestStreet(LatLng point) async {
    try {
      final placemarks = await placemarkFromCoordinates(point.latitude, point.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        ref.read(locationDetailsProvider.notifier).state = p;
        final street = p.street;
        final locality = p.locality ?? '';
        final admin = p.administrativeArea ?? '';
        ref.read(addressProvider.notifier).state =
            street != null && street.isNotEmpty
                ? street
                : locality.isNotEmpty
                    ? locality
                    : admin;
      } else {
        ref.read(addressProvider.notifier).state = 'Selected Location';
      }
    } catch (_) {
      ref.read(addressProvider.notifier).state = 'Selected Location';
    }
  }

  void _onMapMoveEnd() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 600), () async {
      ref.read(selectedLocationProvider.notifier).state = _mapCenter;
      await _reverseGeocodeNearestStreet(_mapCenter);
    });
  }

  Future<void> _recenterToCurrent() async {
    final current = ref.read(currentLocationProvider);
    if (current != null) {
      _mapController.move(current, 18);
      _mapCenter = current;
      ref.read(selectedLocationProvider.notifier).state = current;
      await _reverseGeocodeNearestStreet(current);
    }
  }

  Future<void> _showLocation() async {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.red, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Enable Location",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "We need your location to show nearby delivery options.",
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    await Geolocator.openLocationSettings();
                  },
                  child: const Text(
                    "Enable Location",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Not now",
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);
    final address = ref.watch(addressProvider);
    final locationDetails = ref.watch(locationDetailsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Opacity(
            opacity: _opacityAnimation.value,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _mapCenter,
                initialZoom: 16,
                minZoom: 5,
                maxZoom: 20,
                onPositionChanged: (pos, hasGesture) {
                  if (hasGesture) {
                    _mapCenter = pos.center;
                    _onMapMoveEnd();
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                  subdomains: ['a', 'b', 'c'],
                  userAgentPackageName: 'com.mandalarx.app',
                ),
              ],
            ),
          ),
          if (_opacityAnimation.value < 1) Container(color: Colors.white),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: const Text('Edit Location', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
                ),
                const SizedBox(height: 10),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(width: 48, height: 48, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red.withOpacity(0.2))),
                    const Icon(Icons.location_pin, size: 42, color: Colors.red),
                    Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white)),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 160,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: _recenterToCurrent,
              child: const Icon(Icons.my_location, color: Colors.black),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.15))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Delivery Address', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  Text(address, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  if (locationDetails != null && (locationDetails.street != null || locationDetails.locality != null))
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(_getLocationDetailsHint(locationDetails), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      final selected = ref.read(selectedLocationProvider);
                      if (selected != null) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => CheckOutPageMobile(selectedLocation: selected)));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size(double.infinity, 46),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('CONFIRM LOCATION', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SpinKitFadingCircle(color: Colors.red),
                    const SizedBox(height: 12),
                    Text('Scanning', style: AppFontStyle.caption.copyWith(color: Colors.grey)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getLocationDetailsHint(Placemark placemark) {
    if (placemark.street != null && placemark.street!.isNotEmpty) return 'Near ${placemark.street!}';
    if (placemark.locality != null && placemark.locality!.isNotEmpty) return 'In ${placemark.locality!} area';
    if (placemark.administrativeArea != null && placemark.administrativeArea!.isNotEmpty) return 'In ${placemark.administrativeArea!} region';
    return '';
  }
}
