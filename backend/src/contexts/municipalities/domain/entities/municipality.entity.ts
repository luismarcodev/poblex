import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';

export interface MunicipalityProps {
  id: MunicipalityId;
  slug: string;
  name: string;
  province: string;
  // Código de zona de avisos de AEMET. Null = el municipio no tiene
  // sincronización meteorológica configurada todavía.
  aemetZoneCode: string | null;
  primaryColor: string | null;
  logoUrl: string | null;
  languages: string[];
  active: boolean;
}

export class Municipality {
  private constructor(private readonly props: MunicipalityProps) {}

  static create(props: MunicipalityProps): Municipality {
    return new Municipality(props);
  }

  get id(): MunicipalityId {
    return this.props.id;
  }

  get slug(): string {
    return this.props.slug;
  }

  get name(): string {
    return this.props.name;
  }

  get province(): string {
    return this.props.province;
  }

  get aemetZoneCode(): string | null {
    return this.props.aemetZoneCode;
  }

  get primaryColor(): string | null {
    return this.props.primaryColor;
  }

  get logoUrl(): string | null {
    return this.props.logoUrl;
  }

  get languages(): string[] {
    return this.props.languages;
  }

  get active(): boolean {
    return this.props.active;
  }
}
