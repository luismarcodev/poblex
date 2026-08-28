import { Inject, Injectable } from '@nestjs/common';
import { Result } from '../../../../shared/domain/result';
import { toCsv } from '../../../../shared/infrastructure/http/csv';
import { Survey } from '../../domain/entities/survey.entity';
import { SURVEY_READER_PORT } from '../../domain/ports/survey-reader.port';
import type { SurveyReaderPort } from '../../domain/ports/survey-reader.port';
import { SURVEY_WRITER_PORT } from '../../domain/ports/survey-writer.port';
import type { SurveyWriterPort } from '../../domain/ports/survey-writer.port';
import { AuthorizeSurveyMutationService } from '../services/authorize-survey-mutation.service';

// Cerrar una encuesta es adelantar su fecha de cierre a ahora: a partir de
// ese instante no admite votos, sin necesidad de un estado aparte.
@Injectable()
export class CloseSurveyUseCase {
  constructor(
    @Inject(SURVEY_WRITER_PORT) private readonly writer: SurveyWriterPort,
    private readonly authorize: AuthorizeSurveyMutationService,
  ) {}

  async execute(id: string, managerId: string): Promise<Result<Survey>> {
    const authorized = await this.authorize.ensureMutable(id, managerId);
    if (authorized.isFailure) return Result.failure(authorized.error);

    const closed = await this.writer.close(id, new Date());
    return Result.success(closed);
  }
}

@Injectable()
export class SetSurveyResultsVisibilityUseCase {
  constructor(
    @Inject(SURVEY_WRITER_PORT) private readonly writer: SurveyWriterPort,
    private readonly authorize: AuthorizeSurveyMutationService,
  ) {}

  async execute(
    id: string,
    managerId: string,
    visible: boolean,
  ): Promise<Result<Survey>> {
    const authorized = await this.authorize.ensureMutable(id, managerId);
    if (authorized.isFailure) return Result.failure(authorized.error);

    const updated = await this.writer.setResultsVisible(id, visible);
    return Result.success(updated);
  }
}

@Injectable()
export class DeleteSurveyUseCase {
  constructor(
    @Inject(SURVEY_WRITER_PORT) private readonly writer: SurveyWriterPort,
    private readonly authorize: AuthorizeSurveyMutationService,
  ) {}

  async execute(id: string, managerId: string): Promise<Result<void>> {
    const authorized = await this.authorize.ensureMutable(id, managerId);
    if (authorized.isFailure) return Result.failure(authorized.error);

    await this.writer.delete(id);
    return Result.success(undefined);
  }
}

// Exportación prometida en el PRD: el gestor necesita sacar los resultados a
// una hoja de cálculo. NO se exportan los device_id: identificarían de forma
// estable a quién votó qué.
@Injectable()
export class ExportSurveyResultsUseCase {
  constructor(
    @Inject(SURVEY_READER_PORT) private readonly reader: SurveyReaderPort,
    private readonly authorize: AuthorizeSurveyMutationService,
  ) {}

  async execute(id: string, managerId: string): Promise<Result<string>> {
    const authorized = await this.authorize.ensureMutable(id, managerId);
    if (authorized.isFailure) return Result.failure(authorized.error);
    const survey = authorized.value;

    const tallies = await this.reader.countVotesByOption(id);
    const totalVotes = tallies.reduce((sum, tally) => sum + tally.votes, 0);

    const rows = survey.options.map((option) => {
      const votes =
        tallies.find((tally) => tally.optionId === option.id)?.votes ?? 0;
      const share = totalVotes === 0 ? 0 : (votes / totalVotes) * 100;
      return [
        option.label.resolve('es').text,
        option.label.resolve('va').text,
        String(votes),
        share.toFixed(2).replace('.', ','),
      ];
    });

    return Result.success(
      toCsv(['opcion_es', 'opcion_va', 'votos', 'porcentaje'], rows),
    );
  }
}
