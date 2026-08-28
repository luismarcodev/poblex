import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  Query,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ApiBody, ApiConsumes, ApiHeader, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { ValidationError } from '../../../../shared/domain/errors/common-errors';
import { DeviceIdHeader } from '../../../../shared/infrastructure/http/decorators/device-id.decorator';
import { DeviceThrottle } from '../../../../shared/infrastructure/http/decorators/device-throttle.decorator';
import { DeviceThrottlerGuard } from '../../../../shared/infrastructure/http/device-throttler.guard';
import { MAX_IMAGE_BYTES } from '../../../../shared/infrastructure/storage/image-validation';
import { GetMyIncidentDetailUseCase } from '../../application/use-cases/get-my-incident-detail.use-case';
import { ListMyIncidentsUseCase } from '../../application/use-cases/list-my-incidents.use-case';
import { ReportIncidentUseCase } from '../../application/use-cases/report-incident.use-case';
import { UploadIncidentPhotoUseCase } from '../../application/use-cases/upload-incident-photo.use-case';
import { IncidentHttpMapper } from '../mappers/incident-http.mapper';
import {
  IncidentDetailResponseDto,
  IncidentListResponseDto,
  IncidentResponseDto,
} from './dto/incident-response.dto';
import {
  ListMyIncidentsQueryDto,
  ReportIncidentDto,
} from './dto/report-incident.dto';

// Multer sin @types/multer: solo se usan estos dos campos del fichero subido,
// así que se tipan a mano en vez de añadir una dependencia de tipos.
interface UploadedImage {
  buffer: Buffer;
}

@ApiTags('incidents')
@ApiHeader({ name: 'X-Device-Id', required: true })
@Controller('incidents')
export class IncidentsController {
  constructor(
    private readonly reportIncident: ReportIncidentUseCase,
    private readonly uploadIncidentPhoto: UploadIncidentPhotoUseCase,
    private readonly listMyIncidents: ListMyIncidentsUseCase,
    private readonly getMyIncidentDetail: GetMyIncidentDetailUseCase,
  ) {}

  // Máximo 5 incidencias por dispositivo y hora. Umbral de partida: hay que
  // ajustarlo con datos reales de uso, no a ojo.
  @UseGuards(DeviceThrottlerGuard)
  @Throttle({ default: { limit: 20, ttl: 3_600_000 } })
  @DeviceThrottle({ limit: 5, ttl: 3_600_000 })
  @Post()
  async report(
    @DeviceIdHeader() deviceId: string | undefined,
    @Body() dto: ReportIncidentDto,
  ): Promise<IncidentResponseDto> {
    const result = await this.reportIncident.execute({
      deviceId,
      municipalityId: dto.municipalityId,
      category: dto.category,
      description: dto.description,
      lat: dto.lat,
      lng: dto.lng,
    });
    if (result.isFailure) throw result.error;
    return IncidentHttpMapper.toResponseDto(result.value);
  }

  @UseGuards(DeviceThrottlerGuard)
  @Throttle({ default: { limit: 20, ttl: 3_600_000 } })
  @DeviceThrottle({ limit: 5, ttl: 3_600_000 })
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      properties: { photo: { type: 'string', format: 'binary' } },
    },
  })
  @Post(':id/photo')
  @UseInterceptors(
    FileInterceptor('photo', { limits: { fileSize: MAX_IMAGE_BYTES } }),
  )
  async uploadPhoto(
    @Param('id') id: string,
    @DeviceIdHeader() deviceId: string | undefined,
    @UploadedFile() file: UploadedImage | undefined,
  ): Promise<IncidentResponseDto> {
    if (!file) {
      throw new ValidationError('Missing photo file');
    }

    const result = await this.uploadIncidentPhoto.execute({
      incidentId: id,
      deviceId,
      bytes: file.buffer,
    });
    if (result.isFailure) throw result.error;
    return IncidentHttpMapper.toResponseDto(result.value);
  }

  @Get()
  async listMine(
    @DeviceIdHeader() deviceId: string | undefined,
    @Query() query: ListMyIncidentsQueryDto,
  ): Promise<IncidentListResponseDto> {
    const result = await this.listMyIncidents.execute(
      deviceId,
      query.cursor,
      query.limit,
    );
    if (result.isFailure) throw result.error;

    return {
      items: result.value.items.map((incident) =>
        IncidentHttpMapper.toResponseDto(incident),
      ),
      nextCursor: result.value.nextCursor,
    };
  }

  @Get(':id')
  async detail(
    @Param('id') id: string,
    @DeviceIdHeader() deviceId: string | undefined,
  ): Promise<IncidentDetailResponseDto> {
    const result = await this.getMyIncidentDetail.execute(id, deviceId);
    if (result.isFailure) throw result.error;

    return {
      ...IncidentHttpMapper.toResponseDto(result.value.incident),
      history: result.value.history.map((change) =>
        IncidentHttpMapper.toStatusChangeDto(change),
      ),
    };
  }
}
