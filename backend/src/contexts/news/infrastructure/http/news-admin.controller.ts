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
import { ConfirmNewsAttachmentUseCase } from '../../application/use-cases/confirm-news-attachment.use-case';
import { CreateNewsUseCase } from '../../application/use-cases/create-news.use-case';
import { GetManagedNewsDetailUseCase } from '../../application/use-cases/get-managed-news-detail.use-case';
import {
  DeleteNewsUseCase,
  ListManagedNewsUseCase,
  SetNewsArchivedUseCase,
} from '../../application/use-cases/manage-news.use-cases';
import { RequestNewsAttachmentUploadUrlUseCase } from '../../application/use-cases/request-news-attachment-upload-url.use-case';
import { ToggleNewsPinUseCase } from '../../application/use-cases/toggle-news-pin.use-case';
import { UpdateNewsUseCase } from '../../application/use-cases/update-news.use-case';
import { NewsHttpMapper } from '../mappers/news-http.mapper';
import { ConfirmAttachmentDto } from './dto/confirm-attachment.dto';
import { CreateNewsDto } from './dto/create-news.dto';
import {
  ListManagedNewsQueryDto,
  SetArchivedDto,
} from './dto/list-managed-news-query.dto';
import {
  ManagedNewsResponseDto,
  NewsAttachmentResponseDto,
  NewsResponseDto,
} from './dto/news-response.dto';
import {
  PresignedUploadRequestDto,
  PresignedUploadResponseDto,
} from './dto/presigned-upload.dto';
import { TogglePinDto } from './dto/toggle-pin.dto';
import { UpdateNewsDto } from './dto/update-news.dto';

@ApiTags('news-admin')
@ApiBearerAuth()
@UseGuards(ManagerJwtAuthGuard)
@Controller('admin/news')
export class NewsAdminController {
  constructor(
    private readonly createNews: CreateNewsUseCase,
    private readonly getManagedNewsDetail: GetManagedNewsDetailUseCase,
    private readonly updateNews: UpdateNewsUseCase,
    private readonly toggleNewsPin: ToggleNewsPinUseCase,
    private readonly requestUploadUrl: RequestNewsAttachmentUploadUrlUseCase,
    private readonly confirmAttachment: ConfirmNewsAttachmentUseCase,
    private readonly listManagedNews: ListManagedNewsUseCase,
    private readonly setNewsArchived: SetNewsArchivedUseCase,
    private readonly deleteNews: DeleteNewsUseCase,
  ) {}

  @Get(':id')
  async detail(
    @CurrentManagerId() managerId: string,
    @Param('id') id: string,
  ): Promise<ManagedNewsResponseDto> {
    const result = await this.getManagedNewsDetail.execute(id, managerId);
    if (result.isFailure) throw result.error;
    return NewsHttpMapper.toManagedResponseDto(result.value);
  }

  @Get()
  async list(
    @CurrentManagerId() managerId: string,
    @Query() query: ListManagedNewsQueryDto,
  ): Promise<{ items: ManagedNewsResponseDto[]; nextCursor: string | null }> {
    const result = await this.listManagedNews.execute({
      managerId,
      municipalityId: query.municipalityId,
      includeArchived: query.includeArchived,
      cursor: query.cursor,
      limit: query.limit,
    });
    if (result.isFailure) throw result.error;

    return {
      items: result.value.items.map((news) =>
        NewsHttpMapper.toManagedResponseDto(news),
      ),
      nextCursor: result.value.nextCursor,
    };
  }

  @Patch(':id/archived')
  async setArchived(
    @CurrentManagerId() managerId: string,
    @Param('id') id: string,
    @Body() dto: SetArchivedDto,
  ): Promise<NewsResponseDto> {
    const result = await this.setNewsArchived.execute(
      id,
      managerId,
      dto.archived,
    );
    if (result.isFailure) throw result.error;
    return NewsHttpMapper.toResponseDto(result.value);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async remove(
    @CurrentManagerId() managerId: string,
    @Param('id') id: string,
  ): Promise<void> {
    const result = await this.deleteNews.execute(id, managerId);
    if (result.isFailure) throw result.error;
  }

  // Devuelve una noticia POR MUNICIPIO: publicar en varios crea una entrada
  // independiente en cada uno, con su propio identificador y sus adjuntos.
  @Post()
  async create(
    @CurrentManagerId() managerId: string,
    @Body() dto: CreateNewsDto,
  ): Promise<NewsResponseDto[]> {
    const result = await this.createNews.execute({
      managerId,
      municipalityIds: dto.municipalityIds,
      title: dto.title,
      body: dto.body,
      category: dto.category,
      imageUrl: dto.imageUrl,
      pinned: dto.pinned,
      shareToChannels: dto.shareToChannels,
    });
    if (result.isFailure) throw result.error;
    return result.value.map((news) => NewsHttpMapper.toResponseDto(news));
  }

  @Patch(':id')
  async update(
    @CurrentManagerId() managerId: string,
    @Param('id') id: string,
    @Body() dto: UpdateNewsDto,
  ): Promise<NewsResponseDto> {
    const result = await this.updateNews.execute({
      id,
      managerId,
      title: dto.title,
      body: dto.body,
      category: dto.category,
      imageUrl: dto.imageUrl,
    });
    if (result.isFailure) throw result.error;
    return NewsHttpMapper.toResponseDto(result.value);
  }

  @Patch(':id/pin')
  async togglePin(
    @CurrentManagerId() managerId: string,
    @Param('id') id: string,
    @Body() dto: TogglePinDto,
  ): Promise<NewsResponseDto> {
    const result = await this.toggleNewsPin.execute({
      id,
      managerId,
      pinned: dto.pinned,
    });
    if (result.isFailure) throw result.error;
    return NewsHttpMapper.toResponseDto(result.value);
  }

  @Post(':id/attachments/upload-url')
  async requestAttachmentUploadUrl(
    @CurrentManagerId() managerId: string,
    @Param('id') id: string,
    @Body() dto: PresignedUploadRequestDto,
  ): Promise<PresignedUploadResponseDto> {
    const result = await this.requestUploadUrl.execute({
      newsId: id,
      managerId,
      fileName: dto.fileName,
      contentType: dto.contentType,
    });
    if (result.isFailure) throw result.error;
    return result.value;
  }

  @Post(':id/attachments')
  async confirmAttachmentUpload(
    @CurrentManagerId() managerId: string,
    @Param('id') id: string,
    @Body() dto: ConfirmAttachmentDto,
  ): Promise<NewsAttachmentResponseDto> {
    const result = await this.confirmAttachment.execute({
      newsId: id,
      managerId,
      name: dto.name,
      url: dto.url,
      mimeType: dto.mimeType,
    });
    if (result.isFailure) throw result.error;
    return result.value;
  }
}
