-- CreateEnum
CREATE TYPE "RequestOfferStatus" AS ENUM ('PENDING', 'ACCEPTED', 'DECLINED');

-- CreateTable
CREATE TABLE "RequestOffer" (
    "id" TEXT NOT NULL,
    "requestId" TEXT NOT NULL,
    "travelerId" TEXT NOT NULL,
    "message" TEXT,
    "status" "RequestOfferStatus" NOT NULL DEFAULT 'PENDING',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "RequestOffer_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "RequestOffer_requestId_idx" ON "RequestOffer"("requestId");

-- CreateIndex
CREATE INDEX "RequestOffer_travelerId_idx" ON "RequestOffer"("travelerId");

-- CreateIndex
CREATE UNIQUE INDEX "RequestOffer_requestId_travelerId_key" ON "RequestOffer"("requestId", "travelerId");

-- AddForeignKey
ALTER TABLE "RequestOffer" ADD CONSTRAINT "RequestOffer_requestId_fkey" FOREIGN KEY ("requestId") REFERENCES "PackageRequest"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RequestOffer" ADD CONSTRAINT "RequestOffer_travelerId_fkey" FOREIGN KEY ("travelerId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
