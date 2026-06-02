enum ReferenceBubbleType { text, productCard }

class CommunityMessage {
  const CommunityMessage({
    required this.id,
    required this.author,
    required this.text,
    required this.mine,
    required this.createdAt,
    this.imageUrl,
    this.timestampOverride,
  });

  factory CommunityMessage.fromMap(Map<String, dynamic> map, String currentUserId) {
    final rawDate = map['created_at'] ?? map['createdAt'];
    DateTime createdAt = DateTime.now();
    if (rawDate is String) {
      createdAt = DateTime.tryParse(rawDate)?.toLocal() ?? DateTime.now();
    }
    final userId = map['user_id']?.toString() ?? '';
    return CommunityMessage(
      id: (map['id'] ?? '').toString(),
      author: (map['author'] ?? 'Comunidad').toString(),
      text: (map['content'] ?? map['text'] ?? '').toString(),
      mine: userId == currentUserId,
      imageUrl: (map['image_url'] ?? map['imageUrl'])?.toString(),
      createdAt: createdAt,
    );
  }

  final String id;
  final String author;
  final String text;
  final bool mine;
  final DateTime createdAt;
  final String? imageUrl;
  final String? timestampOverride;

  String get timestampLabel {
    if (timestampOverride != null && timestampOverride!.isNotEmpty) return timestampOverride!;
    final hh = createdAt.hour.toString().padLeft(2, '0');
    final mm = createdAt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}

class CommunityFeedItem {
  const CommunityFeedItem._({
    required this.type,
    required this.mine,
    this.text,
    this.timestamp,
    this.imageUrl,
    this.actionLabel,
  });

  factory CommunityFeedItem.myText(String text, {required String timestamp}) {
    return CommunityFeedItem._(
      type: ReferenceBubbleType.text,
      mine: true,
      text: text,
      timestamp: timestamp,
    );
  }

  factory CommunityFeedItem.incomingText(String text, {required String timestamp}) {
    return CommunityFeedItem._(
      type: ReferenceBubbleType.text,
      mine: false,
      text: text,
      timestamp: timestamp,
    );
  }

  factory CommunityFeedItem.productCard({
    required String imageUrl,
    required String actionLabel,
  }) {
    return CommunityFeedItem._(
      type: ReferenceBubbleType.productCard,
      mine: false,
      imageUrl: imageUrl,
      actionLabel: actionLabel,
    );
  }

  final ReferenceBubbleType type;
  final bool mine;
  final String? text;
  final String? timestamp;
  final String? imageUrl;
  final String? actionLabel;
}
