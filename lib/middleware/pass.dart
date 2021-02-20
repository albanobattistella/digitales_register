part of 'middleware.dart';

final _passMiddleware =
    MiddlewareBuilder<AppState, AppStateBuilder, AppActions>()
      ..add(SettingsActionsNames.offlineEnabled, _enableOffline)
      ..add(SettingsActionsNames.saveNoPass, _setSavePass)
      ..add(SavePassActionsNames.save, _savePass)
      ..add(SavePassActionsNames.delete, _deletePass);

Future<void> _enableOffline(
    MiddlewareApi<AppState, AppStateBuilder, AppActions> api,
    ActionHandler next,
    Action<bool> action) async {
  await next(action);
  final dynamic login = json.decode((await secureStorage.read(key: "login"))!);
  final user = login["user"] as String;
  final pass = login["pass"] as String;
  final url = login["url"] as String;
  secureStorage.write(
    key: "login",
    value: json.encode(
      <String, Object?>{
        "user": user,
        "pass": pass,
        "url": url,
        "offlineEnabled": action.payload,
        "otherAccounts": json.decode(
            await secureStorage.read(key: "login") ?? "{}")["otherAccounts"],
      },
    ),
  );
}

Future<void> _setSavePass(
    MiddlewareApi<AppState, AppStateBuilder, AppActions> api,
    ActionHandler next,
    Action<bool> action) async {
  await next(action);
  _wrapper.safeMode = action.payload;
  if (!api.state.loginState.loggedIn) return;
  if (!action.payload) {
    api.actions.savePassActions.save();
  } else {
    api.actions.savePassActions.delete();
  }
}

Future<void> _savePass(MiddlewareApi<AppState, AppStateBuilder, AppActions> api,
    ActionHandler next, Action<void> action) async {
  await next(action);
  if (_wrapper.user == null || _wrapper.pass == null || _wrapper.safeMode) {
    return;
  }
  secureStorage.write(
    key: "login",
    value: json.encode(
  <String, Object?>     {
        "user": _wrapper.user,
        "pass": _wrapper.pass,
        "url": _wrapper.url,
        "offlineEnabled": api.state.settingsState.offlineEnabled,
        "otherAccounts": json.decode(
            await secureStorage.read(key: "login") ?? "{}")["otherAccounts"],
      },
    ),
  );
}

Future<void> _deletePass(
    MiddlewareApi<AppState, AppStateBuilder, AppActions> api,
    ActionHandler next,
    Action<void> action) async {
  await next(action);
  secureStorage.write(
    key: "login",
    value: json.encode(
    <String, Object?>   {
        "url": _wrapper.url,
        "otherAccounts": json.decode(
            await secureStorage.read(key: "login") ?? "{}")["otherAccounts"],
      },
    ),
  );
}
