class SubscriptionModel {
  final String id;
  final String userId;
  final String? stripeSubscriptionId;
  final String? stripeCustomerId;
  final String tier;
  final String status;
  final DateTime? currentPeriodStart;
  final DateTime? currentPeriodEnd;
  final bool cancelAtPeriodEnd;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubscriptionModel({
    required this.id,
    required this.userId,
    this.stripeSubscriptionId,
    this.stripeCustomerId,
    required this.tier,
    required this.status,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    this.cancelAtPeriodEnd = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriptionModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      stripeSubscriptionId: map['stripe_subscription_id'] as String?,
      stripeCustomerId: map['stripe_customer_id'] as String?,
      tier: map['tier'] as String,
      status: map['status'] as String,
      currentPeriodStart: map['current_period_start'] != null
          ? DateTime.parse(map['current_period_start'] as String)
          : null,
      currentPeriodEnd: map['current_period_end'] != null
          ? DateTime.parse(map['current_period_end'] as String)
          : null,
      cancelAtPeriodEnd: map['cancel_at_period_end'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'stripe_subscription_id': stripeSubscriptionId,
      'stripe_customer_id': stripeCustomerId,
      'tier': tier,
      'status': status,
      'current_period_start': currentPeriodStart?.toIso8601String(),
      'current_period_end': currentPeriodEnd?.toIso8601String(),
      'cancel_at_period_end': cancelAtPeriodEnd,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isPremium => tier == 'premium';
  bool get isActive => status == 'active';
  bool get isPremiumAndActive => isPremium && isActive;
}
