-- Partition fwi_indexes table

-- Year partitions from 1990 to 2040


CREATE TABLE fwi_indexes_y1990 (
    CHECK ( dt >= DATE '1990-01-01' AND dt <= DATE '1990-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y1991 (
    CHECK ( dt >= DATE '1991-01-01' AND dt <= DATE '1991-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y1992 (
    CHECK ( dt >= DATE '1992-01-01' AND dt <= DATE '1992-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y1993 (
    CHECK ( dt >= DATE '1993-01-01' AND dt <= DATE '1993-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y1994 (
    CHECK ( dt >= DATE '1994-01-01' AND dt <= DATE '1994-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y1995 (
    CHECK ( dt >= DATE '1995-01-01' AND dt <= DATE '1995-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y1996 (
    CHECK ( dt >= DATE '1996-01-01' AND dt <= DATE '1996-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y1997 (
    CHECK ( dt >= DATE '1997-01-01' AND dt <= DATE '1997-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y1998 (
    CHECK ( dt >= DATE '1998-01-01' AND dt <= DATE '1998-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y1999 (
    CHECK ( dt >= DATE '1999-01-01' AND dt <= DATE '1999-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y2000 (
    CHECK ( dt >= DATE '2000-01-01' AND dt <= DATE '2000-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y2001 (
    CHECK ( dt >= DATE '2001-01-01' AND dt <= DATE '2001-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y2002 (
    CHECK ( dt >= DATE '2002-01-01' AND dt <= DATE '2002-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y2003 (
    CHECK ( dt >= DATE '2003-01-01' AND dt <= DATE '2003-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y2004 (
    CHECK ( dt >= DATE '2004-01-01' AND dt <= DATE '2004-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y2005 (
    CHECK ( dt >= DATE '2005-01-01' AND dt <= DATE '2005-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y2006 (
    CHECK ( dt >= DATE '2006-01-01' AND dt <= DATE '2006-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y2007 (
    CHECK ( dt >= DATE '2007-01-01' AND dt <= DATE '2007-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y2008 (
    CHECK ( dt >= DATE '2008-01-01' AND dt <= DATE '2008-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y2009 (
    CHECK ( dt >= DATE '2009-01-01' AND dt <= DATE '2009-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y2010 (
    CHECK ( dt >= DATE '2010-01-01' AND dt <= DATE '2010-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y2011 (
    CHECK ( dt >= DATE '2011-01-01' AND dt <= DATE '2011-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y2012 (
    CHECK ( dt >= DATE '2012-01-01' AND dt <= DATE '2012-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y2013 (
    CHECK ( dt >= DATE '2013-01-01' AND dt <= DATE '2013-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y2014 (
    CHECK ( dt >= DATE '2014-01-01' AND dt <= DATE '2014-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y2015 (
    CHECK ( dt >= DATE '2015-01-01' AND dt <= DATE '2015-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y2016 (
    CHECK ( dt >= DATE '2016-01-01' AND dt <= DATE '2016-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y2017 (
    CHECK ( dt >= DATE '2017-01-01' AND dt <= DATE '2017-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y2018 (
    CHECK ( dt >= DATE '2018-01-01' AND dt <= DATE '2018-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y2019 (
    CHECK ( dt >= DATE '2019-01-01' AND dt <= DATE '2019-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y2020 (
    CHECK ( dt >= DATE '2020-01-01' AND dt <= DATE '2020-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y2021 (
    CHECK ( dt >= DATE '2021-01-01' AND dt <= DATE '2021-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y2022 (
    CHECK ( dt >= DATE '2022-01-01' AND dt <= DATE '2022-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y2023 (
    CHECK ( dt >= DATE '2023-01-01' AND dt <= DATE '2023-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y2024 (
    CHECK ( dt >= DATE '2024-01-01' AND dt <= DATE '2024-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y2025 (
    CHECK ( dt >= DATE '2025-01-01' AND dt <= DATE '2025-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y2026 (
    CHECK ( dt >= DATE '2026-01-01' AND dt <= DATE '2026-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y2027 (
    CHECK ( dt >= DATE '2027-01-01' AND dt <= DATE '2027-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y2028 (
    CHECK ( dt >= DATE '2028-01-01' AND dt <= DATE '2028-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y2029 (
    CHECK ( dt >= DATE '2029-01-01' AND dt <= DATE '2029-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y2030 (
    CHECK ( dt >= DATE '2030-01-01' AND dt <= DATE '2030-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y2031 (
    CHECK ( dt >= DATE '2031-01-01' AND dt <= DATE '2031-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y2032 (
    CHECK ( dt >= DATE '2032-01-01' AND dt <= DATE '2032-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y2033 (
    CHECK ( dt >= DATE '2033-01-01' AND dt <= DATE '2033-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y2034 (
    CHECK ( dt >= DATE '2034-01-01' AND dt <= DATE '2034-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y2035 (
    CHECK ( dt >= DATE '2035-01-01' AND dt <= DATE '2035-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y2036 (
    CHECK ( dt >= DATE '2036-01-01' AND dt <= DATE '2036-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y2037 (
    CHECK ( dt >= DATE '2037-01-01' AND dt <= DATE '2037-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y2038 (
    CHECK ( dt >= DATE '2038-01-01' AND dt <= DATE '2038-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y2039 (
    CHECK ( dt >= DATE '2039-01-01' AND dt <= DATE '2039-12-31' )
) INHERITS (fwi_indexes);
CREATE TABLE fwi_indexes_y2040 (
    CHECK ( dt >= DATE '2040-01-01' AND dt <= DATE '2040-12-31' )
) INHERITS (fwi_indexes);

-- indexes

CREATE UNIQUE INDEX fwi_indexes_idx1990 ON fwi_indexes_y1990 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx1991 ON fwi_indexes_y1991 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx1992 ON fwi_indexes_y1992 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx1993 ON fwi_indexes_y1993 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx1994 ON fwi_indexes_y1994 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx1995 ON fwi_indexes_y1995 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx1996 ON fwi_indexes_y1996 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx1997 ON fwi_indexes_y1997 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx1998 ON fwi_indexes_y1998 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx1999 ON fwi_indexes_y1999 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx2000 ON fwi_indexes_y2000 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx2001 ON fwi_indexes_y2001 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx2002 ON fwi_indexes_y2002 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx2003 ON fwi_indexes_y2003 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx2004 ON fwi_indexes_y2004 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx2005 ON fwi_indexes_y2005 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx2006 ON fwi_indexes_y2006 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx2007 ON fwi_indexes_y2007 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx2008 ON fwi_indexes_y2008 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx2009 ON fwi_indexes_y2009 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx2010 ON fwi_indexes_y2010 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx2011 ON fwi_indexes_y2011 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx2012 ON fwi_indexes_y2012 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx2013 ON fwi_indexes_y2013 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx2014 ON fwi_indexes_y2014 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx2015 ON fwi_indexes_y2015 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx2016 ON fwi_indexes_y2016 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx2017 ON fwi_indexes_y2017 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx2018 ON fwi_indexes_y2018 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx2019 ON fwi_indexes_y2019 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx2020 ON fwi_indexes_y2020 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx2021 ON fwi_indexes_y2021 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx2022 ON fwi_indexes_y2022 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx2023 ON fwi_indexes_y2023 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx2024 ON fwi_indexes_y2024 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx2025 ON fwi_indexes_y2025 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx2026 ON fwi_indexes_y2026 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx2027 ON fwi_indexes_y2027 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx2028 ON fwi_indexes_y2028 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx2029 ON fwi_indexes_y2029 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx2030 ON fwi_indexes_y2030 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx2031 ON fwi_indexes_y2031 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx2032 ON fwi_indexes_y2032 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx2033 ON fwi_indexes_y2033 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx2034 ON fwi_indexes_y2034 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx2035 ON fwi_indexes_y2035 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx2036 ON fwi_indexes_y2036 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx2037 ON fwi_indexes_y2037 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx2038 ON fwi_indexes_y2038 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx2039 ON fwi_indexes_y2039 USING btree (point_id , dt);
CREATE UNIQUE INDEX fwi_indexes_idx2040 ON fwi_indexes_y2040 USING btree (point_id , dt);

-- fwi_indexes insertion trigger

CREATE OR REPLACE FUNCTION fwi_indexes_insert_trigger()
RETURNS TRIGGER AS $$
BEGIN
    IF ( NEW.dt >= DATE '1990-01-01' AND
         NEW.dt <= DATE '1990-12-31' ) THEN
        INSERT INTO fwi_indexes_y1990 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '1991-01-01' AND
            NEW.dt <= DATE '1991-12-31' ) THEN
        INSERT INTO fwi_indexes_y1991 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '1992-01-01' AND
            NEW.dt <= DATE '1992-12-31' ) THEN
        INSERT INTO fwi_indexes_y1992 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '1993-01-01' AND
            NEW.dt <= DATE '1993-12-31' ) THEN
        INSERT INTO fwi_indexes_y1993 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '1994-01-01' AND
            NEW.dt <= DATE '1994-12-31' ) THEN
        INSERT INTO fwi_indexes_y1994 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '1995-01-01' AND
            NEW.dt <= DATE '1995-12-31' ) THEN
        INSERT INTO fwi_indexes_y1995 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '1996-01-01' AND
            NEW.dt <= DATE '1996-12-31' ) THEN
        INSERT INTO fwi_indexes_y1996 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '1997-01-01' AND
            NEW.dt <= DATE '1997-12-31' ) THEN
        INSERT INTO fwi_indexes_y1997 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '1998-01-01' AND
            NEW.dt <= DATE '1998-12-31' ) THEN
        INSERT INTO fwi_indexes_y1998 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '1999-01-01' AND
            NEW.dt <= DATE '1999-12-31' ) THEN
        INSERT INTO fwi_indexes_y1999 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2000-01-01' AND
            NEW.dt <= DATE '2000-12-31' ) THEN
        INSERT INTO fwi_indexes_y2000 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2001-01-01' AND
            NEW.dt <= DATE '2001-12-31' ) THEN
        INSERT INTO fwi_indexes_y2001 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2002-01-01' AND
            NEW.dt <= DATE '2002-12-31' ) THEN
        INSERT INTO fwi_indexes_y2002 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2003-01-01' AND
            NEW.dt <= DATE '2003-12-31' ) THEN
        INSERT INTO fwi_indexes_y2003 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2004-01-01' AND
            NEW.dt <= DATE '2004-12-31' ) THEN
        INSERT INTO fwi_indexes_y2004 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2005-01-01' AND
            NEW.dt <= DATE '2005-12-31' ) THEN
        INSERT INTO fwi_indexes_y2005 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2006-01-01' AND
            NEW.dt <= DATE '2006-12-31' ) THEN
        INSERT INTO fwi_indexes_y2006 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2007-01-01' AND
            NEW.dt <= DATE '2007-12-31' ) THEN
        INSERT INTO fwi_indexes_y2007 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2008-01-01' AND
            NEW.dt <= DATE '2008-12-31' ) THEN
        INSERT INTO fwi_indexes_y2008 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2009-01-01' AND
            NEW.dt <= DATE '2009-12-31' ) THEN
        INSERT INTO fwi_indexes_y2009 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2010-01-01' AND
            NEW.dt <= DATE '2010-12-31' ) THEN
        INSERT INTO fwi_indexes_y2010 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2011-01-01' AND
            NEW.dt <= DATE '2011-12-31' ) THEN
        INSERT INTO fwi_indexes_y2011 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2012-01-01' AND
            NEW.dt <= DATE '2012-12-31' ) THEN
        INSERT INTO fwi_indexes_y2012 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2013-01-01' AND
            NEW.dt <= DATE '2013-12-31' ) THEN
        INSERT INTO fwi_indexes_y2013 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2014-01-01' AND
            NEW.dt <= DATE '2014-12-31' ) THEN
        INSERT INTO fwi_indexes_y2014 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2015-01-01' AND
            NEW.dt <= DATE '2015-12-31' ) THEN
        INSERT INTO fwi_indexes_y2015 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2016-01-01' AND
            NEW.dt <= DATE '2016-12-31' ) THEN
        INSERT INTO fwi_indexes_y2016 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2017-01-01' AND
            NEW.dt <= DATE '2017-12-31' ) THEN
        INSERT INTO fwi_indexes_y2017 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2018-01-01' AND
            NEW.dt <= DATE '2018-12-31' ) THEN
        INSERT INTO fwi_indexes_y2018 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2019-01-01' AND
            NEW.dt <= DATE '2019-12-31' ) THEN
        INSERT INTO fwi_indexes_y2019 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2020-01-01' AND
            NEW.dt <= DATE '2020-12-31' ) THEN
        INSERT INTO fwi_indexes_y2020 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2021-01-01' AND
            NEW.dt <= DATE '2021-12-31' ) THEN
        INSERT INTO fwi_indexes_y2021 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2022-01-01' AND
            NEW.dt <= DATE '2022-12-31' ) THEN
        INSERT INTO fwi_indexes_y2022 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2023-01-01' AND
            NEW.dt <= DATE '2023-12-31' ) THEN
        INSERT INTO fwi_indexes_y2023 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2024-01-01' AND
            NEW.dt <= DATE '2024-12-31' ) THEN
        INSERT INTO fwi_indexes_y2024 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2025-01-01' AND
            NEW.dt <= DATE '2025-12-31' ) THEN
        INSERT INTO fwi_indexes_y2025 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2026-01-01' AND
            NEW.dt <= DATE '2026-12-31' ) THEN
        INSERT INTO fwi_indexes_y2026 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2027-01-01' AND
            NEW.dt <= DATE '2027-12-31' ) THEN
        INSERT INTO fwi_indexes_y2027 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2028-01-01' AND
            NEW.dt <= DATE '2028-12-31' ) THEN
        INSERT INTO fwi_indexes_y2028 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2029-01-01' AND
            NEW.dt <= DATE '2029-12-31' ) THEN
        INSERT INTO fwi_indexes_y2029 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2030-01-01' AND
            NEW.dt <= DATE '2030-12-31' ) THEN
        INSERT INTO fwi_indexes_y2030 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2031-01-01' AND
            NEW.dt <= DATE '2031-12-31' ) THEN
        INSERT INTO fwi_indexes_y2031 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2032-01-01' AND
            NEW.dt <= DATE '2032-12-31' ) THEN
        INSERT INTO fwi_indexes_y2032 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2033-01-01' AND
            NEW.dt <= DATE '2033-12-31' ) THEN
        INSERT INTO fwi_indexes_y2033 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2034-01-01' AND
            NEW.dt <= DATE '2034-12-31' ) THEN
        INSERT INTO fwi_indexes_y2034 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2035-01-01' AND
            NEW.dt <= DATE '2035-12-31' ) THEN
        INSERT INTO fwi_indexes_y2035 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2036-01-01' AND
            NEW.dt <= DATE '2036-12-31' ) THEN
        INSERT INTO fwi_indexes_y2036 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2037-01-01' AND
            NEW.dt <= DATE '2037-12-31' ) THEN
        INSERT INTO fwi_indexes_y2037 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2038-01-01' AND
            NEW.dt <= DATE '2038-12-31' ) THEN
        INSERT INTO fwi_indexes_y2038 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2039-01-01' AND
            NEW.dt <= DATE '2039-12-31' ) THEN
        INSERT INTO fwi_indexes_y2039 VALUES (NEW.*);
    ELSIF ( NEW.dt >= DATE '2040-01-01' AND
            NEW.dt <= DATE '2040-12-31' ) THEN
        INSERT INTO fwi_indexes_y2040 VALUES (NEW.*);
    ELSE
        RAISE EXCEPTION 'Date out of range.  Fix the measurement_insert_trigger() function!';
    END IF;
    RETURN NULL;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER insert_fwi_indexes_trigger
    BEFORE INSERT ON fwi_indexes
    FOR EACH ROW EXECUTE PROCEDURE fwi_indexes_insert_trigger();


