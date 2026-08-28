export interface ManagerProps {
  id: string;
  email: string;
  passwordHash: string;
  displayName: string;
}

export class Manager {
  private constructor(private readonly props: ManagerProps) {}

  static create(props: ManagerProps): Manager {
    return new Manager(props);
  }

  get id(): string {
    return this.props.id;
  }

  get email(): string {
    return this.props.email;
  }

  get passwordHash(): string {
    return this.props.passwordHash;
  }

  get displayName(): string {
    return this.props.displayName;
  }
}
