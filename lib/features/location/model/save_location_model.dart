class SavedLocation {
  final double lat;
  final double lng;
  final String address;

  SavedLocation({required this.lat, required this.lng, required this.address});

  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng, 'address': address};

  factory SavedLocation.fromJson(Map<String, dynamic> json) {
    return SavedLocation(
      lat: json['lat'],
      lng: json['lng'],
      address: json['address'],
    );
  }
}
