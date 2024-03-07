class UserModel {
  UserM userm;

  UserModel({
    required this.userm,
  });

  UserModel copyWith({
    UserM? user,
  }) =>
      UserModel(
        userm: user ?? this.userm,
      );
}

class UserM {
  String displayName;
  String email;
  bool isEmailVerified;
  bool isAnonymous;
  Metadata metadata;
  dynamic phoneNumber;
  String photoUrl;
  List<ProviderDatum> providerData;
  dynamic refreshToken;
  dynamic tenantId;
  String uid;

  UserM({
    required this.displayName,
    required this.email,
    required this.isEmailVerified,
    required this.isAnonymous,
    required this.metadata,
    required this.phoneNumber,
    required this.photoUrl,
    required this.providerData,
    required this.refreshToken,
    required this.tenantId,
    required this.uid,
  });

  UserM copyWith({
    String? displayName,
    String? email,
    bool? isEmailVerified,
    bool? isAnonymous,
    Metadata? metadata,
    dynamic phoneNumber,
    String? photoUrl,
    List<ProviderDatum>? providerData,
    dynamic refreshToken,
    dynamic tenantId,
    String? uid,
  }) =>
      UserM(
        displayName: displayName ?? this.displayName,
        email: email ?? this.email,
        isEmailVerified: isEmailVerified ?? this.isEmailVerified,
        isAnonymous: isAnonymous ?? this.isAnonymous,
        metadata: metadata ?? this.metadata,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        photoUrl: photoUrl ?? this.photoUrl,
        providerData: providerData ?? this.providerData,
        refreshToken: refreshToken ?? this.refreshToken,
        tenantId: tenantId ?? this.tenantId,
        uid: uid ?? this.uid,
      );
}

class Metadata {
  DateTime creationTime;
  DateTime lastSignInTime;

  Metadata({
    required this.creationTime,
    required this.lastSignInTime,
  });

  Metadata copyWith({
    DateTime? creationTime,
    DateTime? lastSignInTime,
  }) =>
      Metadata(
        creationTime: creationTime ?? this.creationTime,
        lastSignInTime: lastSignInTime ?? this.lastSignInTime,
      );
}

class ProviderDatum {
  String displayName;
  String email;
  dynamic phoneNumber;
  String photoUrl;
  String providerId;
  String uid;

  ProviderDatum({
    required this.displayName,
    required this.email,
    required this.phoneNumber,
    required this.photoUrl,
    required this.providerId,
    required this.uid,
  });

  ProviderDatum copyWith({
    String? displayName,
    String? email,
    dynamic phoneNumber,
    String? photoUrl,
    String? providerId,
    String? uid,
  }) =>
      ProviderDatum(
        displayName: displayName ?? this.displayName,
        email: email ?? this.email,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        photoUrl: photoUrl ?? this.photoUrl,
        providerId: providerId ?? this.providerId,
        uid: uid ?? this.uid,
      );
}