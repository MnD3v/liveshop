import 'package:json_annotation/json_annotation.dart';
import 'product.dart';

part 'cart_item.g.dart';

@JsonSerializable()
class CartItem {
  final String id;
  @JsonKey(includeFromJson: true)
  final String productId;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final Product? product; // Populated later if loading from JSON only with ID
  final int quantity;
  final Map<String, String>? selectedVariations; // {size: 'M', color: 'Red'}

  CartItem({
    required this.id,
    required this.productId,
    this.product,
    required this.quantity,
    this.selectedVariations,
  });

  double get total => (product?.currentPrice ?? 0) * quantity;

  CartItem copyWith({
    String? id,
    String? productId,
    Product? product,
    int? quantity,
    Map<String, String>? selectedVariations,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedVariations: selectedVariations ?? this.selectedVariations,
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);
  Map<String, dynamic> toJson() => _$CartItemToJson(this);
}
