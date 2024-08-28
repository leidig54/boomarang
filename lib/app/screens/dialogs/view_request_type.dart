import 'package:boomarang_shared/models/request_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ViwewRequestType extends StatelessWidget {
  const ViwewRequestType({
    super.key,
    required this.requestType,
  });

  final RequestType requestType;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(requestType.name),
      contentPadding: const EdgeInsets.all(20),
      children: [
        SizedBox(
          width: 600,
          height: 600,
          child: Markdown(
            data: requestType.description!,
            shrinkWrap: true,
            padding: const EdgeInsets.all(20),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'))
      ],
    );
  }
}
