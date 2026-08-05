import 'package:pray/model/storage/i_user_state_storage.dart';
import 'package:pray/model/types/user_state.dart';

class UserStateRepository {
  final IUserStateStorage _userStateStorage;

  UserStateRepository({required IUserStateStorage userStateStorage})
    : _userStateStorage = userStateStorage;

  Future<void> save(UserState userState) async {
    await _userStateStorage.save(userState);
  }

  Future<UserState?> load() async {
    //TODO:save befor returning
    return await _userStateStorage.load();
  }
}
