import 'dart:async';
import 'dart:collection';
import 'dart:isolate';

/// A channel for communication between isolates, inspired by Kotlin Coroutines channels.
///
/// Channels provide a way to send and receive values between different isolates
/// in a type-safe and efficient manner.
class Channel<T> {
  final ReceivePort? _receivePort;
  final SendPort? _sendPort;
  final int? _capacity;
  final Queue<T> _buffer = Queue<T>();
  final Queue<Completer<T>> _waitingReceivers = Queue<Completer<T>>();
  bool _closed = false;

  Channel._(this._receivePort, this._sendPort, this._capacity);

  /// Creates a new unbuffered channel.
  ///
  /// Messages sent to this channel will block until received.
  ///
  /// Example:
  /// ```dart
  /// final channel = Channel<String>();
  ///
  /// // In isolate 1
  /// await channel.send('Hello');
  ///
  /// // In isolate 2
  /// final message = await channel.receive();
  /// ```
  factory Channel() {
    return Channel._(null, null, null);
  }

  /// Creates a buffered channel with the specified capacity.
  ///
  /// Messages can be sent without blocking until the buffer is full.
  ///
  /// Example:
  /// ```dart
  /// final channel = Channel<int>.buffered(capacity: 10);
  ///
  /// // Can send up to 10 messages without blocking
  /// for (int i = 0; i < 10; i++) {
  ///   channel.trySend(i); // Won't block
  /// }
  /// ```
  factory Channel.buffered({required int capacity}) {
    if (capacity <= 0) throw ArgumentError('Capacity must be positive');
    return Channel._(null, null, capacity);
  }

  /// Creates a channel for inter-isolate communication.
  ///
  /// Returns a record with sender and receiver channels.
  ///
  /// Example:
  /// ```dart
  /// final (sender, receiver) = await Channel.isolate<String>();
  ///
  /// // Use sender in one isolate, receiver in another
  /// await sender.send('Cross-isolate message');
  /// final message = await receiver.receive();
  /// ```
  static Future<(Channel<T>, Channel<T>)> isolate<T>() async {
    final receivePort1 = ReceivePort();
    final receivePort2 = ReceivePort();

    final sender = Channel<T>._(receivePort1, receivePort2.sendPort, null);
    final receiver = Channel<T>._(receivePort2, receivePort1.sendPort, null);

    // Set up message routing for sender
    receivePort1.listen((data) {
      if (data is T) {
        sender._addToBuffer(data);
      } else if (data == _ChannelCloseSignal.instance) {
        sender._closed = true;
        sender._processWaitingReceivers();
      }
    });

    // Set up message routing for receiver
    receivePort2.listen((data) {
      if (data is T) {
        receiver._addToBuffer(data);
      } else if (data == _ChannelCloseSignal.instance) {
        receiver._closed = true;
        receiver._processWaitingReceivers();
      }
    });

    return (sender, receiver);
  }

  /// Internal method to add value to buffer and notify waiting receivers
  void _addToBuffer(T value) {
    if (_waitingReceivers.isNotEmpty) {
      // Directly fulfill waiting receiver
      final completer = _waitingReceivers.removeFirst();
      completer.complete(value);
    } else {
      // Add to buffer
      _buffer.add(value);
    }
  }

  /// Internal method to process waiting receivers when channel closes
  void _processWaitingReceivers() {
    while (_waitingReceivers.isNotEmpty) {
      final completer = _waitingReceivers.removeFirst();
      completer.completeError(ChannelClosedException());
    }
  }

  /// Sends a value to the channel.
  ///
  /// For unbuffered channels, this will block until the value is received.
  /// For buffered channels, this will block only when the buffer is full.
  ///
  /// Throws [ChannelClosedException] if the channel is closed.
  Future<void> send(T value) async {
    if (_closed) throw ChannelClosedException();

    if (_sendPort != null) {
      // Inter-isolate communication
      _sendPort!.send(value);
    } else {
      // Local communication
      _addToBuffer(value);
    }
  }

  /// Tries to send a value without blocking.
  ///
  /// Returns `true` if the value was sent successfully, `false` otherwise.
  bool trySend(T value) {
    if (_closed) return false;

    if (_sendPort != null) {
      _sendPort!.send(value);
      return true;
    } else if (_capacity != null && _buffer.length >= _capacity! && _waitingReceivers.isEmpty) {
      return false; // Buffer full and no waiting receivers
    } else {
      _addToBuffer(value);
      return true;
    }
  }

  /// Receives a value from the channel.
  ///
  /// Blocks until a value is available or the channel is closed.
  ///
  /// Throws [ChannelClosedException] if the channel is closed and empty.
  Future<T> receive() async {
    if (_closed && _buffer.isEmpty) throw ChannelClosedException();

    if (_buffer.isNotEmpty) {
      return _buffer.removeFirst();
    }

    if (_closed) throw ChannelClosedException();

    // No value available, wait for one
    final completer = Completer<T>();
    _waitingReceivers.add(completer);

    return completer.future;
  }

