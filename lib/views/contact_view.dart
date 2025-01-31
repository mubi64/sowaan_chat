import 'dart:convert';

import 'package:app_bar_with_search_switch/app_bar_with_search_switch.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:sowaan_chat/utils/utils.dart';
import 'package:sowaan_chat/views/chat_detail_view.dart';
import 'package:sowaan_chat/views/contact_form.dart';
import '../networking/api_helpers.dart';
import '../networking/dio_client.dart';
import '../widgets/image_view.dart';

class ContactView extends StatefulWidget {
  @override
  _ContactViewState createState() => _ContactViewState();
}

class _ContactViewState extends State<ContactView> {
  Utils utils = Utils();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _searchController = TextEditingController();
  List contactList = [];
  List filteredContactList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchContact();
    _searchController.addListener(() {
      filterContacts(_searchController.text);
    });
  }

  fetchContact() async {
    try {
      setState(() {
        isLoading = true;
      });
      if (!await FlutterContacts.requestPermission()) {
        utils.showToast("Permission denied", context);
        return;
      }

      var contact = await FlutterContacts.getContacts(
          withProperties: true, withPhoto: true);

      if (contact.isEmpty) {
        utils.showToast("No contacts found", context);
        return;
      }

      var encodeData = jsonEncode(contact);
      var decodeData = jsonDecode(encodeData);
      contactList = decodeData;
      filteredContactList = List.from(contactList);

      isLoading = false;
      setState(() {});
    } catch (e) {
      utils.loggerPrint('Error fetching contacts: $e');
      utils.showToast("Failed to fetch contacts. Try again.", context);
    }
  }

  void filterContacts(String query) {
    setState(() {
      print('Query: $query');
      filteredContactList = contactList
          .where((contact) => contact['displayName']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
      print('Filtered: $filteredContactList');
    });
  }

  createContact(data) async {
    try {
      bool available =
          await utils.isNetworkAvailable(context, utils, showDialog: false);
      utils.hideKeyboard(context);
      if (available) {
        utils.showProgressDialog(context);
        var formData = FormData.fromMap(data);
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
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWithSearchSwitch(
        onChanged: (text) {
          _searchController.text = text;
        },
        onSubmitted: (text) {
          _searchController.text = '';
        },
        animation: AppBarAnimationSlideLeft.call,
        appBarBuilder: (context) {
          return AppBar(
            title: Text("Select Contact"),
            actions: const [
              AppBarSearchButton(
                  searchActiveIcon: Icons.search_off,
                  searchActiveButtonColor: Colors.transparent),
            ],
          );
        },
      ),
      body: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.teal,
              child: Icon(Icons.person_add_alt_1, color: Colors.white),
            ),
            title: Text("New Contact",
                style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ContactForm();
              }));
            },
          ),
          ListTile(title: Text("Select from contacts")),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredContactList.isEmpty
                    ? Center(child: Text("No contacts found"))
                    : ListView.builder(
                        itemCount: filteredContactList.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                              onTap: () async {
                                try {
                                  var number = filteredContactList[index]
                                          ['phones'][0]['number']
                                      .toString();
                                  if (number.startsWith("+")) {
                                    _phoneController.text = number
                                        .trim()
                                        .replaceAll(' ', '')
                                        .substring(1);
                                  } else {
                                    // throw error invalid number
                                    throw Exception('Invalid number');
                                  }
                                  _nameController.text =
                                      filteredContactList[index]['displayName']
                                          .toString();
                                  var data = {
                                    'id': '${_phoneController.text}@c.us',
                                    'number': '+${_phoneController.text}',
                                    'name': _nameController.text,
                                  };
                                  createContact(data);
                                } catch (e) {
                                  utils.showToast("Invalid number", context);
                                }

                                // createContact();
                              },
                              child: widgetContactListTile(
                                  filteredContactList[index], ''));
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

Widget widgetContactListTile(e, baseURL) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    child: Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.teal,
          child: Hero(
            tag: 'imageHero${e['id']}',
            child: widgetCommonProfile(
              imagePath: e['photo'].toString(),
              userName: e['displayName'].toString(),
              baseURL: baseURL,
              isBackGroundColorGray: false,
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 240,
                    child: Text(
                      e['displayName'].toString(),
                      overflow: TextOverflow
                          .ellipsis, // Prevent overflow with ellipsis
                      maxLines: 1, // Limit to a single line
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xDD242424),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                e['phones'].length > 0
                    ? e['phones'][0]['number'].toString()
                    : '',
                overflow:
                    TextOverflow.ellipsis, // Prevent overflow with ellipsis
                maxLines: 1, // Limit to a single line
                style:
                    TextStyle(color: const Color(0xFF000000).withOpacity(0.6)),
              ),
              SizedBox(height: 4),
            ],
          ),
        ),
      ],
    ),
  );
}
