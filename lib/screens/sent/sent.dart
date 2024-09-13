import 'package:boomarang/providers/request_provider.dart';
import 'package:boomarang/screens/sent/form.dart';
import 'package:boomarang/screens/shared/meta.dart';
import 'package:boomarang/screens/shared/tile.dart';
import 'package:boomarang_shared/models/request.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SentScreen extends StatefulWidget {
  const SentScreen({super.key});

  @override
  State<SentScreen> createState() => _SentScreenState();
}

class _SentScreenState extends State<SentScreen> {
  BoomarangRequest? selectedRequest;

  @override
  void didChangeDependencies() {
    if (selectedRequest == null) {
      selectedRequest =
          context.read<RequestProvider>().receivedRequests.firstOrNull;
    } else {
      selectedRequest = context
          .read<RequestProvider>()
          .receivedRequests
          .firstWhere((e) => e.id == selectedRequest!.id);
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
                "Sentbox",
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
                child: Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 16.0,
                    ),
                    itemBuilder: (context, index) {
                      BoomarangRequest thisRequest =
                          context.watch<RequestProvider>().sentRequests[index];

                      return RequestTile(
                        tileRequest: context
                            .watch<RequestProvider>()
                            .sentRequests[index],
                        isSelected: thisRequest.id == selectedRequest?.id,
                        onTap: (request) {
                          setState(() {
                            selectedRequest = thisRequest;
                          });
                        },
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const Divider(
                        indent: 8,
                        endIndent: 8,
                      );
                    },
                    itemCount: context
                        .watch<RequestProvider>()
                        .receivedRequests
                        .length,
                  ),
                ),
              ),
              const VerticalDivider(
                width: 1,
              ),
              Expanded(
                child: selectedRequest == null
                    ? Container()
                    : RequestMeta(
                        selectedRequest: selectedRequest!,
                        inbox: false,
                      ),
              ),
              const VerticalDivider(
                width: 1,
              ),
              Expanded(
                flex: 2,
                child: selectedRequest == null
                    ? Container()
                    : SentRequestForm(selectedRequest: selectedRequest!),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
