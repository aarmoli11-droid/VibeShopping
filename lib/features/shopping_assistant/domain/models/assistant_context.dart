import 'conversation_summary.dart';

class AssistantContext {
  final List<String>? storeIds;
  final double? latitude;
  final double? longitude;
  final double? budget;
  final List<String>? dietaryRestrictions;
  final String? activeListId;
  final List<String>? favoriteProductIds;
  final ConversationSummary? conversationSummary;

  const AssistantContext({
    this.storeIds,
    this.latitude,
    this.longitude,
    this.budget,
    this.dietaryRestrictions,
    this.activeListId,
    this.favoriteProductIds,
    this.conversationSummary,
  });

  AssistantContext copyWith({
    List<String>? storeIds,
    double? latitude,
    double? longitude,
    double? budget,
    List<String>? dietaryRestrictions,
    String? activeListId,
    List<String>? favoriteProductIds,
    ConversationSummary? conversationSummary,
  }) {
    return AssistantContext(
      storeIds: storeIds ?? this.storeIds,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      budget: budget ?? this.budget,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      activeListId: activeListId ?? this.activeListId,
      favoriteProductIds: favoriteProductIds ?? this.favoriteProductIds,
      conversationSummary: conversationSummary ?? this.conversationSummary,
    );
  }

  factory AssistantContext.fromJson(Map<String, dynamic> json) {
    return AssistantContext(
      storeIds: (json['storeIds'] as List<dynamic>?)?.cast<String>(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      budget: (json['budget'] as num?)?.toDouble(),
      dietaryRestrictions:
          (json['dietaryRestrictions'] as List<dynamic>?)?.cast<String>(),
      activeListId: json['activeListId'] as String?,
      favoriteProductIds:
          (json['favoriteProductIds'] as List<dynamic>?)?.cast<String>(),
      conversationSummary: json['conversationSummary'] != null
          ? ConversationSummary.fromJson(
              json['conversationSummary'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (storeIds != null) 'storeIds': storeIds,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (budget != null) 'budget': budget,
      if (dietaryRestrictions != null)
        'dietaryRestrictions': dietaryRestrictions,
      if (activeListId != null) 'activeListId': activeListId,
      if (favoriteProductIds != null) 'favoriteProductIds': favoriteProductIds,
      if (conversationSummary != null)
        'conversationSummary': conversationSummary!.toJson(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AssistantContext &&
        other.storeIds == storeIds &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.budget == budget &&
        other.activeListId == activeListId;
  }

  @override
  int get hashCode {
    return Object.hash(storeIds, latitude, longitude, budget, activeListId);
  }

  @override
  String toString() {
    return 'AssistantContext(storeIds: $storeIds, budget: $budget)';
  }
}
