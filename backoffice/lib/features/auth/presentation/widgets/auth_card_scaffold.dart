import 'package:flutter/material.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

class AuthCardScaffold extends StatelessWidget {
  const AuthCardScaffold({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 420;
          return Center(
            child: SingleChildScrollView(
              padding: AppSpacing.screenPadding,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(
                      compact ? AppSpacing.lg : AppSpacing.xxl,
                    ),
                    child: child,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}
