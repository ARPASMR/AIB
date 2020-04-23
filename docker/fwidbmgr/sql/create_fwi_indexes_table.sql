-- Table: fwi_indexes

-- DROP TABLE fwi_indexes;

SET client_min_messages TO warning;

CREATE TABLE fwi_indexes
(
  id serial NOT NULL, -- Primary key
  point_id integer NOT NULL,
  dt date NOT NULL,
  isi real NOT NULL DEFAULT 0.0,
  fwi real NOT NULL DEFAULT 0.0,
  ffmc real NOT NULL DEFAULT 0.0,
  dmc real NOT NULL DEFAULT 0.0,
  dc real NOT NULL DEFAULT 0.0,
  bui real NOT NULL DEFAULT 0.0,
  ffmc_tmp real NOT NULL DEFAULT 0.0,
  dmc_tmp real NOT NULL DEFAULT 0.0,
  dc_tmp real NOT NULL DEFAULT 0.0,
  idi real NOT NULL DEFAULT 0.0,
  angstrom real NOT NULL DEFAULT 0.0,
  fmi real NOT NULL DEFAULT 0.0,
  sharples real NOT NULL DEFAULT 0.0,
  CONSTRAINT fwi_indexes_pkey PRIMARY KEY (id ),
  CONSTRAINT grid_point_fkey FOREIGN KEY (point_id)
      REFERENCES grid (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=TRUE
);
ALTER TABLE fwi_indexes
  OWNER TO meteo;
COMMENT ON TABLE meteo_input
  IS 'Fire weather indexes';
