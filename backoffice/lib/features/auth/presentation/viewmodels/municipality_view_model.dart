import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/session/auth_session.dart';
import '../../domain/entities/manager_profile.dart';

final selectedMunicipalityProvider =
    NotifierProvider.autoDispose<
      SelectedMunicipalityViewModel,
      ManagedMunicipality
    >(SelectedMunicipalityViewModel.new);

class SelectedMunicipalityViewModel
    extends AutoDisposeNotifier<ManagedMunicipality> {
  @override
  ManagedMunicipality build() {
    final municipalities = getIt<AuthSession>().profile?.municipalities;
    if (municipalities == null || municipalities.isEmpty) {
      throw StateError('Authenticated manager has no municipalities');
    }
    return municipalities.first;
  }

  void select(ManagedMunicipality municipality) {
    state = municipality;
  }
}
