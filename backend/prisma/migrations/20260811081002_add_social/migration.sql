-- CreateEnum
CREATE TYPE "SocialPlatform" AS ENUM ('INSTAGRAM', 'FACEBOOK');

-- CreateEnum
CREATE TYPE "SocialAccountStatus" AS ENUM ('CONNECTED', 'EXPIRED', 'ERROR', 'REVOKED');

-- CreateEnum
CREATE TYPE "SocialPublicationStatus" AS ENUM ('PENDING', 'CONTAINER_CREATED', 'PROCESSING', 'PUBLISHED', 'FAILED');

-- AlterTable
ALTER TABLE "news" ADD COLUMN     "source_external_post_id" TEXT,
ADD COLUMN     "source_platform" "SocialPlatform";

-- CreateTable
CREATE TABLE "social_accounts" (
    "id" UUID NOT NULL,
    "municipality_id" UUID NOT NULL,
    "platform" "SocialPlatform" NOT NULL,
    "external_account_id" TEXT NOT NULL,
    "account_name" TEXT NOT NULL,
    "access_token_cipher" BYTEA NOT NULL,
    "token_expires_at" TIMESTAMP(3) NOT NULL,
    "status" "SocialAccountStatus" NOT NULL DEFAULT 'CONNECTED',
    "last_error_message" TEXT,
    "connected_by_manager_id" UUID NOT NULL,
    "connected_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "last_refreshed_at" TIMESTAMP(3),

    CONSTRAINT "social_accounts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "social_publications" (
    "id" UUID NOT NULL,
    "news_id" UUID NOT NULL,
    "municipality_id" UUID NOT NULL,
    "platform" "SocialPlatform" NOT NULL,
    "status" "SocialPublicationStatus" NOT NULL DEFAULT 'PENDING',
    "container_id" TEXT,
    "external_post_id" TEXT,
    "last_error" TEXT,
    "attempt_count" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "published_at" TIMESTAMP(3),
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "social_publications_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "social_accounts_municipality_id_platform_key" ON "social_accounts"("municipality_id", "platform");

-- CreateIndex
CREATE INDEX "social_publications_platform_status_idx" ON "social_publications"("platform", "status");

-- CreateIndex
CREATE UNIQUE INDEX "social_publications_news_id_platform_key" ON "social_publications"("news_id", "platform");

-- CreateIndex
CREATE UNIQUE INDEX "news_municipality_id_source_platform_source_external_post_i_key" ON "news"("municipality_id", "source_platform", "source_external_post_id");

-- AddForeignKey
ALTER TABLE "social_accounts" ADD CONSTRAINT "social_accounts_municipality_id_fkey" FOREIGN KEY ("municipality_id") REFERENCES "municipalities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "social_accounts" ADD CONSTRAINT "social_accounts_connected_by_manager_id_fkey" FOREIGN KEY ("connected_by_manager_id") REFERENCES "managers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "social_publications" ADD CONSTRAINT "social_publications_news_id_fkey" FOREIGN KEY ("news_id") REFERENCES "news"("id") ON DELETE CASCADE ON UPDATE CASCADE;
