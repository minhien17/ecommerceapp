import 'Model.dart';

class CartItem extends Model {
  static const String PRODUCT_ID_KEY = "product_id";
  static const String ITEM_COUNT_KEY = "item_count";

  int itemCount;
  CartItem({
    String? id,
    this.itemCount = 0,
  }) : super(id ?? "");

  factory CartItem.fromMap(Map<String, dynamic> map, {String? id}) {
    return CartItem(
      id: id,
      itemCount: map[ITEM_COUNT_KEY],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      ITEM_COUNT_KEY: itemCount,
    };
    return map;
  }

  @override
  Map<String, dynamic> toUpdateMap() {
    final map = <String, dynamic>{};
    if (itemCount != null) map[ITEM_COUNT_KEY] = itemCount;
    return map;
  }
}

class CartItemModel {
  String? _productId;
  int? _itemCount;

  CartItemModel();

  CartItemModel.fromJson(Map<String, dynamic> json) {
    _productId = json['product_id'];
    _itemCount = json['item_count'];
  }

  String get id => _productId ?? "";
  int get itemCount => _itemCount ?? 0;
}
