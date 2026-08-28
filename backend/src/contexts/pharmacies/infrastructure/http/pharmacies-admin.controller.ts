import { Body, Controller, Put, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { CurrentManagerId } from '../../../managers/infrastructure/http/decorators/current-manager-id.decorator';
import { ManagerJwtAuthGuard } from '../../../managers/infrastructure/security/manager-jwt-auth.guard';
import { UpsertDutyPharmacyUseCase } from '../../application/use-cases/duty-pharmacy.use-cases';
import {
  DutyPharmacyResponseDto,
  UpsertDutyPharmacyDto,
} from './dto/duty-pharmacy.dto';

@ApiTags('pharmacies-admin')
@ApiBearerAuth()
@UseGuards(ManagerJwtAuthGuard)
@Controller('admin/pharmacies')
export class PharmaciesAdminController {
  constructor(private readonly upsertDutyPharmacy: UpsertDutyPharmacyUseCase) {}

  // PUT y no POST: la guardia de un día es única (UNIQUE municipality_id +
  // date), así que la operación es idempotente por diseño.
  @Put('duty')
  async upsert(
    @CurrentManagerId() managerId: string,
    @Body() dto: UpsertDutyPharmacyDto,
  ): Promise<DutyPharmacyResponseDto> {
    const result = await this.upsertDutyPharmacy.execute({
      managerId,
      municipalityId: dto.municipalityId,
      date: dto.date,
      pharmacyName: dto.pharmacyName,
      address: dto.address,
      phone: dto.phone,
      schedule: dto.schedule,
    });
    if (result.isFailure) throw result.error;

    const pharmacy = result.value;
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
}
