-- Partition meteo_input table

-- Year partitions from 1990 to 2040


CREATE TABLE meteo_input_y1990 (
    CHECK ( dt >= DATE '1990-01-01' AND dt <= DATE '1990-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y1991 (
    CHECK ( dt >= DATE '1991-01-01' AND dt <= DATE '1991-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y1992 (
    CHECK ( dt >= DATE '1992-01-01' AND dt <= DATE '1992-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y1993 (
    CHECK ( dt >= DATE '1993-01-01' AND dt <= DATE '1993-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y1994 (
    CHECK ( dt >= DATE '1994-01-01' AND dt <= DATE '1994-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y1995 (
    CHECK ( dt >= DATE '1995-01-01' AND dt <= DATE '1995-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y1996 (
    CHECK ( dt >= DATE '1996-01-01' AND dt <= DATE '1996-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y1997 (
    CHECK ( dt >= DATE '1997-01-01' AND dt <= DATE '1997-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y1998 (
    CHECK ( dt >= DATE '1998-01-01' AND dt <= DATE '1998-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y1999 (
    CHECK ( dt >= DATE '1999-01-01' AND dt <= DATE '1999-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y2000 (
    CHECK ( dt >= DATE '2000-01-01' AND dt <= DATE '2000-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y2001 (
    CHECK ( dt >= DATE '2001-01-01' AND dt <= DATE '2001-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y2002 (
    CHECK ( dt >= DATE '2002-01-01' AND dt <= DATE '2002-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y2003 (
    CHECK ( dt >= DATE '2003-01-01' AND dt <= DATE '2003-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y2004 (
    CHECK ( dt >= DATE '2004-01-01' AND dt <= DATE '2004-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y2005 (
    CHECK ( dt >= DATE '2005-01-01' AND dt <= DATE '2005-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y2006 (
    CHECK ( dt >= DATE '2006-01-01' AND dt <= DATE '2006-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y2007 (
    CHECK ( dt >= DATE '2007-01-01' AND dt <= DATE '2007-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y2008 (
    CHECK ( dt >= DATE '2008-01-01' AND dt <= DATE '2008-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y2009 (
    CHECK ( dt >= DATE '2009-01-01' AND dt <= DATE '2009-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y2010 (
    CHECK ( dt >= DATE '2010-01-01' AND dt <= DATE '2010-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y2011 (
    CHECK ( dt >= DATE '2011-01-01' AND dt <= DATE '2011-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y2012 (
    CHECK ( dt >= DATE '2012-01-01' AND dt <= DATE '2012-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y2013 (
    CHECK ( dt >= DATE '2013-01-01' AND dt <= DATE '2013-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y2014 (
    CHECK ( dt >= DATE '2014-01-01' AND dt <= DATE '2014-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y2015 (
    CHECK ( dt >= DATE '2015-01-01' AND dt <= DATE '2015-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y2016 (
    CHECK ( dt >= DATE '2016-01-01' AND dt <= DATE '2016-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y2017 (
    CHECK ( dt >= DATE '2017-01-01' AND dt <= DATE '2017-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y2018 (
    CHECK ( dt >= DATE '2018-01-01' AND dt <= DATE '2018-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y2019 (
    CHECK ( dt >= DATE '2019-01-01' AND dt <= DATE '2019-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y2020 (
    CHECK ( dt >= DATE '2020-01-01' AND dt <= DATE '2020-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y2021 (
    CHECK ( dt >= DATE '2021-01-01' AND dt <= DATE '2021-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y2022 (
    CHECK ( dt >= DATE '2022-01-01' AND dt <= DATE '2022-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y2023 (
    CHECK ( dt >= DATE '2023-01-01' AND dt <= DATE '2023-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y2024 (
    CHECK ( dt >= DATE '2024-01-01' AND dt <= DATE '2024-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y2025 (
    CHECK ( dt >= DATE '2025-01-01' AND dt <= DATE '2025-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y2026 (
    CHECK ( dt >= DATE '2026-01-01' AND dt <= DATE '2026-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y2027 (
    CHECK ( dt >= DATE '2027-01-01' AND dt <= DATE '2027-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y2028 (
    CHECK ( dt >= DATE '2028-01-01' AND dt <= DATE '2028-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y2029 (
    CHECK ( dt >= DATE '2029-01-01' AND dt <= DATE '2029-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y2030 (
    CHECK ( dt >= DATE '2030-01-01' AND dt <= DATE '2030-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y2031 (
    CHECK ( dt >= DATE '2031-01-01' AND dt <= DATE '2031-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y2032 (
    CHECK ( dt >= DATE '2032-01-01' AND dt <= DATE '2032-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y2033 (
    CHECK ( dt >= DATE '2033-01-01' AND dt <= DATE '2033-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y2034 (
    CHECK ( dt >= DATE '2034-01-01' AND dt <= DATE '2034-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y2035 (
    CHECK ( dt >= DATE '2035-01-01' AND dt <= DATE '2035-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y2036 (
    CHECK ( dt >= DATE '2036-01-01' AND dt <= DATE '2036-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y2037 (
    CHECK ( dt >= DATE '2037-01-01' AND dt <= DATE '2037-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y2038 (
    CHECK ( dt >= DATE '2038-01-01' AND dt <= DATE '2038-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y2039 (
    CHECK ( dt >= DATE '2039-01-01' AND dt <= DATE '2039-12-31' )
) INHERITS (meteo_input);
CREATE TABLE meteo_input_y2040 (
    CHECK ( dt >= DATE '2040-01-01' AND dt <= DATE '2040-12-31' )
) INHERITS (meteo_input);


-- indexes
CREATE UNIQUE INDEX meteo_input_idx1990 ON meteo_input_y1990 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx1991 ON meteo_input_y1991 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx1992 ON meteo_input_y1992 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx1993 ON meteo_input_y1993 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx1994 ON meteo_input_y1994 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx1995 ON meteo_input_y1995 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx1996 ON meteo_input_y1996 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx1997 ON meteo_input_y1997 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx1998 ON meteo_input_y1998 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx1999 ON meteo_input_y1999 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx2000 ON meteo_input_y2000 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx2001 ON meteo_input_y2001 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx2002 ON meteo_input_y2002 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx2003 ON meteo_input_y2003 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx2004 ON meteo_input_y2004 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx2005 ON meteo_input_y2005 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx2006 ON meteo_input_y2006 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx2007 ON meteo_input_y2007 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx2008 ON meteo_input_y2008 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx2009 ON meteo_input_y2009 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx2010 ON meteo_input_y2010 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx2011 ON meteo_input_y2011 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx2012 ON meteo_input_y2012 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx2013 ON meteo_input_y2013 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx2014 ON meteo_input_y2014 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx2015 ON meteo_input_y2015 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx2016 ON meteo_input_y2016 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx2017 ON meteo_input_y2017 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx2018 ON meteo_input_y2018 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx2019 ON meteo_input_y2019 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx2020 ON meteo_input_y2020 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx2021 ON meteo_input_y2021 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx2022 ON meteo_input_y2022 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx2023 ON meteo_input_y2023 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx2024 ON meteo_input_y2024 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx2025 ON meteo_input_y2025 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx2026 ON meteo_input_y2026 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx2027 ON meteo_input_y2027 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx2028 ON meteo_input_y2028 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx2029 ON meteo_input_y2029 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx2030 ON meteo_input_y2030 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx2031 ON meteo_input_y2031 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx2032 ON meteo_input_y2032 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx2033 ON meteo_input_y2033 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx2034 ON meteo_input_y2034 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx2035 ON meteo_input_y2035 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx2036 ON meteo_input_y2036 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx2037 ON meteo_input_y2037 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx2038 ON meteo_input_y2038 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx2039 ON meteo_input_y2039 USING btree (point_id , dt);
CREATE UNIQUE INDEX meteo_input_idx2040 ON meteo_input_y2040 USING btree (point_id , dt);

-- meteo_input insertion trigger

CREATE OR REPLACE FUNCTION meteo_input_insert_trigger()
RETURNS TRIGGER AS $$
BEGIN
    IF ( NEW.dt >= DATE '1990-01-01' AND
         NEW.dt <= DATE '1990-12-31' ) THEN
        INSERT INTO meteo_input_y1990 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '1991-01-01' AND
            NEW.dt <= DATE '1991-12-31' ) THEN
        INSERT INTO meteo_input_y1991 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '1992-01-01' AND
            NEW.dt <= DATE '1992-12-31' ) THEN
        INSERT INTO meteo_input_y1992 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '1993-01-01' AND
            NEW.dt <= DATE '1993-12-31' ) THEN
        INSERT INTO meteo_input_y1993 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '1994-01-01' AND
            NEW.dt <= DATE '1994-12-31' ) THEN
        INSERT INTO meteo_input_y1994 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '1995-01-01' AND
            NEW.dt <= DATE '1995-12-31' ) THEN
        INSERT INTO meteo_input_y1995 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '1996-01-01' AND
            NEW.dt <= DATE '1996-12-31' ) THEN
        INSERT INTO meteo_input_y1996 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '1997-01-01' AND
            NEW.dt <= DATE '1997-12-31' ) THEN
        INSERT INTO meteo_input_y1997 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '1998-01-01' AND
            NEW.dt <= DATE '1998-12-31' ) THEN
        INSERT INTO meteo_input_y1998 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '1999-01-01' AND
            NEW.dt <= DATE '1999-12-31' ) THEN
        INSERT INTO meteo_input_y1999 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2000-01-01' AND
            NEW.dt <= DATE '2000-12-31' ) THEN
        INSERT INTO meteo_input_y2000 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2001-01-01' AND
            NEW.dt <= DATE '2001-12-31' ) THEN
        INSERT INTO meteo_input_y2001 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2002-01-01' AND
            NEW.dt <= DATE '2002-12-31' ) THEN
        INSERT INTO meteo_input_y2002 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2003-01-01' AND
            NEW.dt <= DATE '2003-12-31' ) THEN
        INSERT INTO meteo_input_y2003 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2004-01-01' AND
            NEW.dt <= DATE '2004-12-31' ) THEN
        INSERT INTO meteo_input_y2004 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2005-01-01' AND
            NEW.dt <= DATE '2005-12-31' ) THEN
        INSERT INTO meteo_input_y2005 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2006-01-01' AND
            NEW.dt <= DATE '2006-12-31' ) THEN
        INSERT INTO meteo_input_y2006 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2007-01-01' AND
            NEW.dt <= DATE '2007-12-31' ) THEN
        INSERT INTO meteo_input_y2007 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2008-01-01' AND
            NEW.dt <= DATE '2008-12-31' ) THEN
        INSERT INTO meteo_input_y2008 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2009-01-01' AND
            NEW.dt <= DATE '2009-12-31' ) THEN
        INSERT INTO meteo_input_y2009 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2010-01-01' AND
            NEW.dt <= DATE '2010-12-31' ) THEN
        INSERT INTO meteo_input_y2010 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2011-01-01' AND
            NEW.dt <= DATE '2011-12-31' ) THEN
        INSERT INTO meteo_input_y2011 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2012-01-01' AND
            NEW.dt <= DATE '2012-12-31' ) THEN
        INSERT INTO meteo_input_y2012 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2013-01-01' AND
            NEW.dt <= DATE '2013-12-31' ) THEN
        INSERT INTO meteo_input_y2013 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2014-01-01' AND
            NEW.dt <= DATE '2014-12-31' ) THEN
        INSERT INTO meteo_input_y2014 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2015-01-01' AND
            NEW.dt <= DATE '2015-12-31' ) THEN
        INSERT INTO meteo_input_y2015 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2016-01-01' AND
            NEW.dt <= DATE '2016-12-31' ) THEN
        INSERT INTO meteo_input_y2016 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2017-01-01' AND
            NEW.dt <= DATE '2017-12-31' ) THEN
        INSERT INTO meteo_input_y2017 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2018-01-01' AND
            NEW.dt <= DATE '2018-12-31' ) THEN
        INSERT INTO meteo_input_y2018 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2019-01-01' AND
            NEW.dt <= DATE '2019-12-31' ) THEN
        INSERT INTO meteo_input_y2019 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2020-01-01' AND
            NEW.dt <= DATE '2020-12-31' ) THEN
        INSERT INTO meteo_input_y2020 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2021-01-01' AND
            NEW.dt <= DATE '2021-12-31' ) THEN
        INSERT INTO meteo_input_y2021 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2022-01-01' AND
            NEW.dt <= DATE '2022-12-31' ) THEN
        INSERT INTO meteo_input_y2022 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2023-01-01' AND
            NEW.dt <= DATE '2023-12-31' ) THEN
        INSERT INTO meteo_input_y2023 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2024-01-01' AND
            NEW.dt <= DATE '2024-12-31' ) THEN
        INSERT INTO meteo_input_y2024 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2025-01-01' AND
            NEW.dt <= DATE '2025-12-31' ) THEN
        INSERT INTO meteo_input_y2025 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2026-01-01' AND
            NEW.dt <= DATE '2026-12-31' ) THEN
        INSERT INTO meteo_input_y2026 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2027-01-01' AND
            NEW.dt <= DATE '2027-12-31' ) THEN
        INSERT INTO meteo_input_y2027 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2028-01-01' AND
            NEW.dt <= DATE '2028-12-31' ) THEN
        INSERT INTO meteo_input_y2028 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2029-01-01' AND
            NEW.dt <= DATE '2029-12-31' ) THEN
        INSERT INTO meteo_input_y2029 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2030-01-01' AND
            NEW.dt <= DATE '2030-12-31' ) THEN
        INSERT INTO meteo_input_y2030 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2031-01-01' AND
            NEW.dt <= DATE '2031-12-31' ) THEN
        INSERT INTO meteo_input_y2031 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2032-01-01' AND
            NEW.dt <= DATE '2032-12-31' ) THEN
        INSERT INTO meteo_input_y2032 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2033-01-01' AND
            NEW.dt <= DATE '2033-12-31' ) THEN
        INSERT INTO meteo_input_y2033 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2034-01-01' AND
            NEW.dt <= DATE '2034-12-31' ) THEN
        INSERT INTO meteo_input_y2034 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2035-01-01' AND
            NEW.dt <= DATE '2035-12-31' ) THEN
        INSERT INTO meteo_input_y2035 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2036-01-01' AND
            NEW.dt <= DATE '2036-12-31' ) THEN
        INSERT INTO meteo_input_y2036 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2037-01-01' AND
            NEW.dt <= DATE '2037-12-31' ) THEN
        INSERT INTO meteo_input_y2037 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2038-01-01' AND
            NEW.dt <= DATE '2038-12-31' ) THEN
        INSERT INTO meteo_input_y2038 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2039-01-01' AND
            NEW.dt <= DATE '2039-12-31' ) THEN
        INSERT INTO meteo_input_y2039 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2040-01-01' AND
            NEW.dt <= DATE '2040-12-31' ) THEN
        INSERT INTO meteo_input_y2040 VALUES (NEW.*);
    ELSE
        RAISE EXCEPTION 'Date out of range.  Fix the measurement_insert_trigger() function!';
    END IF;
    RETURN NULL;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER insert_meteo_input_trigger
    BEFORE INSERT ON meteo_input
    FOR EACH ROW EXECUTE PROCEDURE meteo_input_insert_trigger();


