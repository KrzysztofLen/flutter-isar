import 'package:isar/isar.dart';

part 'contact.g.dart';

enum ContactType {
  private('Private'),
  buisness('Buisness');

  const ContactType(this.type);

  final String type;
}

@embedded
class Address {
  String? street;

  String? postcode;
}

@collection
@Name('Contacts')
class Contact {
  Id id = Isar.autoIncrement; // you can also use id = null to auto increment

  @Name('name')
  late String firstName;

  late String lastName;

  late int age;

  @Index()
  @enumerated
  late ContactType contactType;

  late Address address;
}
