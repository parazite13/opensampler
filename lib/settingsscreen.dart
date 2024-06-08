//==============================================================================
//    settingsscreen.dart
//    Released under EUPL 1.2
//    Copyright Cherry Tree Studio 2021
//==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';

import 'main.dart';
import 'settings.dart';

//==============================================================================

class SettingsScreen extends StatefulWidget {

  //----------------------------------------------------------------------------

  final Settings _settings;

  //----------------------------------------------------------------------------

  SettingsScreen(this._settings);

  //----------------------------------------------------------------------------

  @override
  _SettingsScreenState createState() => _SettingsScreenState(_settings);

  //----------------------------------------------------------------------------
}

//==============================================================================

class _SettingsScreenState extends State<SettingsScreen> {

  //----------------------------------------------------------------------------

  Settings _settings;

  _SettingsScreenState(this._settings);

  String fontValue = 'Default';
  int xAmount = 2;
  int yAmount = 3;

  //----------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final TextStyle defaultTextStyle = TextStyle(fontSize: 20);

    xAmount = _settings.x;
    yAmount = _settings.y;

    return FutureBuilder(
        future: MidiCommand().devices,
        builder: (context, snapshot) {
          if(snapshot.hasData){
            return Scaffold(
                appBar: AppBar(
                  title: Text("Settings"),
                ),
                body: SingleChildScrollView(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Row(children: <Widget>[Text("Pad Layout:", style: defaultTextStyle), Spacer()]),
                            _buildHorizontalAmountCombo(context),
                            _buildVerticalAmountCombo(context),
                            Row(children: <Widget>[Text("Midi Inputs:", style: defaultTextStyle), Spacer()]),
                            Column(children:
                              _buildMidiInputCheckboxes(context, snapshot.data),
                            ),
                            Row(children: <Widget>[Text("Global Settings:", style: defaultTextStyle), Spacer()]),
                            _buildFontCombo(context),
                          ]
                      ),
                )
            );
          }else{
            return Scaffold(
                appBar: AppBar(
                  title: Text("Settings"),
                ),
                body: SingleChildScrollView(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Row(children: <Widget>[Text("Pad Layout:", style: defaultTextStyle), Spacer()]),
                            _buildHorizontalAmountCombo(context),
                            _buildVerticalAmountCombo(context),
                            Row(children: <Widget>[Text("Midi Inputs:", style: defaultTextStyle), Spacer()]),
                            CircularProgressIndicator(),
                            Row(children: <Widget>[Text("Global Settings:", style: defaultTextStyle), Spacer()]),
                            _buildFontCombo(context)
                          ]
                      ),
                )
            );
          }
        });
  }


  //----------------------------------------------------------------------------

  Row _buildHorizontalAmountCombo(BuildContext context)
  {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Horizontal Pads'),
        Spacer(),
        DropdownButton<int>(
          value: xAmount,
          onChanged: (int? newValue) {
            setState(() {
              if(newValue != null){
                xAmount = newValue;
                _settings.x = xAmount;
                _settings.save();
              }
            });
          },
          items: <int>[
            1,
            2,
            3,
            4,
            5,
            6,
            7,
            8,
          ].map<DropdownMenuItem<int>>((int value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text("$value"),
            );
          }).toList(),
        ),
      ],
    );
  }

  //----------------------------------------------------------------------------

  List<Row> _buildMidiInputCheckboxes(BuildContext context, List<MidiDevice>? midiDevices)
  {
    return
        midiDevices!.map((e) =>
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(e.name),
                Spacer(),
                Checkbox(value: _settings.midiInputStates.containsKey(e.name) ? _settings.midiInputStates[e.name] : false, onChanged: (bool? newValue){
                  setState(() {
                    _settings.midiInputStates[e.name] = newValue;
                    _settings.save();
                  });
                })
              ]
          ),
        ).toList();
  }

  //----------------------------------------------------------------------------

  Row _buildVerticalAmountCombo(BuildContext context)
  {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Vertical Pads'),
        Spacer(),
        DropdownButton<int>(
          value: yAmount,
          onChanged: (int? newValue) {
            setState(() {
              if(newValue != null){
                yAmount = newValue;
                _settings.y = yAmount;
                _settings.save();
              }
            });
          },
          items: <int>[
            1,
            2,
            3,
            4,
            5,
            6,
            7,
            8,
          ].map<DropdownMenuItem<int>>((int value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text("$value"),
            );
          }).toList(),
        ),
      ],
    );
  }

  //----------------------------------------------------------------------------

  Row _buildFontCombo(BuildContext context)
  {
    // TODO This might be better if it used an enum.

    String? prefFont = preferences?.getString(fontSizeKey);

    if (prefFont == null || prefFont.isEmpty)
      prefFont = "Default";

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Font Size'),
        Spacer(),
        DropdownButton<String>(
          value: prefFont,
          onChanged: (String? newValue) {
            setState(() {
              if(newValue != null){
                fontValue = newValue;
                preferences?.setString(fontSizeKey, newValue);
              }
            });
          },
          items: <String>[
            'Default',
            '12',
            '18',
            '24',
            '32',
            '40',
            '48',
            '56',
            '64'
          ].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }

//----------------------------------------------------------------------------

}

//==============================================================================