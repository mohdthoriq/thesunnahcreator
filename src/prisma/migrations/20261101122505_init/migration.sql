-- CreateEnum
CREATE TYPE "user_role" AS ENUM ('user', 'admin');

-- CreateEnum
CREATE TYPE "verification_purpose" AS ENUM ('verify_email', 'reset_password');

-- CreateEnum
CREATE TYPE "template_status" AS ENUM ('draft', 'published', 'hidden');

-- CreateEnum
CREATE TYPE "slot_type" AS ENUM ('text', 'color');

-- CreateEnum
CREATE TYPE "text_direction" AS ENUM ('ltr', 'rtl');

-- CreateEnum
CREATE TYPE "color_role" AS ENUM ('background', 'text', 'accent');

-- CreateEnum
CREATE TYPE "video_status" AS ENUM ('draft', 'queued', 'processing', 'completed', 'failed');

-- CreateEnum
CREATE TYPE "render_status" AS ENUM ('queued', 'processing', 'error', 'completed', 'failed');

-- CreateEnum
CREATE TYPE "report_status" AS ENUM ('open', 'reviewed', 'closed');

-- CreateTable
CREATE TABLE "aspect_ratios" (
    "id" SMALLSERIAL NOT NULL,
    "code" VARCHAR(10) NOT NULL,
    "name" VARCHAR(50) NOT NULL,
    "width_units" SMALLINT NOT NULL,
    "height_units" SMALLINT NOT NULL,
    "platforms_note" VARCHAR(100),
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "sort_order" SMALLINT NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "aspect_ratios_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "auth_providers" (
    "id" SMALLSERIAL NOT NULL,
    "code" VARCHAR(30) NOT NULL,
    "name" VARCHAR(50) NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "sort_order" SMALLINT NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "auth_providers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "content_reports" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "template_id" UUID NOT NULL,
    "video_id" UUID,
    "reporter_id" UUID,
    "reason_id" SMALLINT NOT NULL,
    "note" VARCHAR(500),
    "status" "report_status" NOT NULL DEFAULT 'open',
    "reviewed_by" UUID,
    "reviewed_at" TIMESTAMPTZ(6),
    "resolution_note" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "content_reports_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "palettes" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "name" VARCHAR(50) NOT NULL,
    "background_hex" CHAR(7) NOT NULL,
    "text_hex" CHAR(7) NOT NULL,
    "accent_hex" CHAR(7) NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "sort_order" SMALLINT NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "palettes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "plans" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "code" VARCHAR(50) NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "description" TEXT,
    "price_idr" DECIMAL(12,2) NOT NULL DEFAULT 0,
    "billing_interval" VARCHAR(10) NOT NULL DEFAULT 'monthly',
    "render_quota_monthly" INTEGER,
    "max_resolution" VARCHAR(10) NOT NULL DEFAULT '720p',
    "has_watermark" BOOLEAN NOT NULL DEFAULT true,
    "all_templates_access" BOOLEAN NOT NULL DEFAULT false,
    "brand_kit_enabled" BOOLEAN NOT NULL DEFAULT false,
    "team_seats" SMALLINT NOT NULL DEFAULT 1,
    "features" JSONB NOT NULL DEFAULT '{}',
    "is_default" BOOLEAN NOT NULL DEFAULT false,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "sort_order" SMALLINT NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "plans_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "render_jobs" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "video_id" UUID NOT NULL,
    "attempt" SMALLINT NOT NULL DEFAULT 1,
    "retry_of_id" UUID,
    "status" "render_status" NOT NULL DEFAULT 'queued',
    "provider_id" SMALLINT NOT NULL,
    "provider_job_id" VARCHAR(100),
    "payload" JSONB NOT NULL,
    "output_key" TEXT,
    "cost_idr" DECIMAL(12,2),
    "queued_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "started_at" TIMESTAMPTZ(6),
    "finished_at" TIMESTAMPTZ(6),
    "error_message" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "render_jobs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "render_providers" (
    "id" SMALLSERIAL NOT NULL,
    "code" VARCHAR(30) NOT NULL,
    "name" VARCHAR(50) NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "is_default" BOOLEAN NOT NULL DEFAULT false,
    "cost_per_render_idr" DECIMAL(12,2),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "render_providers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "report_reasons" (
    "id" SMALLSERIAL NOT NULL,
    "code" VARCHAR(30) NOT NULL,
    "label" VARCHAR(100) NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "sort_order" SMALLINT NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "report_reasons_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "slots" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "template_id" UUID NOT NULL,
    "key" VARCHAR(50) NOT NULL,
    "label" VARCHAR(100) NOT NULL,
    "slot_type" "slot_type" NOT NULL,
    "is_required" BOOLEAN NOT NULL DEFAULT false,
    "is_source" BOOLEAN NOT NULL DEFAULT false,
    "max_chars" SMALLINT,
    "text_direction" "text_direction" NOT NULL DEFAULT 'ltr',
    "font_family" VARCHAR(50),
    "text_transform" VARCHAR(20) NOT NULL DEFAULT 'none',
    "auto_shrink" BOOLEAN NOT NULL DEFAULT false,
    "hide_when_empty" BOOLEAN NOT NULL DEFAULT false,
    "color_role" "color_role",
    "placeholder" TEXT,
    "sort_order" SMALLINT NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "slots_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "slot_placements" (
    "slot_id" UUID NOT NULL,
    "variant_id" UUID NOT NULL,
    "x_pct" DECIMAL(5,2) NOT NULL,
    "y_pct" DECIMAL(5,2) NOT NULL,
    "width_pct" DECIMAL(5,2) NOT NULL,
    "height_pct" DECIMAL(5,2) NOT NULL,
    "font_size_pct" DECIMAL(5,2),
    "text_align" VARCHAR(10) NOT NULL DEFAULT 'center',
    "start_sec" DECIMAL(5,2),
    "end_sec" DECIMAL(5,2),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "slot_placements_pkey" PRIMARY KEY ("slot_id","variant_id")
);

