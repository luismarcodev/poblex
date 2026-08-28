import { Controller, Get, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { GetManagerProfileUseCase } from '../../application/use-cases/get-manager-profile.use-case';
import { CurrentManagerId } from './decorators/current-manager-id.decorator';
import { ManagerProfileResponseDto } from './dto/manager-profile.dto';
import { ManagerJwtAuthGuard } from '../security/manager-jwt-auth.guard';

@ApiTags('managers')
@ApiBearerAuth()
@UseGuards(ManagerJwtAuthGuard)
@Controller('admin/me')
export class ManagersProfileController {
  constructor(private readonly getManagerProfile: GetManagerProfileUseCase) {}

  @Get()
  async me(
    @CurrentManagerId() managerId: string,
  ): Promise<ManagerProfileResponseDto> {
    const result = await this.getManagerProfile.execute(managerId);
    if (result.isFailure) throw result.error;

    const { manager, municipalities } = result.value;
    return {
      id: manager.id,
      email: manager.email,
      displayName: manager.displayName,
      municipalities: municipalities.map((municipality) => ({
        id: municipality.id.value,
        slug: municipality.slug,
        name: municipality.name,
        province: municipality.province,
        primaryColor: municipality.primaryColor,
        logoUrl: municipality.logoUrl,
        languages: municipality.languages,
      })),
    };
  }
}
