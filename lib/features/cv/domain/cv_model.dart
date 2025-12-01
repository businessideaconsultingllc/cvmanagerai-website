import 'dart:convert';

enum CVType {
  generated,
  optimized,
  tailored;

  String toJson() => name;

  static CVType fromJson(String value) {
    return CVType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => CVType.generated,
    );
  }
}

class CVModel {
  final String id;
  final String userId;
  final String title;
  final CVData data;
  final String language;
  final CVType cvType;
  final DateTime createdAt;

  CVModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.data,
    required this.language,
    this.cvType = CVType.generated,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': data.toMap(),
      'language': language,
      'cv_type': cvType.toJson(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory CVModel.fromMap(Map<String, dynamic> map) {
    return CVModel(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      data: CVData.fromMap(map['content'] is String
          ? jsonDecode(map['content'])
          : map['content']),
      language: map['language'],
      cvType: map['cv_type'] != null
          ? CVType.fromJson(map['cv_type'])
          : CVType.generated,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
  CVModel copyWith({
    String? id,
    String? userId,
    String? title,
    CVData? data,
    String? language,
    CVType? cvType,
    DateTime? createdAt,
  }) {
    return CVModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      data: data ?? this.data,
      language: language ?? this.language,
      cvType: cvType ?? this.cvType,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class CVData {
  final PersonalInfo personalInfo;
  final String summary;
  final List<Experience> experience;
  final List<Education> education;
  final List<Certificate> certificates;
  final List<String> skills;
  final List<String> languages;

  CVData({
    required this.personalInfo,
    required this.summary,
    required this.experience,
    required this.education,
    required this.certificates,
    required this.skills,
    required this.languages,
  });

  Map<String, dynamic> toMap() {
    return {
      'personalInfo': personalInfo.toMap(),
      'summary': summary,
      'experience': experience.map((x) => x.toMap()).toList(),
      'education': education.map((x) => x.toMap()).toList(),
      'certificates': certificates.map((x) => x.toMap()).toList(),
      'skills': skills,
      'languages': languages,
    };
  }

  factory CVData.fromMap(Map<String, dynamic> map) {
    return CVData(
      personalInfo: PersonalInfo.fromMap(map['personalInfo'] ?? {}),
      summary: map['summary'] ?? '',
      experience: List<Experience>.from(
          (map['experience'] ?? []).map((x) => Experience.fromMap(x))),
      education: List<Education>.from(
          (map['education'] ?? []).map((x) => Education.fromMap(x))),
      certificates: List<Certificate>.from(
          (map['certificates'] ?? []).map((x) => Certificate.fromMap(x))),
      skills: List<String>.from(map['skills'] ?? []),
      languages: List<String>.from(map['languages'] ?? []),
    );
  }
  CVData copyWith({
    PersonalInfo? personalInfo,
    String? summary,
    List<Experience>? experience,
    List<Education>? education,
    List<Certificate>? certificates,
    List<String>? skills,
    List<String>? languages,
  }) {
    return CVData(
      personalInfo: personalInfo ?? this.personalInfo,
      summary: summary ?? this.summary,
      experience: experience ?? this.experience,
      education: education ?? this.education,
      certificates: certificates ?? this.certificates,
      skills: skills ?? this.skills,
      languages: languages ?? this.languages,
    );
  }
}

class PersonalInfo {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final String? linkedin;
  final String? website;

  PersonalInfo({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    this.linkedin,
    this.website,
  });

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'address': address,
      'linkedin': linkedin,
      'website': website,
    };
  }

  factory PersonalInfo.fromMap(Map<String, dynamic> map) {
    return PersonalInfo(
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      linkedin: map['linkedin'],
      website: map['website'],
    );
  }
  PersonalInfo copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? address,
    String? linkedin,
    String? website,
  }) {
    return PersonalInfo(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      linkedin: linkedin ?? this.linkedin,
      website: website ?? this.website,
    );
  }
}

class Experience {
  final String jobTitle;
  final String company;
  final String startDate;
  final String endDate;
  final String description;

  Experience({
    required this.jobTitle,
    required this.company,
    required this.startDate,
    required this.endDate,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'jobTitle': jobTitle,
      'company': company,
      'startDate': startDate,
      'endDate': endDate,
      'description': description,
    };
  }

  factory Experience.fromMap(Map<String, dynamic> map) {
    return Experience(
      jobTitle: map['jobTitle'] ?? '',
      company: map['company'] ?? '',
      startDate: map['startDate'] ?? '',
      endDate: map['endDate'] ?? '',
      description: map['description'] ?? '',
    );
  }
}

class Education {
  final String degree;
  final String school;
  final String startDate;
  final String endDate;
  final String? description;

  Education({
    required this.degree,
    required this.school,
    required this.startDate,
    required this.endDate,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'degree': degree,
      'school': school,
      'startDate': startDate,
      'endDate': endDate,
      'description': description,
    };
  }

  factory Education.fromMap(Map<String, dynamic> map) {
    return Education(
      degree: map['degree'] ?? '',
      school: map['school'] ?? '',
      startDate: map['startDate'] ?? '',
      endDate: map['endDate'] ?? '',
      description: map['description'],
    );
  }
}

class Certificate {
  final String name;
  final String issuer;
  final String date;
  final String? description;

  Certificate({
    required this.name,
    required this.issuer,
    required this.date,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'issuer': issuer,
      'date': date,
      'description': description,
    };
  }

  factory Certificate.fromMap(Map<String, dynamic> map) {
    return Certificate(
      name: map['name'] ?? '',
      issuer: map['issuer'] ?? '',
      date: map['date'] ?? '',
      description: map['description'],
    );
  }
}
