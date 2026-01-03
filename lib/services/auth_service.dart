import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _keyOnboardingComplete = 'onboarding_complete';
  static const String _keyIsAuthenticated = 'is_authenticated';
  static const String _keyUserMobile = 'user_mobile';
  static const String _keyUserName = 'user_name';

  // Mock OTP for demo (in production, this would come from backend)
  static const String _mockOTP = '123456';

  // Check if onboarding is complete
  Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingComplete) ?? false;
  }

  // Mark onboarding as complete
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingComplete, true);
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsAuthenticated) ?? false;
  }

  // Save user mobile number
  Future<void> saveMobileNumber(String mobile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserMobile, mobile);
  }

  // Get saved mobile number
  Future<String?> getMobileNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserMobile);
  }

  // Generate OTP (mock - returns hardcoded OTP for demo)
  Future<String> generateOTP(String mobile) async {
    // In production, this would call backend API
    // For demo, we return mock OTP and print it
    print('📱 OTP for $mobile: $_mockOTP');
    return _mockOTP;
  }

  // Verify OTP
  Future<bool> verifyOTP(String enteredOTP, String generatedOTP) async {
    return enteredOTP == generatedOTP;
  }

  // Complete authentication
  Future<void> completeAuthentication(String mobile, {String? name}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsAuthenticated, true);
    await prefs.setString(_keyUserMobile, mobile);
    if (name != null) {
      await prefs.setString(_keyUserName, name);
    }
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsAuthenticated, false);
    // Keep onboarding status and mobile number
  }

  // Clear all data (for testing)
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
