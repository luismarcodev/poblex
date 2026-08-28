import type {
  Survey as PrismaSurvey,
  SurveyOption as PrismaSurveyOption,
} from '@prisma/client';
import { LocalizedText } from '../../../../../shared/domain/value-objects/localized-text';
import { MunicipalityId } from '../../../../../shared/domain/value-objects/municipality-id';
import { Survey, SurveyOption } from '../../../domain/entities/survey.entity';

export type PrismaSurveyWithOptions = PrismaSurvey & {
  options: PrismaSurveyOption[];
};

interface RawLocalizedJson {
  es?: string;
  va?: string;
}

export class SurveyMapper {
  static toDomain(row: PrismaSurveyWithOptions): Survey {
    return Survey.create({
      id: row.id,
      municipalityId: MunicipalityId.create(row.municipalityId),
      question: LocalizedText.create(row.question as RawLocalizedJson),
      closesAt: row.closesAt,
      resultsVisible: row.resultsVisible,
      options: [...row.options]
        .sort((left, right) => left.position - right.position)
        .map((option) =>
          SurveyOption.create({
            id: option.id,
            label: LocalizedText.create(option.label as RawLocalizedJson),
            position: option.position,
          }),
        ),
    });
  }
}
