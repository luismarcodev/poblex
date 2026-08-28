import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../viewmodels/password_recovery_view_models.dart';
import '../widgets/auth_card_scaffold.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({required this.token, super.key});

  final String token;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;

  @override
  void dispose() {
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final token = widget.token.trim();
    if (token.isEmpty) {
      return AuthCardScaffold(
        child: _InvalidLinkContent(onBack: () => context.go('/acceso')),
      );
    }

    final recovery = ref.watch(resetPasswordViewModelProvider(token));
    final completed = recovery.valueOrNull?.completed ?? false;
    return AuthCardScaffold(
      child: completed
          ? _PasswordResetContent(onBack: () => context.go('/acceso'))
          : Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ExcludeSemantics(
                    child: Icon(
                      Icons.lock_reset_outlined,
                      size: 56,
                      color: context.semantic.brandGraphic,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.resetPasswordTitle,
                    textAlign: TextAlign.center,
                    style: context.text.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.resetPasswordSubtitle,
                    textAlign: TextAlign.center,
                    style: context.text.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  _PasswordField(
                    controller: _password,
                    label: l10n.newPasswordLabel,
                    obscureText: _obscurePassword,
                    tooltip: _obscurePassword
                        ? l10n.showPassword
                        : l10n.hidePassword,
                    onToggleVisibility: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.requiredField;
                      }
                      return value.length < minimumManagerPasswordLength
                          ? l10n.passwordMinLength
                          : null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _PasswordField(
                    controller: _confirmation,
                    label: l10n.confirmPasswordLabel,
                    obscureText: _obscureConfirmation,
                    tooltip: _obscureConfirmation
                        ? l10n.showPassword
                        : l10n.hidePassword,
                    onToggleVisibility: () => setState(
                      () => _obscureConfirmation = !_obscureConfirmation,
                    ),
                    onFieldSubmitted: (_) => _submit(token),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.requiredField;
                      }
                      return value != _password.text
                          ? l10n.passwordsDoNotMatch
                          : null;
                    },
                  ),
                  if (recovery.hasError) ...[
                    const SizedBox(height: AppSpacing.md),
                    _ResetError(failure: recovery.error),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  FilledButton.icon(
                    onPressed: recovery.isLoading ? null : () => _submit(token),
                    icon: recovery.isLoading
                        ? const SizedBox.square(
                            dimension: 24,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          )
                        : const Icon(Icons.lock_reset_outlined),
                    label: Text(l10n.resetPasswordButton),
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

  void _submit(String token) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ref
        .read(resetPasswordViewModelProvider(token).notifier)
        .submit(_password.text);
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.obscureText,
    required this.tooltip,
    required this.onToggleVisibility,
    required this.validator,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final String tooltip;
  final VoidCallback onToggleVisibility;
  final FormFieldValidator<String> validator;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    obscureText: obscureText,
    autofillHints: const [AutofillHints.newPassword],
    textInputAction: onFieldSubmitted == null
        ? TextInputAction.next
        : TextInputAction.done,
    onFieldSubmitted: onFieldSubmitted,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: const Icon(Icons.lock_outline),
      suffixIcon: IconButton(
        tooltip: tooltip,
        onPressed: onToggleVisibility,
        icon: Icon(
          obscureText
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
        ),
      ),
    ),
    validator: validator,
  );
}

class _ResetError extends StatelessWidget {
  const _ResetError({required this.failure});

  final Object? failure;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final message = switch (failure) {
      NetworkFailure() => l10n.networkError,
      ValidationFailure() ||
      UnauthorizedFailure() ||
      NotFoundFailure() => l10n.invalidOrExpiredResetLink,
      _ => l10n.genericError,
    };
    return Semantics(
      liveRegion: true,
      child: Text(
        message,
        style: context.text.bodyLarge?.copyWith(color: context.colors.error),
      ),
    );
  }
}

class _InvalidLinkContent extends StatelessWidget {
  const _InvalidLinkContent({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.link_off, size: 56, color: context.colors.error),
        const SizedBox(height: AppSpacing.lg),
        Semantics(
          liveRegion: true,
          child: Text(
            l10n.invalidOrExpiredResetLink,
            textAlign: TextAlign.center,
            style: context.text.headlineSmall,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        FilledButton(onPressed: onBack, child: Text(l10n.backToLoginButton)),
      ],
    );
  }
}

class _PasswordResetContent extends StatelessWidget {
  const _PasswordResetContent({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExcludeSemantics(
          child: Icon(
            Icons.check_circle_outline,
            size: 56,
            color: context.semantic.success,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Semantics(
          liveRegion: true,
          header: true,
          child: Text(
            l10n.passwordResetSuccessTitle,
            textAlign: TextAlign.center,
            style: context.text.headlineMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.passwordResetSuccessMessage,
          textAlign: TextAlign.center,
          style: context.text.bodyLarge,
        ),
        const SizedBox(height: AppSpacing.xl),
        FilledButton(onPressed: onBack, child: Text(l10n.backToLoginButton)),
      ],
    );
  }
}
