class NominatimLocationResponse {
  const NominatimLocationResponse({
    required this.placeId,
    required this.name,
    required this.displayName,
    required this.lat,
    required this.lon,
    required this.addressType,
  });

  factory NominatimLocationResponse.fromJson(Map<String, Object?> json) {
    return NominatimLocationResponse(
      placeId: int.parse(json['place_id'].toString()),
      name: json['name'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      lat: json['lat'] as String? ?? '',
      lon: json['lon'] as String? ?? '',
      addressType: json['addresstype'] as String? ?? '',
    );
  }

  final int placeId;
  final String name;
  final String displayName;
  final String lat;
  final String lon;
  final String addressType;

  bool get isCountry => addressType == 'country';
}