-- CreateTable
CREATE TABLE "templates" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "slug" VARCHAR(100) NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "description" TEXT,
    "category_id" SMALLINT NOT NULL,
    "requires_source" BOOLEAN NOT NULL DEFAULT false,
    "status" "template_status" NOT NULL DEFAULT 'draft',
    "version" INTEGER NOT NULL DEFAULT 1,
    "default_palette_id" UUID,
    "created_by" UUID,
    "published_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "templates_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "template_categories" (
    "id" SMALLSERIAL NOT NULL,
    "slug" VARCHAR(50) NOT NULL,
    "name" VARCHAR(50) NOT NULL,
    "description" TEXT,
    "icon" VARCHAR(50),
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "sort_order" SMALLINT NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "template_categories_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "template_variants" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "template_id" UUID NOT NULL,
    "aspect_ratio_id" SMALLINT NOT NULL,
    "background_key" TEXT NOT NULL,
    "thumbnail_key" TEXT NOT NULL,
    "preview_key" TEXT,
    "duration_sec" DECIMAL(5,2) NOT NULL,
    "provider_template_ref" VARCHAR(100),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "template_variants_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "usage_periods" (
    "user_id" UUID NOT NULL,
    "period_start" DATE NOT NULL,
    "plan_id" UUID NOT NULL,
    "renders_used" INTEGER NOT NULL DEFAULT 0,
    "render_quota" INTEGER,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "usage_periods_pkey" PRIMARY KEY ("user_id","period_start")
);

-- CreateTable
CREATE TABLE "users" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "email" VARCHAR(255) NOT NULL,
    "email_verified_at" TIMESTAMPTZ(6),
    "password_hash" TEXT,
    "role" "user_role" NOT NULL DEFAULT 'user',
    "plan_id" UUID NOT NULL,
    "ecourse_member_id" VARCHAR(100),
    "last_login_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_auth_providers" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "user_id" UUID NOT NULL,
    "provider_id" SMALLINT NOT NULL,
    "provider_user_id" VARCHAR(255) NOT NULL,
    "provider_email" VARCHAR(255),
    "linked_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "last_used_at" TIMESTAMPTZ(6),

    CONSTRAINT "user_auth_providers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_profiles" (
    "user_id" UUID NOT NULL,
    "full_name" VARCHAR(100) NOT NULL,
    "account_handle" VARCHAR(24),
    "avatar_url" TEXT,
    "bio" VARCHAR(300),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_profiles_pkey" PRIMARY KEY ("user_id")
);

