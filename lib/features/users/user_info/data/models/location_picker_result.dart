/// Result returned from the location picker
class LocationPickerResult {
  final double latitude;
  final double longitude;
  final String locationName;

  const LocationPickerResult({
    required this.latitude,
    required this.longitude,
    required this.locationName,
  });
}
