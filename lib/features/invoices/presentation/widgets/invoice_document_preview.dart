import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'package:bayaa_pos/shared/widgets/loading/shimmer.dart';
import 'package:bayaa_pos/shared/widgets/loading/skeleton.dart';
import '../documents/invoice_document_renderer.dart';
import '../models/invoice_document_view_data.dart';

/// Rasterize each format once. Resizing and switching formats reuse the pages.
class InvoiceDocumentPreview extends StatefulWidget {
  const InvoiceDocumentPreview(
      {super.key, required this.data, required this.receiptMode});
  final InvoiceData data;
  final bool receiptMode;

  @override
  State<InvoiceDocumentPreview> createState() => _InvoiceDocumentPreviewState();
}

class _InvoiceDocumentPreviewState extends State<InvoiceDocumentPreview> {
  final _pending = <bool, Future<List<_DocumentPage>>>{};
  final _ready = <bool, List<_DocumentPage>>{};
  Object? _configuration;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Theme.of(context);
    final configuration = (
      Localizations.localeOf(context),
      AppColors.primaryColor,
      AppColors.accentColor,
      AppColors.primaryForeground,
    );
    if (_configuration != configuration) {
      _configuration = configuration;
      _pending.clear();
      _ready.clear();
    }
  }

  @override
  void didUpdateWidget(covariant InvoiceDocumentPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _pending.clear();
      _ready.clear();
    }
  }

  Future<List<_DocumentPage>> _render(bool receipt) async {
    final locale = Localizations.localeOf(context);
    final configuration = _configuration;
    final data = widget.data;
    // Let the paper shimmer paint before document generation starts.
    await WidgetsBinding.instance.endOfFrame;
    final bytes = receipt
        ? await InvoiceDocumentRenderer.buildReceipt80mm(data, locale: locale)
        : await InvoiceDocumentRenderer.buildA4(data,
            format: PdfPageFormat.a4, locale: locale);
    final pages = <_DocumentPage>[];
    // Screen resolution, independent of viewport changes. PDF output stays vector.
    await for (final page in Printing.raster(bytes, dpi: receipt ? 144 : 110)) {
      pages.add(_DocumentPage(await page.toPng(), page.width / page.height));
    }
    if (pages.isEmpty) throw StateError('Document contains no pages');
    if (mounted && configuration == _configuration && data == widget.data) {
      _ready[receipt] = pages;
    }
    return pages;
  }

  @override
  Widget build(BuildContext context) {
    final receipt = widget.receiptMode;
    final ready = _ready[receipt];
    if (ready != null) return _pages(ready, receipt);
    return FutureBuilder<List<_DocumentPage>>(
      key: ValueKey((receipt, _configuration, widget.data)),
      future: _pending.putIfAbsent(
          receipt,
          () => _render(receipt)
                  .timeout(const Duration(seconds: 30))
                  .onError((Object error, StackTrace stack) {
                debugPrint('Invoice preview failed: $error\n$stack');
                Error.throwWithStackTrace(error, stack);
              })),
      builder: (context, snapshot) {
        if (snapshot.hasData) return _pages(snapshot.data!, receipt);
        if (snapshot.hasError) {
          final arabic = Localizations.localeOf(context).languageCode == 'ar';
          return Center(
              child: OutlinedButton.icon(
            onPressed: () => setState(() => _pending.remove(receipt)),
            icon: const Icon(Icons.refresh),
            label: Text(arabic
                ? 'تعذر عرض المستند • إعادة المحاولة'
                : 'Unable to display document • Try again'),
          ));
        }
        return _DocumentShimmer(receipt: receipt);
      },
    );
  }

  Widget _pages(List<_DocumentPage> pages, bool receipt) => ListView.builder(
        key: PageStorageKey('invoice-pages-$receipt'),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
        itemCount: pages.length,
        itemBuilder: (context, index) => Center(
            child: Container(
          constraints: BoxConstraints(maxWidth: receipt ? 420 : 780),
          margin: const EdgeInsets.only(bottom: 18),
          color: Colors.white,
          child: AspectRatio(
            aspectRatio: pages[index].aspectRatio,
            child: Image.memory(pages[index].bytes,
                fit: BoxFit.contain,
                gaplessPlayback: true,
                semanticLabel: '${widget.data.invoiceId} • ${index + 1}'),
          ),
        )),
      );
}

class _DocumentPage {
  const _DocumentPage(this.bytes, this.aspectRatio);
  final Uint8List bytes;
  final double aspectRatio;
}

class _DocumentShimmer extends StatelessWidget {
  const _DocumentShimmer({required this.receipt});
  final bool receipt;

  @override
  Widget build(BuildContext context) => Semantics(
        label: Localizations.localeOf(context).languageCode == 'ar'
            ? 'جار تجهيز المستند'
            : 'Preparing document',
        child: ExcludeSemantics(
            child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
          child: Center(
              child: Container(
            constraints: BoxConstraints(maxWidth: receipt ? 420 : 780),
            padding: EdgeInsets.all(receipt ? 24 : 32),
            color: Colors.white,
            child: Shimmer(
                child: Column(children: [
              const SkeletonBox(width: 60, height: 44),
              const SizedBox(height: 20),
              const SkeletonBox(width: 140, height: 18),
              const SizedBox(height: 12),
              const SkeletonBox(width: 110, height: 10),
              const SizedBox(height: 28),
              for (var i = 0; i < 8; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Row(children: [
                    Expanded(
                        flex: 3, child: SkeletonBox(height: i == 0 ? 24 : 12)),
                    const SizedBox(width: 20),
                    const Expanded(child: SkeletonBox(height: 12)),
                  ]),
                ),
              const SizedBox(height: 20),
              const SkeletonBox(height: 30),
            ])),
          )),
        )),
      );
}
