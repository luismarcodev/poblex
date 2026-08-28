import { Injectable } from '@nestjs/common';

export interface TaskHealth {
  lastSuccessAt: Date | null;
  lastFailureAt: Date | null;
  consecutiveFailures: number;
}

// Registro de salud de las tareas programadas. Un fallo repetido en cualquiera
// de ellas es un fallo silencioso hasta que alguien lo mira.
//
// EN MEMORIA a propósito: se pierde en cada reinicio del proceso. Sirve para
// vigilar desde fuera (endpoint de salud) y para disparar el aviso por email,
// no como histórico. Si hace falta histórico real o varias instancias, esto
// pasa a tabla y deja de ser un detalle interno de este servicio.
@Injectable()
export class TaskHealthRegistry {
  private readonly tasks = new Map<string, TaskHealth>();

  recordSuccess(taskName: string): void {
    this.tasks.set(taskName, {
      lastSuccessAt: new Date(),
      lastFailureAt: this.get(taskName).lastFailureAt,
      consecutiveFailures: 0,
    });
  }

  // Devuelve cuántos fallos consecutivos lleva la tarea tras registrar este.
  recordFailure(taskName: string): number {
    const previous = this.get(taskName);
    const consecutiveFailures = previous.consecutiveFailures + 1;
    this.tasks.set(taskName, {
      lastSuccessAt: previous.lastSuccessAt,
      lastFailureAt: new Date(),
      consecutiveFailures,
    });
    return consecutiveFailures;
  }

  get(taskName: string): TaskHealth {
    return (
      this.tasks.get(taskName) ?? {
        lastSuccessAt: null,
        lastFailureAt: null,
        consecutiveFailures: 0,
      }
    );
  }
}
