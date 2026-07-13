class AssistantAction {
  final String id;
  final String iconName;
  final String label;
  final String promptTemplate;
  final String? category;

  const AssistantAction({
    required this.id,
    required this.iconName,
    required this.label,
    required this.promptTemplate,
    this.category,
  });

  AssistantAction copyWith({
    String? id,
    String? iconName,
    String? label,
    String? promptTemplate,
    String? category,
  }) {
    return AssistantAction(
      id: id ?? this.id,
      iconName: iconName ?? this.iconName,
      label: label ?? this.label,
      promptTemplate: promptTemplate ?? this.promptTemplate,
      category: category ?? this.category,
    );
  }

  factory AssistantAction.fromJson(Map<String, dynamic> json) {
    return AssistantAction(
      id: json['id'] as String,
      iconName: json['iconName'] as String,
      label: json['label'] as String,
      promptTemplate: json['promptTemplate'] as String,
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'iconName': iconName,
      'label': label,
      'promptTemplate': promptTemplate,
      if (category != null) 'category': category,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AssistantAction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AssistantAction($label)';
  }
}
