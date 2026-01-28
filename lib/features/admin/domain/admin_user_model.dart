import 'package:flutter/material.dart';

class AdminUserModel {
  final String id;
  final String email;
  final String? fullName;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? address;
  final bool isAdmin;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int creditBalance;
  final DateTime? lastSeen;
  final String signupMethod; // 'email' or 'google'
  final bool isSuspended;

  AdminUserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.firstName,
    this.lastName,
    this.phone,
    this.address,
    required this.isAdmin,
    required this.createdAt,
    this.updatedAt,
    required this.creditBalance,
    this.lastSeen,
    this.signupMethod = 'email', // Default to email
    this.isSuspended = false,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      isAdmin: json['is_admin'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      creditBalance: (json['credits_balance'] as num?)?.toInt() ??
          (json['credit_balance'] as num?)?.toInt() ??
          0,
      lastSeen: json['last_seen'] != null
          ? DateTime.parse(json['last_seen'] as String)
          : null,
      signupMethod: json['auth_provider'] as String? ?? 'email',
      isSuspended: json['is_suspended'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'address': address,
      'is_admin': isAdmin,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'credit_balance': creditBalance,
      'last_seen': lastSeen?.toIso8601String(),
      'auth_provider': signupMethod,
      'is_suspended': isSuspended,
    };
  }

  AdminUserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? firstName,
    String? lastName,
    String? phone,
    String? address,
    bool? isAdmin,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? creditBalance,
    DateTime? lastSeen,
    String? signupMethod,
  }) {
    return AdminUserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      isAdmin: isAdmin ?? this.isAdmin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      creditBalance: creditBalance ?? this.creditBalance,
      lastSeen: lastSeen ?? this.lastSeen,
      signupMethod: signupMethod ?? this.signupMethod,
      isSuspended: isSuspended ?? isSuspended,
    );
  }

  String get displayName {
    if (fullName != null && fullName!.isNotEmpty) return fullName!;
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    if (firstName != null) return firstName!;
    return email;
  }

  /// Check if user is online (last seen within 5 minutes)
  bool get isOnline {
    if (lastSeen == null) return false;
    final diff = DateTime.now().difference(lastSeen!);
    return diff.inMinutes < 5;
  }

  /// Get human-readable online status
  String get onlineStatus {
    if (isOnline) return 'Online';
    if (lastSeen == null) return 'Never';

    final diff = DateTime.now().difference(lastSeen!);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return 'Offline';
  }

  /// Get display text for signup method
  String get signupMethodDisplay {
    return signupMethod == 'google' ? 'Google' : 'Email';
  }

  /// Get icon for signup method
  IconData get signupMethodIcon {
    return signupMethod == 'google' ? Icons.g_mobiledata : Icons.email;
  }
}
