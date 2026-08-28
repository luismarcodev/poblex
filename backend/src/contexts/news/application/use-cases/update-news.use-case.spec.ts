import { Result } from '../../../../shared/domain/result';
import { LocalizedText } from '../../../../shared/domain/value-objects/localized-text';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { NewsItem } from '../../domain/entities/news-item.entity';
import type {
  NewsWriterPort,
  UpdateNewsFields,
} from '../../domain/ports/news-writer.port';
import { NewsCategory } from '../../domain/value-objects/news-category.vo';
import type { AuthorizeNewsMutationService } from '../services/authorize-news-mutation.service';
import { UpdateNewsUseCase } from './update-news.use-case';

const NEWS_ID = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
const MANAGER_ID = 'manager-1';
const IMAGE_URL = 'https://cdn.example/news/current.webp';

function newsWithImage(imageUrl: string | null): NewsItem {
  return NewsItem.create({
    id: NEWS_ID,
    municipalityId: MunicipalityId.create(
      '11111111-1111-4111-8111-111111111111',
    ),
    title: LocalizedText.create({ es: 'Noticia' }),
    body: LocalizedText.create({ es: 'Contenido' }),
    imageUrl,
    category: NewsCategory.create('general'),
    pinned: false,
    publishedAt: new Date('2026-08-10T10:00:00.000Z'),
    archived: false,
    attachments: [],
    sourcePlatform: null,
    sourceExternalPostId: null,
  });
}

function buildHarness() {
  const existing = newsWithImage(IMAGE_URL);
  const update = jest
    .fn<Promise<NewsItem>, [string, UpdateNewsFields]>()
    .mockImplementation((_id, fields) =>
      Promise.resolve(
        newsWithImage(
          fields.imageUrl === undefined ? existing.imageUrl : fields.imageUrl,
        ),
      ),
    );
  const writer = { update } as unknown as NewsWriterPort;
  const authorize = {
    ensureMutable: jest.fn().mockResolvedValue(Result.success(existing)),
  } as unknown as AuthorizeNewsMutationService;

  return { useCase: new UpdateNewsUseCase(writer, authorize), update };
}

describe('UpdateNewsUseCase image patch', () => {
  it('passes null to persistence to remove an existing image', async () => {
    const { useCase, update } = buildHarness();

    const result = await useCase.execute({
      id: NEWS_ID,
      managerId: MANAGER_ID,
      imageUrl: null,
    });

    expect(result.isSuccess).toBe(true);
    expect(result.isSuccess && result.value.imageUrl).toBeNull();
    expect(update).toHaveBeenCalledWith(
      NEWS_ID,
      expect.objectContaining({ imageUrl: null }),
    );
  });

  it('passes undefined when the image field is omitted', async () => {
    const { useCase, update } = buildHarness();

    const result = await useCase.execute({
      id: NEWS_ID,
      managerId: MANAGER_ID,
      title: { es: 'Título actualizado' },
    });

    expect(result.isSuccess).toBe(true);
    expect(result.isSuccess && result.value.imageUrl).toBe(IMAGE_URL);
    expect(update).toHaveBeenCalledWith(
      NEWS_ID,
      expect.objectContaining({ imageUrl: undefined }),
    );
  });
});
