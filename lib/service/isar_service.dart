// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter_isar/schemas/contact.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<List<Contact>> getContacts() async {
    final isar = await db;
    // IsarCollection<Contact> contacts = isar.contacts;
    IsarCollection<Contact> contactsCollection = isar.collection<Contact>();
    final contacts = contactsCollection.where().findAll();
    return contacts;
  }

  Future<void> addNewContact(Contact newContact) async {
    final isar = await db;

    isar.writeTxnSync<int>(() => isar.contacts.putSync(newContact));
  }

  Future<void> updateContact(int id, Contact updatedContact) async {
    final isar = await db;

    await isar.writeTxn(() async {
      final contactToUpdate = await isar.contacts.get(id);

      if (contactToUpdate != null) {
        await isar.contacts.put(updatedContact);
      } else {
        print('Contact with ID not found.');
      }
    });
  }

  Future<void> deleteContact(int id) async {
    final isar = await db;

    await isar.writeTxn(() async {
      final success = await isar.contacts.delete(id);
      print('Contact deleted: $success');
    });
  }

  Future<List<Contact>> findBuisnessContactsWithFilter(
      String postCode, String street) async {
    final isar = await db;

    final result = await isar.contacts
        .filter()
        .contactTypeEqualTo(ContactType.buisness)
        .and()
        .address((address) =>
            address.postcodeEqualTo(postCode).and().streetContains(street))
        .findAll();

    return result;
  }

  Future<List<Contact>> findBuisnessContactsWithWhere(
      String postCode, String street) async {
    final isar = await db;

    final result = await isar.contacts
        .where()
        .contactTypeEqualTo(ContactType.buisness)
        .filter()
        .address((address) =>
            address.postcodeEqualTo(postCode).and().streetContains(street))
        .findAll();
    print(result);
    return result;
  }

  Future<Stream<Contact?>> watchContact(int id) async {
    final isar = await db;

    Stream<Contact?> userChanged = isar.contacts.watchObject(id);
    userChanged.listen((newUser) {
      print('User changed: ${newUser?.firstName}');
    });
    return userChanged;
  }

  Stream<void> watchContacts() async* {
    final isar = await db;
    // yield* isar.contacts.where().watch(fireImmediately: true);
    yield* isar.contacts.watchLazy();

    Stream<void> userChanged = isar.contacts.watchLazy();
    userChanged.listen(
      (event) {
        // Executed when data event is received
        print('Contact added');
      },

      onError: (error) {
        // Executed when error is received
        print('Error: ${error}');
      },
      cancelOnError:
          false, //this decides if subscription is cancelled on error or not
      onDone: () {
        //this block is executed when done event is recieved by listener
        print('Done!');
      },
    );
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      final isar = await Isar.open(
        [ContactSchema],
        directory: dir.path,
        inspector: true,
      );

      return isar;
    }

    return Future.value(Isar.getInstance());
  }
}
