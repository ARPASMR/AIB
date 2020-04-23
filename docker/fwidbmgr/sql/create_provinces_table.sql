-- Table: provinces

-- DROP TABLE provinces;

SET client_min_messages TO warning;

CREATE TABLE provinces
(
  id serial NOT NULL, -- Primary key
  region_id integer NOT NULL,
  name character varying(30) DEFAULT ''::character varying,
  CONSTRAINT provinces_pkey PRIMARY KEY (id ),
  CONSTRAINT regions_fkey FOREIGN KEY (region_id)
      REFERENCES regions (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=TRUE
);

SELECT AddGeometryColumn('provinces', 'p', 3003, 'MULTIPOLYGON', 3);

ALTER TABLE provinces
  OWNER TO meteo;
COMMENT ON TABLE provinces
  IS 'Region provinces';
  
COMMENT ON COLUMN provinces.id IS 'Primary key';
COMMENT ON COLUMN provinces.p IS '3d polygon';

-- Index: provinces_name_idx

-- DROP INDEX provinces_name_idx;

CREATE UNIQUE INDEX provinces_name_idx
  ON provinces
  USING btree(name);
  --(name COLLATE pg_catalog."default" );
ALTER TABLE provinces CLUSTER ON provinces_name_idx;
COMMENT ON INDEX provinces_name_idx
  IS 'provinces name index';
