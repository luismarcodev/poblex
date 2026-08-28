import type {
  FindPublishedNewsParams,
  NewsListResult,
  NewsReaderPort,
} from '../../domain/ports/news-reader.port';
import { ListPublishedNewsUseCase } from './list-published-news.use-case';

const SOLLANA = '11111111-1111-4111-8111-111111111111';

const emptyResult: NewsListResult = {
  pinned: [],
  items: [],
  nextCursor: null,
};

function buildHarness() {
  const findPublished = jest
    .fn<Promise<NewsListResult>, [FindPublishedNewsParams]>()
    .mockResolvedValue(emptyResult);
  const findArchived = jest
    .fn<Promise<NewsListResult>, [FindPublishedNewsParams]>()
    .mockResolvedValue(emptyResult);

  const reader = { findPublished, findArchived } as unknown as NewsReaderPort;
  return {
    useCase: new ListPublishedNewsUseCase(reader),
    findPublished,
    findArchived,
  };
}

describe('ListPublishedNewsUseCase', () => {
  it('reads the published list by default', async () => {
    const { useCase, findPublished, findArchived } = buildHarness();

    await useCase.execute({ municipalityId: SOLLANA });

    expect(findPublished).toHaveBeenCalledTimes(1);
    expect(findArchived).not.toHaveBeenCalled();
  });

  // El histórico del PRD: las de más de 90 días no desaparecen, cambian de
  // sitio, y el vecino nunca borra nada a mano.
  it('reads the archive when asked for it', async () => {
    const { useCase, findPublished, findArchived } = buildHarness();

    await useCase.execute({ municipalityId: SOLLANA, archived: true });

    expect(findArchived).toHaveBeenCalledTimes(1);
    expect(findPublished).not.toHaveBeenCalled();
  });

  // Filtrar en el servidor, no en la página ya cargada: con paginación por
  // cursor, una categoría que solo aparece en la página 3 daría un "no hay
  // resultados" que es mentira.
  it('passes the category down to the repository', async () => {
    const { useCase, findPublished } = buildHarness();

    await useCase.execute({ municipalityId: SOLLANA, category: 'servicios' });

    expect(findPublished.mock.calls[0][0].category?.value).toBe('servicios');
  });

  it('omits the category filter when none is given', async () => {
    const { useCase, findPublished } = buildHarness();

    await useCase.execute({ municipalityId: SOLLANA });

    expect(findPublished.mock.calls[0][0].category).toBeUndefined();
  });

  it('rejects a category that is not a valid slug', async () => {
    const { useCase, findPublished } = buildHarness();

    const result = await useCase.execute({
      municipalityId: SOLLANA,
      category: 'Servicios Municipales!',
    });

    expect(result.isFailure).toBe(true);
    expect(findPublished).not.toHaveBeenCalled();
  });

  it('rejects a malformed municipality', async () => {
    const { useCase, findPublished } = buildHarness();

    const result = await useCase.execute({ municipalityId: 'not-a-uuid' });

    expect(result.isFailure).toBe(true);
    expect(findPublished).not.toHaveBeenCalled();
  });

  it('clamps the page size to the maximum', async () => {
    const { useCase, findPublished } = buildHarness();

    await useCase.execute({ municipalityId: SOLLANA, limit: 500 });

    expect(findPublished.mock.calls[0][0].limit).toBe(20);
  });
});
