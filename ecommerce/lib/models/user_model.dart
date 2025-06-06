class UserModel {
  String? _userId;
  String? _username;
  String? _password;
  String? _displayPicture;
  List<String>? _favouriteProducts;
  String? _phone;
  String? _email;

  UserModel();

  // Constructor đầy đủ
  UserModel.full({
    String? userId,
    String? username,
    String? password,
    String? displayPicture,
    List<String>? favouriteProducts,
    String? phone,
    String? email,
  })  : _userId = userId,
        _username = username,
        _password = password,
        _displayPicture = displayPicture,
        _favouriteProducts = favouriteProducts,
        _phone = phone,
        _email = email;

  UserModel.fromJson(Map<String, dynamic> json) {
    _userId = json['user_id'];
    _username = json['username'];
    _password = json['password'];
    _displayPicture = json['display_picture'];
    _favouriteProducts = List<String>.from(json['favourite_products'] ?? []);
    _phone = json['phone'];
    _email = json['email'];
  }

  String get userId => _userId ?? "user_id";
  String get username => _username ?? "username";
  String get password => _password ?? "password";
  String get displayPicture =>
      _displayPicture ??
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSlRM2-AldpZgaraCXCnO5loktGi0wGiNPydQ&s";
  List<String> get favouriteProducts => _favouriteProducts ?? [];
  String get phone => _phone ?? "phone";
  String get email => _email ?? "email@example.com";
}
