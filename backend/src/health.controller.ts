import { Controller, Get } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { AEMET_SYNC_TASK } from './contexts/alerts/application/use-cases/sync-aemet-alerts.use-case';
import { SOCIAL_INBOUND_POLL_TASK } from './contexts/social/application/use-cases/poll-inbound-social-posts.use-case';
import { SOCIAL_INSTAGRAM_ADVANCE_TASK } from './contexts/social/application/use-cases/advance-instagram-publication.use-case';
import { TaskHealthRegistry } from './shared/infrastructure/cron/task-health.registry';

interface TaskHealthResponse {
  lastSuccessAt: string | null;
  lastFailureAt: string | null;
  consecutiveFailures: number;
  // Degradado si la última ejecución correcta es más vieja que el umbral, o
  // si nunca ha habido una desde el arranque del proceso.
  status: 'ok' | 'degraded';
}

type AemetHealthResponse = TaskHealthResponse;

// Si la última sincronización correcta tiene más de una hora, algo va mal:
// la tarea corre cada 15 minutos.
const STALE_THRESHOLD_MS = 3_600_000;
// El cron de avance de Instagram corre cada 5 minutos.
const INSTAGRAM_STALE_THRESHOLD_MS = 900_000;

@ApiTags('health')
@Controller('health')
export class HealthController {
  constructor(private readonly taskHealth: TaskHealthRegistry) {}

  @Get()
  check(): { status: 'ok'; timestamp: string } {
    return { status: 'ok', timestamp: new Date().toISOString() };
  }

  // Expuesto para vigilar la fuente de alertas DESDE FUERA: un fallo
  // silencioso en los avisos meteorológicos no es tolerable en la Ribera Baixa.
  @Get('aemet')
  aemet(): AemetHealthResponse {
    return this.toHealthResponse(AEMET_SYNC_TASK, STALE_THRESHOLD_MS);
  }

  // Sondeo entrante de redes sociales: cada 15 minutos, mismo umbral que AEMET.
  @Get('social-inbound')
  socialInbound(): TaskHealthResponse {
    return this.toHealthResponse(SOCIAL_INBOUND_POLL_TASK, STALE_THRESHOLD_MS);
  }

  // Avance de publicaciones de Instagram: cada 5 minutos.
  @Get('social-instagram')
  socialInstagram(): TaskHealthResponse {
    return this.toHealthResponse(
      SOCIAL_INSTAGRAM_ADVANCE_TASK,
      INSTAGRAM_STALE_THRESHOLD_MS,
    );
  }

  private toHealthResponse(
    taskName: string,
    staleThresholdMs: number,
  ): TaskHealthResponse {
    const health = this.taskHealth.get(taskName);
    const isStale =
      health.lastSuccessAt === null ||
      Date.now() - health.lastSuccessAt.getTime() > staleThresholdMs;

    return {
      lastSuccessAt: health.lastSuccessAt?.toISOString() ?? null,
      lastFailureAt: health.lastFailureAt?.toISOString() ?? null,
      consecutiveFailures: health.consecutiveFailures,
      status: isStale ? 'degraded' : 'ok',
    };
  }
}
