import 'package:flutter/material.dart';

class UserProfile extends StatelessWidget {
  final String name, username, role;

  const UserProfile({
    Key key,
    this.name,
    this.username,
    this.role,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Text(
              name,
              style: Theme.of(context).textTheme.headline,
            ),
            Text("$username · $role"),
          ],
        ),
      ),
    );
  }
}