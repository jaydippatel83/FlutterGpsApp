import 'package:flutter/material.dart';
import 'package:flutter_gps_app/model/user_api.dart';
import 'package:flutter_gps_app/model/user_model.dart';
import 'package:flutter_gps_app/notifire/user_notifire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'map.dart';

class UserInfo extends StatefulWidget {
  final Position initialPosition;
  UserInfo({@required this.initialPosition});
  @override
  _UserInfoState createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  final GlobalKey _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  UserData _currentUser;
  TextEditingController subingredientsController = new TextEditingController();
  String name;
    var uuid = Uuid();
  @override
  void initState() {
    super.initState();
    UserNotifier userNotifier =
        Provider.of<UserNotifier>(context, listen: false);

    if (userNotifier.currentUser != null) {
      _currentUser = userNotifier.currentUser;
    } else {
      _currentUser = UserData();
    }
  }

  Widget _buildNameField() {
    return TextFormField(
      decoration: InputDecoration(labelText: "Name"),
      initialValue: _currentUser.name,
      keyboardType: TextInputType.text,
      style: TextStyle(fontSize: 20),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Name is required';
        }

        return null;
      },
      onChanged: (String value) {
        name = value;
      },
    );
  }

  userUploaded(UserData userData) {
    UserNotifier userNotifier =
        Provider.of<UserNotifier>(context, listen: false);
    userNotifier.addUser(userData);
    // Navigator.pop(context);
  }

  _saveFood(context) {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      return;
    }
    form.save();
    // uploadUserData(_currentUser, userUploaded, widget.initialPosition);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("User Info"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          autovalidate: true,
          child: Column(
            children: [
              _buildNameField(),
              SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          FocusScope.of(context).requestFocus(new FocusNode());
          // _saveFood(context);
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => Map(
                  widget.initialPosition, name != null ? name : "No User",uuid.v1())));
        },
        child: Icon(Icons.save),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
    );
  }
}
