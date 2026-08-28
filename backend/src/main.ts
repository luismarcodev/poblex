import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import cookieParser from 'cookie-parser';
import { AppModule } from './app.module';
import { DomainExceptionFilter } from './shared/infrastructure/http/domain-exception.filter';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.setGlobalPrefix('v1');
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));
  app.useGlobalFilters(new DomainExceptionFilter());
  app.use(cookieParser());

  // Cookie httpOnly del refresh token de gestor exige credentials:true y un
  // origen explícito (nunca '*'). Se admite lista separada por comas para
  // cubrir backoffice de producción y de pruebas sin recompilar.
  const allowedOrigins = (process.env.CORS_ORIGIN ?? '')
    .split(',')
    .map((origin) => origin.trim())
    .filter((origin) => origin.length > 0);

  app.enableCors({
    origin: allowedOrigins,
    credentials: true,
  });

  if (process.env.NODE_ENV !== 'production') {
    const swaggerConfig = new DocumentBuilder()
      .setTitle('Poblex API')
      .setDescription('API del backend de Poblex')
      .setVersion('1.0')
      .addBearerAuth()
      .build();
    const document = SwaggerModule.createDocument(app, swaggerConfig);
    SwaggerModule.setup('api', app, document);
  }

  const port = process.env.PORT ? Number(process.env.PORT) : 3000;
  await app.listen(port);
}

bootstrap().catch((error: unknown) => {
  console.error(error);
  process.exitCode = 1;
});
