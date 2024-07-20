import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
   HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();

  bool dataLoaded = false;

  Future<bool> dataLoadCheck() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("loadDataSucess")) {
      dataLoaded = true;
    }
    return false;
  }
}

class _HomePageState extends State<HomePage> {
  Future<void> _askPermissions(String routeName) async {
    PermissionStatus permissionStatus = await _getContactPermission();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (permissionStatus == PermissionStatus.granted) {
      await ContactsService.getContacts();
      prefs.setBool("loadDataSucess", true);
    } else {
      _handleInvalidPermissions(permissionStatus);
    }
  }

  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      PermissionStatus permissionStatus = await Permission.contacts.request();
      return permissionStatus;
    } else {
      return permission;
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      const snackBar = SnackBar(content: Text('Access to contact data denied'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      const snackBar =
          SnackBar(content: Text('Contact data not available on device'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hi user! Welcome')),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            widget.dataLoaded == true
                ? ElevatedButton(
                    child: const Text('Load contacts !'),
                    onPressed: () => _askPermissions('/contactsList'),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
