import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../l10n/app_localizations.dart';
import '../viewmodels/password_recovery_view_models.dart';
import '../widgets/auth_card_scaffold.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final recovery = ref.watch(forgotPasswordViewModelProvider);
    final completed = recovery.valueOrNull?.completed ?? false;

    return AuthCardScaffold(
      child: completed
          ? _EmailSentContent(onBack: () => context.go('/acceso'))
          : Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ExcludeSemantics(
                    child: Icon(
                      Icons.mark_email_read_outlined,
                      size: 56,
                      color: context.semantic.brandGraphic,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.forgotPasswordTitle,
                    textAlign: TextAlign.center,
                    style: context.text.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.forgotPasswordSubtitle,
                    textAlign: TextAlign.center,
                    style: context.text.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: l10n.emailLabel,
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.requiredField;
                      }
                      return RegExp(
                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                          ).hasMatch(value.trim())
                          ? null
                          : l10n.invalidEmail;
                    },
                  ),
                  if (recovery.hasError) ...[
                    const SizedBox(height: AppSpacing.md),
                    _RecoveryError(failure: recovery.error),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  FilledButton.icon(
                    onPressed: recovery.isLoading ? null : _submit,
                    icon: recovery.isLoading
                        ? const SizedBox.square(
                            dimension: 24,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          )
                        : const Icon(Icons.send_outlined),
                    label: Text(l10n.sendResetLinkButton),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: recovery.isLoading
                        ? null
                        : () => context.go('/acceso'),
                    child: Text(l10n.backToLoginButton),
                  ),
                ],
              ),
            ),
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ref.read(forgotPasswordViewModelProvider.notifier).submit(_email.text);
  }
}

class _EmailSentContent extends StatelessWidget {
  const _EmailSentContent({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExcludeSemantics(
          child: Icon(
            Icons.outgoing_mail,
            size: 56,
            color: context.semantic.brandGraphic,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Semantics(
          liveRegion: true,
          header: true,
          child: Text(
            l10n.resetEmailSentTitle,
            textAlign: TextAlign.center,
            style: context.text.headlineMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.resetEmailSentMessage,
          textAlign: TextAlign.center,
          style: context.text.bodyLarge,
        ),
        const SizedBox(height: AppSpacing.xl),
        FilledButton(onPressed: onBack, child: Text(l10n.backToLoginButton)),
      ],
    );
  }
}

class _RecoveryError extends StatelessWidget {
  const _RecoveryError({required this.failure});

  final Object? failure;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      liveRegion: true,
      child: Text(
        failure is NetworkFailure ? l10n.networkError : l10n.genericError,
        style: context.text.bodyLarge?.copyWith(color: context.colors.error),
      ),
    );
  }
}
