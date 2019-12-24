import 'package:flutter/material.dart' hide Notification;
import 'package:intl/intl.dart';

import '../data.dart';
import '../main.dart';
import '../util.dart';

class NotificationPage extends StatelessWidget {
  final List<Notification> notifications;
  final SingleArgumentVoidCallback<Notification> deleteNotification;
  final VoidCallback deleteAllNotifications;

  const NotificationPage(
      {Key key,
      this.notifications,
      this.deleteNotification,
      this.deleteAllNotifications})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Benachrichtigungen"),
      ),
      body: notifications.length != 0
          ? ListView.builder(
              itemCount: notifications.length + 1,
              itemBuilder: (_, n) {
                if (n == 0)
                  return Align(
                    alignment: Alignment.centerRight,
                    child: FlatButton(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text("Alle gelesen"),
                          SizedBox(width: 8),
                          Icon(Icons.done_all),
                        ],
                      ),
                      onPressed: deleteAllNotifications,
                    ),
                  );
                return NotificationWidget(
                  notification: notifications[n - 1],
                  onDelete: deleteNotification,
                );
              },
            )
          : Center(
              child: Text(
                "Keine Benachrichtigungen",
                style: Theme.of(context).textTheme.headline,
              ),
            ),
    );
  }
}

class NotificationWidget extends StatelessWidget {
  final Notification notification;
  final SingleArgumentVoidCallback<Notification> onDelete;

  const NotificationWidget(
      {Key key, @required this.notification, @required this.onDelete})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey, width: 0),
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.transparent,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      notification.title,
                    ),
                  ),
                  if (!isNullOrEmpty(notification.subTitle))
                    Text(
                      notification.subTitle,
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(left: 2.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        DateFormat("d.M.yy H:mm").format(notification.timeSent),
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.done,
              ),
              tooltip: "Gelesen",
              onPressed: () => onDelete(notification),
            ),
          ],
        ),
      ),
    );
  }
}