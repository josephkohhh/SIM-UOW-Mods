-- -------------------------------------------------------------
-- TablePlus 27.2.0(840)
--
-- https://tableplus.com/
--
-- Database: sim2026q4mag5
-- Generation Time: 2026-11-05 13:17:03.1010
-- -------------------------------------------------------------


-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS idp_category_category_id_seq;

-- Table Definition
CREATE TABLE "public"."idp_category" (
    "category_id" int4 NOT NULL DEFAULT nextval('idp_category_category_id_seq'::regclass),
    "category_code" varchar(100) NOT NULL,
    "description" text NOT NULL,
    PRIMARY KEY ("category_id")
);

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS userprofile_profile_id_seq;

-- Table Definition
CREATE TABLE "public"."userprofile" (
    "profile_id" int4 NOT NULL DEFAULT nextval('userprofile_profile_id_seq'::regclass),
    "role" varchar(100) NOT NULL,
    "description" text NOT NULL,
    PRIMARY KEY ("profile_id")
);

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS companyprofile_companyprofile_id_seq;
DROP TYPE IF EXISTS "public"."companyprofile_status";
CREATE TYPE "public"."companyprofile_status" AS ENUM ('ACTIVE', 'INACTIVE');

-- Table Definition
CREATE TABLE "public"."companyprofile" (
    "companyprofile_id" int4 NOT NULL DEFAULT nextval('companyprofile_companyprofile_id_seq'::regclass),
    "user_id" int4 NOT NULL,
    "company_name" varchar(150),
    "description" text,
    "phone_no" varchar(30),
    "address" varchar(255),
    "status" "public"."companyprofile_status" NOT NULL DEFAULT 'ACTIVE'::companyprofile_status,
    "created_at" timestamp NOT NULL DEFAULT now(),
    "updated_at" timestamp NOT NULL DEFAULT now(),
    PRIMARY KEY ("companyprofile_id")
);

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS idpcategory_category_id_seq;

-- Table Definition
CREATE TABLE "public"."idpcategory" (
    "category_id" int4 NOT NULL DEFAULT nextval('idpcategory_category_id_seq'::regclass),
    "category_code" varchar(100) NOT NULL,
    "description" text NOT NULL,
    PRIMARY KEY ("category_id")
);

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS useraccount_user_id_seq;
DROP TYPE IF EXISTS "public"."user_role";
CREATE TYPE "public"."user_role" AS ENUM ('CUSTOMER', 'INTERIOR_DESIGNER', 'ADMIN', 'PLATFORM_MANAGEMENT');
DROP TYPE IF EXISTS "public"."user_status";
CREATE TYPE "public"."user_status" AS ENUM ('ACTIVE', 'INACTIVE');

-- Table Definition
CREATE TABLE "public"."useraccount" (
    "user_id" int4 NOT NULL DEFAULT nextval('useraccount_user_id_seq'::regclass),
    "email" varchar(255) NOT NULL,
    "password_hash" varchar(255) NOT NULL,
    "role" "public"."user_role" NOT NULL,
    "name" varchar(100) NOT NULL,
    "surname" varchar(100) NOT NULL,
    "phone_no" varchar(30) NOT NULL,
    "status" "public"."user_status" NOT NULL DEFAULT 'ACTIVE'::user_status,
    "created_at" timestamp NOT NULL DEFAULT now(),
    "updated_at" timestamp NOT NULL DEFAULT now(),
    PRIMARY KEY ("user_id")
);

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS project_project_id_seq;
DROP TYPE IF EXISTS "public"."project_status";
CREATE TYPE "public"."project_status" AS ENUM ('ONGOING', 'COMPLETED', 'CANCELLED');

