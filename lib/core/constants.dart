
class ApiEndpoints {
  static const String baseUrl = "http://192.168.0.3:3000";
  //static const String baseUrl = "http://192.168.2.54:3000";
  //static const String baseUrl = "http://172.16.1.32:3000";

  static const String login = "$baseUrl/auth/login";
  static const String register = "$baseUrl/user/register";

  // NUEVA: Para la administración
  static const String users = "$baseUrl/user";
  static String userById(int id) => "$users/$id";

}
