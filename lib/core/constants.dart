// lib/core/api_endpoints.dart
class ApiEndpoints {
  static const String baseUrl = "http://192.168.0.3:3000";
  //static const String baseUrl = "http://192.168.2.54:3000";
  //static const String baseUrl = "http://172.16.1.32:3000";

  // Auth
  static const String login = "$baseUrl/auth/login";
  static const String register = "$baseUrl/user/register";

  // Usuarios
  static const String users = "$baseUrl/user";
  static String userById(int id) => "$users/$id";

  // ✅ Presupuestos (igual que usuarios)
  static const String budgets = "$baseUrl/budgets";
  static String budgetById(int id) => "$budgets/$id";

    // ✅ Categorías
  static const String categories = "$baseUrl/categories";
  static String categoryById(int id) => "$categories/$id";

  // Currency
  static const String exchangeRates = "$baseUrl/currency/exchange-rates";

  // Noticias (API externa)
  static const String newsApi =
      "https://saurav.tech/NewsAPI/top-headlines/category/business/us.json";
     // Gastos
  static const String expenses = "$baseUrl/expenses";
  static String expenseById(int id) => "$expenses/$id";
  static String expensesByBudget(int budgetId) => "$expenses/budget/$budgetId";
  static String expensesByCategory(int budgetId, int categoryId) =>
      "$expenses/budget/$budgetId/category/$categoryId";
  static String expensesSummary(int budgetId) =>
      "$expenses/budget/$budgetId/summary";
}
