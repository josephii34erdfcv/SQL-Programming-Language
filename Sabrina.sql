-- Sabrina's

CREATE OR REPLACE FUNCTION failingNum(VARIADIC inputs NUMERIC[])
  RETURNS INTEGER AS $$
  DECLARE
    score INTEGER;
    cnt INTEGER;
  BEGIN
    cnt := 0;
    FOR score IN SELECT unnest(inputs) LOOP
      IF score < 60 THEN
        cnt := cnt + 1;
      END IF;
    END LOOP;
    RAISE NOTICE 'The number of failing grades: %', cnt;
    RETURN cnt;
  END;
  $$ LANGUAGE plpgsql;

SELECT * FROM failingNum(56, 79, 44, 90, 23);