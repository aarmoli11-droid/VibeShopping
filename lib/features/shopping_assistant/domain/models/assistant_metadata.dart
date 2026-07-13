class AssistantMetadata {
  final String appVersion;
  final String platform;
  final String language;
  final String timezone;
  final String? buildNumber;

  const AssistantMetadata({
    required this.appVersion,
    required this.platform,
    required this.language,
    required this.timezone,
    this.buildNumber,
  });

  AssistantMetadata copyWith({
    String? appVersion,
    String? platform,
    String? language,
    String? timezone,
    String? buildNumber,
  }) {
    return AssistantMetadata(
      appVersion: appVersion ?? this.appVersion,
      platform: platform ?? this.platform,
      language: language ?? this.language,
      timezone: timezone ?? this.timezone,
      buildNumber: buildNumber ?? this.buildNumber,
    );
  }

  factory AssistantMetadata.fromJson(Map<String, dynamic> json) {
    return AssistantMetadata(
      appVersion: json['appVersion'] as String,
      platform: json['platform'] as String,
      language: json['language'] as String,
      timezone: json['timezone'] as String,
      buildNumber: json['buildNumber'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appVersion': appVersion,
      'platform': platform,
      'language': language,
      'timezone': timezone,
      if (buildNumber != null) 'buildNumber': buildNumber,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AssistantMetadata &&
        other.appVersion == appVersion &&
        other.platform == platform;
  }

  @override
  int get hashCode => Object.hash(appVersion, platform);

  @override
  String toString() {
    return 'AssistantMetadata($appVersion, $platform, $language)';
  }
}
