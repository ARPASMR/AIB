// Fire weather indexes defines

/**
 * \file	fwi_define.h
 * \brief	defines for program
 */

/**
 * \def		GRD_DEFAULT_UNDEF_VALUE
 * \brief	default grid undefined value
 */
#define GRD_DEFAULT_UNDEF_VALUE -9999.0

/**
 * \def		GRD_COLS
 * \brief	default grid columns number
 */
#define GRD_COLS				177

/**
 * \def		GRD_ROWS
 * \brief	default grid rows number
 */
#define GRD_ROWS	   			174

/**
 * \def		GRD_X_START
 * \brief	default grid start point x coordinate
 *
 * Coordinates are expressed using Monte Mario 1 SRS
 * @see postgis documentation at http://postgis.refractions.net/
 * @see http://www.epsg.org/
 */
#define GRD_X_START				1436301.375

/**
 * \def		GRD_Y_START
 * \brief	default grid start point y coordinate
 *
 * Coordinates are expressed using Monte Mario 1 SRS
 * @see postgis documentation at http://postgis.refractions.net/
 * @see http://www.epsg.org/
 */
#define GRD_Y_START 			4916704.500

/**
 * \def		GRD_X_STEP
 * \brief	default grid step in x direction expressed in meters
 */
#define GRD_X_STEP	   			1500.0

/**
 * \def		GRD_Y_STEP
 * \brief	default grid step in y direction expressed in meters
 */
#define GRD_Y_STEP	   			1500.0

/**
 * \def		GRD_DEFAULT_VARNUM
 * \brief	default grid variables number
 */
#define GRD_DEFAULT_VARNUM		1

/**
 * \def		GRD_DEFAULT_SLOTSIZE
 * \brief	Grid slot default size (bytes)
 */
#define GRD_DEFAULT_SLOTSIZE	sizeof(float)

/**
 * 	\def	GRD_FLOAT_SLOTSIZE
 * 	\brief	Grid float slot size (bytes)
 */
#define GRD_FLOAT_SLOTSIZE		GRD_DEFAULT_SLOTSIZE

/**
 * 	\def	GRD_INT_SLOTSIZE
 *	\brief	Grid int slot size (bytes)
 */
#define GRD_INT_SLOTSIZE		sizeof(int)

/**
 * \def		TOPOGRAPHY_FIELDSNUM
 * \brief	Topography file fields number
 */
#define TOPOGRAPHY_FIELDSNUM	 6

/**
 * \def		TEMPERATURE_FIELDSNUM
 * \brief	Temperature dat file fields number
 */
#define TEMPERATURE_FIELDSNUM	 3

/**
 * \def		HUMIDITY_FIELDSNUM
 * \brief	Humidity dat file fields number
 */
#define HUMIDITY_FIELDSNUM		 6

/**
 * \def		WINDSPEED_FIELDSNUM
 * \brief	Windspeed dat file fields number
 */
#define WINDSPEED_FIELDSNUM		13

/**
 * \def		CUMRAIN_FIELDSNUM
 * \brief	Cumulative rain txt file fields number
 */
#define CUMRAIN_FIELDSNUM		 1

/**
 * \def		RAIN_FIELDSNUM
 * \brief	Rain dat file fields number
 */
#define RAIN_FIELDSNUM			 1

// Grid types
/**
 * \def		GEOGRID
 * \brief	Georeferenced grid
 */
#define GEOGRID					 0

/**
 * \def		METEO_INPUT
 * \brief	Grid containing meteo data
 */
#define METEO_INPUT				 1

/**
 * \def		FWI_INDEXES
 * \brief	Grid containing FWI indexes data
 */
#define FWI_INDEXES				 2

/**
 * \def		NUMERIC
 * \brief	Grid containing generic data
 */
#define NUMERIC					 3

// I/O format
/**
 * \def		GRD_FORMAT_TEXT
 * \brief	Grid data are stored as ascii text
 */
#define GRD_FORMAT_TEXT			 0

/**
 * \def		GRD_FORMAT_BINARY
 * \brief	Grid data are stored in binary format
 */
#define GRD_FORMAT_BINARY        1

// METEO parameters
/**
 * \def		METEO_PARAM_TEMPERATURE
 * \brief	Meteo parameter: temperature
 */
#define METEO_PARAM_TEMPERATURE		"temperature"

/**
 * \def		METEO_PARAM_HUMIDITY
 * \brief	Meteo parameter: humidity
 */
#define METEO_PARAM_HUMIDITY		"humidity"

/**
 * \def		METEO_PARAM_WINDSPEED
 * \brief	Meteo parameter: wind speed
 */
