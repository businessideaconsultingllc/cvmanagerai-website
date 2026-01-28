class UserActivity {
  final String id;
  final String userId;
  final String? userEmail;
  final String? userName;
  final String activityType;
  final Map<String, dynamic>? details;
  final DateTime createdAt;

  UserActivity({
    required this.id,
    required this.userId,
    this.userEmail,
    this.userName,
    required this.activityType,
    this.details,
    required this.createdAt,
  });

  factory UserActivity.fromJson(Map<String, dynamic> json) {
    // Handle potential Join result (Supabase can return object or list)
    var profileData = json['profiles'];
    Map<String, dynamic>? profile;
    if (profileData is List && profileData.isNotEmpty) {
      profile = profileData.first;
    } else if (profileData is Map) {
      profile = profileData as Map<String, dynamic>;
    }

    return UserActivity(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userEmail: profile?['email'] as String?,
      userName: profile?['full_name'] as String?,
      activityType: json['activity_type'] as String,
      details: json['details'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }
}
