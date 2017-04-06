create function product (a integer, b integer)
  returns integer AS $$
  begin
    return a * b;
  end;
  $$ language plpgsql;

select * from product(4,5);

-- create fibionnaci function recursive
create function fibo(num_terms integer)
  returns integer as $$
  begin
    if num_terms < 2 then
      return num_terms;
    end if;
    return fibo(num_terms - 1) + fibo(num_terms - 2);
  end;
  $$ language plpgsql;

select * from fibo(20);

-- concatenate two strings
drop function combine(str1 varchar, str2 varchar);
create function combine(str1 varchar, str2 varchar)
  returns varchar as $$
  begin
    return concat(initcap(str1), initcap(str2));
  end;
  $$ language plpgsql;

select * from combine ('a', 'b');

-- generate email from first name and last name
drop function genMail(firstname varchar, lastname varchar, domain varchar);
create function genMail(firstname varchar, lastname varchar, domain varchar default 'pas.org')
  returns varchar as $$
  begin
    firstname = substr(lower(firstname), 1, 1);
    lastname = lower(lastname);
    return concat(firstname, '.', lastname, '@', domain);
  end;
  $$ language plpgsql;

select * from genMail ('Joseph', 'Huang', 'gmail.com');

-- find sum and max from three integers
create function summax (a integer, b integer, c integer, out total integer, out maxi integer) as
  $$
  begin
    total := a + b + c;
    maxi := greatest(a, b, c);
  end;
  $$ language plpgsql;

select * from summax(2, 4, 5);

-- find first name, last name, and domain from first name and email
drop if exists function reverse (fname varchar, email varchar,
  out domain varchar, out lastname varchar, out firstname varchar);
create function reverse (fname varchar, email varchar,
  out domain varchar, out lastname varchar, out firstname varchar) as
  $$
  begin
    firstname := initcap(fname);
    lastname := initcap(substr(email, 3, strpos(email, '@') - 3));
    domain := substr(email, strpos(email, '@') + 1, char_length(email));
  end;
  $$ language plpgsql;

select * from reverse ('Joseph', 'j.huang@gmail.com');

-- find max and total from a list of numerics
drop function if exists usearray (VARIADIC inputs NUMERIC[], out total NUMERIC, out max NUMERIC);
create function usearray (VARIADIC inputs NUMERIC[], out total NUMERIC, out max NUMERIC) AS
  $$
  DECLARE
    i numeric;
  BEGIN
    total := 0;
    max := inputs[1];
    for i in select * from unnest(inputs) loop
      total := total + i;
      if i > max THEN
        max := i;
      END IF;
    END LOOP;
  END;
  $$ language plpgsql;

select * from usearray(1, 2, 3, 4, 5);