import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiHeader, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { DeviceIdHeader } from '../../../../shared/infrastructure/http/decorators/device-id.decorator';
import { DeviceThrottle } from '../../../../shared/infrastructure/http/decorators/device-throttle.decorator';
import { DeviceThrottlerGuard } from '../../../../shared/infrastructure/http/device-throttler.guard';
import { CancelReservationUseCase } from '../../application/use-cases/cancel-reservation.use-case';
import { CreateReservationUseCase } from '../../application/use-cases/create-reservation.use-case';
import { GetFacilityAvailabilityUseCase } from '../../application/use-cases/get-facility-availability.use-case';
import { GetFacilityUseCase } from '../../application/use-cases/get-facility.use-case';
import { ListFacilitiesUseCase } from '../../application/use-cases/list-facilities.use-case';
import { ListMyReservationsUseCase } from '../../application/use-cases/list-my-reservations.use-case';
import { FacilityHttpMapper } from '../mappers/facility-http.mapper';
import { ReservationHttpMapper } from '../mappers/reservation-http.mapper';
import {
  FacilityAvailabilityQueryDto,
  ListFacilitiesQueryDto,
} from './dto/facility.dto';
import {
  FacilityAvailabilityResponseDto,
  FacilityListResponseDto,
  FacilityResponseDto,
} from './dto/facility-response.dto';
import {
  CreateReservationDto,
  ListMyReservationsQueryDto,
} from './dto/reservation.dto';
import {
  ReservationListResponseDto,
  ReservationResponseDto,
} from './dto/reservation-response.dto';

@ApiTags('facilities')
@Controller('facilities')
export class FacilitiesController {
  constructor(
    private readonly listFacilities: ListFacilitiesUseCase,
    private readonly getFacility: GetFacilityUseCase,
    private readonly getFacilityAvailability: GetFacilityAvailabilityUseCase,
  ) {}

  @Get()
  async list(
    @Query() query: ListFacilitiesQueryDto,
  ): Promise<FacilityListResponseDto> {
    const result = await this.listFacilities.execute({
      municipalityId: query.municipalityId,
      category: query.category,
      onlyActive: true,
    });
    if (result.isFailure) throw result.error;
    return {
      items: result.value.map((facility) =>
        FacilityHttpMapper.toResponseDto(facility),
      ),
    };
  }

  @Get(':id')
  async detail(@Param('id') id: string): Promise<FacilityResponseDto> {
    const result = await this.getFacility.execute(id);
    if (result.isFailure) throw result.error;
    return FacilityHttpMapper.toResponseDto(result.value);
  }

  @Get(':id/availability')
  async availability(
    @Param('id') id: string,
    @Query() query: FacilityAvailabilityQueryDto,
  ): Promise<FacilityAvailabilityResponseDto> {
    const result = await this.getFacilityAvailability.execute({
      facilityId: id,
      date: query.date,
    });
    if (result.isFailure) throw result.error;
    return {
      slots: result.value.slots.map((slot) =>
        FacilityHttpMapper.toSlotDto(slot),
      ),
    };
  }
}

@ApiTags('reservations')
@ApiHeader({ name: 'X-Device-Id', required: true })
@Controller('reservations')
export class ReservationsController {
  constructor(
    private readonly createReservation: CreateReservationUseCase,
    private readonly listMyReservations: ListMyReservationsUseCase,
    private readonly cancelReservation: CancelReservationUseCase,
  ) {}

  // Mismo umbral que incidencias: 5 por dispositivo y hora, 20 por IP y
  // hora — punto de partida, a ajustar con datos reales de uso.
  @UseGuards(DeviceThrottlerGuard)
  @Throttle({ default: { limit: 20, ttl: 3_600_000 } })
  @DeviceThrottle({ limit: 5, ttl: 3_600_000 })
  @Post()
  async create(
    @DeviceIdHeader() deviceId: string | undefined,
    @Body() dto: CreateReservationDto,
  ): Promise<ReservationResponseDto> {
    const result = await this.createReservation.execute({
      facilityId: dto.facilityId,
      deviceId: deviceId ?? '',
      slotStart: new Date(dto.slotStart).toISOString(),
    });
    if (result.isFailure) throw result.error;
    return ReservationHttpMapper.toResponseDto(result.value);
  }

  @Get()
  async listMine(
    @DeviceIdHeader() deviceId: string | undefined,
    @Query() query: ListMyReservationsQueryDto,
  ): Promise<ReservationListResponseDto> {
    const result = await this.listMyReservations.execute(
      deviceId,
      query.cursor,
      query.limit,
    );
    if (result.isFailure) throw result.error;
    return {
      items: result.value.items.map((reservation) =>
        ReservationHttpMapper.toResponseDto(reservation),
      ),
      nextCursor: result.value.nextCursor,
    };
  }

  @Post(':id/cancel')
  async cancel(
    @Param('id') id: string,
    @DeviceIdHeader() deviceId: string | undefined,
  ): Promise<{ cancelled: true }> {
    const result = await this.cancelReservation.execute({
      reservationId: id,
      deviceId: deviceId ?? '',
    });
    if (result.isFailure) throw result.error;
    return { cancelled: true };
  }
}
