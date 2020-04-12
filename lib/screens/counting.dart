import 'dart:convert';
import 'dart:async' show Future;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_sound/flutter_sound_player.dart';
import 'package:flutterkutkit/entities/number.dart';
import 'package:flutterkutkit/widgets/base_app_bar.dart';
import 'package:flutterkutkit/widgets/numberGrid.dart';

Future<List<NumberEntity>> _fetchNumbers() async {
  String jsonString = await rootBundle.loadString('assets/data/numbers.json');
  final jsonParsed = json.decode(jsonString);

  return jsonParsed
      .map<NumberEntity>((json) => new NumberEntity.fromJson(json))
      .toList();
}

class CountingScreen extends StatefulWidget {
  CountingScreen();

  @override
  _CountingScreenState createState() => _CountingScreenState();
}

class _CountingScreenState extends State<CountingScreen> {
  Future<List<NumberEntity>> _numbersFuture;
  FlutterSoundPlayer _soundPlayer;

  @override
  void initState() {
    super.initState();

    _numbersFuture = _fetchNumbers();
    _soundPlayer = new FlutterSoundPlayer();
  }

  void _playAudio(String audioPath) async {
    // Load a local audio file and get it as a buffer
    Uint8List buffer = (await rootBundle.load(audioPath)).buffer.asUint8List();
    await _soundPlayer.startPlayerFromBuffer(buffer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: BaseAppBar(
          title: '123',
          backgroundColor: Colors.pink[100],
        ),
        body: new FutureBuilder(
          future: _numbersFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  return NumberGrid(
                    text: snapshot.data[index].text,
                    onTap: () {
                      _playAudio(snapshot.data[index].audio);
                    },
                  );
                },
              );
            } else {
              return Center(
                child: Text('Loading...'),
              );
            }
          },
        ));
  }

  @override
  void dispose() {
    _soundPlayer.release();
    super.dispose();
  }
}
