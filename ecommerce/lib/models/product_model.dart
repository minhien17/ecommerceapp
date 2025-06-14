import 'package:ecommerce/models/Model.dart';
import 'package:enum_to_string/enum_to_string.dart';

enum ProductType {
  electronic,
  book,
  fashion,
  grocery,
  art,
  other,
}

class Product extends Model {
  static const String IMAGES_KEY = "images";
  static const String TITLE_KEY = "title";
  static const String VARIANT_KEY = "variant";
  static const String DISCOUNT_PRICE_KEY = "discount_price";
  static const String ORIGINAL_PRICE_KEY = "original_price";
  static const String RATING_KEY = "rating";
  static const String HIGHLIGHTS_KEY = "highlights";
  static const String DESCRIPTION_KEY = "description";
  static const String SELLER_KEY = "seller";
  static const String OWNER_KEY = "owner";
  static const String PRODUCT_TYPE_KEY = "product_type";
  static const String SEARCH_TAGS_KEY = "search_tags";

  List<String>? images;
  String? title;
  String? variant;
  num? discountPrice = 0;
  num? originalPrice = 0;
  num? rating;
  String? highlights;
  String? description;
  String? seller;
  bool favourite = false;
  String? owner;
  ProductType? productType;
  List<String>? searchTags;

  Product(
    String id, {
    this.images,
    this.title,
    this.variant,
    this.productType,
    this.discountPrice,
    this.originalPrice,
    this.rating = 0.0,
    this.highlights,
    this.description,
    this.seller,
    this.owner,
    this.searchTags,
  }) : super(id);

  int calculatePercentageDiscount() {
    num originalP = originalPrice ?? 0;
    num discountP = discountPrice ?? 0;
    int discount = (((originalP - discountP) * 100) / originalP).round();
    return discount;
  }

  factory Product.fromMap(Map<String, dynamic> map, {String? id}) {
    if (map[SEARCH_TAGS_KEY] == null) {
      map[SEARCH_TAGS_KEY] = <String>[];
    }
    return Product(
      id ?? "",
      images: (map[IMAGES_KEY] ?? []).cast<String>(),
      title: map[TITLE_KEY],
      variant: map[VARIANT_KEY],
      productType:
          EnumToString.fromString(ProductType.values, map[PRODUCT_TYPE_KEY]),
      discountPrice: map[DISCOUNT_PRICE_KEY],
      originalPrice: map[ORIGINAL_PRICE_KEY],
      rating: map[RATING_KEY],
      highlights: map[HIGHLIGHTS_KEY],
      description: map[DESCRIPTION_KEY],
      seller: map[SELLER_KEY],
      owner: map[OWNER_KEY],
      searchTags: map[SEARCH_TAGS_KEY].cast<String>(),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      IMAGES_KEY: images,
      TITLE_KEY: title,
      VARIANT_KEY: variant,
      PRODUCT_TYPE_KEY: EnumToString.convertToString(productType),
      DISCOUNT_PRICE_KEY: discountPrice,
      ORIGINAL_PRICE_KEY: originalPrice,
      RATING_KEY: rating,
      HIGHLIGHTS_KEY: highlights,
      DESCRIPTION_KEY: description,
      SELLER_KEY: seller,
      OWNER_KEY: owner,
      SEARCH_TAGS_KEY: searchTags,
    };

    return map;
  }

  @override
  Map<String, dynamic> toUpdateMap() {
    final map = <String, dynamic>{};
    if (images != null) map[IMAGES_KEY] = images;
    if (title != null) map[TITLE_KEY] = title;
    if (variant != null) map[VARIANT_KEY] = variant;
    if (discountPrice != null) map[DISCOUNT_PRICE_KEY] = discountPrice;
    if (originalPrice != null) map[ORIGINAL_PRICE_KEY] = originalPrice;
    if (rating != null) map[RATING_KEY] = rating;
    if (highlights != null) map[HIGHLIGHTS_KEY] = highlights;
    if (description != null) map[DESCRIPTION_KEY] = description;
    if (seller != null) map[SELLER_KEY] = seller;
    if (productType != null)
      map[PRODUCT_TYPE_KEY] = EnumToString.convertToString(productType);
    if (owner != null) map[OWNER_KEY] = owner;
    if (searchTags != null) map[SEARCH_TAGS_KEY] = searchTags;

    return map;
  }
}

