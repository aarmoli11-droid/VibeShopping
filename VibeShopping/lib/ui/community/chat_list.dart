import 'package:flutter/material.dart';
import 'models/community_models.dart';
import 'chat_bubble.dart';

class ChatList extends StatelessWidget {
  const ChatList({
    super.key,
    required this.messagesStream,
    required this.referenceFeed,
    required this.onDeleteMessage,
  });

  final Stream<List<CommunityMessage>> messagesStream;
  final List<CommunityFeedItem> referenceFeed;
  final Function(String) onDeleteMessage;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CommunityMessage>>(
      stream: messagesStream,
      builder: (context, snapshot) {
        final liveMessages = snapshot.data ?? const <CommunityMessage>[];
        return ListView(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
          children: [
            ...referenceFeed.map((item) => CommunityReferenceBubble(item: item)),
            if (liveMessages.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...liveMessages.map((msg) => CommunityBubble(
                    message: msg,
                    onDelete: onDeleteMessage,
                  )),
            ],
          ],
        );
      },
    );
  }
}
