class CoverLetterModel {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String? jobTitle;
  final String? companyName;
  final String? jobDescription;
  final DateTime createdAt;
  final DateTime updatedAt;

  final String language;

  CoverLetterModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.jobTitle,
    this.companyName,
    this.jobDescription,
    this.language = 'en',
    required this.createdAt,
    required this.updatedAt,
  });

  factory CoverLetterModel.fromMap(Map<String, dynamic> map) {
    return CoverLetterModel(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      content: map['content'],
      jobTitle: map['job_title'],
      companyName: map['company_name'],
      jobDescription: map['job_description'],
      language: map['language'] ?? 'en',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'job_title': jobTitle,
      'company_name': companyName,
      'job_description': jobDescription,
      'language': language,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  CoverLetterModel copyWith({
    String? title,
    String? content,
    String? jobTitle,
    String? companyName,
    String? jobDescription,
    String? language,
    DateTime? updatedAt,
  }) {
    return CoverLetterModel(
      id: id,
      userId: userId,
      title: title ?? this.title,
      content: content ?? this.content,
      jobTitle: jobTitle ?? this.jobTitle,
      companyName: companyName ?? this.companyName,
      jobDescription: jobDescription ?? this.jobDescription,
      language: language ?? this.language,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
