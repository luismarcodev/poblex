-- CreateTable
CREATE TABLE "facilities" (
    "id" UUID NOT NULL,
    "municipality_id" UUID NOT NULL,
    "name" JSONB NOT NULL,
    "description" JSONB,
    "category" TEXT NOT NULL,
    "image_url" TEXT,
    "slot_duration_minutes" INTEGER NOT NULL,
    "opening_hours" JSONB NOT NULL,
    "fee_note" JSONB,
    "max_advance_booking_days" INTEGER NOT NULL DEFAULT 14,
    "active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "facilities_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "reservations" (
    "id" UUID NOT NULL,
    "facility_id" UUID NOT NULL,
    "municipality_id" UUID NOT NULL,
    "device_id" UUID NOT NULL,
    "slot_start" TIMESTAMP(3) NOT NULL,
    "slot_end" TIMESTAMP(3) NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "reservations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "reservation_cancellations" (
    "id" UUID NOT NULL,
    "facility_id" UUID NOT NULL,
    "municipality_id" UUID NOT NULL,
    "device_id" UUID NOT NULL,
    "slot_start" TIMESTAMP(3) NOT NULL,
    "slot_end" TIMESTAMP(3) NOT NULL,
    "cancelled_by" UUID,
    "cancel_note" TEXT,
    "cancelled_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "reservation_cancellations_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "facilities_municipality_id_active_idx" ON "facilities"("municipality_id", "active");

-- CreateIndex
CREATE INDEX "reservations_municipality_id_facility_id_slot_start_idx" ON "reservations"("municipality_id", "facility_id", "slot_start");

-- CreateIndex
CREATE INDEX "reservations_device_id_idx" ON "reservations"("device_id");

-- CreateIndex
CREATE UNIQUE INDEX "reservations_facility_id_slot_start_key" ON "reservations"("facility_id", "slot_start");

-- CreateIndex
CREATE INDEX "reservation_cancellations_facility_id_idx" ON "reservation_cancellations"("facility_id");

-- CreateIndex
CREATE INDEX "reservation_cancellations_device_id_idx" ON "reservation_cancellations"("device_id");

-- AddForeignKey
ALTER TABLE "facilities" ADD CONSTRAINT "facilities_municipality_id_fkey" FOREIGN KEY ("municipality_id") REFERENCES "municipalities"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reservations" ADD CONSTRAINT "reservations_facility_id_fkey" FOREIGN KEY ("facility_id") REFERENCES "facilities"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reservation_cancellations" ADD CONSTRAINT "reservation_cancellations_facility_id_fkey" FOREIGN KEY ("facility_id") REFERENCES "facilities"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reservation_cancellations" ADD CONSTRAINT "reservation_cancellations_cancelled_by_fkey" FOREIGN KEY ("cancelled_by") REFERENCES "managers"("id") ON DELETE SET NULL ON UPDATE CASCADE;
