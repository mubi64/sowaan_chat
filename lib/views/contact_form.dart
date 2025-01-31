import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:sowaan_chat/networking/dio_client.dart';
import 'package:sowaan_chat/utils/utils.dart';
import 'package:sowaan_chat/views/chat_detail_view.dart';

import '../networking/api_helpers.dart';

class ContactForm extends StatefulWidget {
  const ContactForm({super.key});

  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  Utils utils = Utils();
  Contact? _selectedContact;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? conturyCode = "92";

  createContact() async {
    try {
      bool available =
          await utils.isNetworkAvailable(context, utils, showDialog: false);
      utils.hideKeyboard(context);
      if (available) {
        utils.showProgressDialog(context);
        var formData = FormData.fromMap({
          'id': '$conturyCode${_phoneController.text}@c.us',
          'number': '+$conturyCode${_phoneController.text}',
          'name': _nameController.text,
        });
        var response = await APIFunction.post(
            context, utils, ApiClient.apiCreateContact, formData, '');

        if (response != null) {
          utils.hideProgressDialog(context);
          var data = response.data['message'];
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return ChatDetailView(
              id: data['recipient'],
              name: data['recipient_name'],
              isGroup: false,
            );
          }));
        } else {
          utils.hideProgressDialog(context);
          utils.loggerPrint('Error creating contact');
          utils.showToast("An unexpected error occurred", context);
        }
      }
    } catch (e) {
      utils.hideProgressDialog(context);
      utils.loggerPrint('Error creating contact: $e');
      utils.showToast("An unexpected error occurred: $e", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Icon(
                          Icons.person_outline,
                          color: Colors.grey,
                          size: 30,
                        ),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                          child: _buildTextField(
                              "Full Name", _nameController, "")),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Icon(
                          Icons.phone_outlined,
                          color: Colors.grey,
                          size: 30,
                        ),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: IntlPhoneField(
                          controller: _phoneController,
                          showCountryFlag: false,
                          dropdownTextStyle: TextStyle(fontSize: 16),
                          onCountryChanged: (phone) {
                            setState(() => conturyCode = phone.dialCode);
                          },
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                          ),
                          initialCountryCode: 'PK', // Set Pakistan as default
                          onChanged: (phone) {
                            print(
                                'Phone NUmber $phone'); // Prints full number with country code
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: () {
                  createContact();
                },
                child: Text("Save",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, String? hintText) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        // filled: true,
        // fillColor: Colors.grey[900],
      ),
    );
  }
}
