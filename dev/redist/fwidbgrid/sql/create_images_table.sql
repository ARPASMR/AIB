-- Table: images

-- DROP TABLE images;

SET client_min_messages TO warning;

CREATE TABLE images
(
  id serial NOT NULL, -- Primary key
  dt date NOT NULL,
  fwi_page character varying(512) DEFAULT ''::character varying,
  fwi_page_bytea bytea,
  meteo_page character varying(512) DEFAULT ''::character varying,
  meteo_page_bytea bytea,
  snow character varying(512) DEFAULT ''::character varying,
  snow_bytea bytea
)
WITH (
  OIDS=TRUE
);
ALTER TABLE images
  OWNER TO meteo;
COMMENT ON TABLE grid
  IS 'Final fwi indexes images';

