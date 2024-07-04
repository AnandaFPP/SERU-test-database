CREATE TABLE teachers (
    id SERIAL NOT NULL,
    name VARCHAR(100),
    subject VARCHAR(50),
    PRIMARY KEY(id)
);

INSERT INTO teachers (name, subject) VALUES ('Pak Anton', 'Matematika');
INSERT INTO teachers (name, subject) VALUES ('Bu Dina', 'Bahasa Indonesia');
INSERT INTO teachers (name, subject) VALUES ('Pak Eko', 'Biologi');

CREATE TABLE classes (
    id SERIAL NOT NULL,
    name VARCHAR(50),
    teacher_id INT,
    PRIMARY KEY(id),
    FOREIGN KEY (teacher_id) REFERENCES teachers(id)
);

INSERT INTO classes (name, teacher_id) VALUES ('Kelas 10A', 1);
INSERT INTO classes (name, teacher_id) VALUES ('Kelas 11B', 2);
INSERT INTO classes (name, teacher_id) VALUES ('Kelas 12C', 3);

CREATE TABLE students (
    id SERIAL NOT NULL,
    name VARCHAR(100),
    age INT,
    class_id INT,
    PRIMARY KEY(id),
    FOREIGN KEY (class_id) REFERENCES classes(id)
);

INSERT INTO students (name, age, class_id) VALUES ('Budi', 16, 1);
INSERT INTO students (name, age, class_id) VALUES ('Ani', 17, 2);
INSERT INTO students (name, age, class_id) VALUES ('Candra', 18, 3);


-- JAWABAN DARI SOAL DATABASE

/* 1. Tampilkan daftar siswa beserta kelas dan guru yang mengajar kelas tersebut. */

SELECT s.name AS student_name, c.name AS class_name, t.name AS teacher_name
FROM students s
JOIN classes c ON s.class_id = c.id
JOIN teachers t ON c.teacher_id = t.id;

/* 2. Tampilkan daftar kelas yang diajar oleh guru yang sama. */

SELECT c.name AS class_name, t.name AS teacher_name
FROM classes c
JOIN teachers t ON c.teacher_id = t.id
WHERE t.id = 1;

/* 3. buat query view untuk siswa, kelas, dan guru yang mengajar. */

CREATE VIEW student_class_teacher AS
SELECT s.name AS student_name, c.name AS class_name, t.name AS teacher_name
FROM students s
JOIN classes c ON s.class_id = c.id
JOIN teachers t ON c.teacher_id = t.id;

/* 4. buat query yang sama tapi menggunakan store_procedure */

CREATE OR REPLACE FUNCTION get_student_class_teacher()
RETURNS TABLE(student_name VARCHAR, class_name VARCHAR, teacher_name VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT s.name AS student_name, c.name AS class_name, t.name AS teacher_name
    FROM students s
    JOIN classes c ON s.class_id = c.id
    JOIN teachers t ON c.teacher_id = t.id;
END;
$$ LANGUAGE plpgsql;

-- Pemanggilan fungsi 
SELECT * FROM get_student_class_teacher();

/* 5. buat query input, yang akan memberikan warning error jika ada data yang sama pernah masuk. */

CREATE OR REPLACE FUNCTION check_duplicate_student()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM students WHERE name = NEW.name AND class_id = NEW.class_id) THEN
        RAISE EXCEPTION 'Data siswa dengan nama yang sama dalam kelas yang sama sudah ada!';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_insert_students
BEFORE INSERT ON students
FOR EACH ROW
EXECUTE FUNCTION check_duplicate_student();