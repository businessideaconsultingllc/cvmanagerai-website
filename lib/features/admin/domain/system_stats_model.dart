import 'package:flutter/foundation.dart';

@immutable
class SystemStats {
  final int totalUsers;
  final int totalCvs;
  final int totalCoverLetters;
  final int totalCredits;
  final int activeUsers24h;
  final int newUsers7d;

  const SystemStats({
    required this.totalUsers,
    required this.totalCvs,
    required this.totalCoverLetters,
    required this.totalCredits,
    required this.activeUsers24h,
    required this.newUsers7d,
  });

  factory SystemStats.fromJson(Map<String, dynamic> json) {
    return SystemStats(
      totalUsers: json['total_users'] as int? ?? 0,
      totalCvs: json['total_cvs'] as int? ?? 0,
      totalCoverLetters: json['total_cover_letters'] as int? ?? 0,
      totalCredits: json['total_credits'] as int? ?? 0,
      activeUsers24h: json['active_users_24h'] as int? ?? 0,
      newUsers7d: json['new_users_7d'] as int? ?? 0,
    );
  }

  factory SystemStats.empty() {
    return const SystemStats(
      totalUsers: 0,
      totalCvs: 0,
      totalCoverLetters: 0,
      totalCredits: 0,
      activeUsers24h: 0,
      newUsers7d: 0,
    );
  }
}
