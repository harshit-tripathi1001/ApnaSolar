/// Model representing a verified local solar EPC contractor or site verifier.
class VerifiedInstaller {
  final String id;
  final String name;
  final double rating;
  final int reviewsCount;
  final double distanceKm;
  final int pricePerKw;
  final int turnaroundDays;
  final int totalInstallations;
  final String primaryBrand;
  final String inverterBrand;
  final List<String> badges;
  final String phone;
  final String location;
  final bool isTopPick;
  final String status;
  final DateTime? selectedAt;

  const VerifiedInstaller({
    required this.id,
    required this.name,
    required this.rating,
    required this.reviewsCount,
    required this.distanceKm,
    required this.pricePerKw,
    required this.turnaroundDays,
    required this.totalInstallations,
    required this.primaryBrand,
    required this.inverterBrand,
    required this.badges,
    required this.phone,
    this.location = 'Bengaluru, Karnataka',
    this.isTopPick = false,
    this.status = 'Site Audit Scheduled',
    this.selectedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'distanceKm': distanceKm,
      'pricePerKw': pricePerKw,
      'turnaroundDays': turnaroundDays,
      'totalInstallations': totalInstallations,
      'primaryBrand': primaryBrand,
      'inverterBrand': inverterBrand,
      'badges': badges,
      'phone': phone,
      'location': location,
      'isTopPick': isTopPick,
      'status': status,
      'selectedAt': selectedAt?.toIso8601String(),
    };
  }

