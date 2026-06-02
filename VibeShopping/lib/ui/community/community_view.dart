import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibeshopping/data/vibe_community_chat/community_chat_message_query.dart';
import '../auth/auth_placeholder.dart';
import '../../core/supabase_config.dart';
import '../../core/vibe_constants.dart';
import '../assistant/vibe_ai_assistant.dart';
import 'chat_input.dart';
import 'chat_list.dart';
import 'models/community_models.dart';

class VibeCommunityView extends StatefulWidget {
  const VibeCommunityView({super.key});

  @override
  State<VibeCommunityView> createState() => _VibeCommunityViewState();
}

class _VibeCommunityViewState extends State<VibeCommunityView> {
  final TextEditingController _composerController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _sendingMessage = false;
  bool _uploadingImage = false;
  static const String _tableName = 'community_messages';
  static const String _storageBucket = 'chat_images';

  SupabaseClient? get _supabaseClient {
    if (!VibeSupabaseConfig.isConfigured) return null;
    return Supabase.instance.client;
  }

  Stream<List<CommunityMessage>> _communityMessagesStream() {
    final client = _supabaseClient;
    if (client == null) return Stream.value(const []);
    final cutoffUtc = DateTime.now().toUtc().subtract(
          VibeBusinessRules.forumMessageVisibility,
        );
    final currentUserId = client.auth.currentUser?.id ?? '';

    return client
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .gt('created_at', cutoffUtc.toIso8601String())
        .order('created_at')
        .map(
          (rows) => rows
              .map((row) => CommunityMessage.fromMap(row, currentUserId))
              .where((msg) => msg.createdAt.isAfter(cutoffUtc))
              .toList(growable: false),
        );
  }

  Future<void> _checkAuthAndRedirect() async {
    if (Supabase.instance.client.auth.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Necesitas una cuenta para participar')),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Future<void> deleteMessage(String messageId) async {
    final client = _supabaseClient;
    if (client == null) return;
    try {
      await client.from(_tableName).delete().eq('id', messageId);
      setState(() {});
    } catch (e) {
      debugPrint('Error al eliminar mensaje: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo eliminar el mensaje.')),
      );
    }
  }

  Future<void> _sendCurrentTextMessage() async {
    if (Supabase.instance.client.auth.currentUser == null) {
      await _checkAuthAndRedirect();
      return;
    }
    final text = _composerController.text.trim();
    if (text.isEmpty || _sendingMessage) return;
    final client = _supabaseClient;
    if (client == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Configura Supabase para publicar mensajes.')),
      );
      return;
    }

    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _sendingMessage = true);
    try {
      await client.from(_tableName).insert({
        'content': text,
        'user_id': userId,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });
      _composerController.clear();
    } catch (e) {
      debugPrint('Error al enviar mensaje: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo enviar el mensaje.')),
      );
    } finally {
      if (mounted) setState(() => _sendingMessage = false);
    }
  }

  Future<void> _pickAndUploadImage() async {
    if (Supabase.instance.client.auth.currentUser == null) {
      await _checkAuthAndRedirect();
      return;
    }
    if (_uploadingImage) return;

    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
      maxWidth: 1600,
    );
    if (picked == null) return;

    final shouldUpload = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enviar imagen'),
        content: Image.file(File(picked.path)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Enviar')),
        ],
      ),
    );

    if (shouldUpload != true) return;

    final client = _supabaseClient;
    if (client == null) return;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _uploadingImage = true);
    try {
      final bytes = await picked.readAsBytes();
      final extension = fileExtension(picked.name);
      final random = Random().nextInt(99999).toString().padLeft(5, '0');
      final filePath =
          'community/${DateTime.now().millisecondsSinceEpoch}_$random.$extension';

      await client.storage.from(_storageBucket).uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(
              upsert: false,
              contentType: contentTypeFromExtension(extension),
            ),
          );

      final publicUrl =
          client.storage.from(_storageBucket).getPublicUrl(filePath);

      await client.from(_tableName).insert({
        'content': _composerController.text.trim(),
        'image_url': publicUrl,
        'user_id': userId,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });

      _composerController.clear();
    } catch (e) {
      debugPrint('Error al subir imagen: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo subir la imagen.')),
      );
    } finally {
      if (mounted) setState(() => _uploadingImage = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _performCleanup();
  }

  Future<void> _performCleanup() async {
    final supabase = _supabaseClient;
    if (supabase == null) return;
    try {
      await supabase.from('community_messages').delete().lt('created_at',
          DateTime.now().subtract(const Duration(hours: 24)).toIso8601String());
    } catch (e) {
      debugPrint('Error al limpiar mensajes antiguos: $e');
    }
  }

  @override
  void dispose() {
    _composerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final bool isLoggedIn = Supabase.instance.client.auth.currentUser != null;

    final Widget content = Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFEAF3F1),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Center(
                child: Container(
                  width: 250,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF2EC),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                        color: VibeColors.mint.withValues(alpha: 0.92)),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Comunidad',
                    style: TextStyle(
                      color: VibeColors.navy,
                      fontSize: 34 / 2,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ChatList(
                messagesStream: _communityMessagesStream(),
                referenceFeed: const [],
                onDeleteMessage: deleteMessage,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10, 4, 10, 8 + keyboardInset),
              child: ChatInput(
                controller: _composerController,
                sending: _sendingMessage,
                uploadingImage: _uploadingImage,
                onSendPressed: _sendCurrentTextMessage,
                onCameraPressed: _pickAndUploadImage,
                onAssistantPressed: () =>
                    VibeAiAssistant.showAssistantSheet(context),
              ),
            ),
          ],
        ),
      ),
    );

    if (isLoggedIn) return content;

    return Stack(
      children: [
        content,
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.white.withValues(alpha: 0.1)),
          ),
        ),
        Positioned.fill(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1), blurRadius: 10),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "¡Únete a la comunidad! Regístrate para compartir ofertas o guardar tu lista",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text("Luego"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const AuthGatewayLoginView()),
                              );
                            },
                            child: const Text("Registrarse"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

String fileExtension(String fileName) {
  final index = fileName.lastIndexOf('.');
  if (index < 0 || index == fileName.length - 1) return 'jpg';
  return fileName.substring(index + 1).toLowerCase();
}

String contentTypeFromExtension(String extension) {
  return switch (extension) {
    'png' => 'image/png',
    'webp' => 'image/webp',
    'gif' => 'image/gif',
    _ => 'image/jpeg',
  };
}
