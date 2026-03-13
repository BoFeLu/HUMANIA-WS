-- NOTE: updated_at fields are not auto-maintained by PostgreSQL in this DDL.
-- They must be updated by application logic or future triggers.

BEGIN;

SET search_path = public;

-- =========================================================
-- IDEAS
-- =========================================================

CREATE TABLE IF NOT EXISTS ideas.idea (
    idea_id              bigserial PRIMARY KEY,
    title                text NOT NULL,
    summary              text,
    body                 text,
    status               text NOT NULL DEFAULT 'draft',
    priority             smallint NOT NULL DEFAULT 3,
    source_type          text NOT NULL DEFAULT 'manual',
    source_ref           text,
    created_at           timestamptz NOT NULL DEFAULT now(),
    updated_at           timestamptz NOT NULL DEFAULT now(),
    created_by           text NOT NULL DEFAULT current_user,
    CHECK (status IN ('draft','active','validated','archived','rejected')),
    CHECK (priority BETWEEN 1 AND 5)
);

CREATE INDEX IF NOT EXISTS idx_ideas_idea_status
    ON ideas.idea(status);

CREATE INDEX IF NOT EXISTS idx_ideas_idea_priority
    ON ideas.idea(priority);

CREATE INDEX IF NOT EXISTS idx_ideas_idea_created_at
    ON ideas.idea(created_at DESC);

CREATE TABLE IF NOT EXISTS ideas.idea_tag (
    idea_tag_id           bigserial PRIMARY KEY,
    idea_id               bigint NOT NULL REFERENCES ideas.idea(idea_id) ON DELETE CASCADE,
    tag                   text NOT NULL,
    created_at            timestamptz NOT NULL DEFAULT now(),
    UNIQUE (idea_id, tag)
);

CREATE INDEX IF NOT EXISTS idx_ideas_idea_tag_tag
    ON ideas.idea_tag(tag);

CREATE TABLE IF NOT EXISTS ideas.idea_relation (
    idea_relation_id      bigserial PRIMARY KEY,
    from_idea_id          bigint NOT NULL REFERENCES ideas.idea(idea_id) ON DELETE CASCADE,
    to_idea_id            bigint NOT NULL REFERENCES ideas.idea(idea_id) ON DELETE CASCADE,
    relation_type         text NOT NULL DEFAULT 'related',
    created_at            timestamptz NOT NULL DEFAULT now(),
    CHECK (from_idea_id <> to_idea_id),
    CHECK (relation_type IN ('related','depends_on','expands','conflicts_with','derived_from')),
    UNIQUE (from_idea_id, to_idea_id, relation_type)
);

-- =========================================================
-- ARCHIVE
-- =========================================================

CREATE TABLE IF NOT EXISTS archive.document (
    document_id           bigserial PRIMARY KEY,
    title                 text NOT NULL,
    doc_type              text NOT NULL DEFAULT 'generic',
    logical_path          text,
    source_system         text NOT NULL DEFAULT 'local',
    source_ref            text,
    current_version_no    integer NOT NULL DEFAULT 1,
    checksum_sha256       text,
    created_at            timestamptz NOT NULL DEFAULT now(),
    updated_at            timestamptz NOT NULL DEFAULT now(),
    created_by            text NOT NULL DEFAULT current_user
);

CREATE INDEX IF NOT EXISTS idx_archive_document_doc_type
    ON archive.document(doc_type);

CREATE INDEX IF NOT EXISTS idx_archive_document_source_system
    ON archive.document(source_system);

CREATE TABLE IF NOT EXISTS archive.document_version (
    document_version_id   bigserial PRIMARY KEY,
    document_id           bigint NOT NULL REFERENCES archive.document(document_id) ON DELETE CASCADE,
    version_no            integer NOT NULL,
    content_format        text NOT NULL DEFAULT 'text',
    storage_path          text,
    checksum_sha256       text,
    content_excerpt       text,
    created_at            timestamptz NOT NULL DEFAULT now(),
    created_by            text NOT NULL DEFAULT current_user,
    UNIQUE (document_id, version_no)
);

CREATE INDEX IF NOT EXISTS idx_archive_document_version_document
    ON archive.document_version(document_id, version_no DESC);

CREATE TABLE IF NOT EXISTS archive.document_tag (
    document_tag_id       bigserial PRIMARY KEY,
    document_id           bigint NOT NULL REFERENCES archive.document(document_id) ON DELETE CASCADE,
    tag                   text NOT NULL,
    created_at            timestamptz NOT NULL DEFAULT now(),
    UNIQUE (document_id, tag)
);