  factory VerifiedInstaller.fromJson(Map<String, dynamic> json) {
    return VerifiedInstaller(
      id: json['id'] as String? ?? 'installer_1',
      name: json['name'] as String? ?? 'Verified Solar Partner',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      reviewsCount: (json['reviewsCount'] as num?)?.toInt() ?? 100,
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 3.5,
      pricePerKw: (json['pricePerKw'] as num?)?.toInt() ?? 52000,
      turnaroundDays: (json['turnaroundDays'] as num?)?.toInt() ?? 14,
      totalInstallations: (json['totalInstallations'] as num?)?.toInt() ?? 250,
      primaryBrand: json['primaryBrand'] as String? ?? 'Tata Power Solar',
      inverterBrand: json['inverterBrand'] as String? ?? 'Growatt Cloud',
      badges:
          (json['badges'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['MNRE Empanelled'],
      phone: json['phone'] as String? ?? '+91 98450 12345',
      location: json['location'] as String? ?? 'Bengaluru, Karnataka',
      isTopPick: json['isTopPick'] as bool? ?? false,
      status: json['status'] as String? ?? 'Site Audit Scheduled',
      selectedAt: json['selectedAt'] != null
          ? DateTime.tryParse(json['selectedAt'] as String)
          : null,
    );
  }

  VerifiedInstaller copyWith({String? status, DateTime? selectedAt}) {
    return VerifiedInstaller(
      id: id,
      name: name,
      rating: rating,
      reviewsCount: reviewsCount,
      distanceKm: distanceKm,
      pricePerKw: pricePerKw,
      turnaroundDays: turnaroundDays,
      totalInstallations: totalInstallations,
      primaryBrand: primaryBrand,
      inverterBrand: inverterBrand,
      badges: badges,
      phone: phone,
      location: location,
      isTopPick: isTopPick,
      status: status ?? this.status,
      selectedAt: selectedAt ?? this.selectedAt,
    );
  }

  /// Default verified EPC contractors for the regional directory
  static const List<VerifiedInstaller> defaultInstallers = [
    VerifiedInstaller(
      id: 'inst_sunvolt',
      name: 'SunVolt Energy Solutions',
      rating: 4.9,
      reviewsCount: 142,
      distanceKm: 2.4,
      pricePerKw: 52000,
      turnaroundDays: 12,
      totalInstallations: 340,
      primaryBrand: 'Tata Power Solar',
      inverterBrand: 'Growatt Cloud',
      badges: ['MNRE Empanelled', 'BESCOM Certified', 'Top Rated'],
      phone: '+91 98450 12345',
      location: 'Indiranagar, Bengaluru',
      isTopPick: true,
    ),
    VerifiedInstaller(
      id: 'inst_suryashakti',
      name: 'SuryaShakti Rooftop EPC',
      rating: 4.8,
      reviewsCount: 98,
      distanceKm: 3.8,
      pricePerKw: 50500,
      turnaroundDays: 14,
      totalInstallations: 215,
      primaryBrand: 'Waaree Energies',
      inverterBrand: 'Sungrow Grid-Tie',
      badges: ['DISCOM Empanelled', '25-Yr Warranty'],
      phone: '+91 98860 67890',
      location: 'Koramangala, Bengaluru',
    ),
    VerifiedInstaller(
      id: 'inst_apex',
      name: 'Apex CleanTech Systems',
      rating: 4.9,
      reviewsCount: 186,
      distanceKm: 4.5,
      pricePerKw: 53500,
      turnaroundDays: 10,
      totalInstallations: 460,
      primaryBrand: 'Adani Solar TopCon',
      inverterBrand: 'Enphase Microinverters',
      badges: ['Premium EPC', 'Fastest Turnaround'],
      phone: '+91 94480 34567',
      location: 'HSR Layout, Bengaluru',
      isTopPick: true,
    ),
    VerifiedInstaller(
      id: 'inst_greenray',
      name: 'GreenRay Solar Works',
      rating: 4.7,
      reviewsCount: 64,
      distanceKm: 4.2,
      pricePerKw: 49000,
      turnaroundDays: 16,
      totalInstallations: 135,
      primaryBrand: 'Vikram Solar',
      inverterBrand: 'Havells Solis',
      badges: ['Best Value', 'Zero Advance'],
      phone: '+91 97410 45678',
      location: 'Whitefield, Bengaluru',
    ),
    VerifiedInstaller(
      id: 'inst_urjaveda',
      name: 'UrjaVeda Renewables',
      rating: 4.8,
      reviewsCount: 115,
      distanceKm: 5.9,
      pricePerKw: 51000,
      turnaroundDays: 15,
      totalInstallations: 280,
      primaryBrand: 'Goldi Solar',
      inverterBrand: 'GoodWe Smart',
      badges: ['MNRE Empanelled', 'Free 5-Yr O&M'],
      phone: '+91 99000 78901',
      location: 'Jayanagar, Bengaluru',
    ),
    VerifiedInstaller(
      id: 'inst_solaredge',
      name: 'SolarEdge Karnataka EPC',
      rating: 4.9,
      reviewsCount: 210,
      distanceKm: 3.1,
      pricePerKw: 54000,
      turnaroundDays: 11,
      totalInstallations: 520,
      primaryBrand: 'Tata Power Mono',
      inverterBrand: 'SolarEdge Smart',
      badges: ['Master Tier', 'BESCOM Fast-Track'],
      phone: '+91 94800 23456',
      location: 'Domlur, Bengaluru',
      isTopPick: true,
    ),
    VerifiedInstaller(
      id: 'inst_vidyut',
      name: 'Vidyut Mitra Solar Tech',
      rating: 4.7,
      reviewsCount: 82,
      distanceKm: 6.8,
      pricePerKw: 48500,
      turnaroundDays: 18,
      totalInstallations: 190,
      primaryBrand: 'RenewSys Mono',
      inverterBrand: 'Solis Inverters',
      badges: ['Budget Champion', 'Govt Verified'],
      phone: '+91 98440 89012',
      location: 'Malleshwaram, Bengaluru',
    ),
    VerifiedInstaller(
      id: 'inst_ecogrid',
      name: 'EcoGrid Technologies',
      rating: 4.6,
      reviewsCount: 54,
      distanceKm: 7.4,
      pricePerKw: 49500,
      turnaroundDays: 15,
      totalInstallations: 95,
      primaryBrand: 'Waaree Bifacial',
      inverterBrand: 'Growatt Cloud',
      badges: ['Free 3D Audit', 'Local Crew'],
      phone: '+91 96110 34567',
      location: 'Electronic City, Bengaluru',
    ),
    VerifiedInstaller(
      id: 'inst_prakriti',
      name: 'Prakriti Power Infra',
      rating: 4.8,
      reviewsCount: 77,
      distanceKm: 8.5,
      pricePerKw: 51800,
      turnaroundDays: 13,
      totalInstallations: 165,
      primaryBrand: 'Adani Mono PERC',
      inverterBrand: 'Sungrow Dual MPPT',
      badges: ['DISCOM Empanelled', 'Chemical Earthing'],
      phone: '+91 98800 90123',
      location: 'Yelahanka, Bengaluru',
    ),
  ];
}
