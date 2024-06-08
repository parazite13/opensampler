//==============================================================================
//    settings.dart
//    Released under EUPL 1.2
//    Copyright Cherry Tree Studio 2021
//==============================================================================

import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'main.dart';

//==============================================================================

enum PressBehaviour { Stop, Pause, Restart }

//------------------------------------------------------------------------------

String pressBehaviourToString(PressBehaviour mode)
{
  return switch (mode) {
    PressBehaviour.Stop => "Stop",
    PressBehaviour.Pause => "Pause",
    PressBehaviour.Restart => "Restart"
  };
}

//------------------------------------------------------------------------------

PressBehaviour pressBehaviourFromString(String string)
{
  return switch (string) {
    "Stop" => PressBehaviour.Stop,
    "Pause" => PressBehaviour.Pause,
    "Restart" => PressBehaviour.Restart,
    _ => PressBehaviour.Restart
  };
}

//==============================================================================

class PadSettings {

  //----------------------------------------------------------------------------

  late String sample;
  late String caption;
  late Color color;
  late Color textColor;
  late bool looped;
  late bool long;
  late int midiPitch;

  late PressBehaviour behaviour;

  late double volume;

  late Settings _settings;

  //----------------------------------------------------------------------------

  PadSettings(Settings settings, int index)
  {
    _settings = settings;

    index++;

    sample = "";
    caption = "$index";

    midiPitch = 36 + index;

    color = Colors.grey;
    color = color.withOpacity(1.0);

    volume = 1.0;

    textColor = Colors.black;
    textColor = textColor.withOpacity(1.0);

    behaviour = PressBehaviour.Restart;

    looped = false;
    long = false;
  }

  //----------------------------------------------------------------------------

  PadSettings.copy(PadSettings settings)
  {
    this._settings = settings._settings;

    this.sample = settings.sample;
    this.caption = settings.caption;

    this.midiPitch = settings.midiPitch;

    this.color = settings.color;
    this.color = this.color.withOpacity(1.0);

    this.textColor = settings.textColor;
    this.textColor = this.textColor.withOpacity(1.0);

    this.looped = settings.looped;
    this.volume = settings.volume;
    this.long = settings.long;

    this.behaviour = settings.behaviour;
  }

  //----------------------------------------------------------------------------

  PadSettings.fromJson(Settings settings, Map<String, dynamic> map)
  {
    _settings = settings;
    sample = map["sample"];
    caption = map["caption"];

    int colorVal = map["color"];
    color = colorVal != null ? Color(colorVal) : Colors.grey;
    color = color.withOpacity(1.0);

    midiPitch = map["midiPitch"];

    int textColorVal = map["textColor"];
    textColor = textColorVal != null ? Color(textColorVal) : Colors.black;
    textColor = textColor.withOpacity(1.0);

    long = map["long"];
    looped = map["looped"];
    volume = map["volume"];

    behaviour = pressBehaviourFromString(map["behaviour"]);
  }

  //----------------------------------------------------------------------------

  Map<String, dynamic> toJson() =>
  {
    "sample": sample,
    "caption": caption,
    "midiPitch": midiPitch,
    "color": color.value,
    "textColor": textColor.value,
    "looped": looped,
    "volume": volume,
    "long": long,
    "behaviour": pressBehaviourToString(behaviour)
  };

  //----------------------------------------------------------------------------

  void save()
  {
    _settings.save();
  }

  //----------------------------------------------------------------------------
}

//==============================================================================

class Settings {

  //----------------------------------------------------------------------------

  late String name;
  late File file;

  late int x;
  late int y;

  late Map midiInputStates;

  late List<PadSettings> padSettings;

  //----------------------------------------------------------------------------

  static Settings defaultSettings = Settings.temp("Open Sampler", 3,3, Map());

  //----------------------------------------------------------------------------

  Settings.temp(String name, int x, int y, Map midiInputStates)
  {
    this.name = name;
    this.x = x;
    this.y = y;
    this.midiInputStates = midiInputStates;

    padSettings = [];

    for (int i = 0 ; i < x * y ; i++)
      padSettings.add(PadSettings(this, i));

    String? path = documentDirectory.path;
    file = File('$path/temp.json');
  }

  //----------------------------------------------------------------------------

  Settings.copy(Settings settings)
  {
    this.name = settings.name;
    this.file = settings.file;
    this.x = settings.x;
    this.y = settings.y;

    this.midiInputStates = Map();
    for(var entry in settings.midiInputStates.entries){
      this.midiInputStates[entry.key] = entry.value;
    }

    padSettings = [];

    for (int i = 0 ; i < x * y ; i++)
      this.padSettings.add(PadSettings.copy(settings.padSettings[i]));
  }

  //----------------------------------------------------------------------------

  Settings.fromJson(File file, String json)
  {
    this.file = file;

    Map<String, dynamic> map = jsonDecode(json);

    name = map['name'];
    x = map['x'];
    y = map['y'];
    midiInputStates = map['midiInputs'];


    List<Map<String, dynamic>> padMap = List.from(map['padSettings']);

    padSettings = [];

    for (int i = 0 ; i < x * y ; i++)
      padSettings.add(PadSettings.fromJson(this, padMap[i]));
  }

  //----------------------------------------------------------------------------

  Map<String, dynamic> toJson() =>
  {
    'name': name,
    'x': x,
    'y': y,
    'padSettings': List<dynamic>.from(padSettings.map((x) => x)),
    'midiInputs': midiInputStates,
  };

  //----------------------------------------------------------------------------

  String getJson()
  {
    return jsonEncode(this);
  }

  //----------------------------------------------------------------------------

  void save()
  {
    file.writeAsString(getJson());
  }

  //----------------------------------------------------------------------------

  void validate()
  {
    if (x * y > padSettings.length)
    {
      for (int i = padSettings.length ; i < x * y ; i++)
        padSettings.add(PadSettings(this, i));
    }
    else if (x * y < padSettings.length)
    {
      for (int i = padSettings.length - 1; i >= x * y ; i--)
        padSettings.removeAt(i);
    }
  }

  //----------------------------------------------------------------------------
}