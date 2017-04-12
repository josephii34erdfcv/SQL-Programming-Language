DROP TABLE IF EXISTS Individual;
CREATE TABLE public.Individual
(
    id SERIAL PRIMARY KEY,
    firstname VARCHAR(30) NOT NULL,
    lastname VARCHAR(30),
    email VARCHAR(80),
    createdAt DATE
);

DROP TABLE IF EXISTS Grade;
CREATE TABLE public.Grade
(
    grade_id SERIAL PRIMARY KEY,
    student_id INT,
    score NUMERIC,
    scoreLetter VARCHAR(2),
    date DATE,
    CONSTRAINT grade_individual_id_fk FOREIGN KEY (student_id) REFERENCES individual (id),
    CONSTRAINT grade_gradingscale_id_fk FOREIGN KEY (scoreLetter) REFERENCES GradingScale (grade)
);

DROP TABLE IF EXISTS Domain;
CREATE TABLE public.Domain
(
    domain_id SERIAL PRIMARY KEY,
    domain_suffix VARCHAR(50) NOT NULL
);

DROP TABLE IF EXISTS Category;
CREATE TABLE public.Category
(
  category_id SERIAL PRIMARY KEY,
  category_name VARCHAR(40) NOT NULL,
  domain_id INT,
  CONSTRAINT category_domain_id_fk FOREIGN KEY (domain_id) REFERENCES Domain (domain_id)
);

DROP TABLE IF EXISTS GradingScale;
CREATE TABLE public.GradingScale
(
  grade VARCHAR(2) PRIMARY KEY,
  minimum INT NOT NULL
);

CREATE OR REPLACE FUNCTION getLetter(score NUMERIC)
  RETURNS VARCHAR(2) AS
  $$
  DECLARE
    x RECORD;
    letter VARCHAR(2);
  BEGIN
    letter := 'F';
    FOR x IN SELECT * FROM GradingScale ORDER BY minimum
      LOOP
      IF score >= x.minimum THEN
        letter := x.grade;
      END IF;
    END LOOP;
    RETURN letter;
  END;
  $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION setEmail(firstname VARCHAR(30), lastname VARCHAR(30), cat_id INT)
  RETURNS VARCHAR(80) AS
  $$
  DECLARE
    mail VARCHAR(80);
    dom VARCHAR(30);
  BEGIN
    SELECT domain_suffix INTO dom FROM Domain INNER JOIN Category USING (domain_id)
    WHERE Category.category_id = cat_id;
    mail := lower(concat(substr(firstname, 1, 1), '.', lastname, '@', dom));
    RETURN mail;
  END;
  $$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION newPerson(fname VARCHAR(30), lname VARCHAR(30), categ VARCHAR(20))
  RETURNS TABLE (
    id INT,
    "First Name" VARCHAR(30),
    "Last Name" VARCHAR(30),
    email VARCHAR(80),
    "Created at" TIMESTAMP
  )
  AS $$
  DECLARE
    categ_id INT;
  BEGIN
    SELECT category_id INTO categ_id FROM Category WHERE category_name LIKE categ;
    INSERT INTO Individual (firstname, lastname, email, createdAt) VALUES
      (fname, lname, setEmail(fname, lname, categ_id), current_date);

    RETURN QUERY SELECT Individual.id, fname, lname, Individual.email, now()::TIMESTAMP
    FROM Individual ORDER BY Individual.id DESC LIMIT 1;
  END;
  $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insertMulGrades(stud_id INT, day DATE, VARIADIC score NUMERIC[])
  RETURNS VOID AS $$
  DECLARE
    x NUMERIC;
  BEGIN
    FOR x IN SELECT unnest(score) LOOP
      INSERT INTO Grade (student_id, score, scoreLetter, date) VALUES
        (stud_id, x, getLetter(x), day);
    END LOOP;
  END;
  $$ LANGUAGE plpgsql;

INSERT INTO GradingScale (grade, minimum) VALUES
  ('A+', 97),
  ('A', 93),
  ('A-', 90),
  ('B+', 87),
  ('B', 83),
  ('B-', 80),
  ('C+', 77),
  ('C', 73),
  ('C-', 70),
  ('D+', 67),
  ('D', 63),
  ('D-', 60),
  ('F', 0);

INSERT INTO Domain (domain_suffix) VALUES
  ('student.pas.org'),
  ('teacher.pas.org');

INSERT INTO Category (category_name, domain_id) VALUES
  ('student', 1),
  ('teacher', 2);

select * from newPerson('Joseph', 'Huang', 'student');
select * from Individual;
select from insertMulGrades(8, '9/4/2017', 80, 70, 81);
select * from Grade;