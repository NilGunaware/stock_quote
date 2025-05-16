class User {
  final String name;
  final String Lname;
  final String mobile;
  final String passcode;

  User({
    required this.name,
    required this.Lname,
    required this.mobile,
    required this.passcode,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'Lname': Lname,
      'mobile': mobile,
      'passcode': passcode,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] ?? '',
      Lname: json['Lname'] ?? '',
      mobile: json['mobile'] ?? '',
      passcode: json['passcode'] ?? '',
    );
  }
} 