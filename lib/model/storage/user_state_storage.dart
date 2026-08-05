import 'package:isar/isar.dart';
import 'package:pray/model/storage/i_user_state_storage.dart';
import 'package:pray/model/types/user_state.dart';

class UserStateStorage implements IUserStateStorage {
  final Isar isar;

  UserStateStorage(this.isar);

  @override
  Future<void> save(UserState userState) async {
    userState.id = 1;
    await isar.writeTxn(() async {
      await isar.userStates.put(userState);
    });
  }

  @override
  Future<UserState?> load() async {
    final userState = await isar.userStates.get(1);
    return userState ?? UserState();
  }
}
