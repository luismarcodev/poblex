import { ValidationError } from '../../../../shared/domain/errors/common-errors';
import { LocalizedText } from '../../../../shared/domain/value-objects/localized-text';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { Survey, SurveyOption, SurveyProps } from './survey.entity';

const MUNICIPALITY_ID = '4f6c9d2e-1a3b-4c5d-8e9f-0a1b2c3d4e5f';

function option(id: string, label: string, position: number): SurveyOption {
  return SurveyOption.create({
    id,
    label: LocalizedText.create({ es: label }),
    position,
  });
}

function buildProps(overrides: Partial<SurveyProps> = {}): SurveyProps {
  return {
    id: 'survey-1',
    municipalityId: MunicipalityId.create(MUNICIPALITY_ID),
    question: LocalizedText.create({ es: '¿Paella en la plaza?' }),
    closesAt: new Date('2026-06-01T00:00:00Z'),
    resultsVisible: false,
    options: [option('a', 'Sí', 0), option('b', 'No', 1)],
    ...overrides,
  };
}

describe('Survey', () => {
  it('rejects a survey with fewer than two options', () => {
    expect(() =>
      Survey.create(buildProps({ options: [option('a', 'Sí', 0)] })),
    ).toThrow(ValidationError);
  });

  // Regla de negocio: una encuesta cerrada no admite votos.
  it('is open only before its closing date', () => {
    const survey = Survey.create(buildProps());

    expect(survey.isOpenAt(new Date('2026-05-31T23:59:00Z'))).toBe(true);
    expect(survey.isOpenAt(new Date('2026-06-01T00:00:00Z'))).toBe(false);
  });

  it('recognises only its own options', () => {
    const survey = Survey.create(buildProps());

    expect(survey.hasOption('a')).toBe(true);
    expect(survey.hasOption('zzz')).toBe(false);
  });

  describe('areResultsVisibleAt', () => {
    // Enseñar el recuento en vivo condiciona el voto.
    it('hides results while open if the manager kept them hidden', () => {
      const survey = Survey.create(buildProps({ resultsVisible: false }));

      expect(survey.areResultsVisibleAt(new Date('2026-05-01T00:00:00Z'))).toBe(
        false,
      );
    });

    it('shows results once the survey has closed', () => {
      const survey = Survey.create(buildProps({ resultsVisible: false }));

      expect(survey.areResultsVisibleAt(new Date('2026-06-02T00:00:00Z'))).toBe(
        true,
      );
    });

    it('shows results while open when the manager made them visible', () => {
      const survey = Survey.create(buildProps({ resultsVisible: true }));

      expect(survey.areResultsVisibleAt(new Date('2026-05-01T00:00:00Z'))).toBe(
        true,
      );
    });
  });
});
