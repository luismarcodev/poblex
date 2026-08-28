import '../../../../shared/domain/value_objects/localized_text.dart';
import '../../domain/entities/business.dart';
import '../models/business_model.dart';

abstract final class BusinessMapper {
  static MunicipalBusiness toDomain(BusinessModel model) => MunicipalBusiness(
    id: model.id,
    municipalityId: model.municipalityId,
    name: model.name,
    category: model.category,
    description: model.description == null
        ? null
        : LocalizedText(es: model.description!.es, va: model.description!.va),
    address: model.address,
    phone: model.phone,
    email: model.email,
    website: model.website,
    schedule: model.schedule,
    photoUrls: model.photoUrls,
  );
}
