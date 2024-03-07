class StatusModel {
  double humidity;
  bool lock_status;
  double temperature;

  StatusModel({
    required this.humidity,
    required this.lock_status,
    required this.temperature,
  });

  // Create a factory constructor to parse a JSON object into AppCommands
  factory StatusModel.fromJson(Map<String, dynamic> json) {
    return StatusModel(
      humidity: json['humidity'] as double,
      lock_status: json['lock_status'] as bool,
      temperature: json['temperature'] as double,
    );
  }

  // Create a method to convert AppCommands to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'humidity': humidity,
      'lock': lock_status,
      'otp': temperature,
    };
  }
}
