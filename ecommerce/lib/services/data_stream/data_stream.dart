import 'dart:async';

abstract class DataStream<T> {
  late StreamController<T> streamController = StreamController();
  void init() {
    streamController = StreamController();
    reload();
  }

  Stream get stream => streamController.stream;

  void addData(T data) {
    streamController.sink.add(data);
  }

  void addError(dynamic e) {
    streamController.sink.addError(e);
  }

  void reload();

  void dispose() {
    streamController.close();
  }
}

class ProductStream extends DataStream<List<String>> {
  @override
  void reload() {
    // Thêm dữ liệu vào stream
    List<String> products = ["Product 1", "Product 2", "Product 3"];
    addData(products);
  }
}
