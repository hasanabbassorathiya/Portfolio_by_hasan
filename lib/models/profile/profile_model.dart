/// Profile model
/// Represents portfolio owner profile information
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

  ProfileModel({
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
      id: map['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: map['name'] as String,
      title: map['title'] as String,
      bio: map['bio'] as String?,
      email: map['email'] as String,
      phone: map['phone'] as String?,
      location: map['location'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      resumeUrl: map['resume_url'] as String?,
      quote: map['quote'] as String?,
      yearsOfExperience: map['years_of_experience'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'bio': bio,
      'email': email,
      'phone': phone,
      'location': location,
      'avatar_url': avatarUrl,
      'resume_url': resumeUrl,
      'quote': quote,
      'years_of_experience': yearsOfExperience,
    };
  }
}
