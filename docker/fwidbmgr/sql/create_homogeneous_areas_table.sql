-- Table: homogeneous_areas

-- DROP TABLE homogeneous_areas;

CREATE TABLE homogeneous_areas
(
  id serial NOT NULL,
  cathegory integer,
  name character varying(80),
  description character varying(80),
  code real,
  fi_n integer,
  fi_min real,
  fi_max real,
  fi_range real,
  fi_mean real,
  fi_stddev real,
  fi_variance real,
  fi_cf_var real,
  fi_sum real,
  area geometry,
  CONSTRAINT homogeneous_areas_pkey PRIMARY KEY (id ),
  CONSTRAINT enforce_dims_area CHECK (st_ndims(area) = 3),
  CONSTRAINT enforce_geotype_area CHECK (geometrytype(area) = 'MULTILINESTRING'::text OR area IS NULL),
  CONSTRAINT enforce_srid_area CHECK (st_srid(area) = 3003)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE homogeneous_areas
  OWNER TO meteo;
