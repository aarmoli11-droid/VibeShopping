import 'package:flutter/material.dart';
import '../../../../core/vibe_constants.dart';


class VibeImageSlider extends StatefulWidget {
  const VibeImageSlider({super.key, required this.url});

  final List<String> url;

  @override
  State<VibeImageSlider> createState() => _VibeImageSliderState();
}

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
    
    if (pageCount == 0) {
      return Container(
        color: const Color(0xFFA8D5BA).withValues(alpha: 0.2),
        child: const Center(
          child: Icon(Icons.image_not_supported_outlined, color: VibeColors.navy, size: 40),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _controller,
          itemCount: pageCount,
          onPageChanged: (i) => setState(() => _index = i),
          itemBuilder: (context, i) {
            return _NetworkOrAssetImage(url: widget.url[i]);
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
