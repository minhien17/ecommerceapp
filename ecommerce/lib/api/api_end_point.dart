class ApiEndpoint {
  // host wifi

  static String HOST = "192.168.110.109";

  // đổi mạng wifi là phải thay đổi host
  // ipconfig, Ipv4 address

  static String DOMAIN = "http://$HOST:8000/api";

  // login, signup
  static String login = "$DOMAIN/users/login";
  static String signup = "$DOMAIN/signup";

  // end point user
  static String userInfor = "/users/infor";

  // end point product
  static String product = "/products/infor";
}
