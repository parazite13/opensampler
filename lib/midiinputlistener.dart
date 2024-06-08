//==============================================================================
//    padsettings.dart
//    Released under EUPL 1.2
//    Copyright Cherry Tree Studio 2021
//==============================================================================

import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';

import 'settings.dart';

//==============================================================================

class MidiInputListener {

  //----------------------------------------------------------------------------

  late Settings _settings;

  StreamController<PadSettings> onMidiPadTriggered = StreamController();

  //----------------------------------------------------------------------------

  void init(Settings settings) async {
    _settings = settings;

    var midiDevices = await MidiCommand().devices;

    if(midiDevices != null) {
      for (var midiInputState in _settings.midiInputStates.entries) {
        if (midiInputState.value) {
          var midiDevice = midiDevices.firstWhere((element) =>
          element.name == midiInputState.key, orElse: null);
          MidiCommand().connectToDevice(midiDevice);
        }
      }
      MidiCommand().onMidiDataReceived!.listen((event) {
        var pitch = event.data[1];
        var value = event.data[2];
        var pads = _settings.padSettings.where((pad) => pad.midiPitch == pitch);
        for (var pad in pads) {
          if (value > 0) {
            onMidiPadTriggered.add(pad);
          }
        }
      });
    }
  }

//----------------------------------------------------------------------------

}

//==============================================================================