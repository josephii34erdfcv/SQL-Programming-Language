-- Clement's

DROP FUNCTION setdomain(role VARCHAR(30));
CREATE OR REPLACE FUNCTION setdomain(role VARCHAR(30))
  RETURNS TABLE(
    cat_id INT,
    cat_name VARCHAR(30),
    dom_id INT,
    dom_suffix VARCHAR(30)
  ) AS $$
  DECLARE
    domainid INT;
    countduplicate INT;
  BEGIN
    SELECT count(category_name) INTO countduplicate
    FROM category WHERE category_name = role;
    RAISE NOTICE '%', countduplicate;

    IF countduplicate = 0 THEN
      INSERT INTO domain(domain_suffix) VALUES (concat(role, '.pas.org'));
      SELECT domain.domain_id INTO domainid FROM domain
      WHERE domain.domain_suffix = concat(role, '.pas.org');
      INSERT INTO category(category_name, domain_id) VALUES
        (role, domainid);
    ELSE
      RAISE NOTICE 'Duplicate Entry';
    END IF;

    RETURN QUERY SELECT category_id, category_name,
      domain_id, domain_suffix FROM domain INNER JOIN category USING (domain_id);
  END;
  $$ LANGUAGE plpgsql;

select * from setdomain('staff');