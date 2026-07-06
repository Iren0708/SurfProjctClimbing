-- Dev seed: zone formats, instructors, slots (next 7 days from migration time)

INSERT INTO zone_formats (id, name, description, type, capacity_cap, duration_min)
VALUES
    (
        '11111111-1111-1111-1111-111111111101',
        'Болдеринг',
        'Групповой болдеринг с инструктажем для новичков',
        'novice',
        8,
        90
    ),
    (
        '11111111-1111-1111-1111-111111111102',
        'Трассы с верёвкой',
        'Групповая тренировка на верёвочных трассах',
        'experienced',
        16,
        90
    )
ON CONFLICT (id) DO NOTHING;

INSERT INTO instructors (id, name)
VALUES
    ('33333333-3333-3333-3333-333333333333', 'Анна'),
    ('44444444-4444-4444-4444-444444444444', 'Дмитрий')
ON CONFLICT (id) DO NOTHING;

INSERT INTO slots (
    id,
    zone_format_id,
    instructor_id,
    start_at,
    total_seats,
    free_seats,
    free_rental_equipment,
    rental_equipment_total,
    price,
    rental_price,
    status
)
VALUES
    (
        '55555555-5555-5555-5555-555555555501',
        '11111111-1111-1111-1111-111111111101',
        '33333333-3333-3333-3333-333333333333',
        (DATE_TRUNC('day', NOW() AT TIME ZONE 'Europe/Moscow') + INTERVAL '1 day' + INTERVAL '18 hours')
            AT TIME ZONE 'Europe/Moscow',
        8,
        5,
        4,
        6,
        1200,
        400,
        'scheduled'
    ),
    (
        '55555555-5555-5555-5555-555555555502',
        '11111111-1111-1111-1111-111111111101',
        '44444444-4444-4444-4444-444444444444',
        (DATE_TRUNC('day', NOW() AT TIME ZONE 'Europe/Moscow') + INTERVAL '2 days' + INTERVAL '10 hours')
            AT TIME ZONE 'Europe/Moscow',
        8,
        8,
        6,
        6,
        1200,
        400,
        'scheduled'
    ),
    (
        '55555555-5555-5555-5555-555555555503',
        '11111111-1111-1111-1111-111111111102',
        '33333333-3333-3333-3333-333333333333',
        (DATE_TRUNC('day', NOW() AT TIME ZONE 'Europe/Moscow') + INTERVAL '2 days' + INTERVAL '19 hours')
            AT TIME ZONE 'Europe/Moscow',
        12,
        0,
        3,
        8,
        1500,
        500,
        'scheduled'
    ),
    (
        '55555555-5555-5555-5555-555555555504',
        '11111111-1111-1111-1111-111111111102',
        '44444444-4444-4444-4444-444444444444',
        (DATE_TRUNC('day', NOW() AT TIME ZONE 'Europe/Moscow') + INTERVAL '4 days' + INTERVAL '18 hours')
            AT TIME ZONE 'Europe/Moscow',
        14,
        10,
        5,
        8,
        1500,
        500,
        'scheduled'
    ),
    (
        '55555555-5555-5555-5555-555555555505',
        '11111111-1111-1111-1111-111111111101',
        '33333333-3333-3333-3333-333333333333',
        (DATE_TRUNC('day', NOW() AT TIME ZONE 'Europe/Moscow') + INTERVAL '5 days' + INTERVAL '12 hours')
            AT TIME ZONE 'Europe/Moscow',
        8,
        3,
        1,
        6,
        1200,
        400,
        'scheduled'
    ),
    (
        '55555555-5555-5555-5555-555555555506',
        '11111111-1111-1111-1111-111111111102',
        '44444444-4444-4444-4444-444444444444',
        (DATE_TRUNC('day', NOW() AT TIME ZONE 'Europe/Moscow') + INTERVAL '6 days' + INTERVAL '20 hours')
            AT TIME ZONE 'Europe/Moscow',
        16,
        12,
        8,
        8,
        1500,
        500,
        'scheduled'
    ),
    (
        '55555555-5555-5555-5555-555555555507',
        '11111111-1111-1111-1111-111111111101',
        '44444444-4444-4444-4444-444444444444',
        (DATE_TRUNC('day', NOW() AT TIME ZONE 'Europe/Moscow') + INTERVAL '7 days' + INTERVAL '11 hours')
            AT TIME ZONE 'Europe/Moscow',
        8,
        6,
        6,
        6,
        1200,
        400,
        'scheduled'
    ),
    (
        '55555555-5555-5555-5555-555555555508',
        '11111111-1111-1111-1111-111111111102',
        '33333333-3333-3333-3333-333333333333',
        (DATE_TRUNC('day', NOW() AT TIME ZONE 'Europe/Moscow') + INTERVAL '3 days' + INTERVAL '18 hours')
            AT TIME ZONE 'Europe/Moscow',
        12,
        12,
        8,
        8,
        1500,
        500,
        'cancelled'
    )
ON CONFLICT (id) DO NOTHING;
