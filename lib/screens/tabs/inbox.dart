import 'dart:async';

import 'package:boomarang/main.dart';
import 'package:boomarang_shared/models/request.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  List<BoomarangRequest> _requests = [];
  late StreamSubscription requestStreamSubscription;

  BoomarangRequest? _selectedRequest;

  final QuillController _quillController = QuillController.basic();

  @override
  void initState() {
    super.initState();
    requestStreamSubscription = firestore
        .collection('requests')
        .where('recipientUserId', isEqualTo: auth.currentUser!.uid)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _requests = snapshot.docs
            .map((e) => BoomarangRequest.fromMap(e.data()))
            .toList();
        _requests.sort((a, b) {
          return b.dateCreated.compareTo(a.dateCreated);
        });
        _selectedRequest = _requests.firstWhereOrNull(
          (element) => element.id == _selectedRequest?.id,
        );
        if (_selectedRequest == null && _requests.isNotEmpty) {
          _selectedRequest = _requests.first;
        }
      });
    });
  }

  @override
  void dispose() {
    requestStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text("Respond"),
        icon: const Icon(Icons.reply),
      ),
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
                  "Inbox",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
          ),
          const Divider(
            height: 1,
            thickness: 0.5,
          ),
          Expanded(
            child: Row(
              children: [
                Container(
                  constraints: const BoxConstraints(
                    maxWidth: 300,
                    minWidth: 100,
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 16.0),
                    itemBuilder: (context, index) {
                      //complete - blue
                      //awaiting consent - yellow
                      //awaiting completion - green
                      //rejected - red

                      BoomarangRequest request = _requests[index];
                      Color? color;

                      if (request.requestStatus == "rejected") {
                        color = Colors.grey;
                      } else if (request.requestStatus == "replied") {
                        color = Colors.blue;
                      } else if (request.consentVerified == false ||
                          request.consentVerified == null) {
                        color = Colors.amber;
                      } else {
                        color = Colors.green;
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: _selectedRequest == request
                                ? Theme.of(context)
                                    .highlightColor
                                    .withOpacity(0.3)
                                : Colors.transparent,
                            border: Border(
                              left: BorderSide(
                                color: color,
                                width: 4,
                              ),
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              setState(() {
                                _selectedRequest = request;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 4.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(request.senderEmail ?? "Unknown",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                              )),
                                      Text(
                                        request.formattedCreatedDateOrTime,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                  //subject first and last name
                                  Text(
                                    "${request.subjectFirstName} ${request.subjectLastName}",
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  //two lines of details
                                  Text(
                                    request.requestDescription ??
                                        "No description",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          color: Colors.black45,
                                        ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const Divider(
                        indent: 8,
                        endIndent: 8,
                      );
                    },
                    itemCount: _requests.length,
                  ),
                ),
                const VerticalDivider(
                  width: 1,
                ),
                Expanded(
                  child: _selectedRequest == null
                      ? const Center(child: Text("No request selected"))
                      : ListView(
                          padding: const EdgeInsets.all(16.0),
                          children: [
                            //received date
                            const Text("Details"),
                            ListTile(
                              subtitle: const Text("Received"),
                              title: Text(
                                _selectedRequest!.formattedCreatedFullDate,
                              ),
                              leading: const Icon(Icons.calendar_today),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            const Text("Requester"),
                            //sender email
                            ListTile(
                              subtitle: const Text("Email"),
                              title: Text(
                                _selectedRequest!.senderEmail ?? "Unknown",
                              ),
                              leading: const Icon(Icons.email),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            const Text("Subject"),
                            //subject details
                            ListTile(
                              subtitle: const Text("Name"),
                              title: Text(
                                "${_selectedRequest!.subjectFirstName} ${_selectedRequest!.subjectLastName}",
                              ),
                              leading: const Icon(Icons.person),
                            ),
                            //dob verified
                            ListTile(
                              subtitle: const Text("Date of Birth"),
                              title: Text(
                                _selectedRequest!.formattedSubjectDob,
                              ),
                              leading: const Icon(Icons.cake),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            const Text("Identity Verification"),
                            //email verified
                            ListTile(
                              title: const Text("Email"),
                              subtitle: Text(
                                _selectedRequest!.subjectEmailVerified == true
                                    ? "Verified"
                                    : "Not Verified",
                              ),
                              leading:
                                  _selectedRequest!.subjectEmailVerified == true
                                      ? const Icon(
                                          Icons.verified,
                                          color: Colors.green,
                                        )
                                      : const Icon(
                                          Icons.warning,
                                          color: Colors.amber,
                                        ),
                            ),
                            //dob verified
                            ListTile(
                              title: const Text("Date of Birth"),
                              subtitle: Text(
                                _selectedRequest!.subjectDOBVerified == true
                                    ? "Verified"
                                    : "Not Verified",
                              ),
                              leading:
                                  _selectedRequest!.subjectDOBVerified == true
                                      ? const Icon(
                                          Icons.verified,
                                          color: Colors.green,
                                        )
                                      : const Icon(Icons.warning,
                                          color: Colors.amber),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            //consent details
                            const Text("Consent Details"),
                            ListTile(
                              title: const Text("Standard Consent Policy"),
                              subtitle: Text(
                                _selectedRequest!.consentVerified == true
                                    ? "Accepted"
                                    : "Not Accepted",
                              ),
                              leading: _selectedRequest!.consentVerified == true
                                  ? const Icon(
                                      Icons.verified,
                                      color: Colors.green,
                                    )
                                  : const Icon(
                                      Icons.warning,
                                      color: Colors.amber,
                                    ),
                              //generic consent policy highlights in a list
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            const Text("Overview"),
                            //request details
                            ListTile(
                              title: const Text("Description"),
                              subtitle: Text(
                                _selectedRequest?.requestDescription ??
                                    "Unknown",
                              ),
                              leading: const Icon(Icons.description),
                            ),
                            //reply options
                            const SizedBox(
                              height: 100,
                            ),
                          ],
                        ),
                ),
                const VerticalDivider(),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        QuillSimpleToolbar(
                          controller: _quillController,
                          configurations:
                              const QuillSimpleToolbarConfigurations(),
                        ),
                        const Divider(
                          thickness: 0.4,
                        ),
                        QuillEditor.basic(
                          controller: _quillController,
                          configurations: const QuillEditorConfigurations(
                            minHeight: 500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
