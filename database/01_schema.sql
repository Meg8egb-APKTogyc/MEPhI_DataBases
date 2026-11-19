BEGIN;

DROP TABLE IF EXISTS likes          CASCADE;
DROP TABLE IF EXISTS comments       CASCADE;
DROP TABLE IF EXISTS chart          CASCADE;
DROP TABLE IF EXISTS remix_tag      CASCADE;
DROP TABLE IF EXISTS playlist_remix CASCADE;
DROP TABLE IF EXISTS views          CASCADE;
DROP TABLE IF EXISTS tags           CASCADE;
DROP TABLE IF EXISTS playlists      CASCADE;
DROP TABLE IF EXISTS remixes        CASCADE;
DROP TABLE IF EXISTS remixers       CASCADE;
DROP TABLE IF EXISTS users          CASCADE;
DROP TABLE IF EXISTS albums         CASCADE;
DROP TABLE IF EXISTS singers        CASCADE;

CREATE TABLE singers (
    id      bigserial PRIMARY KEY,
    name    text        NOT NULL,
    age     smallint    CHECK (age >= 0 AND age <= 150),
    genre   text,
    country text
);

CREATE TABLE albums (
    id    bigserial PRIMARY KEY,
    title text      NOT NULL,
    year  smallint  NOT NULL CHECK (year >= 1900 AND year <= 2100)
);

CREATE TABLE users (
    id        bigserial PRIMARY KEY,
    name      text        NOT NULL UNIQUE,
    pass_hash text        NOT NULL,
    role      text        NOT NULL DEFAULT 'user'
        CHECK (role IN ('user', 'moderator', 'admin'))
);

CREATE TABLE remixers (
    id                 bigserial PRIMARY KEY,
    name               text        NOT NULL,
    age                smallint    CHECK (age >= 0 AND age <= 150),
    registered_at      timestamptz NOT NULL DEFAULT now(),
    favorite_singer_id bigint      REFERENCES singers (id) ON DELETE SET NULL
);

CREATE TABLE remixes (
    id                 bigserial PRIMARY KEY,
    preview            text   NOT NULL,
    remixer_id         bigint NOT NULL REFERENCES remixers (id) ON DELETE CASCADE,
    original_singer_id bigint NOT NULL REFERENCES singers   (id) ON DELETE RESTRICT,
    resinger_id        bigint NOT NULL REFERENCES singers   (id) ON DELETE RESTRICT,
    album_id           bigint REFERENCES albums (id) ON DELETE SET NULL
);

CREATE TABLE playlists (
    id         bigserial PRIMARY KEY,
    title      text        NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    is_public  boolean     NOT NULL DEFAULT true,
    user_id    bigint      NOT NULL REFERENCES users (id) ON DELETE CASCADE
);

CREATE TABLE tags (
    id         bigserial PRIMARY KEY,
    label      text        NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    creator_id bigint      NOT NULL REFERENCES users (id) ON DELETE CASCADE
);

CREATE TABLE playlist_remix (
    playlist_id bigint NOT NULL REFERENCES playlists (id) ON DELETE CASCADE,
    remix_id    bigint NOT NULL REFERENCES remixes   (id) ON DELETE CASCADE,
    PRIMARY KEY (playlist_id, remix_id)
);

CREATE TABLE remix_tag (
    remix_id bigint NOT NULL REFERENCES remixes (id) ON DELETE CASCADE,
    tag_id   bigint NOT NULL REFERENCES tags    (id) ON DELETE CASCADE,
    PRIMARY KEY (remix_id, tag_id)
);

CREATE TABLE views (
    id        bigserial PRIMARY KEY,
    viewed_at timestamptz NOT NULL DEFAULT now(),
    user_id   bigint      NOT NULL REFERENCES users   (id) ON DELETE CASCADE,
    remix_id  bigint      NOT NULL REFERENCES remixes (id) ON DELETE CASCADE
);


CREATE TABLE chart (
    remix_id bigint  PRIMARY KEY REFERENCES remixes (id) ON DELETE CASCADE,
    place    integer NOT NULL CHECK (place > 0),
    views    bigint  NOT NULL DEFAULT 0 CHECK (views >= 0)
);

CREATE TABLE comments (
    id         bigserial PRIMARY KEY,
    text       text        NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    user_id    bigint      NOT NULL REFERENCES users   (id) ON DELETE CASCADE,
    remix_id   bigint      NOT NULL REFERENCES remixes (id) ON DELETE CASCADE,
    parent_id  bigint      REFERENCES comments (id) ON DELETE CASCADE,
    CONSTRAINT chk_comment_no_self_reply
        CHECK (parent_id IS NULL OR parent_id <> id)
);

CREATE TABLE likes (
    id         bigserial PRIMARY KEY,
    created_at timestamptz NOT NULL DEFAULT now(),
    user_id    bigint      NOT NULL REFERENCES users   (id) ON DELETE CASCADE,
    remix_id   bigint      NOT NULL REFERENCES remixes (id) ON DELETE CASCADE,
    CONSTRAINT uq_like_user_remix UNIQUE (user_id, remix_id)
);

COMMIT;
