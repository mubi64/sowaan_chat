class User {
  String? name;
  int? enabled;
  String? email;
  String? firstName;
  String? lastName;
  String? fullName;
  String? username;
  String? language;
  String? timeZone;
  String? deskTheme;
  String? userType;
  String? lastActive;
  String? lastLogin;

  User(
      {this.name,
      this.enabled,
      this.email,
      this.firstName,
      this.lastName,
      this.fullName,
      this.username,
      this.language,
      this.timeZone,
      this.deskTheme,
      this.userType,
      this.lastActive,
      this.lastLogin});

  User.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    enabled = json['enabled'];
    email = json['email'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    fullName = json['full_name'];
    username = json['username'];
    language = json['language'];
    timeZone = json['time_zone'];
    deskTheme = json['desk_theme'];
    userType = json['user_type'];
    lastActive = json['last_active'];
    lastLogin = json['last_login'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['enabled'] = enabled;
    data['email'] = email;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['full_name'] = fullName;
    data['username'] = username;
    data['language'] = language;
    data['time_zone'] = timeZone;
    data['desk_theme'] = deskTheme;
    data['user_type'] = userType;
    data['last_active'] = lastActive;
    data['last_login'] = lastLogin;
    return data;
  }
}