import 'package:boomarang_shared/models/request.dart';
import 'package:flutter/material.dart';

class RequestTile extends StatelessWidget {
  const RequestTile({
    super.key,
    required this.tileRequest,
    required this.isSelected,
    required this.onTap,
  });

  final BoomarangRequest tileRequest;
  final void Function(BoomarangRequest) onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? Theme.of(context).highlightColor.withOpacity(0.3)
              : Colors.transparent,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => onTap(tileRequest),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        tileRequest.senderEmail ?? "Unknown",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    Text(
                      tileRequest.formattedCreatedDateOrTime,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ],
                ),
                //subject first and last name
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${tileRequest.subjectFirstName} ${tileRequest.subjectLastName}",
                      style: Theme.of(context).textTheme.bodyMedium!,
                    ),
                    Icon(
                      tileRequest.responseSubmitted
                          ? Icons.check
                          : Icons.horizontal_rule,
                      size: 15,
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
