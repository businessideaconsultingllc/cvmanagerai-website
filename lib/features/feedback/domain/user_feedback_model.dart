class UserFeedback {
  final String id;
  final String? userId;
  final String? userEmail;
  final String? profileName;
  final String message;
  final int? rating;
  final bool isRead;
  final DateTime createdAt;

  UserFeedback({
    required this.id,
    this.userId,
    this.userEmail,
    this.profileName,
    required this.message,
    this.rating,
    required this.isRead,
    required this.createdAt,
  });

  factory UserFeedback.fromJson(Map<String, dynamic> json) {
    var profileData = json['profiles'];
    Map<String, dynamic>? profile;
    if (profileData is List && profileData.isNotEmpty) {
      profile = profileData.first;
    } else if (profileData is Map) {
      profile = profileData as Map<String, dynamic>;
    }

    return UserFeedback(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      userEmail: profile?['email'] as String?,
      profileName: profile?['full_name'] as String?,
      message: json['message'] as String,
      rating: json['rating'] as int?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }
}
