import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gps_app/model/user_model.dart';

class UserNotifier with ChangeNotifier {
  List<UserData> _userList = [];
  UserData _currentUser;

  UnmodifiableListView<UserData> get userList =>
      UnmodifiableListView(_userList);

  UserData get currentUser => _currentUser;

  set userList(List<UserData> userList) {
    _userList = userList;
    notifyListeners();
  }

  set currentUser(UserData user) {
    _currentUser = user;
    notifyListeners();
  }

  addUser(UserData user) {
    _userList.insert(0, user);
    notifyListeners();
  }
}
