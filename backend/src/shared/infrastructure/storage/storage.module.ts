import { Global, Module } from '@nestjs/common';
import { FILE_STORAGE_PORT } from './file-storage.port';
import { R2FileStorageAdapter } from './r2-file-storage.adapter';

@Global()
@Module({
  providers: [{ provide: FILE_STORAGE_PORT, useClass: R2FileStorageAdapter }],
  exports: [FILE_STORAGE_PORT],
})
export class StorageModule {}
