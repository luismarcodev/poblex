import { BroadcastNotifier } from '../../../../shared/infrastructure/notifications/broadcast-notifier.service';
import type { BroadcastParams } from '../../../../shared/infrastructure/notifications/broadcast-notifier.service';
import type { ManagerRepositoryPort } from '../../../managers/domain/ports/manager-repository.port';
import { NewsItem } from '../../domain/entities/news-item.entity';
import { NewsForbiddenError } from '../../domain/errors/news-errors';
import type {
  CreateNewsParams,
  NewsWriterPort,
} from '../../domain/ports/news-writer.port';
import { CreateNewsUseCase } from './create-news.use-case';

const SOLLANA = '11111111-1111-4111-8111-111111111111';
const ALBALAT = '22222222-2222-4222-8222-222222222222';
const FOREIGN = '33333333-3333-4333-8333-333333333333';
const MANAGER_ID = '9a8b7c6d-5e4f-4a3b-9c8d-7e6f5a4b3c2d';

function buildHarness(managedMunicipalities: string[]) {
  let sequence = 0;
  const create = jest
    .fn<Promise<NewsItem>, [CreateNewsParams]>()
    .mockImplementation((params) => {
      sequence += 1;
      return Promise.resolve(
        NewsItem.create({
          id: `news-${sequence}`,
          municipalityId: params.municipalityId,
          title: params.title,
          body: params.body,
          imageUrl: null,
          category: params.category,
          pinned: params.pinned,
          publishedAt: params.publishedAt,
          archived: false,
          attachments: [],
          sourcePlatform: null,
          sourceExternalPostId: null,
        }),
      );
    });
  const writer = { create } as unknown as NewsWriterPort;

  const managers = {
    isManagerOfMunicipality: jest
      .fn()
      .mockImplementation((_managerId: string, municipalityId: string) =>
        Promise.resolve(managedMunicipalities.includes(municipalityId)),
      ),
  } as unknown as ManagerRepositoryPort;

  const broadcast = jest
    .fn<Promise<void>, [BroadcastParams]>()
    .mockResolvedValue(undefined);
  const notifier = { broadcast } as unknown as BroadcastNotifier;

  return {
    useCase: new CreateNewsUseCase(writer, managers, notifier),
    create,
    broadcast,
  };
}

const validInput = {
  managerId: MANAGER_ID,
  title: { es: 'Corte de agua' },
  body: { es: 'Mañana de 9 a 14' },
  category: 'servicios',
};

describe('CreateNewsUseCase', () => {
  it('creates one news item per municipality and broadcasts to each', async () => {
    const { useCase, create, broadcast } = buildHarness([SOLLANA, ALBALAT]);

    const result = await useCase.execute({
      ...validInput,
      municipalityIds: [SOLLANA, ALBALAT],
    });

    expect(result.isSuccess).toBe(true);
    expect(result.isSuccess && result.value).toHaveLength(2);
    expect(create).toHaveBeenCalledTimes(2);
    expect(broadcast).toHaveBeenCalledTimes(2);

    const targets = broadcast.mock.calls.map(
      ([params]) => params.municipalityId,
    );
    expect(targets).toEqual([SOLLANA, ALBALAT]);
    expect(broadcast.mock.calls[0][0].data).toEqual({
      type: 'news',
      id: 'news-1',
      municipalityId: SOLLANA,
    });
    expect(broadcast.mock.calls[1][0].data).toEqual({
      type: 'news',
      id: 'news-2',
      municipalityId: ALBALAT,
    });
  });

  // Publicar en tres de cuatro y fallar en el último dejaría el bando a
  // medias sin forma de saberlo desde el backoffice.
  it('writes nothing when the manager lacks one of the municipalities', async () => {
    const { useCase, create, broadcast } = buildHarness([SOLLANA]);

    const result = await useCase.execute({
      ...validInput,
      municipalityIds: [SOLLANA, FOREIGN],
    });

    expect(result.isFailure && result.error).toBeInstanceOf(NewsForbiddenError);
    expect(create).not.toHaveBeenCalled();
    expect(broadcast).not.toHaveBeenCalled();
  });

  it('shares one publication timestamp across every municipality', async () => {
    const { useCase, create } = buildHarness([SOLLANA, ALBALAT]);

    await useCase.execute({
      ...validInput,
      municipalityIds: [SOLLANA, ALBALAT],
    });

    const [first, second] = create.mock.calls.map((call) => call[0]);
    expect(first.publishedAt.getTime()).toBe(second.publishedAt.getTime());
  });

  it('rejects an invalid municipality id before touching anything', async () => {
    const { useCase, create } = buildHarness([SOLLANA]);

    const result = await useCase.execute({
      ...validInput,
      municipalityIds: ['not-a-uuid'],
    });

    expect(result.isFailure).toBe(true);
    expect(create).not.toHaveBeenCalled();
  });

  it('rejects a news item with no language at all', async () => {
    const { useCase, create } = buildHarness([SOLLANA]);

    const result = await useCase.execute({
      ...validInput,
      title: {},
      municipalityIds: [SOLLANA],
    });

    expect(result.isFailure).toBe(true);
    expect(create).not.toHaveBeenCalled();
  });
});
