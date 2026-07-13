// ======================================================
// Archivo: features/products/widgets/vibe_image_slider.dart
// Responsabilidad: Slider de imágenes de producto con
//   dots indicadores de página
// Qué hace: Muestra una o varias imágenes en un PageView.
//   Si hay más de una, muestra dots animados abajo.
//   Soporta URLs de red y assets locales
// Quién lo utiliza: VibeProductCard (imagen principal
//   del producto en la grilla)
//
// Flujo dentro de la aplicación:
//   1. VibeProductCard pasa las URLs de imagen a
//      VibeImageSlider
//   2. El slider muestra la primera imagen (o un
//      placeholder si no hay imágenes)
//   3. Si hay varias, el usuario puede deslizar para
//      ver las demás; los dots indican la posición
//
// Conceptos utilizados:
//   - StatefulWidget: widget con estado mutable
//     (_index cambia al deslizar). El estado persiste
//     mientras el widget está en el árbol
//   - PageController: controla un PageView. Permite
//     saber la página actual y navegar programáticamente
//   - setState: notifica a Flutter que el estado cambió
//     para que reconstruya el widget. Solo se llama
//     dentro de State, nunca en StatelessWidget
//   - AnimatedContainer: widget que anima
//     automáticamente los cambios de sus propiedades
//     (width, color). Al cambiar _index, el dot activo
//     se expande suavemente
// ======================================================

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/vibe_constants.dart';

// ======================================================
// Clase: VibeImageSlider
// StatefulWidget que muestra imágenes del producto en
// un PageView con dots indicadores
// Recibe: url (List<String> — URLs de las imágenes)
// Cuándo se crea: dentro de VibeProductCard.build()
// ======================================================
class VibeImageSlider extends StatefulWidget {
  const VibeImageSlider({super.key, required this.url});

  final List<String> url;

  @override
  State<VibeImageSlider> createState() => _VibeImageSliderState();
}

// ======================================================
// Estado: _VibeImageSliderState
// Mantiene el índice de página activo (_index) y el
// PageController para controlar el PageView
// ======================================================
class _VibeImageSliderState extends State<VibeImageSlider> {
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
    final pageCount = widget.url.length;

    // Caso: sin imágenes → mostrar placeholder
    if (pageCount == 0) {
      return Container(
        color: VibeColors.mint.withValues(alpha: 0.2),
        child: const Center(
          child: Icon(Icons.image_not_supported_outlined,
              color: VibeColors.navy, size: 40),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // ——— PageView con las imágenes ———
        PageView.builder(
          controller: _controller,
          itemCount: pageCount,
          onPageChanged: (i) => setState(() => _index = i),
          itemBuilder: (context, i) {
            return _NetworkOrAssetImage(url: widget.url[i]);
          },
        ),
        // ——— Dots indicadores (solo si >1 imagen) ———
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

// ======================================================
// Clase: _NetworkOrAssetImage (widget privado)
// Muestra una imagen desde URL de red o desde assets
//   locales, detectando automáticamente el tipo
// Recibe: url (String — puede ser http://, https://,
//   o ruta de asset local)
// Cuándo se crea: por cada página del PageView
//
// ¿Por qué existe?
//   Las imágenes pueden venir como URL externa (de la
//   base de datos) o como asset local (para desarrollo
//   o fallback). Este widget decide automáticamente
//   qué constructor de Image usar
// ======================================================
class _NetworkOrAssetImage extends StatelessWidget {
  const _NetworkOrAssetImage({required this.url});

  final String url;

  static const _placeholder = VibeColors.mint;

  @override
  Widget build(BuildContext context) {
    final u = url.trim();
    final network = u.startsWith('http://') || u.startsWith('https://');

    if (network) {
      return Container(
        color: Colors.white,
        child: CachedNetworkImage(
          imageUrl: u,
          width: double.infinity,
          fit: BoxFit.contain,
          errorWidget: (_, __, ___) => _imageError(),
        ),
      );
    }
    return Container(
      color: Colors.white,
      child: Image.asset(
        u,
        width: double.infinity,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _imageError(),
      ),
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
