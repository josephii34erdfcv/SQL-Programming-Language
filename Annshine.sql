-- Annshine's

DROP FUNCTION IF EXISTS curve(VARIADIC inputs NUMERIC[]);
CREATE OR REPLACE FUNCTION curve(VARIADIC inputs NUMERIC[])
  RETURNS TABLE(
    changed FLOAT
  )
  AS $$
  DECLARE
    sum FLOAT;
    count INTEGER;
    num INTEGER;
  BEGIN
    count := 0;
    sum := 0;
    FOR num IN SELECT unnest(inputs) LOOP
      IF (num >= 60) THEN
        count := count + 1;
        sum := sum + num;
      END IF;
    END LOOP;
    IF 85 - sum/count < 0 THEN
      RAISE NOTICE 'the average of the class is % and it is higher than 85 so there is no need for a curve', sum/count;
      FOR num IN SELECT unnest(inputs) LOOP
        changed = num;
        RETURN NEXT;
      END LOOP;
    ELSE
      FOR num IN SELECT unnest(inputs) LOOP
        changed = num + (85 - sum/count);
        RETURN NEXT;
      END LOOP;
    END IF;
  END;
  $$ LANGUAGE plpgsql;

