BEGIN;

ALTER TABLE archive.document
    ADD CONSTRAINT archive_document_current_version_no_check
    CHECK (current_version_no >= 1);

ALTER TABLE archive.document_version
    ADD CONSTRAINT archive_document_version_version_no_check
    CHECK (version_no >= 1);

ALTER TABLE media.asset
    ADD CONSTRAINT media_asset_storage_path_key
    UNIQUE (storage_path);

ALTER TABLE chats.tag
    ADD CONSTRAINT chats_tag_session_tag_unique
    UNIQUE NULLS NOT DISTINCT (session_id, message_id, tag);

COMMIT;
