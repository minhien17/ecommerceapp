import 'dart:io';

import 'package:flutter/cupertino.dart';

class ChosenImage extends ChangeNotifier {
  File _chosenImage = File('');

  File get chosenImage => _chosenImage;
  set setChosenImage(File img) {
    _chosenImage = img;
    notifyListeners();
  }

  // Kiểm tra xem ảnh có được chọn không (ảnh rỗng)
  bool get isImageSelected =>
      _chosenImage.existsSync() && _chosenImage.path.isNotEmpty;
}
