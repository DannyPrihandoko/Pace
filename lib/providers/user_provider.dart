import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../services/database_service.dart';

final userProvider = StateNotifierProvider<UserNotifier, UserProfile?>((ref) {
  return UserNotifier();
});

class UserNotifier extends StateNotifier<UserProfile?> {
  UserNotifier() : super(null) {
    loadUser();
  }

  Future<void> loadUser() async {
    final userMap = await DatabaseService.instance.getUser();
    if (userMap != null) {
      state = UserProfile.fromMap(userMap);
    } else {
      // Create a default user if none exists
      final newUser = UserProfile(
        id: const Uuid().v4(),
        name: 'User ${const Uuid().v4().substring(0, 4)}',
      );
      await saveUser(newUser);
    }
  }

  Future<void> saveUser(UserProfile user) async {
    await DatabaseService.instance.saveUser(user.toMap());
    state = user;
  }

  Future<void> updateName(String name) async {
    if (state != null) {
      final updatedUser = state!.copyWith(name: name);
      await saveUser(updatedUser);
    }
  }
}
