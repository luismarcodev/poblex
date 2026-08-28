import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:poblex_design_system/poblex_design_system.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/duty_pharmacy.dart';

class PharmacyCard extends StatelessWidget {
  const PharmacyCard({
    required this.pharmacy,
    required this.showDate,
    super.key,
  });

  final DutyPharmacy pharmacy;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (showDate) ...<Widget>[
              Text(
                DateFormat.yMMMEd(
                  Localizations.localeOf(context).toLanguageTag(),
                ).format(pharmacy.date.toLocal()),
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
            Text(
              pharmacy.pharmacyName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const ExcludeSemantics(
                  child: Icon(Icons.place_outlined, size: AppSize.iconSm),
                ),
                const SizedBox(width: AppSpacing.xxs),
                Expanded(child: Text(pharmacy.address)),
              ],
            ),
            const SizedBox(height: AppSpacing.xxs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const ExcludeSemantics(
                  child: Icon(Icons.schedule_outlined, size: AppSize.iconSm),
                ),
                const SizedBox(width: AppSpacing.xxs),
                Expanded(child: Text(pharmacy.schedule)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Semantics(
              button: true,
              label: l10n.pharmacyCallSemantic(
                pharmacy.pharmacyName,
                pharmacy.phone,
              ),
              child: OutlinedButton.icon(
                onPressed: () => _call(pharmacy.phone),
                icon: const Icon(Icons.call_outlined),
                label: Text('${l10n.pharmacyCall} · ${pharmacy.phone}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _call(String phone) async {
    final Uri uri = Uri(scheme: 'tel', path: phone);
    await launchUrl(uri);
  }
}
