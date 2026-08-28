import { Controller, Get, Param } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { GetActiveMunicipalityByIdUseCase } from '../../application/use-cases/get-active-municipality-by-id.use-case';
import { ListActiveMunicipalitiesUseCase } from '../../application/use-cases/list-active-municipalities.use-case';
import { Municipality } from '../../domain/entities/municipality.entity';
import { MunicipalityResponseDto } from './dto/municipality-response.dto';

function toResponseDto(municipality: Municipality): MunicipalityResponseDto {
  return {
    id: municipality.id.value,
    slug: municipality.slug,
    name: municipality.name,
    province: municipality.province,
    primaryColor: municipality.primaryColor,
    logoUrl: municipality.logoUrl,
    languages: municipality.languages,
  };
}

@ApiTags('municipalities')
@Controller('municipalities')
export class MunicipalitiesController {
  constructor(
    private readonly listActiveMunicipalities: ListActiveMunicipalitiesUseCase,
    private readonly getActiveMunicipalityById: GetActiveMunicipalityByIdUseCase,
  ) {}

  @Get()
  async list(): Promise<MunicipalityResponseDto[]> {
    const result = await this.listActiveMunicipalities.execute();
    if (result.isFailure) throw result.error;
    return result.value.map(toResponseDto);
  }

  @Get(':id')
  async getById(@Param('id') id: string): Promise<MunicipalityResponseDto> {
    const result = await this.getActiveMunicipalityById.execute(id);
    if (result.isFailure) throw result.error;
    return toResponseDto(result.value);
  }
}
