import 'package:flutter/material.dart';
import 'package:flutter_isar/schemas/contact.dart';

import 'service/isar_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatelessWidget {
  App({super.key});

  final isarService = IsarService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Isar Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            fixedSize: const Size(100, 30),
            textStyle: const TextStyle(fontSize: 12),
          ),
        ),
      ),
      home: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                FutureBuilder(
                  future: isarService.getContacts(),
                  builder: (context, AsyncSnapshot<List<Contact>> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    if (snapshot.hasData) {
                      final contacts = snapshot.data!;

                      return Column(
                        children: <Widget>[
                          Text(
                            'CONTACTS ${contacts.length}',
                            style: const TextStyle(fontSize: 22),
                          ),
                          ...contacts.map(
                            (Contact contact) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Card(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                      ),
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(12),
                                      ),
                                    ),
                                    child: ListTile(
                                      leading: const Icon(Icons.person),
                                      title: Text(
                                          contact.firstName + contact.lastName),
                                      subtitle: Text(contact.contactType.type),
                                      trailing: SizedBox(
                                        width: 200,
                                        child: Row(
                                          children: [
                                            OutlinedButton(
                                              onPressed: () {
                                                contact.firstName = 'Matthew';
                                                contact.lastName = 'Mateo';

                                                isarService.updateContact(
                                                  contact.id,
                                                  contact,
                                                );
                                              },
                                              child: const Text('UPDATE'),
                                            ),
                                            OutlinedButton(
                                              onPressed: () {
                                                isarService
                                                    .deleteContact(contact.id);
                                              },
                                              child: const Text('DELETE'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          )
                        ],
                      );
                    }
                    return const CircularProgressIndicator();
                  },
                ),
                OutlinedButton(
                  onPressed: () {
                    final newContact = Contact()
                      ..firstName = 'Ted'
                      ..lastName = 'Doe'
                      ..age = 50
                      ..address = Address()
                      ..address.street = 'Medio Street'
                      ..address.postcode = '50967'
                      ..contactType = ContactType.buisness;
                    isarService.addNewContact(newContact);
                  },
                  child: const Text('ADD'),
                ),
                OutlinedButton(
                  onPressed: () {
                    isarService.findBuisnessContactsWithWhere(
                        '80000', 'Wilson');
                  },
                  child: const Text('FIND'),
                ),
                // StreamBuilder(
                //   stream: isarService.watchContacts(),
                //   builder: (context, snapshot) {
                //     if (snapshot.hasData) {
                //       print('Contact changed');
                //       print(snapshot);
                //     }
                //     return Placeholder();
                //   },
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
