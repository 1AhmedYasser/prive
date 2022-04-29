import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:flutter_swipe_action_cell/core/controller.dart';
import 'package:lottie/lottie.dart';
import 'package:prive/Extras/resources.dart';
import 'package:prive/Helpers/stream_manager.dart';
import 'package:prive/UltraNetwork/ultra_constants.dart';
import 'package:prive/UltraNetwork/ultra_network.dart';
import 'package:prive/Widgets/ChatWidgets/search_text_field.dart';
import 'package:prive/Widgets/Common/cached_image.dart';
import 'package:collection/collection.dart';
import '../../Models/Call/call_logs.dart';

class CallsScreen extends StatefulWidget {
  const CallsScreen({Key? key}) : super(key: key);

  @override
  _CallsScreenState createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  int currentTab = 0;
  bool isEditing = false;
  SwipeActionController controller = SwipeActionController();
  List<CallLogsData> callLogs = [];
  List<CallLogsData> allCalls = [];
  List<CallLogsData> missedCalls = [];
  bool isLoading = true;
  CancelToken cancelToken = CancelToken();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    _animationController = AnimationController(vsync: this);
    _getCallLogs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(35),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarBrightness: Brightness.light,
          ),
        ),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimationLimiter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 375),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(
                      child: widget,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 30, right: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Expanded(
                            child: SizedBox(
                              height: 48,
                              child: Text(
                                "Calls",
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          if (isEditing)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  isEditing = false;
                                  callLogs.clear();
                                  allCalls.clear();
                                  missedCalls.clear();
                                });
                                _deleteAllCalls();
                              },
                              child: Text(
                                "Clear All",
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Theme.of(context).primaryColorDark,
                                ),
                              ),
                            ),
                          if (callLogs.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  isEditing = !isEditing;
                                  controller.closeAllOpenCell();
                                });
                              },
                              child: Text(
                                isEditing ? "Done" : "Edit",
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Theme.of(context).primaryColorDark,
                                ),
                              ),
                            )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15, bottom: 15),
                      child: Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 200,
                          child: CupertinoSlidingSegmentedControl(
                            groupValue: currentTab,
                            children: const <int, Widget>{
                              0: Text('All'),
                              1: Text('Missed'),
                            },
                            onValueChanged: (value) {
                              setState(() {
                                currentTab = value as int;
                                if (currentTab == 0) {
                                  callLogs = allCalls;
                                } else {
                                  callLogs = missedCalls;
                                }
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30, right: 30),
                      child: SearchTextField(
                        controller: searchController,
                        showCloseButton: false,
                        onChanged: (value) {
                          if (value.isEmpty) {
                            setState(() {
                              if (currentTab == 0) {
                                callLogs = allCalls;
                              } else {
                                callLogs = missedCalls;
                              }
                            });
                          } else {
                            setState(() {
                              if (currentTab == 0) {
                                callLogs = searchLogs(value, allCalls);
                              } else {
                                callLogs = searchLogs(value, missedCalls);
                              }
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            callLogs.isNotEmpty && isLoading == false
                ? Expanded(
                    child: AnimationLimiter(
                      child: RefreshIndicator(
                        onRefresh: () => Future.sync(
                          () => _getCallLogs(),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 375),
                              child: SlideAnimation(
                                horizontalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: SwipeActionCell(
                                    controller: controller,
                                    index: index,
                                    key: ValueKey(callLogs[index]),
                                    trailingActions: [
                                      SwipeAction(
                                        content: Image.asset(
                                          R.images.deleteChatImage,
                                          width: 15,
                                          color: Colors.red,
                                        ),
                                        color: Colors.transparent,
                                        onTap: (handler) async {
                                          await handler(true);
                                          _deleteOneCall(
                                              callLogs[index].cALLID ?? "");
                                          setState(() {
                                            callLogs.removeAt(index);
                                          });
                                        },
                                      ),
                                    ],
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Visibility(
                                              child: const SizedBox(width: 15),
                                              visible: isEditing,
                                            ),
                                            Visibility(
                                              visible: isEditing,
                                              child: CupertinoButton(
                                                padding: EdgeInsets.zero,
                                                minSize: 0,
                                                child: Icon(
                                                  CupertinoIcons
                                                      .minus_circle_fill,
                                                  color: CupertinoColors
                                                      .systemRed
                                                      .resolveFrom(context),
                                                ),
                                                onPressed: () {
                                                  controller.openCellAt(
                                                    index: index,
                                                    trailing: true,
                                                  );
                                                },
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                left: isEditing ? 15 : 25,
                                                right: 10,
                                                bottom: 5,
                                                top: 5,
                                              ),
                                              child: SizedBox(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  child: CachedImage(
                                                    url: callLogs[index]
                                                                .senderID ==
                                                            context
                                                                .currentUser?.id
                                                        ? callLogs[index]
                                                                .receiver
                                                                ?.firstOrNull
                                                                ?.userPhoto ??
                                                            ""
                                                        : callLogs[index]
                                                                .sender
                                                                ?.firstOrNull
                                                                ?.userPhoto ??
                                                            "",
                                                  ),
                                                ),
                                                height: 50,
                                                width: 50,
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    callLogs[index].senderID ==
                                                            context
                                                                .currentUser?.id
                                                        ? "${callLogs[index].receiver?.firstOrNull?.userFirstName ?? ""} ${callLogs[index].receiver?.firstOrNull?.userLastName ?? ""}"
                                                        : "${callLogs[index].sender?.firstOrNull?.userFirstName ?? ""} ${callLogs[index].sender?.firstOrNull?.userLastName ?? ""}",
                                                    style: const TextStyle(
                                                      fontSize: 17,
                                                      color: Colors.black,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        callLogs[index]
                                                                    .callType ==
                                                                "Voice"
                                                            ? Icons.phone
                                                            : Icons.videocam,
                                                        color: callLogs[index]
                                                                    .callStatues !=
                                                                "CANCELLED"
                                                            ? Colors.green
                                                            : Colors.red,
                                                        size: 20,
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                        callLogs[index]
                                                                    .callStatues !=
                                                                "CANCELLED"
                                                            ? "Outgoing"
                                                            : "Missed",
                                                        style: TextStyle(
                                                          color: callLogs[index]
                                                                      .callStatues !=
                                                                  "CANCELLED"
                                                              ? Colors.green
                                                              : Colors.red,
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              DateFormat('dd/MM/yyyy').format(
                                                DateTime.parse(
                                                  callLogs[index]
                                                          .createdAtCalls ??
                                                      DateTime.now().toString(),
                                                ),
                                              ),
                                              style: TextStyle(
                                                color: callLogs[index]
                                                            .callStatues !=
                                                        "CANCELLED"
                                                    ? Colors.grey.shade600
                                                    : Colors.red,
                                              ),
                                            ),
                                            const SizedBox(width: 25),
                                          ],
                                        ),
                                        const Divider(height: 15)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          itemCount: callLogs.length,
                        ),
                      ),
                    ),
                  )
                : isLoading
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(top: 100),
                        child: Center(
                          child: Column(
                            children: [
                              Lottie.asset(
                                R.animations.callLog,
                                width: 120,
                                repeat: true,
                                fit: BoxFit.fill,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Text(
                                "Your Call Will Appear Here",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.grey.shade600,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
          ],
        ),
      ),
    );
  }

  List<CallLogsData> searchLogs(String value, List<CallLogsData> logs) {
    Set<CallLogsData> searchedList = {};
    searchedList.addAll(logs
        .where((element) =>
            element.sender?.first.userFirstName
                ?.toLowerCase()
                .contains(value.toLowerCase()) ==
            true)
        .toList());
    searchedList.addAll(logs
        .where((element) =>
            element.sender?.first.userLastName
                ?.toLowerCase()
                .contains(value.toLowerCase()) ==
            true)
        .toList());
    searchedList.addAll(logs
        .where((element) =>
            element.receiver?.first.userFirstName
                ?.toLowerCase()
                .contains(value.toLowerCase()) ==
            true)
        .toList());
    searchedList.addAll(logs
        .where((element) =>
            element.receiver?.first.userLastName
                ?.toLowerCase()
                .contains(value.toLowerCase()) ==
            true)
        .toList());

    return searchedList.toList();
  }

  void _getCallLogs() {
    UltraNetwork.request(
      context,
      getCallLogs,
      formData: FormData.fromMap({
        "UserID": context.currentUser?.id,
      }),
      cancelToken: cancelToken,
    ).then((value) {
      setState(() {
        isLoading = false;
      });
      if (value != null) {
        CallLogs logsResponse = value;
        if (logsResponse.success == true) {
          setState(() {
            callLogs = logsResponse.data ?? [];
            allCalls = callLogs;
            missedCalls = callLogs
                .where((element) => element.callStatues == "CANCELLED")
                .toList();
          });
        }
      }
    });
  }

  void _deleteOneCall(String callId) {
    UltraNetwork.request(
      context,
      deleteOneCall,
      showLoadingIndicator: false,
      showError: false,
      formData: FormData.fromMap(
        {"CALLID": callId},
      ),
      cancelToken: cancelToken,
    );
  }

  void _deleteAllCalls() {
    UltraNetwork.request(
      context,
      deleteAllCalls,
      showLoadingIndicator: false,
      showError: false,
      formData: FormData.fromMap(
        {"UserID": context.currentUser?.id},
      ),
      cancelToken: cancelToken,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