-- CreateTable
CREATE TABLE "verification_tokens" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "user_id" UUID NOT NULL,
    "purpose" "verification_purpose" NOT NULL,
    "token_hash" CHAR(64) NOT NULL,
    "sent_to_email" VARCHAR(255) NOT NULL,
    "expires_at" TIMESTAMPTZ(6) NOT NULL,
    "used_at" TIMESTAMPTZ(6),
    "requested_ip" INET,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "verification_tokens_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "videos" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "user_id" UUID NOT NULL,
    "template_id" UUID NOT NULL,
    "template_version" INTEGER NOT NULL,
    "variant_id" UUID NOT NULL,
    "palette_id" UUID NOT NULL,
    "inputs" JSONB NOT NULL DEFAULT '{}',
    "status" "video_status" NOT NULL DEFAULT 'draft',
    "resolution" VARCHAR(10),
    "has_watermark" BOOLEAN NOT NULL DEFAULT true,
    "output_key" TEXT,
    "last_render_job_id" UUID,
    "rendered_at" TIMESTAMPTZ(6),
    "deleted_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "videos_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "aspect_ratios_code_key" ON "aspect_ratios"("code");

-- CreateIndex
CREATE UNIQUE INDEX "aspect_ratios_width_units_height_units_key" ON "aspect_ratios"("width_units", "height_units");

-- CreateIndex
CREATE UNIQUE INDEX "auth_providers_code_key" ON "auth_providers"("code");

-- CreateIndex
CREATE INDEX "idx_reports_open" ON "content_reports"("status", "created_at");

-- CreateIndex
CREATE UNIQUE INDEX "palettes_name_key" ON "palettes"("name");

-- CreateIndex
CREATE UNIQUE INDEX "plans_code_key" ON "plans"("code");

-- CreateIndex
CREATE UNIQUE INDEX "render_jobs_retry_of_id_key" ON "render_jobs"("retry_of_id");

-- CreateIndex
CREATE INDEX "idx_render_jobs_video" ON "render_jobs"("video_id", "attempt");

-- CreateIndex
CREATE INDEX "idx_render_jobs_active" ON "render_jobs"("status", "queued_at");

-- CreateIndex
CREATE UNIQUE INDEX "idx_render_jobs_provider" ON "render_jobs"("provider_id", "provider_job_id");

-- CreateIndex
CREATE UNIQUE INDEX "render_providers_code_key" ON "render_providers"("code");

-- CreateIndex
CREATE UNIQUE INDEX "report_reasons_code_key" ON "report_reasons"("code");

-- CreateIndex
CREATE UNIQUE INDEX "slots_template_id_key_key" ON "slots"("template_id", "key");

-- CreateIndex
CREATE UNIQUE INDEX "templates_slug_key" ON "templates"("slug");

-- CreateIndex
CREATE INDEX "idx_templates_gallery" ON "templates"("status", "category_id", "published_at");

-- CreateIndex
CREATE UNIQUE INDEX "template_categories_slug_key" ON "template_categories"("slug");

-- CreateIndex
CREATE INDEX "idx_variants_ratio" ON "template_variants"("aspect_ratio_id", "template_id");

-- CreateIndex
CREATE UNIQUE INDEX "template_variants_template_id_aspect_ratio_id_key" ON "template_variants"("template_id", "aspect_ratio_id");

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "users_ecourse_member_id_key" ON "users"("ecourse_member_id");

-- CreateIndex
CREATE UNIQUE INDEX "uq_provider_identity" ON "user_auth_providers"("provider_id", "provider_user_id");

-- CreateIndex
CREATE UNIQUE INDEX "uq_user_provider" ON "user_auth_providers"("user_id", "provider_id");

-- CreateIndex
CREATE UNIQUE INDEX "verification_tokens_token_hash_key" ON "verification_tokens"("token_hash");