class ProductModel {
  String? _productId;
  List<String>? _images;
  String? _title;
  String? _variant;
  num? _discountPrice = 0;
  num? _originalPrice = 0;
  num? _rating;
  String? _highlights;
  String? _description;
  String? _seller;
  bool _favourite = false;
  String? _owner;
  ProductType? _productType;
  List<String>? _searchTags;

  ProductModel();

  ProductModel.fromJson(Map<String, dynamic> json) {
    _productId = json['product_id'];
    _images = List<String>.from(json['images'] ?? []);
    _title = json['title'];
    _variant = json['variant'];
    _discountPrice = json['discount_price'] ?? 0;
    _originalPrice = json['original_price'] ?? 0;
    _rating = json['rating'];
    _highlights = json['highlights'];
    _description = json['description'];
    _seller = json['seller'];
    _favourite = json['favourite'] ?? false;
    _owner = json['owner'];
    _searchTags = List<String>.from(json['search_tags'] ?? []);

    // parse productType as enum
    if (json['product_type'] != null) {
      final parsedType =
          EnumToString.fromString(ProductType.values, json['product_type']);
      if (parsedType != null) {
        _productType = parsedType;
      } else {
        // Giá trị không hợp lệ → có thể gán giá trị mặc định hoặc log lỗi
        print("⚠️ Invalid product_type: ${json['product_type']}");
        _productType = ProductType
            .other; // hoặc gán một default như ProductType.unknown nếu có
      }
    }
  }

  String get id => _productId ?? "";
  set id(String value) => _productId = value;

  List<String> get images => _images ?? [];
  set images(List<String> value) => _images = value;

  String get title => _title ?? "Untitled";
  set title(String value) => _title = value;

  String get variant => _variant ?? "Unknown";
  set variant(String value) => _variant = value;

  num get discountPrice => _discountPrice ?? 0;
  set discountPrice(num value) => _discountPrice = value;

  num get originalPrice => _originalPrice ?? 0;
  set originalPrice(num value) => _originalPrice = value;

  num get rating => _rating ?? 0;
  set rating(num value) => _rating = value;

  String get highlights => _highlights ?? "";
  set highlights(String value) => _highlights = value;

  String get description => _description ?? "";
  set description(String value) => _description = value;

  String get seller => _seller ?? "Unknown seller";
  set seller(String value) => _seller = value;

  bool get favourite => _favourite;
  set favourite(bool value) => _favourite = value;

  String get owner => _owner ?? "Unknown";
  set owner(String value) => _owner = value;

  ProductType get productType => _productType ?? ProductType.other;
  set productType(ProductType value) => _productType = value;

  List<String> get searchTags => _searchTags ?? [];
  set searchTags(List<String> value) => _searchTags = value;

  int calculatePercentageDiscount() {
    num originalP = originalPrice;
    num discountP = discountPrice;
    int discount = (((originalP - discountP) * 100) / originalP).round();
    return discount;
  }

  ProductModel copyWith({
    String? id,
    List<String>? images,
  }) {
    return ProductModel()
      .._productId = id ?? this._productId
      .._images = images ?? this._images
      .._title = this._title
      .._variant = this._variant
      .._discountPrice = this._discountPrice
      .._originalPrice = this._originalPrice
      .._rating = this._rating
      .._highlights = this._highlights
      .._description = this._description
      .._seller = this._seller
      .._favourite = this._favourite
      .._owner = this._owner
      .._productType = this._productType
      .._searchTags = this._searchTags;
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': _productId,
      'images': _images,
      'title': _title,
      'variant': _variant,
      'discount_price': _discountPrice,
      'original_price': _originalPrice,
      'rating': _rating,
      'highlights': _highlights,
      'description': _description,
      'seller': _seller,
      'favourite': _favourite,
      'owner': _owner,
      'product_type': _productType?.name,
      'search_tags': _searchTags,
    };
  }
}
