-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateEnum
CREATE TYPE "AlertSource" AS ENUM ('AEMET', 'MANUAL');

-- CreateEnum
CREATE TYPE "AlertSeverity" AS ENUM ('AMARILLO', 'NARANJA', 'ROJO');

-- CreateEnum
CREATE TYPE "IncidentStatus" AS ENUM ('RECIBIDO', 'EN_CURSO', 'RESUELTA');

-- CreateEnum
CREATE TYPE "FormFieldType" AS ENUM ('TEXT', 'NUMBER', 'SELECT', 'DATE', 'BOOLEAN');

-- CreateTable
CREATE TABLE "municipalities" (
    "id" UUID NOT NULL,
    "slug" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "province" TEXT NOT NULL,
    "aemet_zone_code" TEXT,
    "primary_color" TEXT,
    "logo_url" TEXT,
    "languages" TEXT[],
    "active" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "municipalities_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "managers" (
    "id" UUID NOT NULL,
    "email" TEXT NOT NULL,
    "password_hash" TEXT NOT NULL,
    "display_name" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "managers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "manager_municipalities" (
    "manager_id" UUID NOT NULL,
    "municipality_id" UUID NOT NULL,

    CONSTRAINT "manager_municipalities_pkey" PRIMARY KEY ("manager_id","municipality_id")
);

