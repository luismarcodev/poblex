import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { CurrentManagerId } from '../../../managers/infrastructure/http/decorators/current-manager-id.decorator';
import { ManagerJwtAuthGuard } from '../../../managers/infrastructure/security/manager-jwt-auth.guard';
import { ConfirmBusinessPhotoUseCase } from '../../application/use-cases/confirm-business-photo.use-case';
import { CreateBusinessUseCase } from '../../application/use-cases/create-business.use-case';
import { DeleteBusinessPhotoUseCase } from '../../application/use-cases/delete-business-photo.use-case';
import { GetManagedBusinessDetailUseCase } from '../../application/use-cases/get-managed-business-detail.use-case';
import {
  DeleteBusinessUseCase,
  ListManagedBusinessesUseCase,
  SetBusinessActiveUseCase,
} from '../../application/use-cases/manage-businesses.use-cases';
import { ReorderBusinessPhotosUseCase } from '../../application/use-cases/reorder-business-photos.use-case';
import { RequestBusinessPhotoUploadUrlUseCase } from '../../application/use-cases/request-business-photo-upload-url.use-case';
import { UpdateBusinessUseCase } from '../../application/use-cases/update-business.use-case';
import { BusinessHttpMapper } from '../mappers/business-http.mapper';
import { BusinessResponseDto } from './dto/business-response.dto';
import { ConfirmPhotoDto } from './dto/confirm-photo.dto';
import { CreateBusinessDto } from './dto/create-business.dto';
import {
  ListManagedBusinessesQueryDto,
  SetActiveDto,
} from './dto/list-managed-businesses-query.dto';
import {
  PresignedPhotoUploadRequestDto,
  PresignedPhotoUploadResponseDto,
} from './dto/presigned-photo-upload.dto';
import { ReorderPhotosDto } from './dto/reorder-photos.dto';
import { UpdateBusinessDto } from './dto/update-business.dto';

@ApiTags('businesses-admin')
@ApiBearerAuth()
@UseGuards(ManagerJwtAuthGuard)
@Controller('admin/businesses')
export class BusinessesAdminController {
  constructor(
    private readonly createBusiness: CreateBusinessUseCase,
    private readonly getManagedBusinessDetail: GetManagedBusinessDetailUseCase,
    private readonly updateBusiness: UpdateBusinessUseCase,
    private readonly listManagedBusinesses: ListManagedBusinessesUseCase,
    private readonly setBusinessActive: SetBusinessActiveUseCase,
    private readonly deleteBusiness: DeleteBusinessUseCase,
    private readonly requestPhotoUpload: RequestBusinessPhotoUploadUrlUseCase,
    private readonly confirmPhoto: ConfirmBusinessPhotoUseCase,
    private readonly deleteBusinessPhoto: DeleteBusinessPhotoUseCase,
    private readonly reorderBusinessPhotos: ReorderBusinessPhotosUseCase,
  ) {}

  @Get(':id')
  async detail(
    @CurrentManagerId() managerId: string,
    @Param('id') id: string,
  ): Promise<BusinessResponseDto> {
    const result = await this.getManagedBusinessDetail.execute(id, managerId);
    if (result.isFailure) throw result.error;
    return BusinessHttpMapper.toResponseDto(result.value);
  }

  @Get()
  async list(
    @CurrentManagerId() managerId: string,
    @Query() query: ListManagedBusinessesQueryDto,
  ): Promise<{ items: BusinessResponseDto[]; nextCursor: string | null }> {
    const result = await this.listManagedBusinesses.execute({
      managerId,
      municipalityId: query.municipalityId,
      includeInactive: query.includeInactive,
      cursor: query.cursor,
      limit: query.limit,
    });
    if (result.isFailure) throw result.error;

    return {
      items: result.value.items.map((business) =>
        BusinessHttpMapper.toResponseDto(business),
      ),
      nextCursor: result.value.nextCursor,
    };
  }

