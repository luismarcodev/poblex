import { Controller, Get, Query } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { DutyPharmacy } from '../../domain/entities/duty-pharmacy.entity';
import {
  GetTodayDutyPharmacyUseCase,
  ListDutyPharmaciesUseCase,
} from '../../application/use-cases/duty-pharmacy.use-cases';
import {
  DutyPharmacyResponseDto,
  ListDutyPharmaciesQueryDto,
  TodayDutyPharmacyQueryDto,
} from './dto/duty-pharmacy.dto';

function toResponseDto(pharmacy: DutyPharmacy): DutyPharmacyResponseDto {
  return {
    id: pharmacy.id,
    municipalityId: pharmacy.municipalityId.value,
    date: pharmacy.date.toISOString().slice(0, 10),
    pharmacyName: pharmacy.pharmacyName,
    address: pharmacy.address,
    phone: pharmacy.phone,
    schedule: pharmacy.schedule,
  };
}

@ApiTags('pharmacies')
@Controller('pharmacies')
export class PharmaciesController {
  constructor(
    private readonly listDutyPharmacies: ListDutyPharmaciesUseCase,
    private readonly getTodayDutyPharmacy: GetTodayDutyPharmacyUseCase,
  ) {}

  @Get('duty')
  async list(
    @Query() query: ListDutyPharmaciesQueryDto,
  ): Promise<DutyPharmacyResponseDto[]> {
    const result = await this.listDutyPharmacies.execute({
      municipalityId: query.municipalityId,
      from: query.from,
      days: query.days,
    });
    if (result.isFailure) throw result.error;
    return result.value.map((pharmacy) => toResponseDto(pharmacy));
  }

  @Get('duty/today')
  async today(
    @Query() query: TodayDutyPharmacyQueryDto,
  ): Promise<DutyPharmacyResponseDto> {
    const result = await this.getTodayDutyPharmacy.execute(
      query.municipalityId,
    );
    if (result.isFailure) throw result.error;
    return toResponseDto(result.value);
  }
}
