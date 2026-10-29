/* створення таблиць*/

CREATE TABLE app_user(                    -- користувач
    user_id INT NOT NULL,                 -- N користувача
    goal VARCHAR(100) NOT NULL,           -- ціль тренувань
    fitness_level VARCHAR(20) NOT NULL    -- рівень фізичної підготовки
);

CREATE TABLE training_program(            -- тренувальна програма
    program_id INT NOT NULL,              -- N програми
    goal VARCHAR(100) NOT NULL,           -- ціль програми
    fitness_level VARCHAR(20) NOT NULL    -- рівень підготовки
);

CREATE TABLE fitness_exercise(            -- фітнес-вправа
    exercise_id INT NOT NULL,             -- N вправи
    name VARCHAR(100) NOT NULL            -- назва вправи
);

CREATE TABLE user_program(                -- зв'язок користувач-програма (M:N)
    user_id INT NOT NULL,
    program_id INT NOT NULL
);

CREATE TABLE program_exercise(            -- зв'язок програма-вправа (M:N)
    program_id INT NOT NULL,
    exercise_id INT NOT NULL
);

CREATE TABLE reference_params(            -- еталонні параметри вправи
    reference_id INT NOT NULL,            -- N еталонних параметрів
    exercise_id INT NOT NULL,             -- вправа (1:1)
    tilt_angle REAL NOT NULL,             -- еталонний кут нахилу, градуси
    speed REAL NOT NULL                   -- еталонна швидкість, м/с
);

CREATE TABLE reference_trajectory_point(  -- точка еталонної траєкторії
    point_id INT NOT NULL,
    reference_id INT NOT NULL,
    seq_no INT NOT NULL,                  -- порядковий номер точки
    x REAL NOT NULL,
    y REAL NOT NULL,
    z REAL NOT NULL
);

CREATE TABLE gymnastic_stick(             -- гімнастична палиця
    stick_id INT NOT NULL
);

CREATE TABLE ar_marker(                   -- AR-маркер палиці
    stick_id INT NOT NULL,
    graphic_pattern BYTEA NOT NULL        -- графічний шаблон
);

CREATE TABLE training_session(            -- сеанс тренування
    session_id INT NOT NULL,
    user_id INT NOT NULL,
    program_id INT NOT NULL,
    stick_id INT NOT NULL,
    start_time TIMESTAMP NOT NULL,        -- час початку
    end_time TIMESTAMP                    -- час завершення (NULL, поки сеанс триває)
);

CREATE TABLE position_measurement(        -- вимірювання положення палиці
    measurement_id INT NOT NULL,
    session_id INT NOT NULL,
    reference_id INT NOT NULL,
    tilt_angle REAL NOT NULL,             -- кут нахилу, градуси
    rotation_angle REAL NOT NULL,         -- кут обертання, градуси
    motion_amplitude REAL NOT NULL,       -- амплітуда руху, м
    recorded_at TIMESTAMP NOT NULL        -- час фіксації
);

CREATE TABLE measurement_trajectory_point( -- точка фактичної траєкторії
    point_id INT NOT NULL,
    measurement_id INT NOT NULL,
    seq_no INT NOT NULL,
    x REAL NOT NULL,
    y REAL NOT NULL,
    z REAL NOT NULL
);

CREATE TABLE technique_error(             -- помилка техніки
    error_id INT NOT NULL,
    measurement_id INT NOT NULL,
    description VARCHAR(255) NOT NULL
);

CREATE TABLE audiovisual_feedback(        -- аудіовізуальний зворотний зв'язок
    feedback_id INT NOT NULL,
    error_id INT NOT NULL,
    generated_at TIMESTAMP NOT NULL       -- час генерації
);

CREATE TABLE hint(                        -- підказка
    feedback_id INT NOT NULL,
    visual_element VARCHAR(100) NOT NULL, -- тип візуального елемента
    sound_signal VARCHAR(100)             -- ідентифікатор звуку (може бути NULL)
);

CREATE TABLE notification(                -- сповіщення
    feedback_id INT NOT NULL,
    text VARCHAR(255) NOT NULL
);

/* обмеження первинного ключа */

ALTER TABLE app_user ADD CONSTRAINT app_user_pk
    PRIMARY KEY (user_id);
