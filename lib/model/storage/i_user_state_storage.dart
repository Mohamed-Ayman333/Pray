import 'package:pray/model/types/user_state.dart';

abstract class IUserStateStorage {
  Future<void> save(UserState userState);
  Future<UserState?> load();
}
