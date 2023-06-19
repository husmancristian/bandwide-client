import 'dart:async';
import 'dart:convert';

import 'package:app/widgets/dialogues.dart';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

class ControlsWidget extends StatefulWidget {
  //
  final Room room;
  final LocalParticipant participant;

  const ControlsWidget(
    this.room,
    this.participant, {
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ControlsWidgetState();
}

class _ControlsWidgetState extends State<ControlsWidget> {
  //
  CameraPosition position = CameraPosition.front;

  List<MediaDevice>? _audioOutputs;

  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    participant.addListener(_onChange);
    _subscription = Hardware.instance.onDeviceChange.stream
        .listen((List<MediaDevice> devices) {
      _loadDevices(devices);
    });
    Hardware.instance.enumerateDevices().then(_loadDevices);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    participant.removeListener(_onChange);
    super.dispose();
  }

  LocalParticipant get participant => widget.participant;

  void _loadDevices(List<MediaDevice> devices) async {
    _audioOutputs = devices.where((d) => d.kind == 'audiooutput').toList();
    setState(() {});
  }

  void _onChange() {
    // trigger refresh
    setState(() {});
  }

  void _unpublishAll() async {
    final result = await context.showUnPublishDialog();
    if (result == true) await participant.unpublishAllTracks();
  }

  bool get isMuted => participant.isMuted;

  void _selectAudioOutput(MediaDevice device) async {
    await widget.room.setAudioOutputDevice(device);
    setState(() {});
  }

  void _toggleCamera() async {
    //
    final track = participant.videoTracks.firstOrNull?.track;
    if (track == null) return;

    try {
      final newPosition = position.switched();
      await track.setCameraPosition(newPosition);
      setState(() {
        position = newPosition;
      });
    } catch (error) {
      print('could not restart track: $error');
      return;
    }
  }

  void _onTapDisconnect() async {
    final result = await context.showDisconnectDialog();
    if (result == true) await widget.room.disconnect();
  }

  void _onTapUpdateSubscribePermission() async {
    final result = await context.showSubscribePermissionDialog();
    if (result != null) {
      try {
        widget.room.localParticipant?.setTrackSubscriptionPermissions(
          allParticipantsAllowed: result,
        );
      } catch (error) {
        await context.showErrorDialog(error);
      }
    }
  }

  void _onTapSimulateScenario() async {
    final result = await context.showSimulateScenarioDialog();
    if (result != null) {
      print('${result}');

      if (SimulateScenarioResult.e2eeKeyRatchet == result) {
        await widget.room.e2eeManager?.ratchetKey();
      }

      await widget.room.sendSimulateScenario(
        signalReconnect:
            result == SimulateScenarioResult.signalReconnect ? true : null,
        nodeFailure: result == SimulateScenarioResult.nodeFailure ? true : null,
        migration: result == SimulateScenarioResult.migration ? true : null,
        serverLeave: result == SimulateScenarioResult.serverLeave ? true : null,
        switchCandidate:
            result == SimulateScenarioResult.switchCandidate ? true : null,
      );
    }
  }

  void _onTapSendData() async {
    final result = await context.showSendDataDialog();
    if (result == true) {
      await widget.participant.publishData(
        utf8.encode('This is a sample data message'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 15,
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 5,
        runSpacing: 5,
        children: [
          IconButton(
            onPressed: _unpublishAll,
            icon: const Icon(Icons.circle_outlined),
            tooltip: 'Unpublish all',
          ),
          PopupMenuButton<MediaDevice>(
            icon: const Icon(Icons.volume_up),
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<MediaDevice>(
                  value: null,
                  child: ListTile(
                    leading: Icon(
                      Icons.speaker,
                      color: Colors.white,
                    ),
                    title: Text('Select Audio Output'),
                  ),
                ),
                if (_audioOutputs != null)
                  ..._audioOutputs!.map((device) {
                    return PopupMenuItem<MediaDevice>(
                      value: device,
                      child: ListTile(
                        leading: (device.deviceId ==
                                widget.room.selectedAudioOutputDeviceId)
                            ? const Icon(
                                Icons.check_box,
                                color: Colors.white,
                              )
                            : const Icon(
                                Icons.square,
                                color: Colors.white,
                              ),
                        title: Text(device.label),
                      ),
                      onTap: () => _selectAudioOutput(device),
                    );
                  }).toList()
              ];
            },
          ),
          IconButton(
            onPressed: _onTapDisconnect,
            icon: const Icon(Icons.close),
            tooltip: 'disconnect',
          ),
          IconButton(
            onPressed: _onTapSendData,
            icon: const Icon(Icons.screen_share_sharp),
            tooltip: 'send demo data',
          ),
          IconButton(
            onPressed: _onTapUpdateSubscribePermission,
            icon: const Icon(Icons.settings),
            tooltip: 'Subscribe permission',
          ),
          IconButton(
            onPressed: _onTapSimulateScenario,
            icon: const Icon(Icons.warning),
            tooltip: 'Simulate scenario',
          ),
        ],
      ),
    );
  }
}
