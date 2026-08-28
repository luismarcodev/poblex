import { Inject, Injectable } from '@nestjs/common';
import { Result } from '../../../../shared/domain/result';
import { BusinessPhoto } from '../../domain/entities/business-photo.entity';
import { BUSINESS_WRITER_PORT } from '../../domain/ports/business-writer.port';
import type { BusinessWriterPort } from '../../domain/ports/business-writer.port';
import { AuthorizeBusinessMutationService } from '../services/authorize-business-mutation.service';

export interface ConfirmBusinessPhotoInput {
  businessId: string;
  managerId: string;
  url: string;
  mimeType: string;
}

@Injectable()
export class ConfirmBusinessPhotoUseCase {
  constructor(
    @Inject(BUSINESS_WRITER_PORT) private readonly writer: BusinessWriterPort,
    private readonly authorize: AuthorizeBusinessMutationService,
  ) {}

  async execute(
    input: ConfirmBusinessPhotoInput,
  ): Promise<Result<BusinessPhoto>> {
    const authResult = await this.authorize.ensureMutable(
      input.businessId,
      input.managerId,
    );
    if (authResult.isFailure) return Result.failure(authResult.error);

    // La posición (orden de galería) la calcula el repositorio dentro de una
    // transacción count+create, no se expone aquí.
    const photo = await this.writer.addPhoto(input.businessId, {
      url: input.url,
      mimeType: input.mimeType,
    });
    return Result.success(photo);
  }
}