  /// Tries to receive a value without blocking.
  ///
  /// Returns the value if available, or `null` if no value is immediately available.
  T? tryReceive() {
    if (_buffer.isNotEmpty) {
      return _buffer.removeFirst();
    }
    return null;
  }

  /// Closes the channel.
  ///
  /// After closing, no more values can be sent, but existing values
  /// can still be received.
  void close() {
    if (_closed) return;

    _closed = true;

    if (_sendPort != null) {
      _sendPort!.send(_ChannelCloseSignal.instance);
    }

    _processWaitingReceivers();
    _receivePort?.close();
  }

  /// Returns `true` if the channel is closed.
  bool get isClosed => _closed;

  /// Returns `true` if the channel is empty.
  bool get isEmpty => _buffer.isEmpty;

  /// Returns the number of elements currently in the channel buffer.
  int get length => _buffer.length;

  /// Creates a stream from this channel.
  ///
  /// Example:
  /// ```dart
  /// final channel = Channel<int>();
  ///
  /// channel.stream.listen((value) {
  ///   print('Received: $value');
  /// });
  /// ```
  Stream<T> get stream async* {
    try {
      while (!_closed || _buffer.isNotEmpty) {
        if (_buffer.isNotEmpty) {
          yield _buffer.removeFirst();
        } else if (!_closed) {
          // Wait for next value
          yield await receive();
        } else {
          // Channel is closed and buffer is empty
          break;
        }
      }
    } on ChannelClosedException {
      // Stream ends when channel is closed and empty
      return;
    }
  }
}

/// Exception thrown when trying to operate on a closed channel.
class ChannelClosedException implements Exception {
  final String message;

  ChannelClosedException([this.message = 'Channel is closed']);

  @override
  String toString() => 'ChannelClosedException: $message';
}

/// Internal signal used to indicate channel closure.
class _ChannelCloseSignal {
  static const instance = _ChannelCloseSignal._();
  const _ChannelCloseSignal._();
}

/// Utility functions for working with multiple channels.
class ChannelUtils {
  /// Selects from multiple channels, returning the first available value.
  ///
  /// Returns a record with the channel index and the received value.
  ///
  /// Example:
  /// ```dart
  /// final channel1 = Channel<String>();
  /// final channel2 = Channel<int>();
  ///
  /// final (index, value) = await ChannelUtils.select([
  ///   channel1.stream,
  ///   channel2.stream,
  /// ]);
  ///
  /// if (index == 0) {
  ///   print('Received string: $value');
  /// } else {
  ///   print('Received int: $value');
  /// }
  /// ```
  static Future<(int, T)> select<T>(List<Stream<T>> streams) async {
    final completer = Completer<(int, T)>();
    final subscriptions = <StreamSubscription>[];

    for (int i = 0; i < streams.length; i++) {
      final subscription = streams[i].listen((value) {
        if (!completer.isCompleted) {
          completer.complete((i, value));
        }
      });
      subscriptions.add(subscription);
    }

    final result = await completer.future;

    // Cancel all subscriptions
    for (final subscription in subscriptions) {
      await subscription.cancel();
    }

    return result;
  }

  /// Merges multiple channels into a single stream.
  ///
  /// Example:
  /// ```dart
  /// final channel1 = Channel<int>();
  /// final channel2 = Channel<int>();
  /// final channel3 = Channel<int>();
  ///
  /// final merged = ChannelUtils.merge([channel1, channel2, channel3]);
  ///
  /// merged.listen((value) {
  ///   print('Received from any channel: $value');
  /// });
  /// ```
  static Stream<T> merge<T>(List<Channel<T>> channels) {
    if (channels.isEmpty) {
      return Stream.empty();
    }

    final controller = StreamController<T>();
    final subscriptions = <StreamSubscription>[];
    int completedChannels = 0;

    for (final channel in channels) {
      final subscription = channel.stream.listen(
            (value) => controller.add(value),
        onError: (Object error, [StackTrace? stackTrace]) =>
            controller.addError(error, stackTrace),
        onDone: () {
          completedChannels++;
          // Close merged stream when all channels are closed
          if (completedChannels == channels.length) {
            controller.close();
          }
        },
      );
      subscriptions.add(subscription);
    }

    controller.onCancel = () async {
      for (final subscription in subscriptions) {
        await subscription.cancel();
      }
    };

    return controller.stream;
  }

  /// Creates a pipeline of channels where output of one feeds into the next.
  ///
  /// Example:
  /// ```dart
  /// final pipeline = ChannelUtils.pipeline<int, String>(
  ///   source: sourceChannel,
  ///   transform: (value) => value.toString(),
  /// );
  ///
  /// pipeline.listen((stringValue) {
  ///   print('Transformed: $stringValue');
  /// });
  /// ```
  static Stream<R> pipeline<T, R>(
      Channel<T> source,
      R Function(T value) transform,
      ) {
    return source.stream.map(transform);
  }
}