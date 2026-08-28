import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/result/result.dart';
import '../../domain/usecases/business_usecases.dart';

/// Alimenta el autocompletado de categoría del editor con las que el
/// municipio ya usa. Un fallo aquí no bloquea el formulario — el campo sigue
/// siendo de texto libre, solo se pierden las sugerencias.
final businessCategoriesProvider = FutureProvider.autoDispose
    .family<List<String>, String>((ref, municipalityId) async {
      final result = await getIt<GetBusinessCategories>()(municipalityId);
      return switch (result) {
        Success(value: final categories) => categories,
        Failure() => const <String>[],
      };
    });
