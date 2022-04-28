import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class SearchTextField extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String hintText;
  final VoidCallback? onTap;
  final bool showCloseButton;
  final bool autoFocus;
  final bool closeOnSearch;
  final double borderRadius;
  final bool isFilled;

  const SearchTextField(
      {Key? key,
      required this.controller,
      this.onChanged,
      this.onTap,
      this.hintText = 'Search',
      this.showCloseButton = true,
      this.closeOnSearch = true,
      this.isFilled = false,
      this.borderRadius = 24,
      this.autoFocus = false})
      : super(key: key);

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: StreamChatTheme.of(context).colorTheme.barsBg,
        border: Border.all(
          color: StreamChatTheme.of(context).colorTheme.borders,
        ),
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      margin: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 8,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              focusNode: _focusNode,
              onTap: widget.onTap,
              controller: widget.controller,
              onChanged: widget.onChanged,
              autofocus: widget.autoFocus,
              textInputAction: TextInputAction.search,
              onEditingComplete: () {
                if (widget.closeOnSearch) {
                  _focusNode.unfocus();
                }
              },
              decoration: InputDecoration(
                filled: widget.isFilled,
                prefixText: '    ',
                prefixIconConstraints: BoxConstraints.tight(const Size(40, 24)),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Icon(
                    Icons.search,
                    size: 23,
                    color: Colors.grey,
                  ),
                ),
                hintText: widget.hintText,
                contentPadding: const EdgeInsets.all(0),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
          if (widget.showCloseButton)
            Material(
              color: Colors.transparent,
              child: IconButton(
                padding: const EdgeInsets.all(0),
                icon: StreamSvgIcon.closeSmall(
                  color: Colors.grey,
                ),
                splashRadius: 24,
                onPressed: () {
                  if (widget.controller!.text.isNotEmpty) {
                    Future.microtask(
                      () => [
                        widget.controller!.clear(),
                        if (widget.onChanged != null) widget.onChanged!(''),
                      ],
                    );
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}
