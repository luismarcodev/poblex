import { Controller, Get, Param, Query } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { GetBusinessDetailUseCase } from '../../application/use-cases/get-business-detail.use-case';
import { ListBusinessCategoriesUseCase } from '../../application/use-cases/list-business-categories.use-case';
import { ListPublishedBusinessesUseCase } from '../../application/use-cases/list-published-businesses.use-case';
import { BusinessHttpMapper } from '../mappers/business-http.mapper';
import {
  BusinessCategoriesQueryDto,
  BusinessDetailQueryDto,
  ListBusinessesQueryDto,
} from './dto/list-businesses-query.dto';
import { BusinessListResponseDto } from './dto/business-list-response.dto';
import { BusinessResponseDto } from './dto/business-response.dto';

@ApiTags('businesses')
@Controller('businesses')
export class BusinessesController {
  constructor(
    private readonly listPublishedBusinesses: ListPublishedBusinessesUseCase,
    private readonly listBusinessCategories: ListBusinessCategoriesUseCase,
    private readonly getBusinessDetail: GetBusinessDetailUseCase,
  ) {}

  @Get()
  async list(
    @Query() query: ListBusinessesQueryDto,
  ): Promise<BusinessListResponseDto> {
    const result = await this.listPublishedBusinesses.execute({
      municipalityId: query.municipalityId,
      category: query.category,
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

  // DECLARADO ANTES QUE @Get(':id') a propósito: si va después, la ruta con
  // parámetro captura "categories" y responde un 400 de UUID inválido.
  @Get('categories')
  async categories(
    @Query() query: BusinessCategoriesQueryDto,
  ): Promise<{ categories: string[] }> {
    const result = await this.listBusinessCategories.execute(
      query.municipalityId,
    );
    if (result.isFailure) throw result.error;
    return { categories: result.value.map((category) => category.value) };
  }

  @Get(':id')
  async detail(
    @Param('id') id: string,
    @Query() query: BusinessDetailQueryDto,
  ): Promise<BusinessResponseDto> {
    const result = await this.getBusinessDetail.execute(
      id,
      query.municipalityId,
    );
    if (result.isFailure) throw result.error;
    return BusinessHttpMapper.toResponseDto(result.value);
  }
}
