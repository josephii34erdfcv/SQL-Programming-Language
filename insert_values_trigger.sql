
DROP TABLE fromSeriesNetwork;
CREATE TEMPORARY TABLE fromSeriesNetwork (
  series_title     CHARACTER(30) NOT NULL,
  series_year      SMALLINT      NOT NULL,
  series_language  CHARACTER(10) NOT NULL,
  series_budget    SMALLINT DEFAULT 0,
  network_name     CHARACTER(30),
  network_location CHARACTER(30)
);

CREATE OR REPLACE FUNCTION enter_values()
  RETURNS TRIGGER AS $$
DECLARE
  same_network  network%ROWTYPE;
  same_series   series%ROWTYPE;
  same_relation series_network%ROWTYPE;
BEGIN
  SELECT *
  INTO same_network
  FROM network
  WHERE network.location = new.network_location
        AND network.name = new.network_name;
  SELECT *
  INTO same_series
  FROM series
  WHERE series.title = new.series_title
        AND series.year = new.series_year;
  IF new.series_budget ISNULL
  THEN
    UPDATE new
    SET new.series_budget = 0;
  END IF;
  IF same_series ISNULL -- if the series is new
  THEN
    INSERT INTO series (title, year, language, budget)
    VALUES (new.series_title, new.series_year, new.series_language, new.series_budget);
    SELECT *
    INTO same_series
    FROM series
    WHERE series.title = new.series_title
          AND series.year = new.series_year;
  END IF;
  IF new.network_name NOTNULL AND new.network_location NOTNULL
     AND same_network ISNULL -- if network exists and is new
  THEN
    INSERT INTO network (name, location)
    VALUES (new.network_name, new.network_location);
    SELECT *
    INTO same_network
    FROM network
    WHERE network.name = new.network_name
          AND network.location = new.network_location;
  END IF;
  SELECT *
  INTO same_relation
  FROM series_network
  WHERE series_network.network_id = same_network.network_id
        AND series_network.series_id = same_series.series_id;
  IF same_relation ISNULL AND same_network.network_id NOTNULL -- if relation is new
  THEN
    INSERT INTO series_network (series_id, network_id)
    VALUES (same_series.series_id, same_network.network_id);
  END IF;
  RETURN new;
END;
$$ LANGUAGE 'plpgsql';

DROP TRIGGER insert_values
ON fromSeriesNetwork;
CREATE TRIGGER insert_values
BEFORE INSERT ON fromSeriesNetwork
FOR EACH ROW EXECUTE PROCEDURE enter_values();

DELETE FROM fromSeriesNetwork;
INSERT INTO fromSeriesNetwork (series_title, series_year, series_language, network_name, network_location)
VALUES ('Sherlock', 2010, 'English', 'BBC', 'United Kingdom');

delete from series_network;
DELETE FROM network;
DELETE FROM series;
SELECT *
FROM network;
SELECT *
FROM series;
SELECT *
FROM series_network;
SELECT *
FROM fromSeriesNetwork;