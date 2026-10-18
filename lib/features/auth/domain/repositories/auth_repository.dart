abstract class AuthRepository {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<void> register(Map<String, dynamic> data);
  Future<Map<String, dynamic>> loadData();
  Future<void> signOut();
}