-- CreateTable
CREATE TABLE "manager_refresh_tokens" (
    "id" UUID NOT NULL,
    "manager_id" UUID NOT NULL,
    "token_hash" TEXT NOT NULL,
    "expires_at" TIMESTAMP(3) NOT NULL,
    "revoked_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "manager_refresh_tokens_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "manager_password_resets" (
    "id" UUID NOT NULL,
    "manager_id" UUID NOT NULL,
    "token_hash" TEXT NOT NULL,
    "expires_at" TIMESTAMP(3) NOT NULL,
    "used_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "manager_password_resets_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "devices" (
    "id" UUID NOT NULL,
    "municipality_id" UUID NOT NULL,
    "fcm_token" TEXT,
    "locale" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "last_seen_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "devices_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "news" (
    "id" UUID NOT NULL,
    "municipality_id" UUID NOT NULL,
    "title" JSONB NOT NULL,
    "body" JSONB NOT NULL,
    "image_url" TEXT,
    "category" TEXT NOT NULL,
    "pinned" BOOLEAN NOT NULL DEFAULT false,
    "published_at" TIMESTAMP(3) NOT NULL,
    "archived" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "news_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "news_attachments" (
    "id" UUID NOT NULL,
    "news_id" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "mime_type" TEXT NOT NULL,

    CONSTRAINT "news_attachments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "events" (
    "id" UUID NOT NULL,
    "municipality_id" UUID NOT NULL,
    "title" JSONB NOT NULL,
    "description" JSONB NOT NULL,
    "start_at" TIMESTAMP(3) NOT NULL,
    "end_at" TIMESTAMP(3),
    "location_name" TEXT,
    "lat" DOUBLE PRECISION,
    "lng" DOUBLE PRECISION,
    "category" TEXT NOT NULL,

    CONSTRAINT "events_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "event_reminders" (
    "id" UUID NOT NULL,
    "event_id" UUID NOT NULL,
    "device_id" UUID NOT NULL,
    "remind_at" TIMESTAMP(3) NOT NULL,
    "sent_at" TIMESTAMP(3),

    CONSTRAINT "event_reminders_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "alerts" (
    "id" UUID NOT NULL,
    "municipality_id" UUID NOT NULL,
    "source" "AlertSource" NOT NULL,
    "severity" "AlertSeverity" NOT NULL,
    "phenomenon" TEXT NOT NULL,
    "body" JSONB NOT NULL,
    "start_at" TIMESTAMP(3) NOT NULL,
    "end_at" TIMESTAMP(3),
    "aemet_id" TEXT,
    "created_by" UUID,
    "updated_by" UUID,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "alerts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "incidents" (
    "id" UUID NOT NULL,
    "municipality_id" UUID NOT NULL,
    "device_id" UUID NOT NULL,
    "category" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "photo_url" TEXT,
    "photo_purge_at" TIMESTAMP(3),
    "lat" DOUBLE PRECISION,
    "lng" DOUBLE PRECISION,
    "status" "IncidentStatus" NOT NULL DEFAULT 'RECIBIDO',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "incidents_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "incident_status_history" (
    "id" UUID NOT NULL,
    "incident_id" UUID NOT NULL,
    "status" "IncidentStatus" NOT NULL,
    "note" TEXT,
    "changed_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "changed_by" UUID NOT NULL,

    CONSTRAINT "incident_status_history_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "surveys" (
    "id" UUID NOT NULL,
    "municipality_id" UUID NOT NULL,
    "question" JSONB NOT NULL,
    "closes_at" TIMESTAMP(3) NOT NULL,
    "results_visible" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "surveys_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "survey_options" (
    "id" UUID NOT NULL,
    "survey_id" UUID NOT NULL,
    "label" JSONB NOT NULL,
    "position" INTEGER NOT NULL,

    CONSTRAINT "survey_options_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "survey_votes" (
    "id" UUID NOT NULL,
    "survey_id" UUID NOT NULL,
    "option_id" UUID NOT NULL,
    "device_id" UUID NOT NULL,
    "voted_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "survey_votes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "forms" (
    "id" UUID NOT NULL,
    "municipality_id" UUID NOT NULL,
    "title" JSONB NOT NULL,
    "description" JSONB NOT NULL,
    "deadline" TIMESTAMP(3),

    CONSTRAINT "forms_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "form_fields" (
    "id" UUID NOT NULL,
    "form_id" UUID NOT NULL,
    "key" TEXT NOT NULL,
    "label" JSONB NOT NULL,
    "type" "FormFieldType" NOT NULL,
    "required" BOOLEAN NOT NULL DEFAULT false,
    "options" JSONB,
    "position" INTEGER NOT NULL,

    CONSTRAINT "form_fields_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "form_submissions" (
    "id" UUID NOT NULL,
    "form_id" UUID NOT NULL,
    "device_id" UUID NOT NULL,
    "submitted_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "form_submissions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "form_answers" (
    "id" UUID NOT NULL,
    "submission_id" UUID NOT NULL,
    "field_id" UUID NOT NULL,
    "value" TEXT NOT NULL,

    CONSTRAINT "form_answers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "duty_pharmacies" (
    "id" UUID NOT NULL,
    "municipality_id" UUID NOT NULL,
    "date" DATE NOT NULL,
    "pharmacy_name" TEXT NOT NULL,
    "address" TEXT NOT NULL,
    "phone" TEXT NOT NULL,
    "schedule" TEXT NOT NULL,

    CONSTRAINT "duty_pharmacies_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "municipalities_slug_key" ON "municipalities"("slug");

-- CreateIndex
CREATE UNIQUE INDEX "managers_email_key" ON "managers"("email");

-- CreateIndex
CREATE INDEX "manager_refresh_tokens_manager_id_idx" ON "manager_refresh_tokens"("manager_id");

-- CreateIndex
CREATE INDEX "manager_password_resets_manager_id_idx" ON "manager_password_resets"("manager_id");

-- CreateIndex
CREATE INDEX "devices_municipality_id_idx" ON "devices"("municipality_id");

-- CreateIndex
CREATE INDEX "news_municipality_id_archived_published_at_idx" ON "news"("municipality_id", "archived", "published_at");

-- CreateIndex
CREATE INDEX "news_attachments_news_id_idx" ON "news_attachments"("news_id");

-- CreateIndex
CREATE INDEX "events_municipality_id_start_at_idx" ON "events"("municipality_id", "start_at");

-- CreateIndex
CREATE INDEX "event_reminders_device_id_idx" ON "event_reminders"("device_id");

-- CreateIndex
CREATE UNIQUE INDEX "event_reminders_event_id_device_id_key" ON "event_reminders"("event_id", "device_id");

-- CreateIndex
CREATE INDEX "alerts_municipality_id_severity_idx" ON "alerts"("municipality_id", "severity");

-- CreateIndex
CREATE UNIQUE INDEX "alerts_municipality_id_aemet_id_key" ON "alerts"("municipality_id", "aemet_id");

-- CreateIndex
CREATE INDEX "incidents_municipality_id_status_idx" ON "incidents"("municipality_id", "status");

-- CreateIndex
CREATE INDEX "incidents_device_id_idx" ON "incidents"("device_id");

-- CreateIndex
CREATE INDEX "incident_status_history_incident_id_idx" ON "incident_status_history"("incident_id");

-- CreateIndex
CREATE INDEX "surveys_municipality_id_closes_at_idx" ON "surveys"("municipality_id", "closes_at");

-- CreateIndex
CREATE INDEX "survey_options_survey_id_idx" ON "survey_options"("survey_id");

-- CreateIndex
CREATE INDEX "survey_votes_option_id_idx" ON "survey_votes"("option_id");

-- CreateIndex
CREATE UNIQUE INDEX "survey_votes_survey_id_device_id_key" ON "survey_votes"("survey_id", "device_id");

-- CreateIndex
CREATE INDEX "forms_municipality_id_deadline_idx" ON "forms"("municipality_id", "deadline");

-- CreateIndex
CREATE INDEX "form_fields_form_id_idx" ON "form_fields"("form_id");

-- CreateIndex
CREATE INDEX "form_submissions_form_id_idx" ON "form_submissions"("form_id");

-- CreateIndex
CREATE INDEX "form_submissions_device_id_idx" ON "form_submissions"("device_id");

-- CreateIndex
CREATE UNIQUE INDEX "form_submissions_form_id_device_id_key" ON "form_submissions"("form_id", "device_id");

-- CreateIndex
CREATE INDEX "form_answers_submission_id_idx" ON "form_answers"("submission_id");

-- CreateIndex
CREATE UNIQUE INDEX "duty_pharmacies_municipality_id_date_key" ON "duty_pharmacies"("municipality_id", "date");

-- AddForeignKey
ALTER TABLE "manager_municipalities" ADD CONSTRAINT "manager_municipalities_manager_id_fkey" FOREIGN KEY ("manager_id") REFERENCES "managers"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "manager_municipalities" ADD CONSTRAINT "manager_municipalities_municipality_id_fkey" FOREIGN KEY ("municipality_id") REFERENCES "municipalities"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "manager_refresh_tokens" ADD CONSTRAINT "manager_refresh_tokens_manager_id_fkey" FOREIGN KEY ("manager_id") REFERENCES "managers"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "manager_password_resets" ADD CONSTRAINT "manager_password_resets_manager_id_fkey" FOREIGN KEY ("manager_id") REFERENCES "managers"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "devices" ADD CONSTRAINT "devices_municipality_id_fkey" FOREIGN KEY ("municipality_id") REFERENCES "municipalities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "news" ADD CONSTRAINT "news_municipality_id_fkey" FOREIGN KEY ("municipality_id") REFERENCES "municipalities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "news_attachments" ADD CONSTRAINT "news_attachments_news_id_fkey" FOREIGN KEY ("news_id") REFERENCES "news"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "events" ADD CONSTRAINT "events_municipality_id_fkey" FOREIGN KEY ("municipality_id") REFERENCES "municipalities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "event_reminders" ADD CONSTRAINT "event_reminders_event_id_fkey" FOREIGN KEY ("event_id") REFERENCES "events"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "alerts" ADD CONSTRAINT "alerts_municipality_id_fkey" FOREIGN KEY ("municipality_id") REFERENCES "municipalities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "alerts" ADD CONSTRAINT "alerts_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "managers"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "alerts" ADD CONSTRAINT "alerts_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "managers"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "incidents" ADD CONSTRAINT "incidents_municipality_id_fkey" FOREIGN KEY ("municipality_id") REFERENCES "municipalities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "incident_status_history" ADD CONSTRAINT "incident_status_history_incident_id_fkey" FOREIGN KEY ("incident_id") REFERENCES "incidents"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "incident_status_history" ADD CONSTRAINT "incident_status_history_changed_by_fkey" FOREIGN KEY ("changed_by") REFERENCES "managers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "surveys" ADD CONSTRAINT "surveys_municipality_id_fkey" FOREIGN KEY ("municipality_id") REFERENCES "municipalities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "survey_options" ADD CONSTRAINT "survey_options_survey_id_fkey" FOREIGN KEY ("survey_id") REFERENCES "surveys"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "survey_votes" ADD CONSTRAINT "survey_votes_survey_id_fkey" FOREIGN KEY ("survey_id") REFERENCES "surveys"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "survey_votes" ADD CONSTRAINT "survey_votes_option_id_fkey" FOREIGN KEY ("option_id") REFERENCES "survey_options"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "forms" ADD CONSTRAINT "forms_municipality_id_fkey" FOREIGN KEY ("municipality_id") REFERENCES "municipalities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "form_fields" ADD CONSTRAINT "form_fields_form_id_fkey" FOREIGN KEY ("form_id") REFERENCES "forms"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "form_submissions" ADD CONSTRAINT "form_submissions_form_id_fkey" FOREIGN KEY ("form_id") REFERENCES "forms"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "form_answers" ADD CONSTRAINT "form_answers_submission_id_fkey" FOREIGN KEY ("submission_id") REFERENCES "form_submissions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "form_answers" ADD CONSTRAINT "form_answers_field_id_fkey" FOREIGN KEY ("field_id") REFERENCES "form_fields"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "duty_pharmacies" ADD CONSTRAINT "duty_pharmacies_municipality_id_fkey" FOREIGN KEY ("municipality_id") REFERENCES "municipalities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

