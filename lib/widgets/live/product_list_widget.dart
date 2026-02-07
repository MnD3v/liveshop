import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:liveshop/providers/live_event_provider.dart';
import 'package:liveshop/models/product.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liveshop/widgets/product/product_detail_dialog.dart';

class ProductListWidget extends StatelessWidget {
  final ScrollController? scrollController;
  const ProductListWidget({Key? key, this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LiveEventProvider>(
      builder: (context, provider, child) {
        final event = provider.currentEvent;
        if (event == null) return const SizedBox.shrink();

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E).withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    if (event.featuredProduct != null) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0, left: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.flash_on,
                              color: Color(0xFFFF2600),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'EN VOGUE',
                              style: GoogleFonts.sora(
                                color: const Color(0xFFFF2600),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _ProductCard(
                        product: event.featuredProduct!,
                        isFeatured: true,
                      ),
                      const SizedBox(height: 24),
                    ],

                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0, left: 4),
                      child: Text(
                        'ACHETER LE LOOK',
                        style: GoogleFonts.sora(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    ...event.productsList
                        .where((p) => p.id != event.featuredProduct?.id)
                        .map(
                          (p) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ProductCard(product: p),
                          ),
                        )
                        .toList(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final bool isFeatured;

  const _ProductCard({Key? key, required this.product, this.isFeatured = false})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isFeatured
            ? const Color(0xFF1C1C1E)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: isFeatured
            ? Border.all(
                color: const Color(0xFFFF2600).withOpacity(0.5),
                width: 1.5,
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => ProductDetailDialog(product: product),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    product.thumbnail,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: GoogleFonts.sora(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '\$${product.currentPrice.toStringAsFixed(2)}',
                            style: GoogleFonts.sora(
                              color: const Color(0xFFFF2600),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (product.isOnSale) ...[
                            const SizedBox(width: 8),
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: GoogleFonts.sora(
                                color: Colors.white38,
                                decoration: TextDecoration.lineThrough,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.add, color: Colors.black, size: 20),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) =>
                            ProductDetailDialog(product: product),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