ALTER TABLE training_program ADD CONSTRAINT training_program_pk
    PRIMARY KEY (program_id);
ALTER TABLE fitness_exercise ADD CONSTRAINT fitness_exercise_pk
    PRIMARY KEY (exercise_id);
ALTER TABLE user_program ADD CONSTRAINT user_program_pk
    PRIMARY KEY (user_id, program_id);
ALTER TABLE program_exercise ADD CONSTRAINT program_exercise_pk
    PRIMARY KEY (program_id, exercise_id);
ALTER TABLE reference_params ADD CONSTRAINT reference_params_pk
    PRIMARY KEY (reference_id);
ALTER TABLE reference_trajectory_point ADD CONSTRAINT ref_point_pk
    PRIMARY KEY (point_id);
ALTER TABLE gymnastic_stick ADD CONSTRAINT gymnastic_stick_pk
    PRIMARY KEY (stick_id);
ALTER TABLE ar_marker ADD CONSTRAINT ar_marker_pk
    PRIMARY KEY (stick_id);
ALTER TABLE training_session ADD CONSTRAINT training_session_pk
    PRIMARY KEY (session_id);
ALTER TABLE position_measurement ADD CONSTRAINT position_measurement_pk
    PRIMARY KEY (measurement_id);
ALTER TABLE measurement_trajectory_point ADD CONSTRAINT meas_point_pk
    PRIMARY KEY (point_id);
ALTER TABLE technique_error ADD CONSTRAINT technique_error_pk
    PRIMARY KEY (error_id);
ALTER TABLE audiovisual_feedback ADD CONSTRAINT audiovisual_feedback_pk
    PRIMARY KEY (feedback_id);
ALTER TABLE hint ADD CONSTRAINT hint_pk
    PRIMARY KEY (feedback_id);
ALTER TABLE notification ADD CONSTRAINT notification_pk
    PRIMARY KEY (feedback_id);

/* обмеження потенційного ключа */

-- одна вправа має один набір еталонних параметрів (1:1)
ALTER TABLE reference_params ADD CONSTRAINT reference_params_exercise_uq
    UNIQUE (exercise_id);

-- порядковий номер точки унікальний в межах траєкторії
ALTER TABLE reference_trajectory_point ADD CONSTRAINT ref_point_seq_uq
    UNIQUE (reference_id, seq_no);
ALTER TABLE measurement_trajectory_point ADD CONSTRAINT meas_point_seq_uq
    UNIQUE (measurement_id, seq_no);

/* обмеження зовнішнього ключа */

ALTER TABLE user_program ADD CONSTRAINT user_program_user_fk
    FOREIGN KEY (user_id) REFERENCES app_user (user_id);
ALTER TABLE user_program ADD CONSTRAINT user_program_program_fk
    FOREIGN KEY (program_id) REFERENCES training_program (program_id);

ALTER TABLE program_exercise ADD CONSTRAINT program_exercise_program_fk
    FOREIGN KEY (program_id) REFERENCES training_program (program_id);
ALTER TABLE program_exercise ADD CONSTRAINT program_exercise_exercise_fk
    FOREIGN KEY (exercise_id) REFERENCES fitness_exercise (exercise_id);

ALTER TABLE reference_params ADD CONSTRAINT reference_params_exercise_fk
    FOREIGN KEY (exercise_id) REFERENCES fitness_exercise (exercise_id);

ALTER TABLE reference_trajectory_point ADD CONSTRAINT ref_point_reference_fk
    FOREIGN KEY (reference_id) REFERENCES reference_params (reference_id);

ALTER TABLE ar_marker ADD CONSTRAINT ar_marker_stick_fk
    FOREIGN KEY (stick_id) REFERENCES gymnastic_stick (stick_id);

ALTER TABLE training_session ADD CONSTRAINT session_user_fk
    FOREIGN KEY (user_id) REFERENCES app_user (user_id);
ALTER TABLE training_session ADD CONSTRAINT session_program_fk
    FOREIGN KEY (program_id) REFERENCES training_program (program_id);
ALTER TABLE training_session ADD CONSTRAINT session_stick_fk
    FOREIGN KEY (stick_id) REFERENCES gymnastic_stick (stick_id);

ALTER TABLE position_measurement ADD CONSTRAINT measurement_session_fk
    FOREIGN KEY (session_id) REFERENCES training_session (session_id);
