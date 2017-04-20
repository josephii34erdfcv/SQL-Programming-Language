-- Andrew's

CREATE OR REPLACE FUNCTION randTable(numValue INT)
  RETURNS TABLE(
  number INTEGER
  ) AS $$
  DECLARE
  BEGIN
    FOR x IN 0..numValue LOOP
      number := random() * 100;
      RETURN NEXT;
    END LOOP;
  END;
  $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION improve(score INT)
  RETURNS BOOLEAN AS $$
  DECLARE
    prevAve DECIMAL;
    sum INTEGER;
    cnt INTEGER;
    num INTEGER;
  BEGIN
    cnt := 0;
    sum := 0;
    FOR num IN SELECT * FROM randTable(100)
      LOOP
      cnt := cnt + 1;
      sum := sum + num;
    END LOOP;
    prevAve := sum/cnt;
    IF score > prevAve THEN
      RAISE NOTICE 'The student has improved';
      RETURN true;
    ELSE
      RETURN false;
    END IF;
  END;
  $$ LANGUAGE plpgsql;

SELECT * FROM improve(90);