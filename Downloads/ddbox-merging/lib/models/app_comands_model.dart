class AppCommands {
  bool lock;
  bool otp;
  bool unlock;

  AppCommands({
    required this.lock,
    required this.otp,
    required this.unlock,
  });

  // Create a factory constructor to parse a JSON object into AppCommands
  factory AppCommands.fromJson(Map<String, dynamic> json) {
    return AppCommands(
      lock: json['lock'] as bool,
      otp: json['otp'] as bool,
      unlock: json['unlock'] as bool,
    );
  }

  // Create a method to convert AppCommands to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'lock': lock,
      'otp': otp,
      'unlock': unlock,
    };
  }
}
