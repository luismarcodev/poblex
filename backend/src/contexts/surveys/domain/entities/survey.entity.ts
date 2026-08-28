import { ValidationError } from '../../../../shared/domain/errors/common-errors';
import { LocalizedText } from '../../../../shared/domain/value-objects/localized-text';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';

export interface SurveyOptionProps {
  id: string;
  label: LocalizedText;
  position: number;
}

export class SurveyOption {
  private constructor(private readonly props: SurveyOptionProps) {}

  static create(props: SurveyOptionProps): SurveyOption {
    return new SurveyOption(props);
  }

  get id(): string {
    return this.props.id;
  }

  get label(): LocalizedText {
    return this.props.label;
  }

  get position(): number {
    return this.props.position;
  }
}

export interface SurveyProps {
  id: string;
  municipalityId: MunicipalityId;
  question: LocalizedText;
  closesAt: Date;
  resultsVisible: boolean;
  options: SurveyOption[];
}

const MIN_OPTIONS = 2;

export class Survey {
  private constructor(private readonly props: SurveyProps) {}

  static create(props: SurveyProps): Survey {
    // Una encuesta con una sola opción no es una encuesta.
    if (props.options.length < MIN_OPTIONS) {
      throw new ValidationError(
        `A survey requires at least ${MIN_OPTIONS} options`,
      );
    }
    return new Survey(props);
  }

  // Regla de negocio en el dominio: una encuesta cerrada no admite votos.
  isOpenAt(instant: Date): boolean {
    return this.props.closesAt.getTime() > instant.getTime();
  }

  hasOption(optionId: string): boolean {
    return this.props.options.some((option) => option.id === optionId);
  }

  // Los resultados se ven si el gestor los hizo visibles o si la encuesta ya
  // cerró: enseñar el recuento en vivo puede condicionar el voto.
  areResultsVisibleAt(instant: Date): boolean {
    return this.props.resultsVisible || !this.isOpenAt(instant);
  }

  get id(): string {
    return this.props.id;
  }

  get municipalityId(): MunicipalityId {
    return this.props.municipalityId;
  }

  get question(): LocalizedText {
    return this.props.question;
  }

  get closesAt(): Date {
    return this.props.closesAt;
  }

  get resultsVisible(): boolean {
    return this.props.resultsVisible;
  }

  get options(): SurveyOption[] {
    return this.props.options;
  }
}
