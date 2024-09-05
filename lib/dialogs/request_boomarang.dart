import 'package:boomarang/main.dart';
import 'package:boomarang/misc/alert_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class RequestBoomarangScreen extends StatefulWidget {
  const RequestBoomarangScreen({
    super.key,
  });

  @override
  State<RequestBoomarangScreen> createState() => _RequestBoomarangScreenState();
}

class _RequestBoomarangScreenState extends State<RequestBoomarangScreen> {
  //form key
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FormBuilder(
        key: _formKey,
        child: SizedBox(
          width: 600,
          child: Dialog(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Request a Boomarang',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  //enter email and fee and we'll do the rest
                  Text(
                    'We\'ll send an email with a link to complete the request.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  FormBuilderTextField(
                    name: 'senderEmail',
                    initialValue: kDebugMode ? "ian@insurance.com" : null,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.email(),
                    ]),
                    decoration: const InputDecoration(
                      labelText: 'Sender Email',
                      helperMaxLines: 2,
                      helperText:
                          'Enter the contact email address on the paper request form, for example the insurance company.',
                      hintText: "requests@vitality.com",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  //first name
                  const SizedBox(height: 16),
                  FormBuilderTextField(
                    name: 'subjectFirstName',
                    initialValue: kDebugMode ? "John" : null,
                    validator: FormBuilderValidators.required(),
                    decoration: const InputDecoration(
                      labelText: 'Subject First Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  //last name
                  FormBuilderTextField(
                    name: 'subjectLastName',
                    initialValue: kDebugMode ? "Doe" : null,
                    validator: FormBuilderValidators.required(),
                    decoration: const InputDecoration(
                      labelText: 'Subject Last Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: loading
                        ? null
                        : () async {
                            if (!_formKey.currentState!.saveAndValidate()) {
                              return;
                            }
                            setState(() {
                              loading = true;
                            });
                            //functions to create the request
                            await functions
                                .httpsCallable('requestBoomarang')({
                              'senderEmail': _formKey
                                  .currentState!.fields['senderEmail']?.value,
                              'subjectFirstName': _formKey.currentState!
                                  .fields['subjectFirstName']?.value,
                              'subjectLastName': _formKey.currentState!
                                  .fields['subjectLastName']?.value,
                            })
                                .then((value) {
                              if (!context.mounted) return;
                              Navigator.of(context).pop();
                            }).catchError((error) {
                              buildErrorAlertDialog(error);
                              setState(() {
                                loading = false;
                              });
                            });
                          },
                    label: const Text('Submit'),
                    icon: loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator())
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
