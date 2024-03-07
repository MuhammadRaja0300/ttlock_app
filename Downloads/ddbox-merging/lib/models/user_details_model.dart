class UserData {
  String uid;
  String dateOfBirth;
  String email;
  String fcmToken;
  String fullName;
  String language;
  bool lock;
  String nationality;
  bool otp;
  String password;
  String profileImageUrl;
  bool pushButton;
  String temperature;
  String token;
  bool unlock;
  String username;

  UserData({
    required this.uid,
    required this.dateOfBirth,
    required this.email,
    required this.fcmToken,
    required this.fullName,
    required this.language,
    required this.lock,
    required this.nationality,
    required this.otp,
    required this.password,
    required this.profileImageUrl,
    required this.pushButton,
    required this.temperature,
    required this.token,
    required this.unlock,
    required this.username,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      uid: json['uid'],
      dateOfBirth: json['date_of_birth'],
      email: json['email'],
      fcmToken: json['fcm_token'],
      fullName: json['full_name'],
      language: json['language'],
      lock: json['lock'],
      nationality: json['nationality'],
      otp: json['otp'],
      password: json['password'],
      profileImageUrl: json['profile_image_url'],
      pushButton: json['push_button'],
      temperature: json['temperature'],
      token: json['token'],
      unlock: json['unlock'],
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'date_of_birth': dateOfBirth,
      'email': email,
      'fcm_token': fcmToken,
      'full_name': fullName,
      'language': language,
      'lock': lock,
      'nationality': nationality,
      'otp': otp,
      'password': password,
      'profile_image_url': profileImageUrl,
      'push_button': pushButton,
      'temperature': temperature,
      'token': token,
      'unlock': unlock,
      'username': username,
    };
  }
}
