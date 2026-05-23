class CaregiverModel {
  final String id;
  final String userId;
  final String name;
  final String phone;
  final String? profileImage;
  final String bio;
  final String location;
  final double hourlyRate;
  final int experienceYears;
  final List<String> specializations; // e.g. ['infant', 'autism', 'elderly']
  final List<String> availability;    // e.g. ['Mon', 'Tue', 'Wed']
  final double rating;
  final int reviewCount;
  final bool isVerified;
  final bool isAvailable;
  final String? certifications;
  final int age;
  final String gender;

  CaregiverModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    this.profileImage,
    required this.bio,
    required this.location,
    required this.hourlyRate,
    required this.experienceYears,
    required this.specializations,
    required this.availability,
    required this.rating,
    required this.reviewCount,
    required this.isVerified,
    required this.isAvailable,
    this.certifications,
    required this.age,
    required this.gender,
  });

  factory CaregiverModel.fromMap(Map<String, dynamic> map, String id) {
    return CaregiverModel(
      id: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      profileImage: map['profileImage'],
      bio: map['bio'] ?? '',
      location: map['location'] ?? '',
      hourlyRate: (map['hourlyRate'] ?? 0).toDouble(),
      experienceYears: map['experienceYears'] ?? 0,
      specializations: List<String>.from(map['specializations'] ?? []),
      availability: List<String>.from(map['availability'] ?? []),
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      isVerified: map['isVerified'] ?? false,
      isAvailable: map['isAvailable'] ?? true,
      certifications: map['certifications'],
      age: map['age'] ?? 0,
      gender: map['gender'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'phone': phone,
      'profileImage': profileImage,
      'bio': bio,
      'location': location,
      'hourlyRate': hourlyRate,
      'experienceYears': experienceYears,
      'specializations': specializations,
      'availability': availability,
      'rating': rating,
      'reviewCount': reviewCount,
      'isVerified': isVerified,
      'isAvailable': isAvailable,
      'certifications': certifications,
      'age': age,
      'gender': gender,
    };
  }

  // Matching score for hybrid algorithm
  double matchScore(Map<String, dynamic> parentPrefs) {
    double score = 0;

    // Content-based: specialization match
    final neededSpecs = List<String>.from(parentPrefs['specializations'] ?? []);
    for (final spec in neededSpecs) {
      if (specializations.contains(spec)) score += 20;
    }

    // Location match
    if (location == parentPrefs['location']) score += 15;

    // Budget match
    final maxBudget = (parentPrefs['maxBudget'] ?? 999999).toDouble();
    if (hourlyRate <= maxBudget) score += 10;

    // Experience weight
    score += (experienceYears * 2).clamp(0, 20).toDouble();

    // Rating weight
    score += rating * 3;

    // Availability
    final neededDays = List<String>.from(parentPrefs['availability'] ?? []);
    for (final day in neededDays) {
      if (availability.contains(day)) score += 3;
    }

    return score;
  }
}