CREATE INDEX IF NOT EXISTS idx_archive_document_tag_tag
    ON archive.document_tag(tag);

-- =========================================================
-- MEDIA
-- =========================================================

CREATE TABLE IF NOT EXISTS media.asset (
    asset_id              bigserial PRIMARY KEY,
    asset_name            text NOT NULL,
    asset_type            text NOT NULL,
    mime_type             text,
    storage_path          text NOT NULL,
    checksum_sha256       text,
    size_bytes            bigint,
    captured_at           timestamptz,
    created_at            timestamptz NOT NULL DEFAULT now(),
    updated_at            timestamptz NOT NULL DEFAULT now(),
    created_by            text NOT NULL DEFAULT current_user,
    CHECK (asset_type IN ('image','audio','video','document','binary','other')),
    CHECK (size_bytes IS NULL OR size_bytes >= 0)
);

CREATE INDEX IF NOT EXISTS idx_media_asset_type
    ON media.asset(asset_type);

CREATE INDEX IF NOT EXISTS idx_media_asset_created_at
    ON media.asset(created_at DESC);

CREATE TABLE IF NOT EXISTS media.asset_tag (
    asset_tag_id          bigserial PRIMARY KEY,
    asset_id              bigint NOT NULL REFERENCES media.asset(asset_id) ON DELETE CASCADE,
    tag                   text NOT NULL,
    created_at            timestamptz NOT NULL DEFAULT now(),
    UNIQUE (asset_id, tag)
);

CREATE INDEX IF NOT EXISTS idx_media_asset_tag_tag
    ON media.asset_tag(tag);

CREATE TABLE IF NOT EXISTS media.asset_reference (
    asset_reference_id    bigserial PRIMARY KEY,
    asset_id              bigint NOT NULL REFERENCES media.asset(asset_id) ON DELETE CASCADE,
    ref_kind              text NOT NULL,
    ref_schema            text,
    ref_table             text,
    ref_id_text           text NOT NULL,
    created_at            timestamptz NOT NULL DEFAULT now(),
    CHECK (ref_kind IN ('idea','document','chat_message','knowledge_item','external','other'))
);

CREATE INDEX IF NOT EXISTS idx_media_asset_reference_asset
    ON media.asset_reference(asset_id);

CREATE INDEX IF NOT EXISTS idx_media_asset_reference_target
    ON media.asset_reference(ref_kind, ref_schema, ref_table, ref_id_text);

-- =========================================================
-- CHATS
-- =========================================================

CREATE TABLE IF NOT EXISTS chats.session (
    session_id            bigserial PRIMARY KEY,
    session_title         text NOT NULL,
    platform              text NOT NULL DEFAULT 'unknown',
    external_session_ref  text,
    started_at            timestamptz NOT NULL DEFAULT now(),
    ended_at              timestamptz,
    created_at            timestamptz NOT NULL DEFAULT now(),
    created_by            text NOT NULL DEFAULT current_user,
    status                text NOT NULL DEFAULT 'open',
    CHECK (status IN ('open','closed','archived'))
);

CREATE INDEX IF NOT EXISTS idx_chats_session_started_at
    ON chats.session(started_at DESC);

CREATE TABLE IF NOT EXISTS chats.message (
    message_id            bigserial PRIMARY KEY,
    session_id            bigint NOT NULL REFERENCES chats.session(session_id) ON DELETE CASCADE,
    message_order         integer NOT NULL,
    role                  text NOT NULL,
    content               text NOT NULL,
    model_name            text,
    external_message_ref  text,
    created_at            timestamptz NOT NULL DEFAULT now(),
    CHECK (message_order >= 1),
    CHECK (role IN ('system','user','assistant','tool','other')),
    UNIQUE (session_id, message_order)
);

CREATE INDEX IF NOT EXISTS idx_chats_message_session
    ON chats.message(session_id, message_order);

CREATE TABLE IF NOT EXISTS chats.tag (
    chat_tag_id           bigserial PRIMARY KEY,
    session_id            bigint REFERENCES chats.session(session_id) ON DELETE CASCADE,
    message_id            bigint REFERENCES chats.message(message_id) ON DELETE CASCADE,
    tag                   text NOT NULL,
    created_at            timestamptz NOT NULL DEFAULT now(),
    CHECK (
        (session_id IS NOT NULL AND message_id IS NULL)
        OR
        (session_id IS NULL AND message_id IS NOT NULL)
    )
);

CREATE INDEX IF NOT EXISTS idx_chats_tag_tag
    ON chats.tag(tag);

COMMIT;

