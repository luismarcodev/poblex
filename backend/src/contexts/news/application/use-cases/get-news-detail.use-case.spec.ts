import { LocalizedText } from '../../../../shared/domain/value-objects/localized-text';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { NewsItem } from '../../domain/entities/news-item.entity';
import { NewsNotFoundError } from '../../domain/errors/news-errors';
import type { NewsReaderPort } from '../../domain/ports/news-reader.port';
import { NewsCategory } from '../../domain/value-objects/news-category.vo';
import { GetNewsDetailUseCase } from './get-news-detail.use-case';

const SOLLANA = '11111111-1111-4111-8111-111111111111';
const ALBALAT = '22222222-2222-4222-8222-222222222222';

function buildNews(): NewsItem {
  return NewsItem.create({
    id: 'news-1',
    municipalityId: MunicipalityId.create(SOLLANA),
    title: LocalizedText.create({ es: 'Corte de agua' }),
    body: LocalizedText.create({ es: 'Mañana de 9 a 14' }),
    imageUrl: null,
    category: NewsCategory.create('servicios'),
    pinned: false,
    publishedAt: new Date('2026-08-01T00:00:00Z'),
    archived: false,
    attachments: [],
    sourcePlatform: null,
    sourceExternalPostId: null,
  });
}

function buildHarness(stored: NewsItem | null) {
  // El doble se comporta como la base de datos: solo devuelve la noticia si
  // el municipio pedido coincide con el suyo.
  const findByIdPublished = jest
    .fn<Promise<NewsItem | null>, [string, MunicipalityId]>()
    .mockImplementation((_id, municipalityId) =>
      Promise.resolve(
        stored && stored.municipalityId.value === municipalityId.value
          ? stored
          : null,
      ),
    );

  const reader = { findByIdPublished } as unknown as NewsReaderPort;
  return { useCase: new GetNewsDetailUseCase(reader), findByIdPublished };
}

describe('GetNewsDetailUseCase', () => {
  it('returns the news item of its own municipality', async () => {
    const { useCase } = buildHarness(buildNews());

    const result = await useCase.execute('news-1', SOLLANA);

    expect(result.isSuccess).toBe(true);
  });

  // Regla innegociable: ninguna consulta se escribe sin filtrar por municipio.
  it('passes the municipality down to the repository', async () => {
    const { useCase, findByIdPublished } = buildHarness(buildNews());

    await useCase.execute('news-1', SOLLANA);

    expect(findByIdPublished.mock.calls[0][1].value).toBe(SOLLANA);
  });

  // Se responde NO ENCONTRADA y no PROHIBIDA: confirmar que existe contenido
  // de otro municipio ya es filtrar información.
  it('hides a news item that belongs to another municipality', async () => {
    const { useCase } = buildHarness(buildNews());

    const result = await useCase.execute('news-1', ALBALAT);

    expect(result.isFailure && result.error).toBeInstanceOf(NewsNotFoundError);
  });

  it('fails when the news item does not exist', async () => {
    const { useCase } = buildHarness(null);

    const result = await useCase.execute('missing', SOLLANA);

    expect(result.isFailure && result.error).toBeInstanceOf(NewsNotFoundError);
  });

  it('rejects a malformed municipality without hitting the repository', async () => {
    const { useCase, findByIdPublished } = buildHarness(buildNews());

    const result = await useCase.execute('news-1', 'not-a-uuid');

    expect(result.isFailure).toBe(true);
    expect(findByIdPublished).not.toHaveBeenCalled();
  });
});
