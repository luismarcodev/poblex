import { Module } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { ScheduleModule } from '@nestjs/schedule';
import { ThrottlerGuard, ThrottlerModule } from '@nestjs/throttler';
import { AlertsModule } from './contexts/alerts/alerts.module';
import { BusinessesModule } from './contexts/businesses/businesses.module';
import { DevicesModule } from './contexts/devices/devices.module';
import { EventsModule } from './contexts/events/events.module';
import { FacilitiesModule } from './contexts/facilities/facilities.module';
import { FormsModule } from './contexts/forms/forms.module';
import { IncidentsModule } from './contexts/incidents/incidents.module';
import { PharmaciesModule } from './contexts/pharmacies/pharmacies.module';
import { ManagersModule } from './contexts/managers/managers.module';
import { MunicipalitiesModule } from './contexts/municipalities/municipalities.module';
import { NewsModule } from './contexts/news/news.module';
import { SocialModule } from './contexts/social/social.module';
import { SurveysModule } from './contexts/surveys/surveys.module';
import { HealthController } from './health.controller';
import { ConfigModule } from './shared/infrastructure/config/config.module';
import { CronModule } from './shared/infrastructure/cron/cron.module';
import { EmailModule } from './shared/infrastructure/email/email.module';
import { NotificationsModule } from './shared/infrastructure/notifications/notifications.module';
import { PrismaModule } from './shared/infrastructure/prisma/prisma.module';
import { StorageModule } from './shared/infrastructure/storage/storage.module';

@Module({
  imports: [
    ConfigModule,
    PrismaModule,
    EmailModule,
    StorageModule,
    NotificationsModule,
    CronModule,
    ScheduleModule.forRoot(),
    ThrottlerModule.forRoot([{ ttl: 60_000, limit: 100 }]),
    MunicipalitiesModule,
    DevicesModule,
    ManagersModule,
    NewsModule,
    SocialModule,
    EventsModule,
    AlertsModule,
    IncidentsModule,
    SurveysModule,
    FormsModule,
    PharmaciesModule,
    BusinessesModule,
    FacilitiesModule,
  ],
  controllers: [HealthController],
  providers: [{ provide: APP_GUARD, useClass: ThrottlerGuard }],
})
export class AppModule {}
