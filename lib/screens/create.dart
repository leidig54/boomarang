import 'package:boomarang/data/templates.dart';
import 'package:boomarang/main.dart';
import 'package:boomarang/providers/tab_provider.dart';
import 'package:boomarang_shared/dob_formatter.dart';
import 'package:boomarang_shared/models/consent_form.dart';
import 'package:boomarang_shared/models/request.dart';
import 'package:boomarang_shared/models/request_form.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CreateNewRequest extends StatefulWidget {
  const CreateNewRequest({
    super.key,
  });

  @override
  State<CreateNewRequest> createState() => _CreateNewRequestState();
}

class _CreateNewRequestState extends State<CreateNewRequest> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool isSaving = false;
  late String id;
  RequestForm? selectedForm;

  @override
  void initState() {
    super.initState();
    id = const Uuid().v4();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          constraints: const BoxConstraints(
            maxWidth: 600,
          ),
          child: FormBuilder(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(32),
              children: [
                //Create New
                Text("Create New Request",
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 32),
                const Text("Subject"),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'subject_first_name',
                  initialValue: kDebugMode ? 'John' : null,
                  decoration: const InputDecoration(
                      labelText: 'First Name', border: OutlineInputBorder()),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.minLength(3),
                  ]),
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'subject_last_name',
                  initialValue: kDebugMode ? 'Doe' : null,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.minLength(3),
                  ]),
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'subject_email',
                  initialValue: kDebugMode ? 'georgeleidig@icloud.com' : null,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.email(),
                  ]),
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'subject_dob',
                  initialValue: kDebugMode ? '01/01/2000' : null,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(8),
                    DateFormatInputFormatter(DateFormat('dd/MM/yyyy')),
                  ],
                  valueTransformer: (value) {
                    if (value == null) {
                      return null;
                    }
                    // Parse the date, set to start of the day, and convert to UTC
                    DateTime localDate = DateFormat('dd/MM/yyyy').parse(value);
                    DateTime localMidnight = DateTime.utc(
                        localDate.year, localDate.month, localDate.day);

                    DateTime utcDate = localMidnight.toUtc();
                    return utcDate;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                    hintText: 'dd/mm/yyyy',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 32),
                const Text("Recipient"),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'recipient_email',
                  initialValue: kDebugMode ? 'georgeleidig@icloud.com' : null,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.email(),
                  ]),
                ),
                const SizedBox(height: 32),
                const Text("Request Type"),
                const SizedBox(height: 16),
                FormBuilderRadioGroup(
                  name: 'form',
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  orientation: OptionsOrientation.vertical,
                  onChanged: (value) {
                    setState(() {
                      selectedForm = forms.firstWhere(
                          (element) => element.id == value.toString());
                    });
                  },
                  options: forms.map((form) {
                    return FormBuilderFieldOption(
                      value: form.id,
                      child: Text(form.name),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                FloatingActionButton.extended(
                  onPressed: () async {
                    if (_formKey.currentState!.saveAndValidate()) {
                      setState(() {
                        isSaving = true;
                      });

                      // Simulate a delay to show the loading indicator
                      await Future.delayed(const Duration(seconds: 1));

                      ConsentForm consentForm = ConsentForm(
                        id: 'general_consent',
                        title: 'General Data Consent Form',
                        content: '''
                ## General Data Consent Form
                
                By providing your consent, you allow us to request and share your data for the purpose outlined in the data request.
                
                The data requested may include sensitive information such as:
                
                - Medical records
                - Financial details
                - Employment history
                - Other personal data
                
                We assure you that your data will be handled securely and in compliance with relevant data protection laws (e.g., GDPR). 
                You have the right to withdraw your consent at any time.
                
                By clicking **Agree**, you confirm that you understand the nature of the request and consent to the transfer of your data.
              ''',
                      );

                      BoomarangRequest request = BoomarangRequest(
                        id: id,
                        subjectFirstName: _formKey.currentState!
                            .fields['subject_first_name']!.value as String,
                        subjectLastName: _formKey.currentState!
                            .fields['subject_last_name']!.value as String,
                        subjectEmail: _formKey.currentState!
                            .fields['subject_email']!.value as String,
                        subjectDOB: DateFormat('dd/MM/yyyy').tryParse(
                            _formKey.currentState!.fields['subject_dob']
                                    ?.value ??
                                "",
                            true),
                        senderEmail: auth.currentUser!.email!,
                        recipientEmail: _formKey.currentState!
                            .fields['recipient_email']!.value as String,
                        dateCreated: DateTime.now(),
                        form: forms.firstWhere((element) =>
                            element.id ==
                            _formKey.currentState!.fields['form']!.value),
                        consentForm: consentForm,
                      );
                      //add isDemo: true to the request map

                      Map<String, dynamic> requestMap = request.toMap();
                      requestMap['isDemo'] = true;

                      firestore.collection('requests').doc(id).set(requestMap);

                      await Future.delayed(const Duration(milliseconds: 300));

                      setState(() {
                        isSaving = false;
                      });

                      if (!context.mounted) return;
                      context.read<TabIndexProvider>().setTabIndex(2);
                    }
                  },
                  label: isSaving
                      ? const CircularProgressIndicator.adaptive()
                      : const Text("Submit"),
                ),
                const SizedBox(
                  height: 100,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
