-- CreateTable
CREATE TABLE "businesses" (
    "id" UUID NOT NULL,
    "municipality_id" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "category" TEXT NOT NULL,
    "description" JSONB,
    "address" TEXT,
    "phone" TEXT,
    "email" TEXT,
    "website" TEXT,
    "schedule" TEXT,
    "active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "businesses_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "business_photos" (
    "id" UUID NOT NULL,
    "business_id" UUID NOT NULL,
    "url" TEXT NOT NULL,
    "mime_type" TEXT NOT NULL,
    "position" INTEGER NOT NULL,

    CONSTRAINT "business_photos_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "businesses_municipality_id_active_category_idx" ON "businesses"("municipality_id", "active", "category");

-- CreateIndex
CREATE INDEX "business_photos_business_id_idx" ON "business_photos"("business_id");

-- AddForeignKey
ALTER TABLE "businesses" ADD CONSTRAINT "businesses_municipality_id_fkey" FOREIGN KEY ("municipality_id") REFERENCES "municipalities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "business_photos" ADD CONSTRAINT "business_photos_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;