  @Post()
  async create(
    @CurrentManagerId() managerId: string,
    @Body() dto: CreateBusinessDto,
  ): Promise<BusinessResponseDto> {
    const result = await this.createBusiness.execute({
      managerId,
      municipalityId: dto.municipalityId,
      name: dto.name,
      category: dto.category,
      description: dto.description,
      address: dto.address,
      phone: dto.phone,
      email: dto.email,
      website: dto.website,
      schedule: dto.schedule,
    });
    if (result.isFailure) throw result.error;
    return BusinessHttpMapper.toResponseDto(result.value);
  }

  @Patch(':id')
  async update(
    @CurrentManagerId() managerId: string,
    @Param('id') id: string,
    @Body() dto: UpdateBusinessDto,
  ): Promise<BusinessResponseDto> {
    const result = await this.updateBusiness.execute({
      id,
      managerId,
      name: dto.name,
      category: dto.category,
      description: dto.description,
      address: dto.address,
      phone: dto.phone,
      email: dto.email,
      website: dto.website,
      schedule: dto.schedule,
    });
    if (result.isFailure) throw result.error;
    return BusinessHttpMapper.toResponseDto(result.value);
  }

  @Patch(':id/active')
  async setActive(
    @CurrentManagerId() managerId: string,
    @Param('id') id: string,
    @Body() dto: SetActiveDto,
  ): Promise<BusinessResponseDto> {
    const result = await this.setBusinessActive.execute(
      id,
      managerId,
      dto.active,
    );
    if (result.isFailure) throw result.error;
    return BusinessHttpMapper.toResponseDto(result.value);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async remove(
    @CurrentManagerId() managerId: string,
    @Param('id') id: string,
  ): Promise<void> {
    const result = await this.deleteBusiness.execute(id, managerId);
    if (result.isFailure) throw result.error;
  }

  @Post(':id/photos/upload-url')
  async requestPhotoUploadUrl(
    @CurrentManagerId() managerId: string,
    @Param('id') id: string,
    @Body() dto: PresignedPhotoUploadRequestDto,
  ): Promise<PresignedPhotoUploadResponseDto> {
    const result = await this.requestPhotoUpload.execute({
      businessId: id,
      managerId,
      fileName: dto.fileName,
      contentType: dto.contentType,
    });
    if (result.isFailure) throw result.error;
    return result.value;
  }

  @Post(':id/photos')
  async confirmPhotoUpload(
    @CurrentManagerId() managerId: string,
    @Param('id') id: string,
    @Body() dto: ConfirmPhotoDto,
  ): Promise<BusinessResponseDto> {
    const result = await this.confirmPhoto.execute({
      businessId: id,
      managerId,
      url: dto.url,
      mimeType: dto.mimeType,
    });
    if (result.isFailure) throw result.error;

    const detail = await this.getManagedBusinessDetail.execute(id, managerId);
    if (detail.isFailure) throw detail.error;
    return BusinessHttpMapper.toResponseDto(detail.value);
  }

  @Delete(':id/photos/:photoId')
  @HttpCode(HttpStatus.NO_CONTENT)
  async removePhoto(
    @CurrentManagerId() managerId: string,
    @Param('id') id: string,
    @Param('photoId') photoId: string,
  ): Promise<void> {
    const result = await this.deleteBusinessPhoto.execute({
      businessId: id,
      photoId,
      managerId,
    });
    if (result.isFailure) throw result.error;
  }

  @Patch(':id/photos/order')
  async reorderPhotos(
    @CurrentManagerId() managerId: string,
    @Param('id') id: string,
    @Body() dto: ReorderPhotosDto,
  ): Promise<BusinessResponseDto> {
    const result = await this.reorderBusinessPhotos.execute({
      businessId: id,
      managerId,
      orderedPhotoIds: dto.orderedPhotoIds,
    });
    if (result.isFailure) throw result.error;
    return BusinessHttpMapper.toResponseDto(result.value);
  }
}
