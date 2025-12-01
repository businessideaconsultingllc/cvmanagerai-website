class CreditTransaction {
  final String id;
  final String userId;
  final String operationType;
  final int creditsUsed;
  final int balanceAfter;
  final DateTime createdAt;

  CreditTransaction({
    required this.id,
    required this.userId,
    required this.operationType,
    required this.creditsUsed,
    required this.balanceAfter,
    required this.createdAt,
  });

  factory CreditTransaction.fromMap(Map<String, dynamic> map) {
    return CreditTransaction(
      id: map['id'],
      userId: map['user_id'],
      operationType: map['operation_type'],
      creditsUsed: map['credits_used'],
      balanceAfter: map['balance_after'],
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'operation_type': operationType,
      'credits_used': creditsUsed,
      'balance_after': balanceAfter,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get operationDisplayName {
    switch (operationType) {
      case 'generate_cv':
        return 'Generate CV';
      case 'optimize_cv':
        return 'Optimize CV';
      case 'tailor_cv':
        return 'Tailor CV';
      case 'cover_letter':
        return 'Generate Cover Letter';
      case 'ats_check':
        return 'ATS Score Check';
      case 'reset':
        return 'Monthly Reset';
      default:
        return operationType;
    }
  }
}
