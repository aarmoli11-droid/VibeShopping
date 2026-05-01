import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase_config.dart';
import '../../vibe_core/vibe_constants.dart';
import '../../models/vibe_store_kind.dart';
import '../../vibe_datasource/services/gemini_shopping_assistant_service.dart';
import 'product_detail_view.dart';

/// Contenedor principal con Home, Chat y Perfil.
class MarketExplorerShell extends StatefulWidget {
  const MarketExplorerShell({super.key});

  @override
  State<MarketExplorerShell> createState() => _MarketExplorerShellState();
}

class _MarketExplorerShellState extends State<MarketExplorerShell> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const MarketExplorerHomeView(),
      const _VibeCommunityView(),
      const _MarketProfilePlaceholder(),
    ];

    return Scaffold(
      body: pages[_navIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (i) => setState(() => _navIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

Future<void> _openAssistantSheet(BuildContext context) async {
  final service = context.read<GeminiShoppingAssistantService>();
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: VibeColors.backgroundWhite,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Asistente de Compras',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: VibeColors.navy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Gemini está listo para ayudarte a comparar precios y planificar tu canasta (sin compras en la app).',
              style: TextStyle(
                color: VibeColors.navy.withValues(alpha: 0.75),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () async {
                Navigator.of(ctx).pop();
                if (!context.mounted) return;
                try {
                  await service.askShoppingQuestion('Hola');
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Asistente de Compras: conexión respondió correctamente.'),
                    ),
                  );
                } catch (_) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No se pudo contactar al asistente en este momento.'),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.bolt, size: 20),
              label: const Text('Probar conexión'),
              style: FilledButton.styleFrom(
                backgroundColor: VibeColors.navy,
                foregroundColor: VibeColors.backgroundWhite,
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _MarketProfilePlaceholder extends StatelessWidget {
  const _MarketProfilePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Center(
        child: Text(
          'Tu perfil — próximamente',
          style: TextStyle(color: VibeColors.navy.withValues(alpha: 0.7)),
        ),
      ),
    );
  }
}

class _VibeCommunityView extends StatefulWidget {
  const _VibeCommunityView();

  @override
  State<_VibeCommunityView> createState() => _VibeCommunityViewState();
}

class _VibeCommunityViewState extends State<_VibeCommunityView> {
  final TextEditingController _composerController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _sendingMessage = false;
  bool _uploadingImage = false;
  static const String _tableName = 'community_messages';
  static const String _storageBucket = 'community-media';

  static final List<_CommunityFeedItem> _referenceFeed = [
    _CommunityFeedItem.myText(
      'He encontrado estas manzanas a buen precio en Bm.',
      timestamp: '17:47',
    ),
    _CommunityFeedItem.incomingText(
      '¡Ey! Encontré bananas en promoción en Maxi Palí.',
      timestamp: '17:48',
    ),
    _CommunityFeedItem.productCard(
      imageUrl:
          'https://walmartcr.vtexassets.com/arquivos/ids/530538-1200-900?v=638419993933470000&width=1200&height=900&aspect=true',
      actionLabel: 'Purchase',
    ),
    _CommunityFeedItem.productCard(
      imageUrl:
          'https://walmartcr.vtexassets.com/arquivos/ids/1097368-1200-900?v=639123051022470000&width=1200&height=900&aspect=true',
      actionLabel: 'Purchase',
    ),
    _CommunityFeedItem.incomingText(
      'Está a un 20% de descuento, en tan solo 1.700',
      timestamp: '17:48',
    ),
  ];

  SupabaseClient? get _supabaseClient {
    if (!VibeSupabaseConfig.isConfigured) return null;
    return Supabase.instance.client;
  }

  Stream<List<_CommunityMessage>> _communityMessagesStream() {
    final client = _supabaseClient;
    if (client == null) return Stream.value(const []);
    final cutoffUtc = DateTime.now().toUtc().subtract(
      VibeBusinessRules.forumMessageVisibility,
    );

    return client
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .gt('createdAt', cutoffUtc.toIso8601String())
        .order('createdAt')
        .map(
          (rows) => rows
              .map(_CommunityMessage.fromMap)
              .where((msg) => msg.createdAt.isAfter(cutoffUtc))
              .toList(growable: false),
        );
  }

  Future<void> _sendCurrentTextMessage() async {
    final text = _composerController.text.trim();
    if (text.isEmpty || _sendingMessage) return;
    final client = _supabaseClient;
    if (client == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configura Supabase para publicar mensajes.')),
      );
      return;
    }
    setState(() => _sendingMessage = true);
    try {
      await client.from(_tableName).insert({
        'author': 'John',
        'text': text,
        'imageUrl': null,
        'isMine': true,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      });
      _composerController.clear();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo enviar el mensaje.')),
      );
    } finally {
      if (mounted) setState(() => _sendingMessage = false);
    }
  }

  Future<void> _pickAndUploadImage() async {
    if (_uploadingImage) return;
    final client = _supabaseClient;
    if (client == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configura Supabase para subir imágenes.')),
      );
      return;
    }
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
      maxWidth: 1600,
    );
    if (picked == null) return;
    setState(() => _uploadingImage = true);
    try {
      final bytes = await picked.readAsBytes();
      final extension = _fileExtension(picked.name);
      final random = Random().nextInt(99999).toString().padLeft(5, '0');
      final filePath =
          'community/${DateTime.now().millisecondsSinceEpoch}_$random.$extension';
      await client.storage.from(_storageBucket).uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(
              upsert: false,
              contentType: _contentTypeFromExtension(extension),
            ),
          );
      final publicUrl = client.storage.from(_storageBucket).getPublicUrl(filePath);
      await client.from(_tableName).insert({
        'author': 'Aarón',
        'text': _composerController.text.trim(),
        'imageUrl': publicUrl,
        'isMine': true,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      });
      _composerController.clear();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo subir la imagen a Supabase Storage.')),
      );
    } finally {
      if (mounted) setState(() => _uploadingImage = false);
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
    return Scaffold(
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
                    border: Border.all(color: VibeColors.mint.withValues(alpha: 0.92)),
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
              child: StreamBuilder<List<_CommunityMessage>>(
                stream: _communityMessagesStream(),
                builder: (context, snapshot) {
                  final liveMessages = snapshot.data ?? const <_CommunityMessage>[];
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
                    children: [
                      ..._referenceFeed.map((item) => _CommunityReferenceBubble(item: item)),
                      if (liveMessages.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        ...liveMessages.map((msg) => _CommunityBubble(message: msg)),
                      ],
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10, 4, 10, 8 + keyboardInset),
              child: _GlassComposer(
                controller: _composerController,
                sending: _sendingMessage,
                uploadingImage: _uploadingImage,
                onSendPressed: _sendCurrentTextMessage,
                onCameraPressed: _pickAndUploadImage,
                onAssistantPressed: () => _openAssistantSheet(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _fileExtension(String fileName) {
  final index = fileName.lastIndexOf('.');
  if (index < 0 || index == fileName.length - 1) return 'jpg';
  return fileName.substring(index + 1).toLowerCase();
}

String _contentTypeFromExtension(String extension) {
  return switch (extension) {
    'png' => 'image/png',
    'webp' => 'image/webp',
    'gif' => 'image/gif',
    _ => 'image/jpeg',
  };
}

/// Home: selector de cadenas, banner, categorías y grilla sin botón de compra.
class MarketExplorerHomeView extends StatefulWidget {
  const MarketExplorerHomeView({super.key});

  @override
  State<MarketExplorerHomeView> createState() => _MarketExplorerHomeViewState();
}

class _MarketExplorerHomeViewState extends State<MarketExplorerHomeView> {
  /// `true` = comparar todas las cadenas; si no, usa [_selectedKinds].
  bool _allStores = true;
  final Set<VibeStoreKind> _selectedKinds = {};
  String? _categoryId;
  final TextEditingController _searchController = TextEditingController();
  /// Zona de entrega (demo) para el selector tipo Instacart.
  String _deliveryZone = 'San José';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static const _categories = <_CategoryOption>[
    _CategoryOption(
      id: 'todo',
      label: 'Todo',
      iconAsset: 'assets/assets_icons/bolsa_icon_all.png',
    ),
    _CategoryOption(
      id: 'carnes',
      label: 'Carnes',
      iconAsset: 'assets/assets_icons/carne-de-vaca.png',
    ),
    _CategoryOption(
      id: 'panaderia',
      label: 'Panadería',
      iconAsset: 'assets/assets_icons/panaderia.png',
    ),
    _CategoryOption(
      id: 'frutas',
      label: 'Frutas',
      iconAsset: 'assets/assets_icons/fruta.png',
    ),
    _CategoryOption(
      id: 'higiene',
      label: 'Higiene',
      iconAsset: 'assets/assets_icons/cepillado_higiene.png',
    ),
    _CategoryOption(
      id: 'snacks',
      label: 'Snacks',
      iconAsset: 'assets/assets_icons/aperitivos_snacks.png',
    ),
    _CategoryOption(
      id: 'lacteos',
      label: 'Lácteos',
      iconAsset: 'assets/assets_icons/lacteos.png',
    ),
    _CategoryOption(
      id: 'bebidas',
      label: 'Bebidas',
      iconAsset: 'assets/assets_icons/bebidas.png',
    ),
  ];

  List<ProductDetailData> get _visibleProducts {
    final q = _searchController.text.trim().toLowerCase();
    var list = _demoProducts.where((p) {
      if (_categoryId == null || _categoryId == 'todo') return true;
      return p.categoryId == _categoryId;
    }).toList();
    if (_selectedKinds.isNotEmpty) {
      list = list
          .where(
            (p) => _selectedKinds.any((store) => p.priceByStore.containsKey(store)),
          )
          .toList();
    }
    if (q.isNotEmpty) {
      list = list.where((p) => p.name.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  String _selectorLabel() {
    if (_allStores || _selectedKinds.isEmpty) {
      return 'Todos los supermercados';
    }
    if (_selectedKinds.length == 1) {
      return _selectedKinds.first.displayName;
    }
    return _selectedKinds.map((e) => e.shortName).join(', ');
  }

  void _openLocationPicker() {
    const zones = ['San José', 'Escazú', 'Santa Ana', 'Cartago', 'Heredia', 'Alajuela'];
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: VibeColors.backgroundWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Text(
                  'Zona de entrega',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: VibeColors.navy,
                  ),
                ),
              ),
              ...zones.map(
                (z) => ListTile(
                  title: Text(z, style: const TextStyle(color: VibeColors.navy)),
                  trailing: z == _deliveryZone
                      ? const Icon(Icons.check, color: VibeColors.navy, size: 20)
                      : null,
                  onTap: () {
                    setState(() => _deliveryZone = z);
                    Navigator.pop(ctx);
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _openStorePicker() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: VibeColors.backgroundWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        var all = _allStores;
        final selected = Set<VibeStoreKind>.from(_selectedKinds);

        return StatefulBuilder(
          builder: (context, setModal) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Supermercados',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: VibeColors.navy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    value: all,
                    activeColor: VibeColors.mint,
                    title: const Text('Todos (comparar)'),
                    onChanged: (v) {
                      setModal(() {
                        all = v ?? false;
                        if (all) selected.clear();
                      });
                    },
                  ),
                  ...VibeStoreKind.values.map((k) {
                    return CheckboxListTile(
                      value: selected.contains(k),
                      activeColor: VibeColors.mint,
                      secondary: _StoreLogoBadge(kind: k, size: 28),
                      title: Text(k.displayName),
                      onChanged: all
                          ? null
                          : (v) {
                              setModal(() {
                                if (v ?? false) {
                                  selected.add(k);
                                } else {
                                  selected.remove(k);
                                }
                              });
                            },
                    );
                  }),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () {
                      setState(() {
                        _allStores = all;
                        _selectedKinds
                          ..clear()
                          ..addAll(selected);
                      });
                      Navigator.pop(ctx);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: VibeColors.navy,
                      foregroundColor: VibeColors.backgroundWhite,
                    ),
                    child: const Text('Listo'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final compactHeader = screenWidth < 370;
    final cartSize = compactHeader ? 36.0 : 38.0;
    final searchHintSize = compactHeader ? 14.0 : 15.0;
    final headerGap = compactHeader ? 8.0 : 10.0;
    final locationMaxWidth = compactHeader ? 92.0 : 110.0;

    return Scaffold(
      backgroundColor: VibeColors.backgroundMint,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Material(
                        color: VibeColors.backgroundWhite,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: _openLocationPicker,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.place_outlined,
                                  color: VibeColors.navy,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: locationMaxWidth),
                                  child: Text(
                                    _deliveryZone,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: VibeColors.navy,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: VibeColors.navy.withValues(alpha: 0.55),
                                  size: 22,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 48,
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: _VibeBrandCartMark(size: cartSize),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: EdgeInsets.only(left: cartSize + headerGap),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 520),
                                child: TextField(
                                  controller: _searchController,
                                  textInputAction: TextInputAction.search,
                                  cursorColor: VibeColors.navy,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText: 'Buscar productos',
                                    hintStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize: searchHintSize,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.search,
                                      color: Colors.black,
                                      size: 22,
                                    ),
                                    filled: true,
                                    fillColor: VibeColors.backgroundWhite,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 12,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFA8D5BA),
                                        width: 1.35,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFA8D5BA),
                                        width: 1.75,
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFA8D5BA),
                                        width: 1.35,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Material(
                  color: VibeColors.backgroundWhite,
                  borderRadius: BorderRadius.circular(12),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: _openStorePicker,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          Icon(
                            Icons.storefront_outlined,
                            color: VibeColors.navy.withValues(alpha: 0.85),
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _selectorLabel(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: VibeColors.navy,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.expand_more_rounded,
                            color: VibeColors.navy.withValues(alpha: 0.45),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildBanner()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: const Text(
                  'Categorías',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: VibeColors.navy,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 46,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: _categories.map((c) {
                    final selected = c.id == _categoryId;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        avatar: _CategoryChipIcon(assetPath: c.iconAsset),
                        showCheckmark: false,
                        label: Text(c.label),
                        selected: selected,
                        onSelected: (_) => setState(() => _categoryId = c.id),
                        selectedColor: const Color(0xFFA8D5BA).withValues(alpha: 0.22),
                        checkmarkColor: VibeColors.navy,
                        labelStyle: TextStyle(
                          color: VibeColors.navy,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 13,
                        ),
                        side: const BorderSide(color: Color(0xFFA8D5BA), width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            if (_visibleProducts.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No hay productos en esta categoría con ese criterio.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: VibeColors.navy.withValues(alpha: 0.65),
                        fontSize: 15,
                        height: 1.35,
                      ),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final p = _visibleProducts[index];
                      return _ProductCard(
                        data: p,
                        allStores: _allStores,
                        selectedKinds: _selectedKinds,
                        onTap: () {
                          final stores = resolveStoresForComparison(
                            _allStores,
                            _selectedKinds,
                          );
                          Navigator.of(context).push<void>(
                            MaterialPageRoute<void>(
                              builder: (_) => ProductDetailView(
                                product: p,
                                comparisonStores: stores,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    childCount: _visibleProducts.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner() {
    final activeStores = resolveStoresForComparison(_allStores, _selectedKinds);
    final headline = _allStores || _selectedKinds.isEmpty
        ? 'Comparativa de precios — referencia informativa'
        : _selectedKinds.length == 1
            ? 'Ofertas y referencias — ${_selectedKinds.first.displayName}'
            : 'Comparando: ${_selectedKinds.map((e) => e.shortName).join(' · ')}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 160,
          color: VibeColors.backgroundWhite,
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      VibeColors.backgroundWhite,
                      const Color(0xFFA8D5BA).withValues(alpha: 0.12),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _bannerLogo(),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            headline,
                            style: const TextStyle(
                              color: VibeColors.navy,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Espacio publicitario / campaña del comercio seleccionado.',
                            style: TextStyle(
                              color: VibeColors.navy.withValues(alpha: 0.65),
                              fontSize: 13,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: activeStores
                                .map((store) => _StoreLogoBadge(kind: store, size: 40))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bannerLogo() {
    if (_allStores || _selectedKinds.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/images/logo_vibe.png',
          width: 72,
          height: 72,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackLogo('VS'),
        ),
      );
    }
    final first = _selectedKinds.first;
    return _OfficialStoreLogo(kind: first);
  }
}

class _OfficialStoreLogo extends StatelessWidget {
  const _OfficialStoreLogo({required this.kind});

  final VibeStoreKind kind;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 72,
        height: 72,
        color: VibeColors.backgroundWhite,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(6),
        child: Image.asset(
          kind.officialLogoAsset,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _fallbackLogo(kind.shortName),
        ),
      ),
    );
  }
}

class _CategoryOption {
  const _CategoryOption({
    required this.id,
    required this.label,
    required this.iconAsset,
  });

  final String id;
  final String label;
  final String iconAsset;
}

final _demoProducts = <ProductDetailData>[
  ProductDetailData(
    id: 'pollo',
    categoryId: 'carnes',
    name: 'Pechuga de pollo 1 kg',
    description: 'Pechuga de Pollo Entera Don Cristobal. Precios referenciales por cadena.',
    imageUrls: const [
      'https://www.masxmenos.cr/pechuga-entera-pollo-kg/p',
      'https://picsum.photos/seed/vs-pollo2/800/800',
    ],
    priceByStore: {
      VibeStoreKind.walmart: '₡ 2 320',
      VibeStoreKind.maxiPali: '₡ 2 200',
      VibeStoreKind.bm: '₡ 2 050',
      VibeStoreKind.coopeagri: '₡ 2 480',
    },
  ),
  ProductDetailData(
    id: 'res-molida',
    categoryId: 'carnes',
    name: 'Carne molida 500 g',
    description: 'Res molida para guisos y hamburguesas.',
    imageUrls: const ['https://walmartcr.vtexassets.com/arquivos/ids/1097446-1200-900?v=639123144546870000&width=1200&height=900&aspect=true'],
    priceByStore: {
      VibeStoreKind.bm: '₡ 3 100',
      VibeStoreKind.walmart: '₡ 3 250',
      VibeStoreKind.maxiPali: '₡ 3 180',
      VibeStoreKind.coopeagri: '₡ 3 220',
    },
  ),
  ProductDetailData(
    id: 'chuleta',
    categoryId: 'carnes',
    name: 'Chuleta de cerdo 1 kg',
    description: 'Chuleta para parrilla o horno.',
    imageUrls: const ['image.png'],
    priceByStore: {
      VibeStoreKind.maxiPali: '₡ 3 890',
      VibeStoreKind.walmart: '₡ 3 950',
      VibeStoreKind.bm: '₡ 3 820',
      VibeStoreKind.coopeagri: '₡ 3 900',
    },
  ),
  ProductDetailData(
    id: 'pan',
    categoryId: 'panaderia',
    name: 'Pan blanco 600 g',
    description: 'Pan de molde clásico.',
    imageUrls: const [
      'https://walmartcr.vtexassets.com/arquivos/ids/1041569-1200-900?v=639023658028230000&width=1200&height=900&aspect=true',
      'https://picsum.photos/seed/vs-pan2/800/800',
    ],
    priceByStore: {
      VibeStoreKind.walmart: '₡ 980',
      VibeStoreKind.bm: '₡ 950',
      VibeStoreKind.maxiPali: '₡ 1 020',
      VibeStoreKind.coopeagri: '₡ 990',
    },
  ),
  ProductDetailData(
    id: 'tortillas',
    categoryId: 'panaderia',
    name: 'Tortillas de maíz 500 g',
    description: 'Paquete de tortillas.',
    imageUrls: const ['https://walmartcr.vtexassets.com/arquivos/ids/262511-1200-900?v=637745206660200000&width=1200&height=900&aspect=true'],
    priceByStore: {
      VibeStoreKind.coopeagri: '₡ 720',
      VibeStoreKind.maxiPali: '₡ 750',
      VibeStoreKind.walmart: '₡ 740',
      VibeStoreKind.bm: '₡ 710',
    },
  ),
  ProductDetailData(
    id: 'croissant',
    categoryId: 'panaderia',
    name: 'Croissants x4',
    description: 'Panadería dulce, referencia por tienda.',
    imageUrls: const ['https://walmartcr.vtexassets.com/arquivos/ids/963392-1200-900?v=638881089055030000&width=1200&height=900&aspect=true'],
    priceByStore: {
      VibeStoreKind.bm: '₡ 1 450',
      VibeStoreKind.walmart: '₡ 1 520',
      VibeStoreKind.maxiPali: '₡ 1 490',
      VibeStoreKind.coopeagri: '₡ 1 480',
    },
  ),
  ProductDetailData(
    id: 'manzana',
    categoryId: 'frutas',
    name: 'Manzana Gala 1 kg',
    description: 'Fruta fresca, precios orientativos.',
    imageUrls: const ['https://walmartcr.vtexassets.com/arquivos/ids/530538-1200-900?v=638419993933470000&width=1200&height=900&aspect=true'],
    priceByStore: {
      VibeStoreKind.walmart: '₡ 1 290',
      VibeStoreKind.maxiPali: '₡ 1 350',
      VibeStoreKind.bm: '₡ 1 260',
      VibeStoreKind.coopeagri: '₡ 1 310',
    },
  ),
  ProductDetailData(
    id: 'platano',
    categoryId: 'frutas',
    name: 'Plátano 1 kg',
    description: 'Plátano maduro.',
    imageUrls: const ['https://walmartcr.vtexassets.com/arquivos/ids/1097368-1200-900?v=639123051022470000&width=1200&height=900&aspect=true'],
    priceByStore: {
      VibeStoreKind.coopeagri: '₡ 890',
      VibeStoreKind.bm: '₡ 920',
      VibeStoreKind.walmart: '₡ 910',
      VibeStoreKind.maxiPali: '₡ 940',
    },
  ),
  ProductDetailData(
    id: 'sandia',
    categoryId: 'frutas',
    name: 'Sandía entera',
    description: 'Sandía por unidad.',
    imageUrls: const ['https://walmartcr.vtexassets.com/arquivos/ids/1065145-1200-900?v=639063508917730000&width=1200&height=900&aspect=true'],
    priceByStore: {
      VibeStoreKind.maxiPali: '₡ 2 100',
      VibeStoreKind.walmart: '₡ 2 050',
      VibeStoreKind.bm: '₡ 1 990',
      VibeStoreKind.coopeagri: '₡ 2 080',
    },
  ),
  ProductDetailData(
    id: 'Jabon Dove',
    categoryId: 'higiene',
    name: 'Jabón en barra x3',
    description: 'Jabón Dove de Hidratacion Fresca 4 Pack - 360 g.',
    imageUrls: const ['https://walmartcr.vtexassets.com/arquivos/ids/795082-1200-900?v=638687788727100000&width=1200&height=900&aspect=true'],
    priceByStore: {
      VibeStoreKind.walmart: '₡ 1 150',
      VibeStoreKind.bm: '₡ 1 120',
      VibeStoreKind.maxiPali: '₡ 1 180',
      VibeStoreKind.coopeagri: '₡ 1 160',
    },
  ),
  ProductDetailData(
    id: 'papel',
    categoryId: 'higiene',
    name: 'Papel higiénico 12 rollos',
    description: 'Doble hoja, referencia por cadena.',
    imageUrls: const ['https://picsum.photos/seed/papel1/800/600'],
    priceByStore: {
      VibeStoreKind.bm: '₡ 3 400',
      VibeStoreKind.walmart: '₡ 3 550',
      VibeStoreKind.maxiPali: '₡ 3 480',
      VibeStoreKind.coopeagri: '₡ 3 520',
    },
  ),
  ProductDetailData(
    id: 'shampoo',
    categoryId: 'higiene',
    name: 'Shampoo 400 ml',
    description: 'Cuidado capilar.',
    imageUrls: const ['https://picsum.photos/seed/shampoo1/800/600'],
    priceByStore: {
      VibeStoreKind.maxiPali: '₡ 2 890',
      VibeStoreKind.walmart: '₡ 2 950',
      VibeStoreKind.bm: '₡ 2 820',
      VibeStoreKind.coopeagri: '₡ 2 900',
    },
  ),
  ProductDetailData(
    id: 'papas',
    categoryId: 'snacks',
    name: 'Papas fritas 150 g',
    description: 'Snack salado.',
    imageUrls: const ['https://picsum.photos/seed/papas1/800/600'],
    priceByStore: {
      VibeStoreKind.walmart: '₡ 890',
      VibeStoreKind.maxiPali: '₡ 920',
      VibeStoreKind.bm: '₡ 860',
      VibeStoreKind.coopeagri: '₡ 900',
    },
  ),
  ProductDetailData(
    id: 'galletas',
    categoryId: 'snacks',
    name: 'Galletas surtidas 300 g',
    description: 'Galletas dulces.',
    imageUrls: const ['https://picsum.photos/seed/galleta1/800/600'],
    priceByStore: {
      VibeStoreKind.bm: '₡ 1 050',
      VibeStoreKind.coopeagri: '₡ 1 080',
      VibeStoreKind.walmart: '₡ 1 100',
      VibeStoreKind.maxiPali: '₡ 1 120',
    },
  ),
  ProductDetailData(
    id: 'chocolate',
    categoryId: 'snacks',
    name: 'Chocolate 100 g',
    description: 'Barra de chocolate.',
    imageUrls: const ['https://picsum.photos/seed/choco1/800/600'],
    priceByStore: {
      VibeStoreKind.maxiPali: '₡ 1 450',
      VibeStoreKind.walmart: '₡ 1 480',
      VibeStoreKind.bm: '₡ 1 420',
      VibeStoreKind.coopeagri: '₡ 1 460',
    },
  ),
  ProductDetailData(
    id: 'leche',
    categoryId: 'lacteos',
    name: 'Leche entera 1 L',
    description: 'Lácteo refrigerado, referencia.',
    imageUrls: const ['https://picsum.photos/seed/leche1/800/600'],
    priceByStore: {
      VibeStoreKind.coopeagri: '₡ 920',
      VibeStoreKind.bm: '₡ 950',
      VibeStoreKind.walmart: '₡ 940',
      VibeStoreKind.maxiPali: '₡ 970',
    },
  ),
  ProductDetailData(
    id: 'yogur',
    categoryId: 'lacteos',
    name: 'Yogur natural x4',
    description: 'Pack yogures.',
    imageUrls: const ['https://picsum.photos/seed/yogur1/800/600'],
    priceByStore: {
      VibeStoreKind.walmart: '₡ 1 280',
      VibeStoreKind.maxiPali: '₡ 1 320',
      VibeStoreKind.bm: '₡ 1 250',
      VibeStoreKind.coopeagri: '₡ 1 300',
    },
  ),
  ProductDetailData(
    id: 'queso',
    categoryId: 'lacteos',
    name: 'Queso semiduro 250 g',
    description: 'Queso en bloque.',
    imageUrls: const ['https://picsum.photos/seed/queso1/800/600'],
    priceByStore: {
      VibeStoreKind.bm: '₡ 2 100',
      VibeStoreKind.walmart: '₡ 2 180',
      VibeStoreKind.maxiPali: '₡ 2 150',
      VibeStoreKind.coopeagri: '₡ 2 120',
    },
  ),
  ProductDetailData(
    id: 'agua',
    categoryId: 'bebidas',
    name: 'Agua 1.5 L',
    description: 'Agua embotellada.',
    imageUrls: const ['https://picsum.photos/seed/agua1/800/600'],
    priceByStore: {
      VibeStoreKind.walmart: '₡ 650',
      VibeStoreKind.maxiPali: '₡ 680',
      VibeStoreKind.bm: '₡ 620',
      VibeStoreKind.coopeagri: '₡ 660',
    },
  ),
  ProductDetailData(
    id: 'jugo',
    categoryId: 'bebidas',
    name: 'Jugo natural 1 L',
    description: 'Jugo en cartón.',
    imageUrls: const ['https://picsum.photos/seed/jugo1/800/600'],
    priceByStore: {
      VibeStoreKind.maxiPali: '₡ 1 450',
      VibeStoreKind.bm: '₡ 1 380',
      VibeStoreKind.walmart: '₡ 1 420',
      VibeStoreKind.coopeagri: '₡ 1 440',
    },
  ),
  ProductDetailData(
    id: 'refresco',
    categoryId: 'bebidas',
    name: 'Refresco 2 L',
    description: 'Bebida gaseosa.',
    imageUrls: const ['https://picsum.photos/seed/refresco1/800/600'],
    priceByStore: {
      VibeStoreKind.bm: '₡ 1 190',
      VibeStoreKind.walmart: '₡ 1 250',
      VibeStoreKind.maxiPali: '₡ 1 230',
      VibeStoreKind.coopeagri: '₡ 1 240',
    },
  ),
];

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.data,
    required this.allStores,
    required this.selectedKinds,
    required this.onTap,
  });

  final ProductDetailData data;
  final bool allStores;
  final Set<VibeStoreKind> selectedKinds;
  final VoidCallback onTap;

  bool get _showStoreOnPrice => allStores || selectedKinds.length > 1 || selectedKinds.isEmpty;

  @override
  Widget build(BuildContext context) {
    final gridRef = data.resolveGridPrice(
      allStores: allStores,
      selectedKinds: selectedKinds,
    );
    final urls = _gridCardImageUrls(data);

    return Material(
      color: VibeColors.backgroundWhite,
      borderRadius: BorderRadius.circular(12),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: _ProductImagePager(urls: urls),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                data.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: VibeColors.navy,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                gridRef.price,
                style: const TextStyle(
                  color: VibeColors.navy,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              if (_showStoreOnPrice && gridRef.store != null) ...[
                const SizedBox(height: 2),
                _StoreLogoBadge(kind: gridRef.store!, size: 22),
                const SizedBox(height: 3),
                Text(
                  'En ${gridRef.store!.displayName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: VibeColors.navy.withValues(alpha: 0.62),
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Hasta 2 imágenes por producto, deslizables.
class _ProductImagePager extends StatefulWidget {
  const _ProductImagePager({required this.urls});

  final List<String> urls;

  @override
  State<_ProductImagePager> createState() => _ProductImagePagerState();
}

class _ProductImagePagerState extends State<_ProductImagePager> {
  late final PageController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pageCount = widget.urls.length;
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _controller,
          itemCount: pageCount,
          onPageChanged: (i) => setState(() => _index = i),
          itemBuilder: (context, i) {
            return _NetworkOrAssetImage(url: widget.urls[i]);
          },
        ),
        if (pageCount > 1)
          Positioned(
            bottom: 6,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pageCount,
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.5),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: i == _index ? 14 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _index
                          ? VibeColors.mint
                          : VibeColors.navy.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _NetworkOrAssetImage extends StatelessWidget {
  const _NetworkOrAssetImage({required this.url});

  final String url;

  static const _placeholder = Color(0xFFA8D5BA);

  @override
  Widget build(BuildContext context) {
    final u = url.trim();
    final network = u.startsWith('http://') || u.startsWith('https://');
    if (network) {
      return Image.network(
        u,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imageError(),
      );
    }
    return Image.asset(
      u,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _imageError(),
    );
  }

  Widget _imageError() {
    return ColoredBox(
      color: _placeholder.withValues(alpha: 0.2),
      child: const Center(
        child: Icon(Icons.image_not_supported_outlined, color: VibeColors.navy),
      ),
    );
  }
}

/// Usa todas las imágenes disponibles; mínimo una de respaldo.
List<String> _gridCardImageUrls(ProductDetailData data) {
  const fallback = 'https://picsum.photos/seed/vibegrid/400/400';
  final raw = data.imageUrls.where((e) => e.trim().isNotEmpty).toList();
  if (raw.isEmpty) return [fallback];
  return raw;
}

class _CategoryChipIcon extends StatelessWidget {
  const _CategoryChipIcon({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.category_outlined,
          size: 18,
          color: VibeColors.navy,
        ),
      ),
    );
  }
}

class _VibeBrandCartMark extends StatelessWidget {
  const _VibeBrandCartMark({this.size = 38});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Center(
        child: _BrandGlyph(size: size),
      ),
    );
  }
}

class _StoreLogoBadge extends StatelessWidget {
  const _StoreLogoBadge({required this.kind, this.size = 32});

  final VibeStoreKind kind;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: VibeColors.backgroundWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFA8D5BA).withValues(alpha: 0.8),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(3),
      child: Image.asset(
        kind.officialLogoAsset,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            kind.shortName,
            style: const TextStyle(
              color: VibeColors.navy,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandGlyph extends StatelessWidget {
  const _BrandGlyph({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/assets_icons/VibeShopping_icon.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Image.asset(
        'assets/images/logo_vibe.png',
        width: size * 0.85,
        height: size * 0.85,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.shopping_cart_rounded,
          color: VibeColors.navy,
          size: 26,
        ),
      ),
    );
  }
}

Widget _fallbackLogo(String text) {
  return Container(
    width: 72,
    height: 72,
    color: VibeColors.mint.withValues(alpha: 0.35),
    alignment: Alignment.center,
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w800,
        color: VibeColors.navy,
      ),
    ),
  );
}

class _CommunityBubble extends StatelessWidget {
  const _CommunityBubble({required this.message});

  final _CommunityMessage message;

  @override
  Widget build(BuildContext context) {
    final bgColor = message.mine ? const Color(0xFF2C4361) : const Color(0xFFF8FAFB);
    final textColor = message.mine ? Colors.white : const Color(0xFF2F3C4C);
    final cross = message.mine ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final align = message.mine ? Alignment.centerRight : Alignment.centerLeft;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(message.mine ? 16 : 4),
      bottomRight: Radius.circular(message.mine ? 4 : 16),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: align,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 285),
          child: Container(
            decoration: BoxDecoration(color: bgColor, borderRadius: radius),
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Column(
              crossAxisAlignment: cross,
              children: [
                if (message.author.isNotEmpty && !message.mine)
                  Text(
                    message.author,
                    style: TextStyle(
                      color: const Color(0xFF5F6E7D).withValues(alpha: 0.92),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                if (message.author.isNotEmpty && !message.mine) const SizedBox(height: 4),
                if (message.text.isNotEmpty)
                  Text(
                    message.text,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      height: 1.28,
                    ),
                  ),
                if (message.imageUrl != null && message.imageUrl!.isNotEmpty) ...[
                  if (message.text.isNotEmpty) const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      message.imageUrl!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 180,
                        color: VibeColors.mint.withValues(alpha: 0.18),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.broken_image_outlined,
                          color: VibeColors.navy,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.timestampLabel,
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.56),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (message.mine) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.done_all_rounded,
                        size: 15,
                        color: textColor.withValues(alpha: 0.76),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassComposer extends StatelessWidget {
  const _GlassComposer({
    required this.controller,
    required this.onCameraPressed,
    required this.onSendPressed,
    required this.onAssistantPressed,
    required this.sending,
    required this.uploadingImage,
  });

  final TextEditingController controller;
  final VoidCallback onCameraPressed;
  final VoidCallback onSendPressed;
  final VoidCallback onAssistantPressed;
  final bool sending;
  final bool uploadingImage;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.58),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: VibeColors.mint.withValues(alpha: 0.9)),
                ),
                child: Row(
                  children: [
                    _ActionIconButton(
                      icon: uploadingImage
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(
                              Icons.camera_alt_outlined,
                              color: Color(0xFF476073),
                              size: 20,
                            ),
                      onTap: uploadingImage ? null : onCameraPressed,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        minLines: 1,
                        maxLines: 3,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF3A4A59),
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'Escribe un mensaje...',
                          hintStyle: TextStyle(
                            color: const Color(0xFF6D7782).withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 9,
                          ),
                          fillColor: Colors.white.withValues(alpha: 0.82),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: BorderSide(
                              color: VibeColors.mint.withValues(alpha: 0.85),
                              width: 1.1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _ActionIconButton(
                      icon: sending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(
                              Icons.send_rounded,
                              color: Color(0xFF214053),
                              size: 20,
                            ),
                      backgroundColor: VibeColors.mint.withValues(alpha: 0.72),
                      onTap: sending ? null : onSendPressed,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Material(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onAssistantPressed,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: VibeColors.mint.withValues(alpha: 0.95)),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF2C4361)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CommunityMessage {
  const _CommunityMessage({
    required this.author,
    required this.text,
    required this.mine,
    required this.createdAt,
    this.imageUrl,
    this.timestampOverride,
  });

  factory _CommunityMessage.fromMap(Map<String, dynamic> map) {
    final rawDate = map['createdAt'];
    DateTime createdAt = DateTime.now();
    if (rawDate is String) {
      createdAt = DateTime.tryParse(rawDate)?.toLocal() ?? DateTime.now();
    }
    return _CommunityMessage(
      author: (map['author'] ?? 'Community').toString(),
      text: (map['text'] ?? '').toString(),
      mine: map['isMine'] == true,
      imageUrl: map['imageUrl']?.toString(),
      createdAt: createdAt,
    );
  }

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

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.icon,
    required this.onTap,
    this.backgroundColor = const Color(0xFFE8F1EE),
  });

  final Widget icon;
  final VoidCallback? onTap;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: icon,
        ),
      ),
    );
  }
}

class _CommunityReferenceBubble extends StatelessWidget {
  const _CommunityReferenceBubble({required this.item});

  final _CommunityFeedItem item;

  @override
  Widget build(BuildContext context) {
    if (item.type == _ReferenceBubbleType.productCard) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: 280,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FBFB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: VibeColors.mint.withValues(alpha: 0.65)),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  child: Image.network(
                    item.imageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      color: VibeColors.mint.withValues(alpha: 0.2),
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported_outlined),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    item.actionLabel ?? 'Purchase',
                    style: const TextStyle(
                      color: Color(0xFF2F4B5B),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return _CommunityBubble(
      message: _CommunityMessage(
        author: '',
        text: item.text ?? '',
        mine: item.mine,
        imageUrl: null,
        createdAt: DateTime.now(),
        timestampOverride: item.timestamp ?? '',
      ),
    );
  }
}

enum _ReferenceBubbleType { text, productCard }

class _CommunityFeedItem {
  const _CommunityFeedItem._({
    required this.type,
    required this.mine,
    this.text,
    this.timestamp,
    this.imageUrl,
    this.actionLabel,
  });

  factory _CommunityFeedItem.myText(String text, {required String timestamp}) {
    return _CommunityFeedItem._(
      type: _ReferenceBubbleType.text,
      mine: true,
      text: text,
      timestamp: timestamp,
    );
  }

  factory _CommunityFeedItem.incomingText(String text, {required String timestamp}) {
    return _CommunityFeedItem._(
      type: _ReferenceBubbleType.text,
      mine: false,
      text: text,
      timestamp: timestamp,
    );
  }

  factory _CommunityFeedItem.productCard({
    required String imageUrl,
    required String actionLabel,
  }) {
    return _CommunityFeedItem._(
      type: _ReferenceBubbleType.productCard,
      mine: false,
      imageUrl: imageUrl,
      actionLabel: actionLabel,
    );
  }

  final _ReferenceBubbleType type;
  final bool mine;
  final String? text;
  final String? timestamp;
  final String? imageUrl;
  final String? actionLabel;
}

extension on VibeStoreKind {
  String get displayName => switch (this) {
        VibeStoreKind.walmart => 'Walmart',
        VibeStoreKind.maxiPali => 'Maxi Palí',
        VibeStoreKind.bm => 'BM',
        VibeStoreKind.coopeagri => 'Coopeagri',
      };

  String get shortName => switch (this) {
        VibeStoreKind.walmart => 'Walmart',
        VibeStoreKind.maxiPali => 'Maxi Palí',
        VibeStoreKind.bm => 'BM',
        VibeStoreKind.coopeagri => 'Coopeagri',
      };

  /// Logo oficial en `assets/assets_logos/` para banner y cabeceras.
  String get officialLogoAsset => switch (this) {
        VibeStoreKind.walmart => 'assets/assets_logos/Walmart_logo.jpg',
        VibeStoreKind.maxiPali => 'assets/assets_logos/maxipali_logo.jpeg',
        VibeStoreKind.bm => 'assets/assets_logos/Bm_logo.png',
        VibeStoreKind.coopeagri => 'assets/assets_logos/Coopeagri_logo.png',
      };
}
