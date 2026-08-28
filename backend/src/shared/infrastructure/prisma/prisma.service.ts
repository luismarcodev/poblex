import { PrismaPg } from '@prisma/adapter-pg';
import { Injectable, OnModuleDestroy, OnModuleInit } from '@nestjs/common';
import { PrismaClient } from './prisma-client';

// Prisma 7 exige un driver adapter explícito — ya no lee DATABASE_URL
// implícitamente en runtime. `pg` conecta por TCP normal, adecuado para un
// backend NestJS de proceso largo (no serverless) contra Neon.
@Injectable()
export class PrismaService
  extends PrismaClient
  implements OnModuleInit, OnModuleDestroy
{
  constructor() {
    super({
      adapter: new PrismaPg({ connectionString: process.env.DATABASE_URL }),
    });
  }

  async onModuleInit() {
    await this.$connect();
  }

  async onModuleDestroy() {
    await this.$disconnect();
  }
}
