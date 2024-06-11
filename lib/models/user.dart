class BoomarangUser {
  final String? title;
  final String? firstName;
  final String? lastName;

  BoomarangUser({
    this.title,
    this.firstName,
    this.lastName,
  });

  factory BoomarangUser.fromMap(Map<String, dynamic> map) {
    return BoomarangUser(
      title: map['title'],
      firstName: map['firstName'],
      lastName: map['lastName'],
    );
  }
}
