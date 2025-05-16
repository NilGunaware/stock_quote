import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class PasscodeViewModel extends ChangeNotifier {
  final UserService _userService;
  
  bool _isLoading = false;
  bool _isRegistered = false;
  bool _isError = false;
  String? _errorMessage;
  User? _currentUser;
  String _enteredPasscode = '';
  int _incorrectAttempts = 0;
  static const int _maxAttempts = 3;

  PasscodeViewModel(this._userService) {
    _initialize();
  }

  // Getters
  bool get isLoading => _isLoading;
  bool get isRegistered => _isRegistered;
  bool get isError => _isError;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  String get enteredPasscode => _enteredPasscode;
  bool get isPasscodeComplete => _enteredPasscode.length == 4;
  int get remainingAttempts => _maxAttempts - _incorrectAttempts;

  Future<void> _initialize() async {
    _setLoading(true);
    try {
      _isRegistered = await _userService.isUserRegistered();
      if (_isRegistered) {
        _currentUser = await _userService.getUser();
      }
    } catch (e) {
      _setError('Failed to initialize: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> registerUser(String name,String Lname, String mobile, String passcode) async {
    if (name.isEmpty || mobile.isEmpty || passcode.length != 4) {
      _setError('Please fill all fields correctly');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final user = User(
        name: name,
        Lname: Lname,
        mobile: mobile,
        passcode: passcode,
      );
      await _userService.saveUser(user);
      _currentUser = user;
      _isRegistered = true;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Registration failed: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> verifyPasscode(String passcode) async {
    if (_currentUser == null) {
      _setError('User data not found');
      return false;
    }

    if (passcode == _currentUser!.passcode) {
      _clearError();
      _incorrectAttempts = 0;
      return true;
    } else {
      _incorrectAttempts++;
      if (_incorrectAttempts >= _maxAttempts) {
        _setError('Too many incorrect attempts. Please try again later.');
        // Optional: You could implement a timeout here
        _incorrectAttempts = 0;
      } else {
        _setError('Incorrect passcode. ${remainingAttempts} attempts remaining');
      }
      return false;
    }
  }

  void updateEnteredPasscode(String digit) {
    if (_enteredPasscode.length < 4) {
      _enteredPasscode += digit;
      _clearError();
      notifyListeners();
    }
  }

  void deleteLastDigit() {
    if (_enteredPasscode.isNotEmpty) {
      _enteredPasscode = _enteredPasscode.substring(0, _enteredPasscode.length - 1);
      _clearError();
      notifyListeners();
    }
  }

  void clearPasscode() {
    _enteredPasscode = '';
    notifyListeners();
  }

  Future<void> resetPasscode() async {
    await _userService.clearUser();
    _isRegistered = false;
    _currentUser = null;
    _incorrectAttempts = 0;
    clearPasscode();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _isError = true;
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _isError = false;
    _errorMessage = null;
    notifyListeners();
  }
} 