#define METEO_PARAM_WINDSPEED		"windspeed"

/**
 * 	\def	METEO_PARAM_CUMRAIN
 * 	\brief	Meteo parameter: cumulative rain
 */
#define METEO_PARAM_CUMRAIN			"cumrain"

/**
 * \def		METEO_PARAM_RAIN
 * \brief	Meteo parameter: rain
 */
#define METEO_PARAM_RAIN		"rain"

// Program actions
/**
 * \def		ACTION_CREATE
 * \brief	Program switch to create empty database
 */
#define ACTION_CREATE			"create"

/**
 * \def		ACTION_CREATE_STD_GRID
 * \brief	Program switch to create the standard grid (177x174)
 */
#define ACTION_CREATE_STD_GRID	"createstdgrid"

/**
 * \def		ACTION_IN
 * \brief	Program switch to store the needed input data in database
 */
#define ACTION_IN				"in"

/**
 * \def		ACTION_OUT
 * \brief	Program switch to store FWI indexes computation results in database
 */
#define ACTION_OUT				"out"

/**
 * \def		ACTION_OUT_IMG
 * \brief	Program switch to store summary images in database
 */
#define ACTION_OUT_IMG			"outimg"

/**
 * \def		ACTION_EXPORT_IMAGES
 * \brief	Program switch to export summary images from database to disk
 */
#define ACTION_EXPORT_IMAGES	"exportimg"

/**
 * \def		ACTION_EXPORT_INDEXES
 * \brief	Program switch to export FWI indexes as GrADS files
 */
#define ACTION_EXPORT_INDEXES	"exportidx"

/**
 * \def		ACTION_COMPUTE_INDEXES
 * \brief	Program switch to compute indexes
 *
 * This is an experimental feature
 * At the moment this action computes only these three new indexes
 * - angstroem
 * - fmi
 * - sharples
 */
#define ACTION_COMPUTE_INDEXES	"computeidx"

/**
 * \def		ACTION_COMPUTE_INDEXES_24
 * \brief	Program switch to compute indexes over 24 time slots
 *
 * This is an experimental feature
 * At the moment this action computes only these three new indexes
 *
 */
#define ACTION_COMPUTE_INDEXES_24	"computeidx24"

/**
 * 	\def	ACTION_EXPORT_SNOW_DEFAULT
 * 	\brief	Program switch to default export of snow grids
 */
#define ACTION_EXPORT_SNOW_DEFAULT	"exportsnowdefault"

/**
 * 	\def	ACTION_EXPORT_SNOW_ALL
 * 	\brief	Program switch to export all snow grids
 */
#define ACTION_EXPORT_SNOW_ALL		"exportsnowall"

/**
 * 	\def	ACTION_UPDATE_SNOW
 * 	\brief	Program switch to update snow field only
 */
#define	ACTION_UPDATE_SNOW			"updatesnow"

//#ifdef DEBUG
/**
 * \def		ACTION_TEST
 * \brief	Used only for testing
 */
#define	ACTION_TEST				"test"
//#endif

// GIS constants
/**
 * \def		GIS_DEFAULT_SRID
 * \brief	Default used SRID (Gauss-Boaga - Monte Mario 1 - Roma 40)
 */
#define GIS_DEFAULT_SRID		3003

// Database tables
/**
 * \def		GRD_DEFAULT_TABLE
 * \brief	Default grid table name
 */
#define GRD_DEFAULT_TABLE		"grid"

/**
 * \def		GRD_METEO_INPUT_TABLE
 * \brief	Default meteo input tables name
 */
#define GRD_METEO_INPUT_TABLE	"meteo_input"

/**
 * \def		GRD_FWI_INDEXES_TABLE
 * \brief	Default FWI indexes tables name
 */
#define GRD_FWI_INDEXES_TABLE	"fwi_indexes"

// Text tags
/**
 * \def		TAG_DATE
 * \brief	Date tag used in fwidbmgr.conf configuration file
 */
#define TAG_DATE				"<<date>>"

/**
 * \def		TAG_DATE_LEN
 * \brief	Length of date tag used in fwidbmgr.conf configuration file
 */
#define TAG_DATE_LEN			8

// Usefull defines
/**
 * \def		NOT_FOUND
 * \brief	Not found value after serch
 */
#define NOT_FOUND				-1

/**
 * \def		SUCCESS
 * \brief	successful operation return value
 */
#define SUCCESS					1

/**
 * \def		FAILURE
 * \brief	unsuccessfull operation return value
 */
#define FAILURE					0




