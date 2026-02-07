import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

@JsonSerializable()
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? salePrice;
  final List<String> images;
  final String thumbnail;
  final int stock;
  final Map<String, dynamic>?
  variations; // {size: ['S', 'M', 'L'], color: ['Red', 'Blue']}
  final bool isFeatured;
  final DateTime? featuredAt;
  final String? category;
  final double rating;
  final int reviewsCount;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.salePrice,
    required this.images,
    required this.thumbnail,
    required this.stock,
    this.variations,
    this.isFeatured = false,
    this.featuredAt,
    this.category,
    this.rating = 0.0,
    this.reviewsCount = 0,
  });

  double get currentPrice => salePrice ?? price;
  bool get isOnSale => salePrice != null && salePrice! < price;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);
}
