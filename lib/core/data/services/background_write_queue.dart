// lib/core/data/services/background_write_queue.dart

import 'dart:async';
import 'dart:collection';

/// Asynchronous write queue that processes operations without blocking UI.
class BackgroundWriteQueue {
  final Queue<_QueuedWrite> _queue = Queue();
  final StreamController<_QueuedWrite> _controller = StreamController();
  
  bool _isProcessing = false;
  int _processedCount = 0;
  int _failedCount = 0;

  void start() {
    _controller.stream.listen(_processWrite);
  }

  Future<void> enqueue(Future<void> Function() writeOperation) async {
    final queuedWrite = _QueuedWrite(
      operation: writeOperation,
      timestamp: DateTime.now(),
    );
    
    _queue.add(queuedWrite);
    _controller.add(queuedWrite);
  }

  Future<void> _processWrite(_QueuedWrite write) async {
    if (_isProcessing) return;
    
    _isProcessing = true;
    
    try {
      await _executeWithRetry(write);
      _processedCount++;
      _queue.remove(write);
    } catch (e) {
      _failedCount++;
      print('Write operation failed after retries: $e');
    } finally {
      _isProcessing = false;
      
      if (_queue.isNotEmpty) {
        _controller.add(_queue.first);
      }
    }
  }

  Future<void> _executeWithRetry(_QueuedWrite write, {int attempt = 0}) async {
    const maxAttempts = 3;
    const baseDelay = Duration(milliseconds: 100);
    
    try {
      await write.operation();
    } catch (e) {
      if (attempt < maxAttempts - 1) {
        final delay = baseDelay * (1 << attempt);
        await Future.delayed(delay);
        return _executeWithRetry(write, attempt: attempt + 1);
      } else {
        rethrow;
      }
    }
  }

  Map<String, int> getStats() {
    return {
      'queued': _queue.length,
      'processed': _processedCount,
      'failed': _failedCount,
    };
  }

  void clear() {
    _queue.clear();
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}

class _QueuedWrite {
  final Future<void> Function() operation;
  final DateTime timestamp;

  _QueuedWrite({
    required this.operation,
    required this.timestamp,
  });
}
