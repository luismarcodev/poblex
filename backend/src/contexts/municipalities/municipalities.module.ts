import { Module } from '@nestjs/common';
import { GetActiveMunicipalityByIdUseCase } from './application/use-cases/get-active-municipality-by-id.use-case';
import { ListActiveMunicipalitiesUseCase } from './application/use-cases/list-active-municipalities.use-case';
import { MUNICIPALITY_READER_PORT } from './domain/ports/municipality-reader.port';
import { MunicipalityPrismaRepository } from './infrastructure/persistence/prisma/municipality-prisma.repository';
import { MunicipalitiesController } from './infrastructure/http/municipalities.controller';

@Module({
  controllers: [MunicipalitiesController],
  providers: [
    ListActiveMunicipalitiesUseCase,
    GetActiveMunicipalityByIdUseCase,
    {
      provide: MUNICIPALITY_READER_PORT,
      useClass: MunicipalityPrismaRepository,
    },
  ],
  // El contexto de alertas necesita leer los municipios con zona AEMET para
  // la tarea de sincronización.
  exports: [GetActiveMunicipalityByIdUseCase, MUNICIPALITY_READER_PORT],
})
export class MunicipalitiesModule {}
