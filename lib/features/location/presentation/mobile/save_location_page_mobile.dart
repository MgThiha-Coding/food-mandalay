import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mandalar_x/core/consts/app_colors.dart';
import 'package:mandalar_x/core/consts/app_font_style.dart';
import 'package:mandalar_x/features/location/data/save_locatoin_notifier.dart';

final _selectedLocationProvider = StateProvider<LatLng?>((ref) => null);
final _currentLocationProvider = StateProvider<LatLng?>((ref) => null);
final _addressProvider = StateProvider<String>((ref) => 'Finding address...');
final _loadingProvider = StateProvider<bool>((ref) => true);
final _locationDetailsProvider = StateProvider<Placemark?>((ref) => null);

class SaveLocationPageMobile extends ConsumerStatefulWidget {
  const SaveLocationPageMobile({super.key});
  @override
  ConsumerState<SaveLocationPageMobile> createState() =>
      _SaveLocationPageMobileState();
}

class _SaveLocationPageMobileState extends ConsumerState<SaveLocationPageMobile>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final MapController _mapController = MapController();
  LatLng _mapCenter = const LatLng(21.9162, 95.9558);
  Timer? _debounce;
  late AnimationController _fadeController;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut))
      ..addListener(() {
        setState(() {});
      });

    WidgetsBinding.instance.addPostFrameCallback((_) => _checkGpsAndInit());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _fadeController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkGpsAndInit();
  }

  Future<void> _checkGpsAndInit() async {
    ref.read(_loadingProvider.notifier).state = true;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ref.read(_loadingProvider.notifier).state = false;
      await _showEnableLocationModal();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      ref.read(_loadingProvider.notifier).state = false;
      return;
    }

    Position? lastKnown = await Geolocator.getLastKnownPosition();
    if (lastKnown != null) {
      final latLng = LatLng(lastKnown.latitude, lastKnown.longitude);
      ref.read(_currentLocationProvider.notifier).state = latLng;
      ref.read(_selectedLocationProvider.notifier).state = latLng;
      _mapCenter = latLng;
      WidgetsBinding.instance.addPostFrameCallback((_) => _mapController.move(latLng, 16));
      _reverseGeocode(latLng);
      _fadeController.forward();
    }

    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      ref.read(_loadingProvider.notifier).state = true;
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
      final latLng = LatLng(pos.latitude, pos.longitude);

      ref.read(_currentLocationProvider.notifier).state = latLng;
      ref.read(_selectedLocationProvider.notifier).state = latLng;
      _mapCenter = latLng;
      WidgetsBinding.instance.addPostFrameCallback((_) => _mapController.move(latLng, 18));
      _reverseGeocode(latLng);
      _fadeController.forward();
    } catch (_) {
      ref.read(_addressProvider.notifier).state = 'Finding your location...';
    } finally {
      ref.read(_loadingProvider.notifier).state = false;
    }
  }

  Future<void> _reverseGeocode(LatLng point) async {
    try {
      final placemarks = await placemarkFromCoordinates(point.latitude, point.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        ref.read(_locationDetailsProvider.notifier).state = p;
        final nearestStreet = p.street ?? '';
        final locality = p.locality ?? '';
        final admin = p.administrativeArea ?? '';
        ref.read(_addressProvider.notifier).state =
            '${nearestStreet.isNotEmpty ? nearestStreet : locality}, $admin'.replaceAll(RegExp(r'^,|,$'), '');
      }
    } catch (_) {}
  }

  void _onMapMoveEnd() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 1), () async {
      ref.read(_selectedLocationProvider.notifier).state = _mapCenter;
      _reverseGeocode(_mapCenter);
    });
  }

  Future<void> _recenterToCurrent() async {
    final current = ref.read(_currentLocationProvider);
    if (current != null) {
      _mapController.move(current, 18);
      _mapCenter = current;
      ref.read(_selectedLocationProvider.notifier).state = current;
      _reverseGeocode(current);
    }
  }

  Future<void> _showEnableLocationModal() async {
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
                        Text("Enable Location",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        SizedBox(height: 4),
                        Text("We need your location to show nearby delivery options.",
                            style: TextStyle(fontSize: 13, color: Colors.black54)),
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
                  onPressed: () async {
                    Navigator.pop(context);
                    await Geolocator.openLocationSettings();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  child: const Text("Enable Location",
                      style: TextStyle(
                          fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Not now", style: TextStyle(color: Colors.black54)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(_loadingProvider);
    final address = ref.watch(_addressProvider);
    final locationDetails = ref.watch(_locationDetailsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Opacity(
            opacity: _fade.value,
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
                  }),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 2))
                      ]),
                  child: const Text('Edit Location',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 10),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red.withOpacity(0.2),
                      ),
                    ),
                    const Icon(Icons.location_pin, size: 42, color: Colors.red),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 200,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: _recenterToCurrent,
              child: const Icon(Icons.my_location, color: Colors.black),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10)
                  ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Saved Address', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 6),
                  Text(address, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  if (locationDetails != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(_getLocationDetailsHint(locationDetails),
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      final selected = ref.read(_selectedLocationProvider);
                      if (selected != null) {
                        await ref.read(savedLocationProvider.notifier).save(selected, address);
                        if (!context.mounted) return;
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size(double.infinity, 46),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: Text('SAVE LOCATION',
                        style: AppFontStyle.label.copyWith(color: AppColors.appBackground)),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 15,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.45),
                      ),
                      child: Icon(Icons.arrow_back_ios, color: Colors.white, size: 16),
                    ),
                  ),
                ),
                SizedBox.shrink(),
              ],
            ),
          ),
          if (loading)
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
    if (placemark.street != null && placemark.street!.isNotEmpty) {
      return 'Near ${placemark.street!}';
    }
    if (placemark.locality != null && placemark.locality!.isNotEmpty) {
      return 'In ${placemark.locality!} area';
    }
    if (placemark.administrativeArea != null && placemark.administrativeArea!.isNotEmpty) {
      return 'In ${placemark.administrativeArea!} region';
    }
    return '';
  }
}
