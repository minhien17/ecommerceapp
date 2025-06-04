class UserModel {
  String? _email;
  String? _username;
  String? _userid;
  String? _image;

  UserModel();

  // Constructor đầy đủ
  UserModel.full({
    String? email,
    String? username,
    String? userid,
    String? image,
  })  : _email = email,
        _username = username,
        _userid = userid,
        _image = image;

  UserModel.fromJson(Map<String, dynamic> json) {
    _email = json['email'];
    _username = json['username'];
    _userid = json['userid'];
    _image = json['image'];
  }

  String get email => _email ?? "email";

  String get username => _username ?? "username";

  String get userid => _userid ?? "id";

  String get image =>
      _image ??
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSlRM2-AldpZgaraCXCnO5loktGi0wGiNPydQ&s";
}
