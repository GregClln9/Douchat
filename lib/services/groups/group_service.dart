import 'package:douchat3/main.dart';
import 'package:douchat3/providers/client_provider.dart';
import 'package:douchat3/providers/group_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';

class GroupService {
  final Socket socket;

  GroupService({required this.socket});

  void sendMessage(dynamic data) {
    socket.emit('group-message', data);
  }

  void sendTypingEvent(dynamic data) {
    socket.emit('group-typing', data);
  }

  void removeMessage(dynamic data) {
    socket.emit('remove-group-message', data);
  }

  void sendAllReceipts(
      {required List<String> messages,
      required String groupId,
      required String userId}) {
    socket.emit('group-receipts',
        {'messages': messages, 'group': groupId, 'userId': userId});
  }

  void updateMessageReceipt(dynamic data) {
    final BuildContext context = globalKey.currentContext!;
    final client = Provider.of<ClientProvider>(context, listen: false).client;
    if (client.id != data['from']) {
      Provider.of<GroupProvider>(context, listen: false).updateReadState(
          messagesToUpdate: [data['id']],
          groupId: data['group'],
          readBy: client.id,
          notify: true);
      sendAllReceipts(
          messages: [data['id']], groupId: data['group'], userId: client.id);
    }
  }

  void subscribeToReceipts() {
    socket.on('group-message', updateMessageReceipt);
  }

  void cancelSubscriptionToReceipts() {
    socket.off('group-message', updateMessageReceipt);
  }
}