-- Table Definition
CREATE TABLE "public"."project" (
    "project_id" int4 NOT NULL DEFAULT nextval('project_project_id_seq'::regclass),
    "user_id" int4 NOT NULL,
    "companyprofile_id" int4 NOT NULL,
    "project_name" varchar(150) NOT NULL,
    "description" text NOT NULL,
    "category_code" varchar(100) NOT NULL,
    "status" "public"."project_status" NOT NULL DEFAULT 'ONGOING'::project_status,
    "created_at" timestamp NOT NULL DEFAULT now(),
    "updated_at" timestamp NOT NULL DEFAULT now(),
    PRIMARY KEY ("project_id")
);

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS projectview_view_id_seq;

-- Table Definition
CREATE TABLE "public"."projectview" (
    "view_id" int4 NOT NULL DEFAULT nextval('projectview_view_id_seq'::regclass),
    "project_id" int4 NOT NULL,
    "user_id" int4 NOT NULL,
    "created_at" timestamp NOT NULL DEFAULT now(),
    PRIMARY KEY ("view_id")
);

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS favorite_favourite_id_seq;

-- Table Definition
CREATE TABLE "public"."favorite" (
    "favourite_id" int4 NOT NULL DEFAULT nextval('favorite_favourite_id_seq'::regclass),
    "user_id" int4 NOT NULL,
    "project_id" int4 NOT NULL,
    "created_at" timestamp NOT NULL DEFAULT now(),
    PRIMARY KEY ("favourite_id")
);



-- Indices
CREATE UNIQUE INDEX idp_category_category_code_key ON public.idp_category USING btree (category_code);
CREATE INDEX ix_idp_category_category_id ON public.idp_category USING btree (category_id);


-- Indices
CREATE UNIQUE INDEX userprofile_role_key ON public.userprofile USING btree (role);
CREATE INDEX ix_userprofile_profile_id ON public.userprofile USING btree (profile_id);


-- Indices
CREATE UNIQUE INDEX companyprofile_user_id_key ON public.companyprofile USING btree (user_id);
CREATE INDEX ix_companyprofile_companyprofile_id ON public.companyprofile USING btree (companyprofile_id);
ALTER TABLE "public"."companyprofile" ADD FOREIGN KEY ("user_id") REFERENCES "public"."useraccount"("user_id");


-- Indices
CREATE UNIQUE INDEX idpcategory_category_code_key ON public.idpcategory USING btree (category_code);
CREATE INDEX ix_idpcategory_category_id ON public.idpcategory USING btree (category_id);


-- Indices
CREATE UNIQUE INDEX ix_useraccount_email ON public.useraccount USING btree (email);
CREATE INDEX ix_useraccount_user_id ON public.useraccount USING btree (user_id);


-- Indices
CREATE UNIQUE INDEX project_project_name_key ON public.project USING btree (project_name);
CREATE INDEX ix_project_project_id ON public.project USING btree (project_id);
ALTER TABLE "public"."project" ADD FOREIGN KEY ("companyprofile_id") REFERENCES "public"."companyprofile"("companyprofile_id");
ALTER TABLE "public"."project" ADD FOREIGN KEY ("user_id") REFERENCES "public"."useraccount"("user_id");


-- Indices
CREATE INDEX ix_projectview_view_id ON public.projectview USING btree (view_id);
ALTER TABLE "public"."projectview" ADD FOREIGN KEY ("project_id") REFERENCES "public"."project"("project_id") ON DELETE CASCADE;
ALTER TABLE "public"."projectview" ADD FOREIGN KEY ("user_id") REFERENCES "public"."useraccount"("user_id") ON DELETE CASCADE;


-- Indices
CREATE UNIQUE INDEX unique_user_project ON public.favorite USING btree (user_id, project_id);
CREATE INDEX ix_favorite_favourite_id ON public.favorite USING btree (favourite_id);
ALTER TABLE "public"."favorite" ADD FOREIGN KEY ("user_id") REFERENCES "public"."useraccount"("user_id") ON DELETE CASCADE;
ALTER TABLE "public"."favorite" ADD FOREIGN KEY ("project_id") REFERENCES "public"."project"("project_id") ON DELETE CASCADE;
