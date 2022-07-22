import 'package:flutter/material.dart';
import 'package:prive/Widgets/Common/cached_image.dart';
import 'package:intl/intl.dart';
import '../../../Models/Stories/stories.dart';
import 'package:easy_localization/easy_localization.dart';

class ViewersModalView extends StatefulWidget {
  final List<StoryViewUser> viewUsers;
  const ViewersModalView({Key? key, required this.viewUsers}) : super(key: key);

  @override
  State<ViewersModalView> createState() => _ViewersModalViewState();
}

class _ViewersModalViewState extends State<ViewersModalView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(13),
          topRight: Radius.circular(13),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 20),
              child: SizedBox(
                width: 35,
                height: 6,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.viewUsers.length == 1
                    ? "1 ${"View".tr()}"
                    : "${widget.viewUsers.length} ${"Views".tr()}",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 5, bottom: 5),
              child: Divider(
                thickness: 1,
              ),
            ),
            MediaQuery.removePadding(
              context: context,
              removeTop: true,
              removeBottom: true,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      SizedBox(
                        width: 45,
                        height: 45,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: CachedImage(
                            url: widget.viewUsers[index].userPhoto ?? "",
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          "${widget.viewUsers[index].userFirstName ?? ""} ${widget.viewUsers[index].userLastName ?? ""}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        child: getReviewDate(
                            widget.viewUsers[index].createdAtReview ?? ""),
                      )
                    ],
                  );
                },
                separatorBuilder: (context, index) {
                  return const Padding(
                    padding: EdgeInsets.only(left: 63),
                    child: Divider(
                      height: 15,
                    ),
                  );
                },
                itemCount: widget.viewUsers.length,
              ),
            )
          ],
        ),
      ),
    );
  }

  RichText getReviewDate(String date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    DateTime reviewDate = DateTime.parse(date).toLocal();
    String formattedDate = "";
    String day = "";
    if (DateTime(reviewDate.year, reviewDate.month, reviewDate.day) == today) {
      day = "Today";
      formattedDate = DateFormat('hh:mm a', "en").format(reviewDate);
    } else if (DateTime(reviewDate.year, reviewDate.month, reviewDate.day) ==
        yesterday) {
      day = "Yesterday";
      formattedDate = DateFormat('hh:mm a', "en").format(reviewDate);
    } else {
      day = DateFormat('MMM d', "en").format(reviewDate);
      formattedDate = DateFormat('hh:mm a', "en").format(reviewDate);
    }
    return RichText(
      textAlign: TextAlign.end,
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: <TextSpan>[
          TextSpan(
            text: day,
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),
          TextSpan(
            text: "  $formattedDate",
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
