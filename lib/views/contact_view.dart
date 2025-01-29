import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:sowaan_chat/utils/utils.dart';

import '../networking/api_helpers.dart';
import '../networking/dio_client.dart';

class ContactView extends StatefulWidget {
  @override
  _ContactViewState createState() => _ContactViewState();
}

class _ContactViewState extends State<ContactView> {
  final FlutterNativeContactPicker _contactPicker =
      FlutterNativeContactPicker();
  Utils utils = Utils();
  Contact? _selectedContact;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? conturyCode = "92";

  Future<void> _pickContact() async {
    try {
      final Contact? contact = await _contactPicker.selectContact();
      if (contact != null &&
          contact.phoneNumbers != null &&
          contact.phoneNumbers!.isNotEmpty) {
        String pickedNumber = contact.phoneNumbers!.first;
        utils.loggerPrint(
            'Selected contact: ${contact.fullName}, Phone: $pickedNumber');

        setState(() {
          _selectedContact = contact;
          _nameController.text = _selectedContact!.fullName ?? "";
          _phoneController.text = pickedNumber;
        });
      }
    } catch (e) {
      utils.loggerPrint('Error picking contact: $e');
    }
  }

  createContact() async {
    try {
      bool available =
          await utils.isNetworkAvailable(context, utils, showDialog: false);
      utils.hideKeyboard(context);
      if (available) {
        utils.showProgressDialog(context);
        var formData = FormData.fromMap({
          'name': _nameController.text,
          'id': '${conturyCode! + _phoneController.text}@c.us',
          'number': '+${conturyCode! + _phoneController.text}',
        });
        var response = await APIFunction.post(
            context, utils, ApiClient.apiCreateContact, formData, '');

        if (response != null) {
          utils.hideProgressDialog(context);
          Navigator.pop(context);
          utils.showToast("Contact created successfully!", context);
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
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Contact"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.contact_phone),
            onPressed: _pickContact,
          ),
        ],
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
