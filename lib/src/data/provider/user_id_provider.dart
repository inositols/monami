import 'package:flutter_riverpod/legacy.dart' show ChangeNotifierProvider;

import 'package:monami/src/presentation/views/view_models/base_model.dart';

final userId = ChangeNotifierProvider((ref) => UserIdViewModel());

class UserIdViewModel extends BaseViewModel {}
