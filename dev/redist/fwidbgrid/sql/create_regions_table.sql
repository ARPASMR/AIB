-- Table: regions
--
-- DROP TABLE regions;

CREATE TABLE regions
(
  id serial NOT NULL, -- Primary key
  name character varying(30) DEFAULT ''::character varying,
  CONSTRAINT regions_pkey PRIMARY KEY (id )
)
WITH (
  OIDS=TRUE
);

SELECT AddGeometryColumn('regions', 'p', 3003, 'MULTIPOLYGON', 3);

ALTER TABLE regions
  OWNER TO meteo;

COMMENT ON TABLE regions
  IS 'Regions polygon limits';
COMMENT ON COLUMN regions.id IS 'Primary key';
COMMENT ON COLUMN regions.p IS '3d polygon';

-- Index: regions_name_idx

-- DROP INDEX regions_name_idx;

CREATE UNIQUE INDEX regions_name_idx
  ON regions
  USING btree(name);
  --(name COLLATE pg_catalog."default" );
ALTER TABLE regions CLUSTER ON regions_name_idx;
COMMENT ON INDEX regions_name_idx
  IS 'regions name index';
