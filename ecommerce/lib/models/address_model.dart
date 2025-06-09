class AddressModel {
  int? _addressId;
  String? _title;
  String? _receiver;
  String? _addressLine1;
  String? _addressLine2;
  String? _city;
  String? _district;
  String? _state;
  String? _landmark;
  String? _pincode;
  String? _phone;

  AddressModel();

  // Constructor đầy đủ
  AddressModel.full({
    int? addressId,
    String? title,
    String? receiver,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? district,
    String? state,
    String? landmark,
    String? pincode,
    String? phone,
  })  : _addressId = addressId,
        _title = title,
        _receiver = receiver,
        _addressLine1 = addressLine1,
        _addressLine2 = addressLine2,
        _city = city,
        _district = district,
        _state = state,
        _landmark = landmark,
        _pincode = pincode,
        _phone = phone;

  // Constructor từ JSON
  AddressModel.fromJson(Map<String, dynamic> json) {
    _addressId = json['address_id'];
    _title = json['title'];
    _receiver = json['receiver'];
    _addressLine1 = json['address_line_1'];
    _addressLine2 = json['address_line_2'];
    _city = json['city'];
    _district = json['district'];
    _state = json['state'];
    _landmark = json['landmark'];
    _pincode = json['pincode'];
    _phone = json['phone'];
  }

  // Convert AddressModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'address_id': _addressId,
      'title': _title,
      'receiver': _receiver,
      'address_line_1': _addressLine1,
      'address_line_2': _addressLine2,
      'city': _city,
      'district': _district,
      'state': _state,
      'landmark': _landmark,
      'pincode': _pincode,
      'phone': _phone,
    };
  }

  // Getters
  int get addressId => _addressId ?? 0;
  String get title => _title ?? "";
  String get receiver => _receiver ?? "";
  String get addressLine1 => _addressLine1 ?? "";
  String get addressLine2 => _addressLine2 ?? "";
  String get city => _city ?? "";
  String get district => _district ?? "";
  String get state => _state ?? "";
  String get landmark => _landmark ?? "";
  String get pincode => _pincode ?? "";
  String get phone => _phone ?? "";
}
