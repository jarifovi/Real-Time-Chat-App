import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class UserProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<UserModel> _users = [];
  UserModel? _selectedUser;
  String _searchQuery = '';
  bool _isLoading = false;
  StreamSubscription<List<UserModel>>? _usersSubscription;

  List<UserModel> get users {
    if (_searchQuery.isEmpty) {
      return _users;
    }
    return _users.where((user) {
      return user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  UserModel? get selectedUser => _selectedUser;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  /// Load and listen to all registered users
  void listenToUsers(String currentUid) {
    _isLoading = true;
    notifyListeners();

    _usersSubscription?.cancel();
    _usersSubscription = _firestoreService
        .getUsersStream(currentUid)
        .listen((userList) {
      _users = userList;
      _isLoading = false;
      notifyListeners();
    });
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void selectUser(UserModel user) {
    _selectedUser = user;
    notifyListeners();
  }

  void clearSelection() {
    _selectedUser = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _usersSubscription?.cancel();
    super.dispose();
  }
}
