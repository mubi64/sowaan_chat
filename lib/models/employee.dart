class Employee {
  String? name;
  String? firstName;
  String? middleName;
  String? lastName;
  String? salutation;
  String? employeeName;
  String? image;
  String? gender;
  String? dateOfBirth;
  String? dateOfJoining;
  String? userId;
  String? dateOfRetirement;
  String? preferedEmail;
  String? companyEmail;

  Employee(
      {this.name,
      this.firstName,
      this.middleName,
      this.lastName,
      this.salutation,
      this.employeeName,
      this.image,
      this.gender,
      this.dateOfBirth,
      this.dateOfJoining,
      this.userId,
      this.dateOfRetirement,
      this.preferedEmail,
      this.companyEmail});

  Employee.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    firstName = json['first_name'];
    middleName = json['middle_name'];
    lastName = json['last_name'];
    salutation = json['salutation'];
    employeeName = json['employee_name'];
    image = json['image'];
    gender = json['gender'];
    dateOfBirth = json['date_of_birth'];
    dateOfJoining = json['date_of_joining'];
    userId = json['user_id'];
    dateOfRetirement = json['date_of_retirement'];
    preferedEmail = json['prefered_email'];
    companyEmail = json['company_email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['first_name'] = firstName;
    data['middle_name'] = middleName;
    data['last_name'] = lastName;
    data['salutation'] = salutation;
    data['employee_name'] = employeeName;
    data['image'] = image;
    data['gender'] = gender;
    data['date_of_birth'] = dateOfBirth;
    data['date_of_joining'] = dateOfJoining;
    data['user_id'] = userId;
    data['date_of_retirement'] = dateOfRetirement;
    data['prefered_email'] = preferedEmail;
    data['company_email'] = companyEmail;
    return data;
  }
}
