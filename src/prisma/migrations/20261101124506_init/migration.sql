/*
  Warnings:

  - You are about to drop the column `last_used_at` on the `user_auth_providers` table. All the data in the column will be lost.
  - You are about to drop the column `linked_at` on the `user_auth_providers` table. All the data in the column will be lost.
  - You are about to drop the column `provider_email` on the `user_auth_providers` table. All the data in the column will be lost.
  - You are about to drop the column `provider_id` on the `user_auth_providers` table. All the data in the column will be lost.
  - You are about to drop the `auth_providers` table. If the table is not empty, all the data it contains will be lost.
  - A unique constraint covering the columns `[user_id]` on the table `user_auth_providers` will be added. If there are existing duplicate values, this will fail.
  - Added the required column `provider` to the `user_auth_providers` table without a default value. This is not possible if the table is not empty.

*/
-- CreateEnum
CREATE TYPE "auth_provider_types" AS ENUM ('manual', 'google');

-- DropForeignKey
ALTER TABLE "user_auth_providers" DROP CONSTRAINT "user_auth_providers_provider_id_fkey";

-- DropIndex
DROP INDEX "uq_provider_identity";

-- DropIndex
DROP INDEX "uq_user_provider";

-- AlterTable
ALTER TABLE "user_auth_providers" DROP COLUMN "last_used_at",
DROP COLUMN "linked_at",
DROP COLUMN "provider_email",
DROP COLUMN "provider_id",
ADD COLUMN     "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "last_login_at" TIMESTAMPTZ(6),
ADD COLUMN     "password_hash" VARCHAR(100),
ADD COLUMN     "provider" "auth_provider_types" NOT NULL,
ADD COLUMN     "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
ALTER COLUMN "provider_user_id" DROP NOT NULL;

-- DropTable
DROP TABLE "auth_providers";

-- CreateIndex
CREATE UNIQUE INDEX "user_auth_providers_user_id_key" ON "user_auth_providers"("user_id");
