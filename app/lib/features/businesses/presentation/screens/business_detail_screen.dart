import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poblex_design_system/poblex_design_system.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/session/session_view_model.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/domain/value_objects/localized_text.dart';
import '../../../../shared/presentation/category_label.dart';
import '../../../../shared/presentation/failure_view.dart';
import '../../../../shared/presentation/widgets/photo_gallery.dart';
import '../../domain/entities/business.dart';
import '../viewmodels/business_detail_view_model.dart';

class BusinessDetailScreen extends ConsumerWidget {
  const BusinessDetailScreen({required this.businessId, super.key});
  final String businessId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<BusinessDetailUiState> detail = ref.watch(
      businessDetailViewModelProvider(businessId),
    );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.businessDetailTitle)),
      body: detail.when(
        loading: () => Semantics(
          label: l10n.loadingNews,
          child: const Center(child: CircularProgressIndicator()),
        ),
        error: (_, _) => FailureView(
          failure: const UnknownFailure(),
          sectionName: l10n.sectionBusinesses,
          onRetry: () => ref
              .read(businessDetailViewModelProvider(businessId).notifier)
              .retry(),
        ),
        data: (BusinessDetailUiState value) {
          if (value.failure != null) {
            return FailureView(
              failure: value.failure!,
              sectionName: l10n.sectionBusinesses,
              onRetry: () => ref
                  .read(businessDetailViewModelProvider(businessId).notifier)
                  .retry(),
            );
          }
          return _BusinessDetail(business: value.business!);
        },
      ),
    );
  }
}

class _BusinessDetail extends ConsumerWidget {
  const _BusinessDetail({required this.business});
  final MunicipalBusiness business;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final locale = ref.watch(sessionViewModelProvider).value!.locale;
    final ResolvedLocalizedText? description = business.description?.resolve(
      locale,
    );

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSize.maxContentWidth),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (business.photoUrls.isNotEmpty) ...<Widget>[
                  PhotoGallery(photoUrls: business.photoUrls),
                  const SizedBox(height: AppSpacing.md),
                ],
                Chip(label: Text(prettifyCategorySlug(business.category))),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  business.name,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                if (business.address != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.sm),
                  _InfoRow(icon: Icons.place_outlined, text: business.address!),
                ],
                if (business.schedule != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.xs),
                  _InfoRow(
                    icon: Icons.schedule_outlined,
                    text: business.schedule!,
                  ),
                ],
                if (description != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    description.text,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: <Widget>[
                    if (business.phone != null)
                      _ContactButton(
                        icon: Icons.call_outlined,
                        label: l10n.businessCall,
                        semanticLabel: l10n.businessCallSemantic(
                          business.name,
                          business.phone!,
                        ),
                        onPressed: () =>
                            launchUrl(Uri(scheme: 'tel', path: business.phone)),
                      ),
                    if (business.email != null)
                      _ContactButton(
                        icon: Icons.email_outlined,
                        label: l10n.businessEmail,
                        semanticLabel: l10n.businessEmailSemantic(
                          business.name,
                          business.email!,
                        ),
                        onPressed: () => launchUrl(
                          Uri(scheme: 'mailto', path: business.email),
                        ),
                      ),
                    if (business.website != null)
                      _ContactButton(
                        icon: Icons.public,
                        label: l10n.businessWebsite,
                        semanticLabel: l10n.businessWebsiteSemantic(
                          business.name,
                        ),
                        onPressed: () => launchUrl(
                          Uri.parse(business.website!),
                          mode: LaunchMode.externalApplication,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({
    required this.icon,
    required this.label,
    required this.semanticLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final String semanticLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ExcludeSemantics(child: Icon(icon, size: AppSize.iconSm)),
        const SizedBox(width: AppSpacing.xs),
        Expanded(child: Text(text)),
      ],
    );
  }
}
