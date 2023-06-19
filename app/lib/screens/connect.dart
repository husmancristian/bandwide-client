import 'package:app/widgets/room.dart';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConnectPage extends StatefulWidget {
  //
  const ConnectPage({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
  //
  static const _storeKeyUri = 'uri';
  static const _storeKeyToken = 'token';
  static const _storeKeySimulcast = 'simulcast';
  static const _storeKeyAdaptiveStream = 'adaptive-stream';
  static const _storeKeyDynacast = 'dynacast';
  static const _storeKeyFastConnect = 'fast-connect';
  static const _storeKeyE2EE = 'e2ee';
  static const _storeKeySharedKey = 'shared-key';

  String uriCtrl = 'ws://localhost:7880';
  String tokenCtrl =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2ODcwMzAyNTEsImlzcyI6ImRldmtleSIsIm5hbWUiOiJteUFwcCIsIm5iZiI6MTY4NzAyOTk1MSwic3ViIjoibXlBcHAiLCJ2aWRlbyI6eyJyb29tIjoibXktZmlyc3Qtcm9vbSIsInJvb21Kb2luIjp0cnVlfX0.l_c2I8Ha4TypTmIcN0VIDhRe5HfcmnysmTnPw772zbA.10EO4DrTAWk7UfgQ-pI_8WjFk-ZbtuNs0Fm7_KpEhvo';
  String sharedKeyCtrl = '';
  bool _simulcast = false;
  bool _adaptiveStream = false;
  bool _dynacast = true;
  bool _busy = false;
  bool _fastConnect = false;
  bool _e2ee = false;

  @override
  void initState() {
    super.initState();
    _readPrefs();
  }

  // Read saved URL and Token
  Future<void> _readPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      uriCtrl = 'ws://localhost:7880';
      tokenCtrl =
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3MzAyMzA1MDUsImlzcyI6ImRldmtleSIsIm5hbWUiOiJ0aGlyZGd1eSIsIm5iZiI6MTY4NzAzMDUwNSwic3ViIjoidGhpcmRndXkiLCJ2aWRlbyI6eyJyb29tIjoibXktZmlyc3Qtcm9vbSIsInJvb21Kb2luIjp0cnVlfX0.fOAzkeNsHVmozF9S7LKpb9ZYJLXC_Q6PrOVGzFh_zZ4';
      sharedKeyCtrl = prefs.getString(_storeKeySharedKey) ?? '';
      _simulcast = prefs.getBool(_storeKeySimulcast) ?? false;
      _adaptiveStream = prefs.getBool(_storeKeyAdaptiveStream) ?? false;
      _dynacast = prefs.getBool(_storeKeyDynacast) ?? true;
      _fastConnect = prefs.getBool(_storeKeyFastConnect) ?? false;
      _e2ee = prefs.getBool(_storeKeyE2EE) ?? false;
    });
  }

  // Save URL and Token
  Future<void> _writePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    print(uriCtrl);
    await prefs.setString(_storeKeyUri, uriCtrl);
    await prefs.setString(_storeKeyToken, tokenCtrl);
    await prefs.setString(_storeKeySharedKey, sharedKeyCtrl);
    await prefs.setBool(_storeKeySimulcast, _simulcast);
    await prefs.setBool(_storeKeyAdaptiveStream, _adaptiveStream);
    await prefs.setBool(_storeKeyDynacast, _dynacast);
    await prefs.setBool(_storeKeyFastConnect, _fastConnect);
    await prefs.setBool(_storeKeyE2EE, _e2ee);
  }

  Future<void> _connect(BuildContext ctx) async {
    //
    try {
      setState(() {
        _busy = true;
      });

      // Save URL and Token for convenience
      await _writePrefs();

      print('Connecting with url: $uriCtrl, '
          'token: $tokenCtrl...');

      //create new room
      final room = Room();

      // Create a Listener before connecting
      final listener = room.createListener();
      E2EEOptions? e2eeOptions;
      if (_e2ee) {
        final keyProvider = await BaseKeyProvider.create();
        e2eeOptions = E2EEOptions(keyProvider: keyProvider);
        var sharedKey = sharedKeyCtrl;
        await keyProvider.setKey(sharedKey);
      }

      // Try to connect to the room
      // This will throw an Exception if it fails for any reason.
      await room.connect(
        uriCtrl,
        tokenCtrl,
        roomOptions: RoomOptions(
          adaptiveStream: _adaptiveStream,
          dynacast: _dynacast,
          e2eeOptions: e2eeOptions,
        ),
        fastConnectOptions: _fastConnect
            ? FastConnectOptions(
                microphone: const TrackOption(enabled: false),
                camera: const TrackOption(enabled: false),
              )
            : null,
      );
      if (!mounted) return;
      await Navigator.push<void>(
        ctx,
        MaterialPageRoute(builder: (_) => RoomPage(room, listener)),
      );
    } catch (error) {
      print('Could not connect $error');
      // await ctx.showErrorDialog(error);
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: _busy ? null : () => _connect(context),
                    icon: const Icon(Icons.connected_tv),
                    label: const Text('Connect'),
                  )
                ],
              ),
            ),
          ),
        ),
      );
}
