import 'package:pray/model/storage/i_user_state_storage.dart';
import 'package:pray/model/types/user_state.dart';

class UserStateStorage implements IUserStateStorage {
  @override
  Future<void> save(UserState userState) async {
    // TODO: Persist state (e.g., flutter_secure_storage)
  }

  @override
  Future<UserState?> load() async {
    // TODO: Read state from persistent storage
    return null;
  }
}
