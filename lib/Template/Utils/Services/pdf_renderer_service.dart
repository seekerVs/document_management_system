import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pdfx/pdfx.dart';

/// A service to handle sequential rendering of PDF pages to avoid
/// native concurrency issues and provide basic memory caching.
class PdfRendererService {
  // Static queue to ensure only one page is rendered at a time globally
  static Future<void> _renderQueue = Future.value();

  // Basic cache: key is "docHash_pageIndex", value is the rendered image
  // We use a LinkedHashMap to implement a simple LRU cache
  static final _cache = <String, PdfPageImage>{};
  static const int _maxCacheSize = 20; // Cache last 20 pages

  /// Renders a specific page from a document.
  /// [docId] should be a unique identifier for the document (e.g., file path or remote URL)
  static Future<PdfPageImage?> renderPage({
    required PdfDocument document,
    required String docId,
    required int pageIndex,
    double scale = 2.0,
  }) async {
    final cacheKey = '${docId}_$pageIndex';

    // 1. Check Cache
    if (_cache.containsKey(cacheKey)) {
      final img = _cache.remove(cacheKey)!;
      _cache[cacheKey] = img;
      return img;
    }

    // 2. Queue the rendering task
    final completer = Completer<PdfPageImage?>();

    _renderQueue = _renderQueue.then((_) async {
      try {
        if (_cache.containsKey(cacheKey)) {
          completer.complete(_cache[cacheKey]);
          return;
        }

        final page = await document.getPage(pageIndex);
        final img = await page.render(
          width: page.width * scale,
          height: page.height * scale,
        );
        await page.close();

        if (img != null) {
          if (_cache.length >= _maxCacheSize) {
            _cache.remove(_cache.keys.first);
          }
          _cache[cacheKey] = img;
        }
        completer.complete(img);
      } catch (e) {
        debugPrint('Error rendering PDF page $pageIndex: $e');
        completer.complete(null);
      }
    });

    return completer.future;
  }

  /// Clears the cache for a specific document or all documents
  static void clearCache({String? docId}) {
    if (docId == null) {
      _cache.clear();
    } else {
      _cache.removeWhere((key, _) => key.startsWith('${docId}_'));
    }
  }
}
