export interface BusinessPhotoProps {
  id: string;
  url: string;
  mimeType: string;
  position: number;
}

export class BusinessPhoto {
  private constructor(private readonly props: BusinessPhotoProps) {}

  static create(props: BusinessPhotoProps): BusinessPhoto {
    return new BusinessPhoto(props);
  }

  get id(): string {
    return this.props.id;
  }

  get url(): string {
    return this.props.url;
  }

  get mimeType(): string {
    return this.props.mimeType;
  }

  get position(): number {
    return this.props.position;
  }
}
