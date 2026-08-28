import { Controller, Get, Param, Query } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { GetNewsDetailUseCase } from '../../application/use-cases/get-news-detail.use-case';
import { ListNewsCategoriesUseCase } from '../../application/use-cases/list-news-categories.use-case';
import { ListPublishedNewsUseCase } from '../../application/use-cases/list-published-news.use-case';
import { NewsHttpMapper } from '../mappers/news-http.mapper';
import {
  ListNewsQueryDto,
  NewsCategoriesQueryDto,
  NewsDetailQueryDto,
} from './dto/list-news-query.dto';
import { NewsListResponseDto } from './dto/news-list-response.dto';
import { NewsResponseDto } from './dto/news-response.dto';

@ApiTags('news')
@Controller('news')
export class NewsController {
  constructor(
    private readonly listPublishedNews: ListPublishedNewsUseCase,
    private readonly listNewsCategories: ListNewsCategoriesUseCase,
    private readonly getNewsDetail: GetNewsDetailUseCase,
  ) {}

  @Get()
  async list(@Query() query: ListNewsQueryDto): Promise<NewsListResponseDto> {
    const result = await this.listPublishedNews.execute({
      municipalityId: query.municipalityId,
      category: query.category,
      cursor: query.cursor,
      limit: query.limit,
    });
    if (result.isFailure) throw result.error;

    return {
      pinned: result.value.pinned.map((news) =>
        NewsHttpMapper.toResponseDto(news),
      ),
      items: result.value.items.map((news) =>
        NewsHttpMapper.toResponseDto(news),
      ),
      nextCursor: result.value.nextCursor,
    };
  }

  // Histórico del vecino. DECLARADO ANTES QUE @Get(':id') a propósito: si va
  // después, la ruta con parámetro captura "archive" y responde un 400 de
  // UUID inválido que cuesta una tarde entender.
  @Get('archive')
  async archive(
    @Query() query: ListNewsQueryDto,
  ): Promise<NewsListResponseDto> {
    const result = await this.listPublishedNews.execute({
      municipalityId: query.municipalityId,
      category: query.category,
      cursor: query.cursor,
      limit: query.limit,
      archived: true,
    });
    if (result.isFailure) throw result.error;

    return {
      pinned: [],
      items: result.value.items.map((news) =>
        NewsHttpMapper.toResponseDto(news),
      ),
      nextCursor: result.value.nextCursor,
    };
  }

  // Igual que 'archive': antes que @Get(':id').
  @Get('categories')
  async categories(
    @Query() query: NewsCategoriesQueryDto,
  ): Promise<{ categories: string[] }> {
    const result = await this.listNewsCategories.execute(query.municipalityId);
    if (result.isFailure) throw result.error;
    return { categories: result.value.map((category) => category.value) };
  }

  @Get(':id')
  async detail(
    @Param('id') id: string,
    @Query() query: NewsDetailQueryDto,
  ): Promise<NewsResponseDto> {
    const result = await this.getNewsDetail.execute(id, query.municipalityId);
    if (result.isFailure) throw result.error;
    return NewsHttpMapper.toResponseDto(result.value);
  }
}