-- CreateIndex
CREATE INDEX "idx_tokens_user_purpose" ON "verification_tokens"("user_id", "purpose", "created_at");

-- CreateIndex
CREATE INDEX "idx_tokens_expiry" ON "verification_tokens"("expires_at");

-- CreateIndex
CREATE UNIQUE INDEX "videos_last_render_job_id_key" ON "videos"("last_render_job_id");

-- CreateIndex
CREATE INDEX "idx_videos_history" ON "videos"("user_id", "created_at");

-- AddForeignKey
ALTER TABLE "content_reports" ADD CONSTRAINT "content_reports_template_id_fkey" FOREIGN KEY ("template_id") REFERENCES "templates"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "content_reports" ADD CONSTRAINT "content_reports_video_id_fkey" FOREIGN KEY ("video_id") REFERENCES "videos"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "content_reports" ADD CONSTRAINT "content_reports_reporter_id_fkey" FOREIGN KEY ("reporter_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "content_reports" ADD CONSTRAINT "content_reports_reason_id_fkey" FOREIGN KEY ("reason_id") REFERENCES "report_reasons"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "content_reports" ADD CONSTRAINT "content_reports_reviewed_by_fkey" FOREIGN KEY ("reviewed_by") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "render_jobs" ADD CONSTRAINT "render_jobs_video_id_fkey" FOREIGN KEY ("video_id") REFERENCES "videos"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "render_jobs" ADD CONSTRAINT "render_jobs_provider_id_fkey" FOREIGN KEY ("provider_id") REFERENCES "render_providers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "render_jobs" ADD CONSTRAINT "render_jobs_retry_of_id_fkey" FOREIGN KEY ("retry_of_id") REFERENCES "render_jobs"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "slots" ADD CONSTRAINT "slots_template_id_fkey" FOREIGN KEY ("template_id") REFERENCES "templates"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "slot_placements" ADD CONSTRAINT "slot_placements_slot_id_fkey" FOREIGN KEY ("slot_id") REFERENCES "slots"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "slot_placements" ADD CONSTRAINT "slot_placements_variant_id_fkey" FOREIGN KEY ("variant_id") REFERENCES "template_variants"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "templates" ADD CONSTRAINT "templates_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "template_categories"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "templates" ADD CONSTRAINT "templates_default_palette_id_fkey" FOREIGN KEY ("default_palette_id") REFERENCES "palettes"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "templates" ADD CONSTRAINT "templates_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "template_variants" ADD CONSTRAINT "template_variants_template_id_fkey" FOREIGN KEY ("template_id") REFERENCES "templates"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "template_variants" ADD CONSTRAINT "template_variants_aspect_ratio_id_fkey" FOREIGN KEY ("aspect_ratio_id") REFERENCES "aspect_ratios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "usage_periods" ADD CONSTRAINT "usage_periods_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "usage_periods" ADD CONSTRAINT "usage_periods_plan_id_fkey" FOREIGN KEY ("plan_id") REFERENCES "plans"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "users" ADD CONSTRAINT "users_plan_id_fkey" FOREIGN KEY ("plan_id") REFERENCES "plans"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_auth_providers" ADD CONSTRAINT "user_auth_providers_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_auth_providers" ADD CONSTRAINT "user_auth_providers_provider_id_fkey" FOREIGN KEY ("provider_id") REFERENCES "auth_providers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_profiles" ADD CONSTRAINT "user_profiles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "verification_tokens" ADD CONSTRAINT "verification_tokens_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "videos" ADD CONSTRAINT "videos_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "videos" ADD CONSTRAINT "videos_template_id_fkey" FOREIGN KEY ("template_id") REFERENCES "templates"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "videos" ADD CONSTRAINT "videos_variant_id_fkey" FOREIGN KEY ("variant_id") REFERENCES "template_variants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "videos" ADD CONSTRAINT "videos_palette_id_fkey" FOREIGN KEY ("palette_id") REFERENCES "palettes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "videos" ADD CONSTRAINT "videos_last_render_job_id_fkey" FOREIGN KEY ("last_render_job_id") REFERENCES "render_jobs"("id") ON DELETE SET NULL ON UPDATE CASCADE;
