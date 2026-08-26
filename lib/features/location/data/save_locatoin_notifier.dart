import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:mandalar_x/features/location/model/save_location_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedLocationNotifier extends StateNotifier<SavedLocation?> {
  SavedLocationNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('saved_location');
    if (raw != null) state = SavedLocation.fromJson(jsonDecode(raw));
  }

  Future<void> save(LatLng latLng, String address) async {
    final prefs = await SharedPreferences.getInstance();
    final data = SavedLocation(lat: latLng.latitude, lng: latLng.longitude, address: address);
    await prefs.setString('saved_location', jsonEncode(data.toJson()));
    state = data;
  }
}

final savedLocationProvider =
    StateNotifierProvider<SavedLocationNotifier, SavedLocation?>((ref) => SavedLocationNotifier());