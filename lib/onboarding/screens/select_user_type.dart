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
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "What do you want to do?",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  const Icon(Icons.send),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  Text('Submit a request',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  const Text(
                                      'You want a quick and easy way to submit a request for sensitive information.',
                                      textAlign: TextAlign.center),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  OutlinedButton(
                                      onPressed: () async {
                                        await firestore
                                            .collection('users')
                                            .doc(auth.currentUser!.uid)
                                            .set({'userType': 'requester'},
                                                SetOptions(merge: true));
                                      },
                                      child: const Text('Select')),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 32,
                        ),
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  const Icon(Icons.reply),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  Text('Reply to requests',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  const Text(
                                      'You want a quick and easy way of responding to requests for sensitive information.',
                                      textAlign: TextAlign.center),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  OutlinedButton(
                                      onPressed: () async {
                                        await firestore
                                            .collection('users')
                                            .doc(auth.currentUser!.uid)
                                            .set({'userType': 'holder'},
                                                SetOptions(merge: true));
                                      },
                                      child: const Text('Select')),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
