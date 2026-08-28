import { Survey } from '../../domain/entities/survey.entity';
import type { SurveyOptionTally } from '../../domain/ports/survey-reader.port';
import { SurveyResponseDto } from '../http/dto/survey-response.dto';

export class SurveyHttpMapper {
  static toResponseDto(
    survey: Survey,
    tallies: SurveyOptionTally[] | null,
    votedOptionId: string | null,
  ): SurveyResponseDto {
    const now = new Date();

    return {
      id: survey.id,
      municipalityId: survey.municipalityId.value,
      question: survey.question.toJSON(),
      closesAt: survey.closesAt.toISOString(),
      isOpen: survey.isOpenAt(now),
      // Sin verificación de empadronamiento, las encuestas se etiquetan
      // visiblemente como NO vinculantes. El flag viaja en la respuesta para
      // que el cliente no pueda "olvidarse" de mostrarlo.
      binding: false,
      options: survey.options.map((option) => ({
        id: option.id,
        label: option.label.toJSON(),
        position: option.position,
        votes: tallies
          ? (tallies.find((tally) => tally.optionId === option.id)?.votes ?? 0)
          : null,
      })),
      votedOptionId,
    };
  }
}
