import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import 'routeros_api_exception.dart';
import 'routeros_api_response.dart';
import 'routeros_sentence_codec.dart';

class RouterOsApiClient {
  RouterOsApiClient({
    required this.host,
    this.port = 8728,
    this.useSsl = false,
    this.timeout = const Duration(seconds: 10),
  });

  final String host;
  final int port;
  final bool useSsl;
  final Duration timeout;

  Socket? _socket;
  _SocketByteReader? _reader;
  bool _isLoggedIn = false;

  bool get isConnected => _socket != null;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> connect() async {
    if (_socket != null) {
      return;
    }

    try {
      final socket = useSsl
          ? await SecureSocket.connect(host, port, timeout: timeout)
          : await Socket.connect(host, port, timeout: timeout);
      socket.setOption(SocketOption.tcpNoDelay, true);
      _socket = socket;
      _reader = _SocketByteReader(socket);
    } on Object catch (error) {
      throw RouterOsConnectionException(
        'Unable to connect to $host:$port.',
        cause: error,
      );
    }
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    await connect();

    try {
      await _loginModern(username: username, password: password);
      _isLoggedIn = true;
    } on RouterOsAuthenticationException {
      rethrow;
    } on RouterOsTrapException {
      await _loginLegacy(username: username, password: password);
      _isLoggedIn = true;
    }
  }

  Future<RouterOsApiResponse> execute(
    String command, {
    Map<String, String> attributes = const {},
    List<String> queries = const [],
    String? tag,
    Duration? timeout,
  }) async {
    await connect();
    final words = _buildSentence(
      command,
      attributes: attributes,
      queries: queries,
      tag: tag,
    );
    await _writeSentence(words);

    return _readResponse().timeout(timeout ?? this.timeout);
  }

  Stream<Map<String, String>> listen(
    String command, {
    Map<String, String> attributes = const {},
    List<String> queries = const [],
    String? tag,
  }) async* {
    await connect();
    await _writeSentence(
      _buildSentence(
        command,
        attributes: attributes,
        queries: queries,
        tag: tag,
      ),
    );

    while (true) {
      final reply = await _readReply();
      if (reply.isRecord) {
        yield reply.attributes;
        continue;
      }
      if (reply.isDone) {
        return;
      }
      if (reply.isTrap || reply.isFatal) {
        throw _exceptionFromReply(reply);
      }
    }
  }

  Future<void> disconnect() async {
    _isLoggedIn = false;
    final socket = _socket;
    final reader = _reader;
    _socket = null;
    _reader = null;
    await reader?.cancel();
    await socket?.close();
  }

  Future<void> _loginModern({
    required String username,
    required String password,
  }) async {
    await execute(
      '/login',
      attributes: {'name': username, 'password': password},
    );
  }

  Future<void> _loginLegacy({
    required String username,
    required String password,
  }) async {
    final challenge = await execute('/login', attributes: {'name': username});
    final challengeHex = challenge.doneAttributes['ret'];
    if (challengeHex == null || challengeHex.isEmpty) {
      throw const RouterOsAuthenticationException(
        'RouterOS did not return a login challenge.',
      );
    }

    final digest = _legacyChallengeResponse(password, challengeHex);
    await execute(
      '/login',
      attributes: {'name': username, 'response': '00$digest'},
    );
  }

  String _legacyChallengeResponse(String password, String challengeHex) {
    final challenge = _decodeHex(challengeHex);
    final input = <int>[0, ...utf8.encode(password), ...challenge];
    return md5.convert(input).toString();
  }

  List<String> _buildSentence(
    String command, {
    required Map<String, String> attributes,
    required List<String> queries,
    required String? tag,
  }) {
    final normalizedCommand = command.startsWith('/') ? command : '/$command';
    return [
      normalizedCommand,
      for (final entry in attributes.entries) '=${entry.key}=${entry.value}',
      for (final query in queries) query.startsWith('?') ? query : '?$query',
      if (tag != null) '.tag=$tag',
    ];
  }

  Future<void> _writeSentence(List<String> words) async {
    final socket = _socket;
    if (socket == null) {
      throw const RouterOsConnectionException('RouterOS socket is not open.');
    }

    socket.add(RouterOsSentenceCodec.encodeSentence(words));
    await socket.flush();
  }

  Future<RouterOsApiResponse> _readResponse() async {
    final records = <Map<String, String>>[];

    while (true) {
      final reply = await _readReply();
      if (reply.isRecord) {
        records.add(reply.attributes);
        continue;
      }
      if (reply.isDone) {
        return RouterOsApiResponse(
          records: records,
          doneAttributes: reply.attributes,
        );
      }
      if (reply.isTrap || reply.isFatal) {
        throw _exceptionFromReply(reply);
      }
    }
  }

