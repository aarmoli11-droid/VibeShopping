import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../helpers/product_display_helper.dart';
import '../../comparison/providers/comparison_provider.dart';
import '../../comparison/widgets/store_price_comparison.dart';

class ProductDetailView extends StatefulWidget {
  const ProductDetailView({
    super.key,
    required this.product,
  });

  final ProductEntity product;

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  @override
  Widget build(BuildContext context) {
    final imageUrl = ProductDisplayHelper.primaryImage(widget.product);
    final price = ProductDisplayHelper.displayPrice(widget.product);
    final comparisonProvider = context.read<ComparisonProvider>();
    final result = comparisonProvider.compareProduct(widget.product.id);
    final summary = comparisonProvider.summaryFor(widget.product.id);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (imageUrl != null && imageUrl.isNotEmpty)
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.3,
                child: Padding(
                  padding: const EdgeInsets.all(48.0),
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 3.0,
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      filterQuality: FilterQuality.high,
                      fit: BoxFit.contain,
                      progressIndicatorBuilder: (context, url, progress) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 32.0,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Cantidad estándar disponible",
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (result != null && summary != null)
              StorePriceComparison(result: result, summary: summary),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
