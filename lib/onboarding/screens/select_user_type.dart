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
                title: const Text('Holder'),
                subtitle: const Text(
                    'You hold sensitive data and want to respond to requests.\nE.g. doctors, accountants, universities.'),
                trailing: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_forward_ios),
                  ],
                ),
                leading: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_circle_up),
                  ],
                ),
                isThreeLine: true,
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
                title: const Text('Requester'),
                subtitle: const Text(
                    'You want to submit requests for sensitive data.\nE.g. insurance, legal, recruitment.'),
                trailing: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_forward_ios),
                  ],
                ),
                leading: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_circle_down),
                  ],
                ),
                isThreeLine: true,
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
