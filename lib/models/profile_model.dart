class ProfileModel {
  final String id;
  final String name;
  final String title;
  final String? bio;
  final String email;
  final String? phone;
  final String? location;
  final String? avatarUrl;
  final String? resumeUrl;
  final String? quote;
  final int? yearsOfExperience;

  const ProfileModel({
    required this.id,
    required this.name,
    required this.title,
    this.bio,
    required this.email,
    this.phone,
    this.location,
    this.avatarUrl,
    this.resumeUrl,
    this.quote,
    this.yearsOfExperience,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      bio: map['bio']?.toString(),
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString(),
      location: map['location']?.toString(),
      avatarUrl: map['avatar_url']?.toString(),
      resumeUrl: map['resume_url']?.toString(),
      quote: map['quote']?.toString(),
      yearsOfExperience: map['years_of_experience'] is int ? map['years_of_experience'] : null,
    );
  }
}
