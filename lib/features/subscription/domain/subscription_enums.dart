enum SubscriptionTier {
  free,
  premium;

  String get displayName {
    switch (this) {
      case SubscriptionTier.free:
        return 'Free';
      case SubscriptionTier.premium:
        return 'Premium';
    }
  }

  String get description {
    switch (this) {
      case SubscriptionTier.free:
        return '3 credits/month';
      case SubscriptionTier.premium:
        return '25 credits/month + No Ads';
    }
  }

  int get monthlyCredits {
    switch (this) {
      case SubscriptionTier.free:
        return 3;
      case SubscriptionTier.premium:
        return 25;
    }
  }

  static SubscriptionTier fromString(String value) {
    return SubscriptionTier.values.firstWhere(
      (tier) => tier.name == value,
      orElse: () => SubscriptionTier.free,
    );
  }
}

enum SubscriptionStatus {
  active,
  canceled,
  pastDue,
  incomplete,
  expired;

  static SubscriptionStatus fromString(String value) {
    final normalized = value.toLowerCase().replaceAll('_', '');
    switch (normalized) {
      case 'active':
        return SubscriptionStatus.active;
      case 'canceled':
      case 'cancelled':
        return SubscriptionStatus.canceled;
      case 'pastdue':
        return SubscriptionStatus.pastDue;
      case 'incomplete':
        return SubscriptionStatus.incomplete;
      case 'expired':
        return SubscriptionStatus.expired;
      default:
        return SubscriptionStatus.active;
    }
  }
}
