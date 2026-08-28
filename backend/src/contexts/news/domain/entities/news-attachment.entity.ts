export interface NewsAttachmentProps {
  id: string;
  name: string;
  url: string;
  mimeType: string;
}

export class NewsAttachment {
  private constructor(private readonly props: NewsAttachmentProps) {}

  static create(props: NewsAttachmentProps): NewsAttachment {
    return new NewsAttachment(props);
  }

  get id(): string {
    return this.props.id;
  }

  get name(): string {
    return this.props.name;
  }

  get url(): string {
    return this.props.url;
  }

  get mimeType(): string {
    return this.props.mimeType;
  }
}