ALTER TABLE position_measurement ADD CONSTRAINT measurement_reference_fk
    FOREIGN KEY (reference_id) REFERENCES reference_params (reference_id);

ALTER TABLE measurement_trajectory_point ADD CONSTRAINT meas_point_measurement_fk
    FOREIGN KEY (measurement_id) REFERENCES position_measurement (measurement_id);

ALTER TABLE technique_error ADD CONSTRAINT error_measurement_fk
    FOREIGN KEY (measurement_id) REFERENCES position_measurement (measurement_id);

ALTER TABLE audiovisual_feedback ADD CONSTRAINT feedback_error_fk
    FOREIGN KEY (error_id) REFERENCES technique_error (error_id);

ALTER TABLE hint ADD CONSTRAINT hint_feedback_fk
    FOREIGN KEY (feedback_id) REFERENCES audiovisual_feedback (feedback_id);
ALTER TABLE notification ADD CONSTRAINT notification_feedback_fk
    FOREIGN KEY (feedback_id) REFERENCES audiovisual_feedback (feedback_id);

/* обмеження змісту стовпців */

-- допустимі значення рівня підготовки
ALTER TABLE app_user ADD CONSTRAINT app_user_level_check
    CHECK (fitness_level IN ('початковий', 'середній', 'високий'));
ALTER TABLE training_program ADD CONSTRAINT program_level_check
    CHECK (fitness_level IN ('початковий', 'середній', 'високий'));

-- діапазони кутів, амплітуди, швидкості
ALTER TABLE reference_params ADD CONSTRAINT reference_tilt_range
    CHECK (tilt_angle BETWEEN -180 AND 180);
ALTER TABLE reference_params ADD CONSTRAINT reference_speed_positive
    CHECK (speed > 0);
ALTER TABLE position_measurement ADD CONSTRAINT measurement_tilt_range
    CHECK (tilt_angle BETWEEN -180 AND 180);
ALTER TABLE position_measurement ADD CONSTRAINT measurement_rotation_range
    CHECK (rotation_angle BETWEEN -180 AND 180);
ALTER TABLE position_measurement ADD CONSTRAINT measurement_amplitude_range
    CHECK (motion_amplitude >= 0);

-- порядковий номер точки траєкторії
ALTER TABLE reference_trajectory_point ADD CONSTRAINT ref_point_seq_check
    CHECK (seq_no >= 1);
ALTER TABLE measurement_trajectory_point ADD CONSTRAINT meas_point_seq_check
    CHECK (seq_no >= 1);

-- час завершення сеансу не раніше за час початку
ALTER TABLE training_session ADD CONSTRAINT session_time_check
    CHECK (end_time IS NULL OR end_time >= start_time);

-- текстові поля не можуть складатися лише з пробілів
ALTER TABLE technique_error ADD CONSTRAINT error_description_check
    CHECK (length(trim(description)) > 0);
ALTER TABLE notification ADD CONSTRAINT notification_text_check
    CHECK (length(trim(text)) > 0);

/* обмеження з регулярними виразами */

-- назва вправи: починається з великої літери, далі літери, цифри, пробіли, дефіс
ALTER TABLE fitness_exercise ADD CONSTRAINT fitness_exercise_name_template
    CHECK (name ~ '^[А-ЯІЇЄҐA-Z][А-Яа-яІіЇїЄєҐґA-Za-z0-9 ’-]{1,99}$');

-- ціль тренувань користувача: починається з великої літери, далі літери, цифри, пробіли, кома, крапка, дефіс
ALTER TABLE app_user ADD CONSTRAINT app_user_goal_template
    CHECK (goal ~ '^[А-ЯІЇЄҐA-Z][А-Яа-яІіЇїЄєҐґA-Za-z0-9 ,.’-]{2,99}$');

-- тип візуального елемента підказки: ідентифікатор латиницею
ALTER TABLE hint ADD CONSTRAINT hint_visual_element_template
    CHECK (visual_element ~ '^[a-z][a-z0-9_]{1,99}$');

-- ідентифікатор звукового сигналу: латиниця, цифри, підкреслення
ALTER TABLE hint ADD CONSTRAINT hint_sound_signal_template
    CHECK (sound_signal IS NULL OR sound_signal ~ '^[a-z][a-z0-9_]{1,99}$');