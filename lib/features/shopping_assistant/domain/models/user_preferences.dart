class UserPreferences {
  final String? userId;
  final List<String>? preferredStoreIds;
  final List<String>? dietaryRestrictions;
  final double? budgetLimit;
  final String? language;
  final bool? notificationsEnabled;

  const UserPreferences({
    this.userId,
    this.preferredStoreIds,
    this.dietaryRestrictions,
    this.budgetLimit,
    this.language,
    this.notificationsEnabled,
  });

  UserPreferences copyWith({
    String? userId,
    List<String>? preferredStoreIds,
    List<String>? dietaryRestrictions,
    double? budgetLimit,
    String? language,
    bool? notificationsEnabled,
  }) {
    return UserPreferences(
      userId: userId ?? this.userId,
      preferredStoreIds: preferredStoreIds ?? this.preferredStoreIds,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      budgetLimit: budgetLimit ?? this.budgetLimit,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      userId: json['userId'] as String?,
      preferredStoreIds:
          (json['preferredStoreIds'] as List<dynamic>?)?.cast<String>(),
      dietaryRestrictions:
          (json['dietaryRestrictions'] as List<dynamic>?)?.cast<String>(),
      budgetLimit: (json['budgetLimit'] as num?)?.toDouble(),
      language: json['language'] as String?,
      notificationsEnabled: json['notificationsEnabled'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (userId != null) 'userId': userId,
      if (preferredStoreIds != null) 'preferredStoreIds': preferredStoreIds,
      if (dietaryRestrictions != null)
        'dietaryRestrictions': dietaryRestrictions,
      if (budgetLimit != null) 'budgetLimit': budgetLimit,
      if (language != null) 'language': language,
      if (notificationsEnabled != null)
        'notificationsEnabled': notificationsEnabled,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserPreferences && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() {
    return 'UserPreferences(userId: $userId, language: $language)';
  }
}
