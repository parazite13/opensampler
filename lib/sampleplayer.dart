//==============================================================================
//    padsettings.dart
//    Released under EUPL 1.2
//    Copyright Cherry Tree Studio 2021
//==============================================================================

import 'package:audioplayers/audioplayers.dart';

import 'settings.dart';

//==============================================================================

class SamplePlayer {

  //----------------------------------------------------------------------------

  List<AudioPlayer?> _players = [];
  late Settings _settings;

  //----------------------------------------------------------------------------

  void init(Settings settings) async {

    _settings = settings;

    for (AudioPlayer? player in _players) {
      if(player != null){
        player.release();
      }
    }

    _players.clear();

    for (PadSettings pad in settings.padSettings) {
      if (pad.sample.isNotEmpty) {
        AudioPlayer player = AudioPlayer();
        await player.setPlayerMode(pad.long ? PlayerMode.mediaPlayer : PlayerMode.lowLatency);
        await player.setSource(DeviceFileSource(pad.sample));
        await player.setReleaseMode(pad.looped ? ReleaseMode.loop : ReleaseMode.stop);
        await player.setVolume(pad.volume);

        _players.add(player);
      }
      else {
        _players.add(null);
      }
    }
  }

  //----------------------------------------------------------------------------

  void play(int idx)
  {
    AudioPlayer? player = _players[idx];

    if (player != null) {

      if (player.state == PlayerState.playing) {

        switch (_settings.padSettings[idx].behaviour)
        {
          case PressBehaviour.Pause:
            player.pause();
            break;

          case PressBehaviour.Stop:
            player.stop();
            break;

          case PressBehaviour.Restart:
            player.seek(Duration.zero);
            player.resume();
            break;
        }

      }
      else {
        player.resume();
      }
    }

  }

  //----------------------------------------------------------------------------

  void stop() {

    for (AudioPlayer? player in _players) {
      if (player != null) {
        player.stop();
      }
    }

  }

  //----------------------------------------------------------------------------

  void clear()
  {
    _settings = Settings.defaultSettings;
    _players = [];
  }

  //----------------------------------------------------------------------------

  bool isPlaying(int index){
    if(index >= _players.length){
      return false;
    }
    AudioPlayer? player = _players[index];
    return player != null && player.state == PlayerState.playing;
  }
}

//==============================================================================