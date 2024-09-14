import 'package:boomarang/screens/profile.dart';
import 'package:flutter/material.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  String selectedTile = 'profile';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 150,
            width: double.infinity,
            color: Theme.of(context).canvasColor,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "Admin",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
          ),
          const Divider(
            height: 1,
            thickness: 0.5,
          ),
          const SizedBox(
            height: 16,
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: const Text('Profile'),
                          subtitle: const Text('Edit your profile'),
                          leading: const Icon(Icons.person),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          tileColor: selectedTile == 'profile'
                              ? Theme.of(context).highlightColor
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
                const VerticalDivider(
                  width: 1,
                ),
                const Expanded(
                  flex: 2,
                  child: BoomarangProfileScreen(),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
