import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AlertWidget extends StatefulWidget {
  final String image;
  final String title;
  final String description;
  final String okButtonText;
  final String cancelButtonText;
  final Function? onOkButtonPressed;
  final bool withCancel;

  const AlertWidget(
      {Key? key,
      this.image = "",
      this.title = "Information",
      this.description = "",
      this.okButtonText = "Ok",
      this.cancelButtonText = "Cancel",
      this.onOkButtonPressed,
      this.withCancel = false})
      : super(key: key);

  @override
  State<AlertWidget> createState() => _AlertWidgetState();
}

class _AlertWidgetState extends State<AlertWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 18, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      width: MediaQuery.of(context).size.width,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            top: -70,
            child: IgnorePointer(
              child: Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  height: 100,
                  child: Image.asset(
                    widget.image,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 55,
              ),
              Text(
                widget.title,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 21),
              ).tr(),
              if (widget.description.isNotEmpty)
                const SizedBox(
                  height: 20,
                ),
              if (widget.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 50, right: 50),
                  child: Text(
                    widget.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 17,
                        color: Color(0xff777777)),
                  ).tr(),
                ),
              const SizedBox(
                height: 40,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  children: [
                    if (widget.withCancel)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            widget.cancelButtonText,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor,
                            ),
                          ).tr(),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            minimumSize:
                                Size(MediaQuery.of(context).size.width, 50),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: BorderSide(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (widget.withCancel) const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (widget.onOkButtonPressed == null) {
                            Navigator.pop(context);
                          } else {
                            widget.onOkButtonPressed!();
                          }
                        },
                        child: Text(
                          widget.okButtonText,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ).tr(),
                        style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).primaryColor,
                          minimumSize:
                              Size(MediaQuery.of(context).size.width, 50),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
