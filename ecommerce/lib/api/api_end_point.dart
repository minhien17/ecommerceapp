class ApiEndpoint {
  // host wifi

  static String HOST = "192.168.3.56"; // mạng dữ liệu
  //"192.168.1.103"; // FEF

  // đổi mạng wifi là phải thay đổi host
  // ipconfig, Ipv4 address

  static String DOMAIN = "http://$HOST:8000/api";

  // login, signup
  static String login = "$DOMAIN/users/login";
  static String signup = "$DOMAIN/signup";

  // end point user
  static String userInfor = "$DOMAIN/users/infor";
  static String productYouLike = "$DOMAIN/users/favourite";
  static String userCart = "$DOMAIN/users/cart";

  // end point product
  static String product = "$DOMAIN/products";

  static String search = "$DOMAIN/search";

  static String review = "$DOMAIN/products/review";
}
