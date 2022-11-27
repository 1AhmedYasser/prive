import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class GoogleMapsViewWidget extends StatefulWidget {
  const GoogleMapsViewWidget({
    Key? key,
    required this.channelName,
    required this.message,
    required this.channel,
    required this.onBack,
  }) : super(key: key);
  final String channelName;
  final Message message;
  final Channel channel;
  final VoidCallback onBack;

  @override
  State<GoogleMapsViewWidget> createState() => _GoogleMapsViewWidgetState();
}

class _GoogleMapsViewWidgetState extends State<GoogleMapsViewWidget> {
  late StreamSubscription _messageSubscription;
  late double lat;
  late double long;

  GoogleMapController? mapController;

  Attachment get _messageAttachment => widget.message.attachments.first;

  @override
  void initState() {
    super.initState();
    lat = _messageAttachment.extraData['lat'] as double;
    long = _messageAttachment.extraData['long'] as double;
    _messageSubscription = widget.channel.on('location_update').listen(_updateHandler);
  }

  @override
  void dispose() {
    super.dispose();
    _messageSubscription.cancel();
  }

  void _updateHandler(Event event) {
    double newLat = event.extraData['lat'] as double;
    double newLong = event.extraData['long'] as double;

    setState(() {
      lat = newLat;
      long = newLong;
    });

    mapController?.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(
          newLat,
          newLong,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var pos = LatLng(lat, long);
    return WillPopScope(
      onWillPop: () async {
        widget.onBack();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.channelName,
            style: const TextStyle(
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.white,
          leading: const BackButton(
            color: Colors.black,
          ),
        ),
        body: AnimatedCrossFade(
          duration: kThemeAnimationDuration,
          crossFadeState: mapController != null ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: ConstrainedBox(
            constraints: BoxConstraints.loose(MediaQuery.of(context).size),
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: pos,
                zoom: 18,
              ),
              onMapCreated: (controller) => setState(() => mapController = controller),
              markers: {
                Marker(
                  markerId: const MarkerId('user-location-marker-id'),
                  position: pos,
                )
              },
            ),
          ),
          secondChild: Center(
            child: Icon(
              Icons.location_history,
              color: Colors.red.withOpacity(0.76),
            ),
          ),
        ),
      ),
    );
  }
}
