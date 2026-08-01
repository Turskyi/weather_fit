class NominatimLocationResponse {
  const NominatimLocationResponse({
    required this.placeId,
    required this.name,
    required this.displayName,
    required this.lat,
    required this.lon,
    required this.addressType,
    this.address = const <String, Object?>{},
  });

  factory NominatimLocationResponse.fromJson(Map<String, Object?> json) {
    final Map<String, Object?> address = json['address'] is Map<String, Object?>
        ? json['address'] as Map<String, Object?>
        : <String, Object?>{};

    return NominatimLocationResponse(
      placeId: int.parse(json['place_id'].toString()),
      name: json['name'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      lat: json['lat'] as String? ?? '',
      lon: json['lon'] as String? ?? '',
      addressType: json['addresstype'] as String? ?? '',
      address: address,
    );
  }

  final int placeId;
  final String name;
  final String displayName;
  final String lat;
  final String lon;
  final String addressType;
  final Map<String, Object?> address;

  bool get isCountry => addressType == 'country';
}
