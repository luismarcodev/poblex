import { Global, Module } from '@nestjs/common';
import { TaskHealthRegistry } from './task-health.registry';

// El registro de salud lo escriben las tareas de cada contexto y lo lee el
// controlador de salud: global para no acoplar contextos entre sí.
@Global()
@Module({
  providers: [TaskHealthRegistry],
  exports: [TaskHealthRegistry],
})
export class CronModule {}
