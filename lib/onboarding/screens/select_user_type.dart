import 'package:boomarang/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SelectUserTypeScreen extends StatefulWidget {
  const SelectUserTypeScreen({
    super.key,
  });

  @override
  State<SelectUserTypeScreen> createState() => _SelectUserTypeScreenState();
}

class _SelectUserTypeScreenState extends State<SelectUserTypeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Select User Type",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 32),
              ListTile(
                title: const Text('Healthcare Provider'),
                subtitle: const Text(
                    'You hold patient data and want to respond to requests.'),
                trailing:
                    //healthcare icon
                    const Icon(Icons.medical_services_outlined),
                onTap: () async {
                  await firestore
                      .collection('users')
                      .doc(auth.currentUser!.uid)
                      .set({'userType': 'holder'}, SetOptions(merge: true));
                },
              ),
              const Divider(
                thickness: 1,
                height: 1,
              ),
              ListTile(
                title: const Text('Insurer'),
                subtitle: const Text(
                    'You want to submit requests for reports on your clients.'),
                trailing:
                    //insurance icon
                    const Icon(Icons.business_center_outlined),
                onTap: () async {
                  await firestore
                      .collection('users')
                      .doc(auth.currentUser!.uid)
                      .set({'userType': 'requester'}, SetOptions(merge: true));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
