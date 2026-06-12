-- CreateEnum
CREATE TYPE "PackageRequestStatus" AS ENUM ('OPEN', 'MATCHED', 'CLOSED');

-- CreateTable
CREATE TABLE "PackageRequest" (
    "id" TEXT NOT NULL,
    "senderId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "originAirport" TEXT NOT NULL,
    "destinationAirport" TEXT NOT NULL,
    "desiredByDate" TIMESTAMP(3),
    "weightKg" DECIMAL(5,2) NOT NULL,
    "rewardOffered" DECIMAL(10,2) NOT NULL,
    "currency" TEXT NOT NULL DEFAULT 'EUR',
    "category" "CustomsCategory" NOT NULL DEFAULT 'OTHER',
    "notes" TEXT,
    "status" "PackageRequestStatus" NOT NULL DEFAULT 'OPEN',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "PackageRequest_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "PackageRequest_originAirport_destinationAirport_status_idx" ON "PackageRequest"("originAirport", "destinationAirport", "status");

-- CreateIndex
CREATE INDEX "PackageRequest_senderId_idx" ON "PackageRequest"("senderId");

-- AddForeignKey
ALTER TABLE "PackageRequest" ADD CONSTRAINT "PackageRequest_senderId_fkey" FOREIGN KEY ("senderId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
