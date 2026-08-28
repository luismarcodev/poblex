-- CreateEnum
CREATE TYPE "AlertPhenomenonType" AS ENUM ('INCENDIO', 'EVACUACION', 'METEOROLOGICO', 'SANITARIO', 'OTRO');

-- AlterTable
ALTER TABLE "alerts" ADD COLUMN     "phenomenon_type" "AlertPhenomenonType" NOT NULL DEFAULT 'METEOROLOGICO';
