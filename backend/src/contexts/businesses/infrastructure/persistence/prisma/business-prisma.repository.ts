import { Injectable } from '@nestjs/common';
import { MunicipalityId } from '../../../../../shared/domain/value-objects/municipality-id';
import { Prisma } from '../../../../../shared/infrastructure/prisma/prisma-client';
import { PrismaService } from '../../../../../shared/infrastructure/prisma/prisma.service';
import { Business } from '../../../domain/entities/business.entity';
import { BusinessPhoto } from '../../../domain/entities/business-photo.entity';
import { BusinessCategory } from '../../../domain/value-objects/business-category.vo';
import type {
  BusinessListResult,
  BusinessReaderPort,
  FindManagedBusinessesParams,
  FindPublishedBusinessesParams,
} from '../../../domain/ports/business-reader.port';
import type {
  BusinessWriterPort,
  CreateBusinessParams,
  CreateBusinessPhotoParams,
  UpdateBusinessFields,
} from '../../../domain/ports/business-writer.port';
import { BusinessMapper, PrismaBusinessWithPhotos } from './business.mapper';

const PHOTOS_INCLUDE = { photos: { orderBy: { position: 'asc' as const } } };

function encodeCursor(createdAt: Date, id: string): string {
  return Buffer.from(`${createdAt.toISOString()}|${id}`).toString('base64url');
}

function decodeCursor(cursor: string): { createdAt: Date; id: string } {
  const [iso, id] = Buffer.from(cursor, 'base64url')
    .toString('utf-8')
    .split('|');
  return { createdAt: new Date(iso), id };
}

// Orden descendente por fecha de alta con el id como desempate estable.
function buildCursorFilter(cursor?: string) {
  if (!cursor) return {};
  const { createdAt, id } = decodeCursor(cursor);
  return {
    OR: [{ createdAt: { lt: createdAt } }, { createdAt, id: { lt: id } }],
  };
}

// Se pide una fila de más que el límite: si llega, hay página siguiente.
function paginate(
  rows: PrismaBusinessWithPhotos[],
  limit: number,
): { rows: PrismaBusinessWithPhotos[]; nextCursor: string | null } {
  const hasMore = rows.length > limit;
  const pageRows = hasMore ? rows.slice(0, limit) : rows;
  const lastRow = pageRows[pageRows.length - 1];

  return {
    rows: pageRows,
    nextCursor:
      hasMore && lastRow ? encodeCursor(lastRow.createdAt, lastRow.id) : null,
  };
}

