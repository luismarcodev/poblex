import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { CurrentManagerId } from '../../../managers/infrastructure/http/decorators/current-manager-id.decorator';
import { ManagerJwtAuthGuard } from '../../../managers/infrastructure/security/manager-jwt-auth.guard';
import { CancelReservationAsManagerUseCase } from '../../application/use-cases/cancel-reservation-as-manager.use-case';
import { CreateFacilityUseCase } from '../../application/use-cases/create-facility.use-case';
import { ListFacilitiesUseCase } from '../../application/use-cases/list-facilities.use-case';
import { ListManagedReservationsUseCase } from '../../application/use-cases/list-managed-reservations.use-case';
import { UpdateFacilityUseCase } from '../../application/use-cases/update-facility.use-case';
import { FacilityHttpMapper } from '../mappers/facility-http.mapper';
import { ReservationHttpMapper } from '../mappers/reservation-http.mapper';
import { CreateFacilityDto, UpdateFacilityDto } from './dto/facility.dto';
import {
  FacilityListResponseDto,
  FacilityResponseDto,
} from './dto/facility-response.dto';
import {
  CancelReservationAsManagerDto,
  ListManagedReservationsQueryDto,
} from './dto/reservation.dto';
import { ReservationListResponseDto } from './dto/reservation-response.dto';

@ApiTags('facilities-admin')
@ApiBearerAuth()
@UseGuards(ManagerJwtAuthGuard)
@Controller('admin/facilities')
export class FacilitiesAdminController {
  constructor(
    private readonly listFacilities: ListFacilitiesUseCase,
    private readonly createFacility: CreateFacilityUseCase,
    private readonly updateFacility: UpdateFacilityUseCase,
  ) {}

  @Get()
  async list(
    @Query('municipalityId') municipalityId: string,
  ): Promise<FacilityListResponseDto> {
    const result = await this.listFacilities.execute({
      municipalityId,
      onlyActive: false,
    });
    if (result.isFailure) throw result.error;
    return {
      items: result.value.map((facility) =>
        FacilityHttpMapper.toResponseDto(facility),
      ),
    };
  }

  @Post()
  async create(
    @CurrentManagerId() managerId: string,
    @Body() dto: CreateFacilityDto,
  ): Promise<FacilityResponseDto> {
    const result = await this.createFacility.execute({
      managerId,
      municipalityId: dto.municipalityId,
      name: dto.name,
      description: dto.description,
      category: dto.category,
      imageUrl: dto.imageUrl,
      slotDurationMinutes: dto.slotDurationMinutes,
      openingHours: dto.openingHours,
      feeNote: dto.feeNote,
      maxAdvanceBookingDays: dto.maxAdvanceBookingDays ?? 14,
    });
    if (result.isFailure) throw result.error;
    return FacilityHttpMapper.toResponseDto(result.value);
  }

  @Patch(':id')
  async update(
    @CurrentManagerId() managerId: string,
    @Param('id') id: string,
    @Body() dto: UpdateFacilityDto,
  ): Promise<FacilityResponseDto> {
    const result = await this.updateFacility.execute({
      facilityId: id,
      managerId,
      name: dto.name,
      description: dto.description,
      category: dto.category,
      imageUrl: dto.imageUrl,
      slotDurationMinutes: dto.slotDurationMinutes,
      openingHours: dto.openingHours,
      feeNote: dto.feeNote,
      maxAdvanceBookingDays: dto.maxAdvanceBookingDays,
      active: dto.active,
    });
    if (result.isFailure) throw result.error;
    return FacilityHttpMapper.toResponseDto(result.value);
  }
}

@ApiTags('reservations-admin')
@ApiBearerAuth()
@UseGuards(ManagerJwtAuthGuard)
@Controller('admin/reservations')
export class ReservationsAdminController {
  constructor(
    private readonly listManagedReservations: ListManagedReservationsUseCase,
    private readonly cancelReservationAsManager: CancelReservationAsManagerUseCase,
  ) {}

  @Get()
  async list(
    @Query() query: ListManagedReservationsQueryDto,
  ): Promise<ReservationListResponseDto> {
    const result = await this.listManagedReservations.execute({
      municipalityId: query.municipalityId,
      facilityId: query.facilityId,
      cursor: query.cursor,
      limit: query.limit,
    });
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
    @CurrentManagerId() managerId: string,
    @Param('id') id: string,
    @Body() dto: CancelReservationAsManagerDto,
  ): Promise<{ cancelled: true }> {
    const result = await this.cancelReservationAsManager.execute({
      reservationId: id,
      managerId,
      note: dto.note,
    });
    if (result.isFailure) throw result.error;
    return { cancelled: true };
  }
}
