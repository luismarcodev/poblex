import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from './../src/app.module';

describe('Health (e2e)', () => {
  let app: INestApplication<App>;

  beforeEach(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.setGlobalPrefix('v1');
    await app.init();
  });

  it('/v1/health (GET)', async () => {
    const response = await request(app.getHttpServer())
      .get('/v1/health')
      .expect(200);

    const body: unknown = response.body;
    expect(typeof body).toBe('object');
    expect(body).not.toBeNull();
    const health = body as Record<string, unknown>;
    expect(health.status).toBe('ok');
    expect(typeof health.timestamp).toBe('string');
  });

  afterEach(async () => {
    await app.close();
  });
});