  Future<RouterOsReply> _readReply() async {
    final sentence = await _readSentence();
    if (sentence.isEmpty) {
      throw const RouterOsApiException('Received an empty RouterOS reply.');
    }

    return RouterOsReply(
      type: sentence.first,
      attributes: _parseAttributes(sentence.skip(1)),
    );
  }

  Future<List<String>> _readSentence() async {
    final reader = _reader;
    if (reader == null) {
      throw const RouterOsConnectionException(
        'RouterOS socket reader is closed.',
      );
    }

    final words = <String>[];
    while (true) {
      final length = await reader.readLength();
      if (length == 0) {
        return words;
      }
      words.add(utf8.decode(await reader.readBytes(length)));
    }
  }

  Map<String, String> _parseAttributes(Iterable<String> words) {
    final attributes = <String, String>{};
    for (final word in words) {
      if (word.startsWith('.tag=')) {
        attributes['.tag'] = word.substring(5);
        continue;
      }
      if (!word.startsWith('=')) {
        continue;
      }
      final separator = word.indexOf('=', 1);
      if (separator <= 1) {
        continue;
      }
      attributes[word.substring(1, separator)] = word.substring(separator + 1);
    }
    return attributes;
  }

  RouterOsApiException _exceptionFromReply(RouterOsReply reply) {
    final message =
        reply.attributes['message'] ??
        reply.attributes['error'] ??
        'RouterOS command failed.';
    final category = reply.attributes['category'];

    if (category == '2' || message.toLowerCase().contains('invalid user')) {
      return RouterOsAuthenticationException(message, cause: reply.attributes);
    }

    return RouterOsTrapException(
      message,
      category: category,
      cause: reply.attributes,
    );
  }

  List<int> _decodeHex(String hex) {
    final normalized = hex.length.isOdd ? '0$hex' : hex;
    return [
      for (var i = 0; i < normalized.length; i += 2)
        int.parse(normalized.substring(i, i + 2), radix: 16),
    ];
  }
}

class _SocketByteReader {
  _SocketByteReader(Socket socket) {
    _subscription = socket.listen(
      _onData,
      onError: _onError,
      onDone: _onDone,
      cancelOnError: true,
    );
  }

  final _buffer = Queue<int>();
  final _waiters = Queue<Completer<void>>();
  Object? _error;
  bool _isClosed = false;
  late final StreamSubscription<List<int>> _subscription;

  Future<int> readLength() async {
    final first = await readByte();
    if ((first & 0x80) == 0x00) {
      return first;
    }
    if ((first & 0xC0) == 0x80) {
      final second = await readByte();
      return ((first & 0x3F) << 8) + second;
    }
    if ((first & 0xE0) == 0xC0) {
      final second = await readByte();
      final third = await readByte();
      return ((first & 0x1F) << 16) + (second << 8) + third;
    }
    if ((first & 0xF0) == 0xE0) {
      final second = await readByte();
      final third = await readByte();
      final fourth = await readByte();
      return ((first & 0x0F) << 24) + (second << 16) + (third << 8) + fourth;
    }
    final second = await readByte();
    final third = await readByte();
    final fourth = await readByte();
    final fifth = await readByte();
    return (second << 24) + (third << 16) + (fourth << 8) + fifth;
  }

  Future<Uint8List> readBytes(int length) async {
    final bytes = Uint8List(length);
    for (var index = 0; index < length; index++) {
      bytes[index] = await readByte();
    }
    return bytes;
  }

  Future<int> readByte() async {
    while (_buffer.isEmpty) {
      if (_error != null) {
        throw RouterOsConnectionException(
          'RouterOS socket failed while reading.',
          cause: _error,
        );
      }
      if (_isClosed) {
        throw const RouterOsConnectionException(
          'RouterOS socket closed while reading.',
        );
      }

      final completer = Completer<void>();
      _waiters.add(completer);
      await completer.future;
    }

    return _buffer.removeFirst();
  }

  void _onData(List<int> data) {
    _buffer.addAll(data);
    _wakeWaiters();
  }

  void _onError(Object error) {
    _error = error;
    _wakeWaiters();
  }

  void _onDone() {
    _isClosed = true;
    _wakeWaiters();
  }

  void _wakeWaiters() {
    while (_waiters.isNotEmpty) {
      _waiters.removeFirst().complete();
    }
  }

  Future<void> cancel() => _subscription.cancel();
}
