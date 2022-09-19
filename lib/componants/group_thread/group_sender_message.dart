import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:douchat3/componants/message_thread/message/video_preview.dart';
import 'package:douchat3/models/groups/group_message.dart';
import 'package:douchat3/models/user.dart';
import 'package:douchat3/providers/group_provider.dart';
import 'package:douchat3/themes/colors.dart';
import 'package:douchat3/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class GroupSenderMessage extends StatelessWidget {
  final GroupMessage message;
  final bool isLastMessage;
  const GroupSenderMessage(
      {Key? key, required this.message, required this.isLastMessage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        Utils.showModalGroupMessageOptions(
            context: context, message: message, sender: true);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FractionallySizedBox(
              alignment: Alignment.centerRight,
              widthFactor: 0.75,
              child: Stack(children: [
                Padding(
                    padding: const EdgeInsets.only(right: 30),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          DecoratedBox(
                              decoration: BoxDecoration(
                                  color: primary,
                                  borderRadius: BorderRadius.circular(30)),
                              position: DecorationPosition.background,
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                  child: _handleMessageType(
                                      type: message.type, context: context))),
                          Padding(
                              padding: const EdgeInsets.only(top: 12, left: 12),
                              child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                      DateFormat('dd MMM, h:mm a', 'fr_FR')
                                          .format(message.timeStamp),
                                      style: Theme.of(context)
                                          .textTheme
                                          .overline!
                                          .copyWith(color: Colors.white70))))
                        ])),
              ])),
          !message.type.startsWith('temp')
              ?
              //  Padding(
              //     padding:
              //         const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              //     child: Align(
              //         alignment: Alignment.centerRight,
              //         child: DecoratedBox(
              //             decoration: BoxDecoration(
              //                 color: Colors.black,
              //                 borderRadius: BorderRadius.circular(30)),
              //             child: Icon(Icons.check_circle_rounded,
              //                 color: message.read == true
              //                     ? Colors.green
              //                     : Colors.white,
              //                 size: 20))))
              isLastMessage
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8, right: 8),
                      child: Builder(builder: (BuildContext context) {
                        String readMessage = "Lu par ";
                        if (message.readBy.isNotEmpty) {
                          for (int i = 0;
                              i < message.readBy.length && i < 3;
                              i++) {
                            final User user = Provider.of<GroupProvider>(
                                    context,
                                    listen: false)
                                .getGroup(message.group)
                                .users
                                .firstWhere((u) => u.id == message.readBy[i],
                                    orElse: () => User(
                                        id: 'no_user',
                                        username: '',
                                        photoUrl: '',
                                        online: false));
                            if (user.id != 'no_user') {
                              readMessage +=
                                  "${user.username}${i == 2 || i == (message.readBy.length - 1) ? ' ' : ','}";
                            }
                          }
                          if (message.readBy.length > 3) {
                            final int others = message.readBy.length - 3;
                            readMessage +=
                                "et ${others} autre${others == 1 ? '' : 's'}}";
                          }
                        }
                        return Text(message.readBy.isEmpty ? '' : readMessage,
                            style: Theme.of(context)
                                .textTheme
                                .caption!
                                .copyWith(
                                    color: Colors.white.withOpacity(0.3)));
                      }))
                  : Container()
              : Container()
        ],
      ),
    );
  }

  Widget _handleMessageType(
      {required String type, required BuildContext context}) {
    if (type.startsWith('temp_loading') || type.startsWith('temp_error')) {
      if (type.split('_')[2] == 'image') {
        return Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                  height: 170,
                  width: 100,
                  child: Image.file(File(message.content), fit: BoxFit.cover)),
            ),
            Align(
                alignment: Alignment.bottomRight,
                child: type.startsWith('temp_loading')
                    ? LoadingAnimationWidget.threeArchedCircle(
                        color: Colors.white, size: 10)
                    : Icon(Icons.error, color: bubbleDark))
          ],
        );
      } else {
        final VideoPlayerController controller =
            VideoPlayerController.file(File(message.content));
        controller.initialize();
        return Stack(children: [
          Align(
              alignment: Alignment.center,
              child: Container(
                  height: 170, width: 100, child: VideoPlayer(controller))),
          Align(
              alignment: Alignment.bottomRight,
              child: type.startsWith('temp_loading')
                  ? LoadingAnimationWidget.threeArchedCircle(
                      color: Colors.white, size: 10)
                  : Icon(Icons.error, color: bubbleDark))
        ]);
      }
    } else if (type == 'text') {
      return Text(message.content,
          softWrap: true,
          style: Theme.of(context)
              .textTheme
              .caption!
              .copyWith(height: 1.2, color: Colors.white));
    } else if (type == 'gif') {
      return Container(
        height: 240,
        width: 220,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
                imageUrl: message.content,
                fit: BoxFit.fill,
                progressIndicatorBuilder: (BuildContext context, String url,
                        DownloadProgress loadingProgress) =>
                    LoadingAnimationWidget.threeArchedCircle(
                        color: Colors.white, size: 50))),
      );
    } else if (type == 'image') {
      return Container(
          height: 240,
          width: 220,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: message.content,
                fit: BoxFit.fill,
                progressIndicatorBuilder: (BuildContext context, String url,
                        DownloadProgress progress) =>
                    LoadingAnimationWidget.threeArchedCircle(
                        color: Colors.white, size: 30),
                errorWidget: (_, __, ___) =>
                    Icon(Icons.error, color: bubbleDark),
              )));
    } else {
      return Container(
          height: 240,
          width: 220,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: VideoPreview(url: message.content)));
    }
  }
}