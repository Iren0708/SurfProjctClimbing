-- Schema for «Вертикаль» client API (see 01-analysis/4-design/data-model.md)

CREATE TABLE clients (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name            TEXT,
    phone           TEXT NOT NULL,
    phone_anonymized BOOLEAN NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ,
    CONSTRAINT clients_phone_e164_chk CHECK (phone ~ '^\+[1-9][0-9]{1,14}$'),
    CONSTRAINT clients_name_len_chk CHECK (name IS NULL OR char_length(name) BETWEEN 1 AND 100)
);

CREATE UNIQUE INDEX clients_phone_active_uidx ON clients (phone) WHERE deleted_at IS NULL;

CREATE TABLE auth_sessions (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id       UUID NOT NULL REFERENCES clients (id) ON DELETE CASCADE,
    refresh_token_hash TEXT NOT NULL UNIQUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at      TIMESTAMPTZ NOT NULL,
    revoked_at      TIMESTAMPTZ,
    CONSTRAINT auth_sessions_expiry_chk CHECK (expires_at > created_at)
);

CREATE INDEX auth_sessions_client_id_idx ON auth_sessions (client_id);

CREATE TABLE otp_codes (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone           TEXT NOT NULL,
    purpose         TEXT NOT NULL,
    code_hash       TEXT NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at      TIMESTAMPTZ NOT NULL,
    consumed_at     TIMESTAMPTZ,
    attempt_count   INTEGER NOT NULL DEFAULT 0,
    CONSTRAINT otp_codes_phone_e164_chk CHECK (phone ~ '^\+[1-9][0-9]{1,14}$'),
    CONSTRAINT otp_codes_purpose_chk CHECK (purpose IN ('login', 'phone_change')),
    CONSTRAINT otp_codes_expiry_chk CHECK (expires_at > created_at),
    CONSTRAINT otp_codes_attempt_count_chk CHECK (attempt_count >= 0)
);

CREATE INDEX otp_codes_phone_purpose_created_at_idx ON otp_codes (phone, purpose, created_at DESC);

CREATE TABLE zone_formats (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name            TEXT NOT NULL,
    description     TEXT,
    type            TEXT NOT NULL,
    capacity_cap    INTEGER NOT NULL,
    duration_min    INTEGER NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT zone_formats_type_chk CHECK (type IN ('novice', 'experienced')),
    CONSTRAINT zone_formats_capacity_chk CHECK (
        capacity_cap > 0
        AND ((type = 'novice' AND capacity_cap <= 8) OR (type = 'experienced' AND capacity_cap <= 16))
    ),
    CONSTRAINT zone_formats_duration_chk CHECK (duration_min > 0)
);

CREATE TABLE instructors (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name            TEXT NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE slots (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    zone_format_id          UUID NOT NULL REFERENCES zone_formats (id) ON DELETE RESTRICT,
    instructor_id           UUID NOT NULL REFERENCES instructors (id) ON DELETE RESTRICT,
    start_at                TIMESTAMPTZ NOT NULL,
    total_seats             INTEGER NOT NULL,
    free_seats              INTEGER NOT NULL,
    free_rental_equipment   INTEGER NOT NULL,
    rental_equipment_total  INTEGER NOT NULL,
    price                   INTEGER NOT NULL,
    rental_price            INTEGER NOT NULL,
    status                  TEXT NOT NULL DEFAULT 'scheduled',
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT slots_status_chk CHECK (status IN ('scheduled', 'cancelled')),
    CONSTRAINT slots_seats_chk CHECK (total_seats > 0 AND free_seats >= 0 AND free_seats <= total_seats),
    CONSTRAINT slots_rental_chk CHECK (
        rental_equipment_total >= 0
        AND free_rental_equipment >= 0
        AND free_rental_equipment <= rental_equipment_total
    ),
    CONSTRAINT slots_price_chk CHECK (price >= 0 AND rental_price >= 0)
);

CREATE INDEX slots_start_at_idx ON slots (start_at);
CREATE INDEX slots_status_idx ON slots (status);
CREATE INDEX slots_zone_format_id_idx ON slots (zone_format_id);
CREATE INDEX slots_instructor_id_idx ON slots (instructor_id);

CREATE TABLE bookings (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slot_id             UUID NOT NULL REFERENCES slots (id) ON DELETE RESTRICT,
    client_id           UUID NOT NULL REFERENCES clients (id) ON DELETE RESTRICT,
    equipment           TEXT NOT NULL,
    status              TEXT NOT NULL DEFAULT 'active',
    price_total         INTEGER NOT NULL,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    cancelled_at        TIMESTAMPTZ,
    cancellation_reason TEXT,
    CONSTRAINT bookings_equipment_chk CHECK (equipment IN ('own', 'rental')),
    CONSTRAINT bookings_status_chk CHECK (status IN ('active', 'cancelled', 'late_cancel', 'club_cancelled')),
    CONSTRAINT bookings_price_total_chk CHECK (price_total >= 0),
    CONSTRAINT bookings_cancelled_at_chk CHECK (
        (status = 'active' AND cancelled_at IS NULL)
        OR (status <> 'active' AND cancelled_at IS NOT NULL)
    )
);

CREATE UNIQUE INDEX bookings_active_client_slot_uidx ON bookings (client_id, slot_id) WHERE status = 'active';
CREATE INDEX bookings_slot_id_idx ON bookings (slot_id);
CREATE INDEX bookings_client_id_idx ON bookings (client_id);
CREATE INDEX bookings_status_idx ON bookings (status);

CREATE TABLE idempotency_keys (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id       UUID NOT NULL REFERENCES clients (id) ON DELETE CASCADE,
    idempotency_key UUID NOT NULL,
    request_hash    TEXT NOT NULL,
    response_status INTEGER,
    response_body   JSONB,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at      TIMESTAMPTZ NOT NULL,
    CONSTRAINT idempotency_keys_expiry_chk CHECK (expires_at > created_at),
    UNIQUE (client_id, idempotency_key)
);

CREATE INDEX idempotency_keys_expires_at_idx ON idempotency_keys (expires_at);
