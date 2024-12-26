import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  Future<Map<String, dynamic>> fetchUser() async {
    final response = await http.get(Uri.parse(
        'https://script.googleusercontent.com/macros/echo?user_content_key=Cm7DIwMCf-zjeqhggn0C1ID0chFRfMdVF23g9yCzX9QgKq8zlp5GHLJXeh84DHSh5ohIO0KUCPeNX1LTvWEbT8LbUSmYuUUwm5_BxDlH2jW0nuo2oDemN9CCS2h10ox_1xSncGQajx_ryfhECjZEnGAkbPvDWlBkb3uMi7c-vLvim6Jrozx5isP83T1mygtuu-Nsb6IKy6bvz-hlPxx20Xf1UHN9xxka22vARFAGoyVh-2yvTfnkHtz9Jw9Md8uu&lib=MCLBqBtrw4yJazfRJYB5InOzNkRQCIOg8'));
    print(response.body);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Invalid phone number or password');
    } else {
      throw Exception('Failed to load data');
    }
  }

  // GET request for get-data
  Future<List<dynamic>> fetchData() async {
    final response = await http.get(Uri.parse(
        'https://script.googleusercontent.com/macros/echo?user_content_key=ui9NifYrhR43rqBVuirW8OIJo9EWV5oc6HswmI6Av7HrYky2tRdR-MUGSP4xsQIf9BoyFdoxuy1lj2JxkQHBdbYM6ndWtZHKm5_BxDlH2jW0nuo2oDemN9CCS2h10ox_1xSncGQajx_ryfhECjZEnH4GDLK3Fvu7qkPF5uHejlPjBgQMwx8NmXjxh3YbOnVTc9MIhSZudMGkVSnVJRwfBT_8wQv9Q0nuDM2_9N3S-tdgPNYiCULuD9z9Jw9Md8uu&lib=MCLBqBtrw4yJazfRJYB5InOzNkRQCIOg8'));
    if (response.statusCode == 200) {
      // Extract the list from the parent object
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData['data'] is List) {
        return responseData['data']; // Return the list directly
      } else {
        throw Exception("Expected 'data' to be a list, but it was not.");
      }
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Invalid phone number or password');
    } else {
      throw Exception('Failed to load data');
    }
  }
}
