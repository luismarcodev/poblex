import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/news_item.dart';

class PdfAttachmentScreen extends StatelessWidget {
  const PdfAttachmentScreen({required this.attachment, super.key});
  final NewsAttachment attachment;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(attachment.name)),
      body: Semantics(
        label: l10n.pdfViewerSemantic(attachment.name),
        child: PdfViewer.uri(Uri.parse(attachment.url)),
      ),
    );
  }
}

/// Safe destination for a restored/deep-linked `/pdf` route. Route extras are
/// in-memory only, so Android can restore the URL without its attachment.
/// Rendering an empty box here would leave the neighbour on a blank screen.
class PdfAttachmentUnavailableScreen extends StatelessWidget {
  const PdfAttachmentUnavailableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.pdfUnavailableTitle)),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppSize.maxContentWidth,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const AppIconBadge(
                          icon: Icons.picture_as_pdf_outlined,
                          size: AppIconBadgeSize.large,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          l10n.pdfUnavailableTitle,
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          l10n.pdfUnavailableBody,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        FilledButton.icon(
                          onPressed: () => context.canPop()
                              ? context.pop()
                              : context.go('/news'),
                          icon: const Icon(Icons.arrow_back),
                          label: Text(l10n.pdfBackToNews),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
