import 'package:dr/actions/login_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tuple/tuple.dart';

import '../container/login_page.dart';
import '../util.dart';
import 'no_internet.dart';

typedef LoginCallback = void Function(String user, String pass, String url);
typedef ChangePassCallback = void Function(String user, String oldPass, String newPass, String url);
typedef SetSafeModeCallback = void Function(bool safeMode);

class LoginPageContent extends StatefulWidget {
  final LoginPageViewModel vm;
  final LoginCallback onLogin;
  final ChangePassCallback onChangePass;
  final SetSafeModeCallback setSaveNoPass;
  final VoidCallback onReload;
  final VoidCallback onPop;

  LoginPageContent({
    Key key,
    @required this.vm,
    this.onLogin,
    this.setSaveNoPass,
    this.onReload,
    this.onPop,
    this.onChangePass,
  }) : super(key: key);

  @override
  _LoginPageContentState createState() => _LoginPageContentState();
}

class _LoginPageContentState extends State<LoginPageContent> {
  final _usernameController = TextEditingController(),
      _passwordController = TextEditingController(),
      _newPassword1Controller = TextEditingController(),
      _newPassword2Controller = TextEditingController(),
      _urlController = TextEditingController.fromValue(
    TextEditingValue(
      text: "https://.digitalesregister.it",
      selection: TextSelection.fromPosition(
        TextPosition(offset: 8),
      ),
    ),
  );
  bool safeMode;
  bool customUrl = false;
  bool newPasswordsMatch = true;
  Tuple2<String, String> nonCustomServer;
  @override
  void initState() {
    safeMode = widget.vm.safeMode;
    nonCustomServer = widget.vm.servers.entries.first.toTuple();
    _usernameController.text = widget.vm.username;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!widget.vm.mustChangePass) {
          widget.onPop();
          return true;
        }
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.vm.changePass ? 'Passwort ändern' : 'Login'),
          automaticallyImplyLeading: !widget.vm.mustChangePass,
        ),
        body: widget.vm.noInternet
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    NoInternet(),
                    SizedBox(
                      height: 25,
                    ),
                    RaisedButton(
                      child: Text("Nochmal versuchen"),
                      onPressed: () => widget.onReload(),
                    ),
                  ],
                ),
              )
            : Stack(
                children: [
                  Center(
                    child: ListView(
                      shrinkWrap: true,
                      children: <Widget>[
                        ListTile(
                          title: Text("Schule"),
                          trailing: DropdownButton(
                            items: widget.vm.servers.entries
                                .map(
                                  (s) => DropdownMenuItem(
                                    child: Text(s.key),
                                    value: s.toTuple(),
                                  ),
                                )
                                .toList()
                                  ..add(
                                    DropdownMenuItem(
                                      child: Text("Serveradresse eingeben"),
                                      value: null,
                                    ),
                                  ),
                            onChanged: (Tuple2 value) {
                              setState(() {
                                nonCustomServer = value;
                                // workaround: selection was not set anymore
                                if (value == null) {
                                  _urlController.selection = TextSelection.fromPosition(
                                    TextPosition(offset: 8),
                                  );
                                }
                              });
                            },
                            value: nonCustomServer,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (nonCustomServer == null)
                                TextField(
                                  decoration: InputDecoration(labelText: 'Adresse'),
                                  controller: _urlController,
                                  enabled: !widget.vm.loading,
                                  autofocus: true,
                                  keyboardType: TextInputType.url,
                                ),
                              Divider(),
                              TextField(
                                decoration: InputDecoration(labelText: 'Benutzername'),
                                controller: _usernameController,
                                enabled: !widget.vm.loading,
                              ),
                              TextField(
                                decoration: InputDecoration(
                                    labelText:
                                        widget.vm.changePass ? 'Passwort' : 'Altes Passwort'),
                                controller: _passwordController,
                                obscureText: true,
                                enabled: !widget.vm.loading,
                              ),
                              if (widget.vm.changePass) ...[
                                SizedBox(
                                  height: 8,
                                ),
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    widget.vm.mustChangePass
                                        ? "Du musst dein Passwort ändern:"
                                        : "Ändere dein Passwort:",
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 0,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    "Das neue Passwort muss:\n"
                                    "- mindestens 10 Zeichen lang sein\n"
                                    "- mindestens einen Großbuchstaben enthalten\n"
                                    "- mindestens einen Kleinbuchstaben enthalten\n"
                                    "- mindestens eine Zahl enthalten\n"
                                    "- mindestens ein Sondezeichen enthalten\n"
                                    "- nicht mit dem alten Passwort übereinstimmen\n"
                                    "(des hon net i mir ausgedenkt)",
                                  ),
                                ),
                                TextField(
                                  decoration: InputDecoration(labelText: 'Neues Passwort'),
                                  controller: _newPassword1Controller,
                                  obscureText: true,
                                  enabled: !widget.vm.loading,
                                  onChanged: (_) {
                                    setState(() {
                                      newPasswordsMatch = _newPassword1Controller.text ==
                                          _newPassword2Controller.text;
                                    });
                                  },
                                ),
                                TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Neues Passwort wiederholen',
                                    errorText: newPasswordsMatch
                                        ? null
                                        : "Die neuen Passwörter stimmen nicht überein",
                                  ),
                                  controller: _newPassword2Controller,
                                  obscureText: true,
                                  enabled: !widget.vm.loading,
                                  onChanged: (_) {
                                    setState(() {
                                      newPasswordsMatch = _newPassword1Controller.text ==
                                          _newPassword2Controller.text;
                                    });
                                  },
                                ),
                              ],
                              SizedBox(height: 8),
                              RaisedButton(
                                onPressed: widget.vm.loading || !newPasswordsMatch
                                    ? null
                                    : () {
                                        widget.setSaveNoPass(safeMode);
                                        if (widget.vm.changePass) {
                                          widget.onChangePass(
                                            _usernameController.text,
                                            _passwordController.text,
                                            _newPassword1Controller.text,
                                            nonCustomServer?.item2 ?? _urlController.text,
                                          );
                                        } else {
                                          widget.onLogin(
                                            _usernameController.value.text,
                                            _passwordController.value.text,
                                            nonCustomServer?.item2 ?? _urlController.text,
                                          );
                                        }
                                      },
                                child: Text(
                                  widget.vm.changePass ? 'Passwort ändern' : 'Login',
                                ),
                              ),
                              Divider(),
                            ],
                          ),
                        ),
                        SwitchListTile(
                          title: Text("Angemeldet bleiben"),
                          value: !safeMode,
                          onChanged: widget.vm.loading
                              ? null
                              : (bool value) {
                                  setState(() {
                                    safeMode = !value;
                                  });
                                },
                        ),
                        Center(
                          child: widget.vm.error?.isNotEmpty == true
                              ? Text(
                                  widget.vm.error,
                                  style:
                                      Theme.of(context).textTheme.body1.copyWith(color: Colors.red),
                                )
                              : SizedBox(),
                        ),
                      ],
                    ),
                  ),
                  if (widget.vm.loading) LinearProgressIndicator(),
                ],
              ),
      ),
    );
  }
}
