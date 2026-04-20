-- Esquema base para base de datos propia del generador.

CREATE SCHEMA IF NOT EXISTS generator;

CREATE TABLE IF NOT EXISTS generator.templates (
  id UUID PRIMARY KEY,
  code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS generator.documents (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL,
  created_by_user_id UUID NOT NULL,
  template_id UUID NOT NULL REFERENCES generator.templates(id),
  status TEXT NOT NULL CHECK (status IN ('draft', 'rendered', 'failed')),
  payload JSONB NOT NULL,
  rendered_file_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_generator_documents_tenant
  ON generator.documents(tenant_id);

CREATE INDEX IF NOT EXISTS idx_generator_documents_created_by
  ON generator.documents(created_by_user_id);
