class ATSScoreModel {
  final String id;
  final String userId;
  final String cvContent;
  final int score;
  final List<String> problems;
  final List<String> fixPoints;
  final String howToOptimize;
  final DateTime createdAt;

  ATSScoreModel({
    required this.id,
    required this.userId,
    required this.cvContent,
    required this.score,
    required this.problems,
    required this.fixPoints,
    required this.howToOptimize,
    required this.createdAt,
  });

  factory ATSScoreModel.fromMap(Map<String, dynamic> map) {
    return ATSScoreModel(
      id: map['id'],
      userId: map['user_id'],
      cvContent: map['cv_content'],
      score: map['score'],
      problems: List<String>.from(map['problems'] ?? []),
      fixPoints: List<String>.from(map['fix_points'] ?? []),
      howToOptimize: map['how_to_optimize'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'cv_content': cvContent,
      'score': score,
      'problems': problems,
      'fix_points': fixPoints,
      'how_to_optimize': howToOptimize,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