@Injectable()
export class BusinessPrismaRepository
  implements BusinessReaderPort, BusinessWriterPort
{
  constructor(private readonly prisma: PrismaService) {}

  async findPublished(
    params: FindPublishedBusinessesParams,
  ): Promise<BusinessListResult> {
    const rows: PrismaBusinessWithPhotos[] =
      await this.prisma.business.findMany({
        where: {
          municipalityId: params.municipalityId.value,
          active: true,
          category: params.category?.value,
          ...buildCursorFilter(params.cursor),
        },
        include: PHOTOS_INCLUDE,
        orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
        take: params.limit + 1,
      });

    const page = paginate(rows, params.limit);

    return {
      items: page.rows.map((row) => BusinessMapper.toDomain(row)),
      nextCursor: page.nextCursor,
    };
  }

  async findForManager(
    params: FindManagedBusinessesParams,
  ): Promise<BusinessListResult> {
    const rows: PrismaBusinessWithPhotos[] =
      await this.prisma.business.findMany({
        where: {
          municipalityId: params.municipalityId.value,
          active: params.includeInactive ? undefined : true,
          ...buildCursorFilter(params.cursor),
        },
        include: PHOTOS_INCLUDE,
        orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
        take: params.limit + 1,
      });

    const page = paginate(rows, params.limit);

    return {
      items: page.rows.map((row) => BusinessMapper.toDomain(row)),
      nextCursor: page.nextCursor,
    };
  }

  async findByIdPublished(
    id: string,
    municipalityId: MunicipalityId,
  ): Promise<Business | null> {
    // findFirst y no findUnique: el municipio forma parte del filtro, y un
    // comercio de otro pueblo tiene que salir como inexistente.
    const row = await this.prisma.business.findFirst({
      where: { id, municipalityId: municipalityId.value, active: true },
      include: PHOTOS_INCLUDE,
    });
    return row ? BusinessMapper.toDomain(row) : null;
  }

  async findCategories(
    municipalityId: MunicipalityId,
  ): Promise<BusinessCategory[]> {
    const rows = await this.prisma.business.findMany({
      where: { municipalityId: municipalityId.value, active: true },
      select: { category: true },
      distinct: ['category'],
      orderBy: { category: 'asc' },
    });
    return rows.map((row) => BusinessCategory.create(row.category));
  }

  // Lectura de gestión: sin filtro de municipio porque quien llama ya ha
  // comprobado la autorización con AuthorizeBusinessMutationService, que
  // necesita leer el comercio justamente para saber a qué municipio pertenece.
  async findAdminById(id: string): Promise<Business | null> {
    const row = await this.prisma.business.findUnique({
      where: { id },
      include: PHOTOS_INCLUDE,
    });
    return row ? BusinessMapper.toDomain(row) : null;
  }

  async create(params: CreateBusinessParams): Promise<Business> {
    const row = await this.prisma.business.create({
      data: {
        municipalityId: params.municipalityId.value,
        name: params.name,
        category: params.category.value,
        // Prisma.DbNull, no plain null: description es una columna jsonb
        // nullable y el cliente exige el sentinel explícito para NULL real.
        description: params.description
          ? (params.description.toJSON() as Prisma.InputJsonValue)
          : Prisma.DbNull,
        address: params.address,
        phone: params.phone,
        email: params.email,
        website: params.website,
        schedule: params.schedule,
      },
      include: PHOTOS_INCLUDE,
    });
    return BusinessMapper.toDomain(row);
  }

  async update(id: string, fields: UpdateBusinessFields): Promise<Business> {
    const row = await this.prisma.business.update({
      where: { id },
      data: {
        name: fields.name,
        category: fields.category?.value,
        description:
          fields.description === undefined
            ? undefined
            : fields.description === null
              ? Prisma.DbNull
              : (fields.description.toJSON() as Prisma.InputJsonValue),
        address: fields.address,
        phone: fields.phone,
        email: fields.email,
        website: fields.website,
        schedule: fields.schedule,
      },
      include: PHOTOS_INCLUDE,
    });
    return BusinessMapper.toDomain(row);
  }

  async setActive(id: string, active: boolean): Promise<Business> {
    const row = await this.prisma.business.update({
      where: { id },
      data: { active },
      include: PHOTOS_INCLUDE,
    });
    return BusinessMapper.toDomain(row);
  }

  async delete(id: string): Promise<void> {
    // Las fotos-fila caen por ON DELETE CASCADE; los objetos R2 ya se han
    // purgado en el caso de uso antes de llegar aquí.
    await this.prisma.business.delete({ where: { id } });
  }

  async addPhoto(
    businessId: string,
    photo: CreateBusinessPhotoParams,
  ): Promise<BusinessPhoto> {
    const row = await this.prisma.$transaction(async (tx) => {
      const position = await tx.businessPhoto.count({ where: { businessId } });
      return tx.businessPhoto.create({
        data: {
          businessId,
          url: photo.url,
          mimeType: photo.mimeType,
          position,
        },
      });
    });
    return BusinessMapper.photoToDomain(row);
  }

  async findPhotoById(
    businessId: string,
    photoId: string,
  ): Promise<BusinessPhoto | null> {
    const row = await this.prisma.businessPhoto.findFirst({
      where: { id: photoId, businessId },
    });
    return row ? BusinessMapper.photoToDomain(row) : null;
  }

  async deletePhoto(photoId: string): Promise<void> {
    await this.prisma.businessPhoto.delete({ where: { id: photoId } });
  }

  async reorderPhotos(
    businessId: string,
    orderedPhotoIds: string[],
  ): Promise<void> {
    // La pertenencia del set completo de ids a businessId ya se validó en el
    // caso de uso (ReorderBusinessPhotosUseCase) contra la lista real de
    // fotos del comercio, así que aquí basta con el id único de cada fila.
    await this.prisma.$transaction(
      orderedPhotoIds.map((id, index) =>
        this.prisma.businessPhoto.update({
          where: { id },
          data: { position: index },
        }),
      ),
    );
  }
}
