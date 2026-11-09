/// Simulated streaming audio engine. Position advances at the playback speed and a
/// buffer runs ahead of it like a progressive HTTP stream. Swap for just_audio (HLS/MP3
/// streaming with background playback) in production; the provider API stays the same.
class StreamState {
  const StreamState({
    required this.bookId,
    required this.chapterIndex,
    required this.position,
    required this.duration,
    required this.buffered,
    this.playing = false,
    this.speed = 1.0,
    this.sleepLeft,
    this.bitrateKbps = 64,
  });

  final String bookId;
  final int chapterIndex;
  final Duration position;
  final Duration duration;
  final Duration buffered;
  final bool playing;
  final double speed;
  final Duration? sleepLeft;
  final int bitrateKbps;

  bool get buffering => playing && buffered - position < const Duration(seconds: 2);

  StreamState copyWith({int? chapterIndex, Duration? position, Duration? duration, Duration? buffered, bool? playing, double? speed, Duration? sleepLeft, bool clearSleep = false}) => StreamState(
    bookId: bookId,
    chapterIndex: chapterIndex ?? this.chapterIndex,
    position: position ?? this.position,
    duration: duration ?? this.duration,
    buffered: buffered ?? this.buffered,
    playing: playing ?? this.playing,
    speed: speed ?? this.speed,
    sleepLeft: clearSleep ? null : (sleepLeft ?? this.sleepLeft),
    bitrateKbps: bitrateKbps,
  );

  /// One engine tick of [wall] real time.
  StreamState tick(Duration wall) {
    if (!playing) return this;
    final step = Duration(microseconds: (wall.inMicroseconds * speed).round());
    var pos = position + step;
    var buf = buffered + step * 3; // the network fills faster than playback drains it
    if (buf > duration) buf = duration;
    if (pos > buf) pos = buf;
    var sleep = sleepLeft;
    var play = playing;
    if (sleep != null) {
      sleep -= wall;
      if (sleep <= Duration.zero) {
        sleep = null;
        play = false;
      }
    }
    if (pos >= duration) {
      pos = duration;
      play = false;
    }
    return StreamState(bookId: bookId, chapterIndex: chapterIndex, position: pos, duration: duration, buffered: buf, playing: play, speed: speed, sleepLeft: sleep, bitrateKbps: bitrateKbps);
  }

  StreamState seekBy(Duration d) {
    var p = position + d;
    if (p < Duration.zero) p = Duration.zero;
    if (p > duration) p = duration;
    return copyWith(position: p, buffered: p > buffered ? p : buffered);
  }

  static const speeds = [1.0, 1.25, 1.5, 2.0, 0.75];
  double get nextSpeed => speeds[(speeds.indexOf(speed) + 1) % speeds.length];
}
