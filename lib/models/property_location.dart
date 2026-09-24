/// Model representing a user's property address and geospatial coordinates.
class PropertyLocation {
  final String formattedAddress;
  final String locality;
  final String city;
  final String state;
  final String postalCode;
  final double latitude;
  final double longitude;
  final double peakSunHoursPerDay;

  const PropertyLocation({
    required this.formattedAddress,
    required this.locality,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.latitude,
    required this.longitude,
    this.peakSunHoursPerDay = 5.2,
  });

  /// Default mock property in Indiranagar, Bengaluru
  factory PropertyLocation.mockIndiranagar() {
    return const PropertyLocation(
      formattedAddress:
          '42, 14th Main Rd, HAL 2nd Stage, Indiranagar, Bengaluru, KA 560038',
      locality: 'Indiranagar',
      city: 'Bengaluru',
      state: 'Karnataka',
      postalCode: '560038',
      latitude: 12.9719,
      longitude: 77.6412,
      peakSunHoursPerDay: 5.2,
    );
  }
}
