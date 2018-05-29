/*
 * id:       "      $Id::                                                                                                            $:"
 * author:   "  $Author::                                                                                                            $:"
 * date:     "    $Date::                                                                                                            $:"
 * revision: "$Revision::                                                                                                            $:"
 * url:      " $HeadURL::                                                                                                            $:"
 */

/*
 ============================================================================

 Name        : fwidbmgr.cpp
 Author      : Luca Paganotti
 Version     : 0.1
 Copyright   : (c) 2012
 Description : fwi db manager
 ============================================================================
 */

/**
 * \file  fwidbmgr.cpp
 * \brief The main program file.
 */

/**	\mainpage FWI database manager
 *
 *  <i>fwidbmanager</i> is a custom application developed to store/retrieve meteo data and fire weather indexes
 *  in/from a postgresql database.
 *
 *  Presently fwi indexes are computed on a dayly basis taking as input the following data:
 *
 *  <ul>
 *    <li>a 174x177 point grid of Lumbardy starting from point (1436301.375 4916704.500) with 1500 meters resolution expressed in Gauss-Boaga (EPSG:3003). To each grid point the following information are associated</li>
 *    <ol>
 *      <li><i>nometeo</i> a flag indicating the fact that no meteo data are associated to the grid point</li>
 *      <ul>
 *        <li>1 means that no meteo data are associated to the grid point</li>
 *        <li>0 means that meteo data are associated to the grid point</li>
 *      </ul>
 *      <li><i>name</i> a symbolic name representing the grid point row and column in the format [row]-[column] with values starting from 1</li>
 *      <li><i>mask</i> a flag indicating that the grid point is inside the region border</li>
 *      <ul>
 *        <li>1 means that the grid point is inside the region border</li>
 *        <li>0 means that the grid point is outside the region border</li>
 *      </ul>
 *      <li><i>dz/dx</i> how z coordinate changes in the x direction</li>
 *      <li><i>dz/dy</i> how z coordinate changes in the y direction</li>
 *      <li><i>lake_mask</i> a flag indicating if the the point falls inside a lake area</li>
 *      <ul>
 *        <li>1 means that the grid point is inside a lake area</li>
 *        <li>0 means that the grid point is outside a lake area</li>
 *      </ul>
 *      <li><i>urban_weight</i> a real parameter between 0.0 and 1.0 indicating the urban weight</li>
 *      <li><i>p</i> the point geometry in the form (x, y, z)</li>
 *    </ol>
 *    <li>a set of GRIB files on the previous grid containing the following meteo data</li>
 *    <ul>
 *      <li>temperature</li>
 *      <ol>
 *        <li><i>xb</i> T background field</li>
 *        <li><i>xa</i> T analysis field</li>
 *        <li><i>tidi</i> T integral data influence</li>
 *      </ol>
 *      <li>humidity</li>
 *      <ol>
 *        <li><i>tdb</i> TD background field</li>
 *        <li><i>ta</i> T analysis field</li>
 *        <li><i>tda</i> ??????</li>
 *        <li><i>rha</i> RH analysis field</li>
 *        <li><i>rhidi</i> RH integral data influence</li>
 *        <li><i>hdxa</i> HUMIDEX analysis</li>
 *      </ol>
 *      <li>wind speed</li>
 *      <ol>
 *        <li><i>bu</i> u background</li>
 *        <li><i>bv</i> v background</li>
 *        <li><i>bhu</i> horizontal u background</li>
 *        <li><i>bhv</i> horizontal v background</li>
 *        <li><i>bvw</i> background vertical wind</li>
 *        <li><i>avw</i> analysis bertical wind</li>
 *        <li><i>au</i> u analysis</li>
 *        <li><i>av</i> v analysis</li>
 *        <li><i>ahu</i> horizontal u analysis</li>
 *        <li><i>ahv</i> horizontal v analysis</li>
 *        <li><i>adiv</i> analysis divergence</li>
 *        <li><i>avor</i> ??????</li>
 *        <li><i>wsidi</i> WS integral data influence</li>
 *      </ol>
 *      <li>cumulated rain</li>
 *      <li>rain</li>
 *      <ol>
 *        <li><i>snow</i>snow</li>
 *        <li><i>snow_covering</i> snow covering factor</li>
 *        <li><i>snow_dissolution</i> snow dissolution factor</li>
 *      </ol>
 *    </ul>
 *  </ul>
 *
 * \page folder_struct Distribution folder structure
 *
 * The application resides on disk in a specific folder to be defined by the environment variable <code>FWIDBMGR_HOME</code>.
 * For example <code>FWIDBMGR_HOME=~/fwidbmgr</code>
 *
 * Folder structure following:
 *
 * <b>config</b>
 * Contains the needed configuration files:
 * - <i>fwidbmgr.conf</i> is the application main configuration file
 * - <i>fwiscale.ini</i> (description is needed) not used at the moment
 * - <i>LogConfig.xml</i> is the log4cxx configuration file
 *
 * <b>log</b>
 * Contains the log file:
 * - <i>fwidbmgrDailyLog.log</i>
 *
 * <b>sql</b>
 * Contains the sql files containing the needed queries to create the fwi database from scratch
 * - <i>create_fwidb.sql</i> (description is needed)
 * - <i>create_fwi_indexes_table.sql</i> (description is needed)
 * - <i>create_grid_table.sql</i> (description is needed)
 * - <i>create_images_table.sql</i> (description is needed)
 * - <i>create_meteo_input_table.sql</i> (description is needed)
 * - <i>create_provinces_table.sql</i> (description is needed)
 * - <i>create_regions_table.sql</i> (description is needed)
 * - <i>partition_fwi_indexes_table.sql</i> (description is needed)
 * - <i>partition_meteo_input_table.sql</i> (description is needed)
 * - <i>postgis-64.sql</i> (description is needed)
 * - <i>spatial_ref_sys.sql</i> (description is needed)
 *
 * \page app_config Application configuration file
 *
 * The application configuration is done via a config file which format is driven by libconfig++ specifications. See the related codumentation at
 * http://www.hyperrealm.com/libconfig/
 *
 * The following sections describe briefly the main configuration parameters to be set in the configuration file.
 *
 * - \subpage db_connection_config "Database connection"
 * - \subpage application_paths "Application paths"
 * - \subpage application_files "Applications files"
 * - \subpage application_images "Application images"
 *
 * \page db_connection_config Database connection
 *
 * The first configuration parameters to be set are those related to the database connection. You need postgres superuser credentials and
 * the ones of a standard postgres user that must be setup in the database server before running the application.
 * Database connection needed parameters are:
 *
 * <ul>
 *   <li><i>host</i> the network name or IP address of the machine running postgresql server e.g "localhost"</li>
 *   <li><i>port</i> e.g 5432 is the standard postgresql port change it accordingly to your system setup</li>
 *   <li><i>dbname</i> the database name e.g. "fwidb"</li>
 *   <li><i>user</i> the standard postgres user e.g. "meteo"</li>
 *   <li><i>password</i> standard user password e.g. "secret"</li>
 *   <li><i>superuser</i> e.g. postgres</li>
 *   <li><i>superpwd</i> postgres user password</li>
 * </ul>
 *
 * \page application_paths Application paths
 *
 * <b>To be done.</b>
 *
 * \page application_files Application files
 *
 * This is a big configuration section with many subsections.
 *
 * <b>To be done</b>
 *
 * \page application_images Application images
 *
 * <b>To be done</b>
 */

#include <stdio.h>
#include <stdlib.h>
#include <cstdlib>
#include <string.h>
#include <strings.h>
#include <time.h>
#include <iostream>
#include <fstream>
#include <sstream>
#include <iomanip>
#include <vector>
#include <assert.h>
#include <getopt.h>

#include <arpa/inet.h>

// libconfig support
#include <libconfig.h++>

//#define __OPENSUSE_11_3__
//#undef __OPENSUSE_11_3__

// postgresql support
#ifdef __OPENSUSE_11_3__
#include <pgsql/libpq-fe.h>
#else
#include <libpq-fe.h>
#endif

// geos support
//#include <geos.h>
#include <geos/geom/Coordinate.h>
#include <geos/geom/CoordinateArraySequence.h>
#include <geos/geom/CoordinateArraySequenceFactory.h>
#include <geos/geom/Geometry.h>
#include <geos/geom/GeometryFactory.h>
#include <geos/geom/LinearRing.h>
#include <geos/geom/Polygon.h>
#include <geos/io/WKTWriter.h>

// boost ptime support
#include "boost/date_time/posix_time/posix_time.hpp" //include all types plus i/o
#include <boost/date_time/date_facet.hpp>

// log4cxx support
#include "log4cxx/logger.h"
#include "log4cxx/basicconfigurator.h"
#include "log4cxx/helpers/exception.h"
#include <log4cxx/xml/domconfigurator.h>

// syslog
#include <syslog.h>

#include <fwi_define.h>
#include <CommandLineArguments.h>
#include <Grid.h>

using namespace std;
using namespace fwi;
using namespace fwi::grid;
using namespace fwi::generators;
using namespace libconfig;
using namespace geos;
using namespace geos::geom;
using namespace geos::io;
using namespace boost::posix_time;
using namespace log4cxx;
using namespace log4cxx::helpers;
using namespace log4cxx::xml;

/**
 * \var		PGconn* conn
 * \brief	Global connection object
 * @see postgresql documentation at http://www.postgresql.org/
 */
static PGconn* conn = NULL;

/**
 * \var		Config cfg
 * \brief	Application configuration object
 * @see libconfig++ documentation at http://www.hyperrealm.com/libconfig/
 */
static Config  cfg;

/**
 * \var		log4cxx::LoggerPtr logger(log4cxx::Logger::getLogger("fwi"))
 * \brief	Application logger
 *
 * \@see	log4cxx documentation at http://logging.apache.org/log4cxx/
 */
log4cxx::LoggerPtr logger(log4cxx::Logger::getLogger("fwi"));

/**
 * \var		bool default_config
 * \brief   Use default config file in FWIDBMGR_HOME
 */
bool default_config = true;

/**
 * \fn		string getProgramHome()
 * \brief	Reads environment variable FWIDBMGR_HOME
 *
 * This environment variable has to be defined in order to run fwidbmgr
 *
 * @return the path pointed by FWIDBMGR_HOME or a standard path
 */
std::string getProgramHome()
{
	std::string key = "FWIDBMGR_HOME";
    char * val = getenv( key.c_str() );
	//return val == NULL ? std::string("/home/buck/dev/arpa/fwidbmgr") : std::string(val);
    return val == NULL ? std::string("/home/meteo/dev/redist/fwidbmgr") : std::string(val);
}

/**
 * \fn		struct tm parseDate(std::string dt)
 * \brief	Parses a string for a date value.
 * \param	dt string to be parsed
 * \return  struct tm filled with parsed values
 */
struct tm parseDate(std::string dt)
{
	struct tm tp;
	bzero(&tp, sizeof(struct tm));
	if( dt.at(4) != '-' && dt.at(7) != '-' )
	{
		dt = dt.insert(4, 1, '-');
		dt = dt.insert(7, 1, '-');
	}
	strptime(dt.c_str(), "%F", &tp);

	return tp;
}

/**
 * \fn		bool readConfig()
 * \brief	Read configuration file
 * \return	true on success else false
 * @see libconfig++ documentation at http://www.hyperrealm.com/libconfig/
 */
bool readConfig(std::string configFilePath = "")
{
	std::string home    = getProgramHome();
	std::string cfgpath = home;
	cfgpath += "/config/fwidbmgr.conf";
	try
	{
		if( configFilePath.empty() )
		{
			LOG4CXX_INFO(logger, "Try to read: " << cfgpath.c_str() << ".");
			cfg.readFile(cfgpath.c_str());
		}
		else
		{
			LOG4CXX_INFO(logger, "Try to read: " << configFilePath.c_str() << ".");
			cfg.readFile(configFilePath.c_str());
		}
	}
	catch( libconfig::ParseException* pe )
	{
		LOG4CXX_FATAL(logger, "Config file exception: "<< pe->getError() << " in " << pe->getFile() << " at line: " << pe->getLine());
		return false;
	}
	return true;
}

/**
 * \fn		void usage()
 * \brief	helper function for usage display
 *
 * Displays the following text:
 *
 * <b>fwidbmgr usage</b>
 *
 * <i>fwidbmgr -a action [-d date] [-c config] [-D database] [-H host] [-P port] [-U user] [-p password] [-h]</i>
 *
 * where action must be one of:
 *
 * <table border="0">
 *   <tr><td><b>create</b></td><td>creates an empty database structure</td></tr>
 *   <tr><td><b>createstdgrid</b></td><td>creates the standard 177x174 point grid</td></tr>
 *   <tr><td><b>in</b></td><td>saves in db input data for date given by option date</td></tr>
 *   <tr><td><b>out</b></td><td>saves in db output data of fwi indexes computation</td></tr>
 *   <tr><td><b>outimg</b></td><td>saves in db output images</td></tr>
 *   <tr><td><b>exportimg</b></td><td>exports images from db to files</td></tr>
 *   <tr><td><b>exportidx</b></td><td>exports indexes grid to text files</td></tr>
 *   <tr><td><b>computeidx</b></td><td>computes new indexes angstroem, fmi and sharples [experimental]</td></tr>
 *   <tr><td><b>computeidx24</b></td><td>computes new indexes over 24 time slots [experimental]</td></tr>
 *   <tr><td><b>exportsnowdefault</b></td><td>exports snow grids in default way (all snow info except <quote>snow</quote> grid)</td></tr>
 *   <tr><td><b>exportsnowall</b></td><td>exports all snow grids</td></tr>
 *   <tr><td><b>updatesnow</b></td><td>updates snow grid only</td></tr>
 * </table>
 *
 * where date must be a valid date in ISO 8601 format ex. (2012-03-22)
 *
 * where config is the absolute path to the configuration file
 *
 * where database is the database name to be used
 *
 * where host is the database host name or IP address
 *
 * where port is the postgresql port
 *
 * where user is the database user that has the proper rights
 *
 * where password is the user password
 *
 * h --> prints this text
 */
void usage()
{
	cout << endl;
	cout << "fwidbmgr usage" << endl;
	cout << "\tfwidbmgr -a action [-d date] [-c config] [-D database] [-H host] [-P port] [-U user] [-p password] [-h]" << endl;
	cout << "where action must be one of: " << endl;
	cout << "\t* create:            creates an empty database structure" << endl;
	cout << "\t* createstdgrid:     creates the standard 177x174 point grid" << endl;
	cout << "\t* in:                saves in db input data for date given by option date" << endl;
	cout << "\t* out:               saves in db output data of fwi indexes computation" << endl;
	cout << "\t* outimg:            saves in db output images" << endl;
	cout << "\t* exportimg:         exports images from db to files" << endl;
	cout << "\t* exportidx:         exports indexes grid to text files" << endl;
	cout << "\t* computeidx:        computes new indexes angstroem, fmi and sharples [experimental]" << endl;
	cout << "\t* computeidx24:      computes new indexes over 24 time slots [experimental]" << endl;
	cout << "\t* exportsnowdefault: exports snow grids in default way (all snow info except 'snow' grid)" << endl;
    cout << "\t* exportsnowall:     exports all snow grids" << endl;
    cout << "\t* updatesnow:        updates snow grid only" << endl;
	cout << "where date must be a valid date in ISO 8601 format ex. (2012-03-22)" << endl;
	cout << "where config is the absolute path to the configuration file" << endl;
	cout << "where database is the database name to be used" << endl;
	cout << "where host is the database host name or IP address" << endl;
	cout << "where port is the postgresql port" << endl;
	cout << "where user is the database user that has the proper rights" << endl;
	cout << "where password is the user password" << endl;
	cout << "h --> prints this text" << endl;
	cout << endl;
}

/**
 * \fn		bool process_cmd_line(int argc, char** argv, CommandLineArguments* args)
 * \brief	Process command line parameters
 * \param	argc Number of command line parameters
 * \param	argv array of string parameters
 * \param   args command line arguments
 * \return  true on success else false
 * @see CommandLineArguments
 */
bool process_cmd_line(int argc, char** argv, CommandLineArguments* args)
{
	int c = 0;

	assert( args != NULL );

	if( (argc != 1 && argc != 2 && argc != 3) && argc < 5 )
	{
		LOG4CXX_FATAL(logger, "Wrong number of arguments.");
		syslog(LOG_CRIT, "Wrong number of arguments.");
		cout << "Wrong number of arguments." << endl;
		return false;
	}

	if( argc == 1 )
	{
		usage();
		return true;
	}

	while( (c = getopt(argc, argv, "a:c:d:D:H:P:U:p:h")) != EOF )
	{
		switch( c )
		{
		case 'a':
			args->setAction(optarg);
			LOG4CXX_INFO(logger, "action: " << args->getAction() << ".");
			break;
		case 'c':
			{
				if( !readConfig(optarg) )
				{
					LOG4CXX_ERROR(logger, "Unable to read config file: " << optarg << ".");
					return false;
				}
				else
				{
					default_config = false;
				}
			}
			break;
		case 'd':
			{
				std::string dt  = optarg;
				size_t pos = 0;
				while( (pos = dt.find('-')) != dt.npos )
				{
					dt.erase(pos, 1);
				}
				args->setDate(dt);
				LOG4CXX_INFO(logger, "date: " << args->getDate() << ".");
			}
			break;
		case 'D':
			args->setDbName(optarg);
			LOG4CXX_INFO(logger, "db name: " << args->getDbName() << ".");
			break;
		case 'H':
			args->setHost(optarg);
			LOG4CXX_INFO(logger, "host: " << args->getHost() << ".");
			break;
		case 'P':
			{
				args->setPort(atoi(optarg));
				stringstream ss;
				ss << "port: " << args->getPort() << " ";
				logger->info(ss.str());
			}
			break;
		case 'U':
			args->setUser(optarg);
			LOG4CXX_INFO(logger, "user: " << args->getUser() << ".");
			break;
		case 'p':
			args->setPassword(optarg);
			LOG4CXX_INFO(logger, "password: ******" << ".");
			break;
		case 'h':
			args->setHelp(true);
			usage();
			return true;
			break;
		default:
			LOG4CXX_WARN(logger, "Some options were not correct.");
			syslog(LOG_WARNING, "Some options were not correct.");
			return false;
		}
	}

	return true;
}

/**
 * \fn		bool getSqlFiles(std::vector<std::string> &files)
 * \brief	gets sql files paths from configuration
 * \param	files string vector containing files paths
 * \return	true on success else false
 * @see libconfig++ documentation at http://www.hyperrealm.com/libconfig/
 */
bool getSqlFiles(std::vector<std::string> &files)
{
	int    sqlfilesnum  = 0;
	std::string cfgpath;
	std::string file;
	char   s[10];

	bzero(s, 10);

	files.clear();

	if( !cfg.lookupValue("fwidbmgr.files.sqlfilesnum", sqlfilesnum) )
	{
		return false;
	}

	stringstream ss;
	ss << "Got " << sqlfilesnum << " sql files.";
	logger->info(ss.str());

	for( int i = 0; i < sqlfilesnum; i++ )
	{
		cfgpath  = "fwidbmgr.files.sqlfiles.[";
		sprintf(s, "%d", i);
		cfgpath += s;
		cfgpath += "]";

		if( cfg.lookupValue(cfgpath, file) )
		{
			files.push_back(file);
		}
		else
		{
			return false;
		}
	}

	return true;
}

/**
 * \fn		string loadQueryFromFile(std::string filepath)
 * \brief	loads in memory a file content
 * \param	filepath complete file path
 * \return  the file content
 */
std::string loadQueryFromFile(std::string filepath)
{
	ifstream ifs(filepath.c_str(), ifstream::in);

	std::string result((std::istreambuf_iterator<char>(ifs)), std::istreambuf_iterator<char>());

	ifs.close();

	return result;
}

/**
 * \fn		bool execute(std::string& query)
 * \brief	executes query command
 * \param	query sql commands to be executed
 * \return	true on success else false
 */
bool execute(std::string& query)
{
	assert( conn != NULL );
	assert( PQstatus(conn) != CONNECTION_BAD );

	PGresult* result = PQexec(conn, query.c_str());

	if( PQresultStatus(result) != PGRES_COMMAND_OK )
	{
		LOG4CXX_FATAL(logger, "SQL command failed: " << PQerrorMessage(conn) << ".");
		syslog(LOG_CRIT, "SQL command failed: %s.", PQerrorMessage(conn));
		PQclear(result);
		return false;
	}
	else
	{
#ifdef DEBUG
		LOG4CXX_INFO(logger, "Executed query:\n" << query);
#endif
	}

	return true;
}

/**
 * \fn		bool create_database()
 * \brief	creates database structure based on configuration contents
 * \return	true on success else false
 */
bool create_database()
{
	assert( conn != NULL );
	assert(  PQstatus(conn) != CONNECTION_BAD );

	std::string sqlpath;
	std::string file;
	std::string dbname;
	std::string query;

	if( cfg.lookupValue("fwidbmgr.paths.sqlpath", sqlpath) )
	{
		LOG4CXX_INFO(logger, "sql files path:" << sqlpath << ".");
	}
	else
	{
		return false;
	}

	if( cfg.lookupValue("fwidbmgr.files.sqlfiles.[0]", file) )
	{
		LOG4CXX_INFO(logger, "Using file: " << file << " to create database.");
	}
	else
	{
		return false;
	}

	file  = sqlpath + "/" + file;
	query = loadQueryFromFile(file);
	if( file.find("create_fwidb.sql") != std::string::npos )
	{
		if( cfg.lookupValue("fwidbmgr.dbconnection.dbname", dbname) )
		{
			LOG4CXX_INFO(logger, "create fwi db: " << dbname << ".");
			query.replace(query.find("fwidb"), 5, dbname);
			query.replace(query.find("fwidb"), 5, dbname);
			query.replace(query.find("fwidb"), 5, dbname);
		}
		else
		{
			return false;
		}
	}

	return execute(query);

}

/**
 * \fn		bool fill_database()
 * \brief	fills empty database structure with data (ex. spatial ref systems from postgis)
 * \return	true on success else false
 * @see libconfig++ documentation at http://www.hyperrealm.com/libconfig/
 */
bool fill_database()
{
	assert( conn != NULL );
	assert(  PQstatus(conn) != CONNECTION_BAD );

	std::string sqlpath;
	std::string file;
	std::string dbname;
	std::vector<std::string> sqlfiles;

	if( getSqlFiles(sqlfiles) )
	{
		if( cfg.lookupValue("fwidbmgr.paths.sqlpath", sqlpath) )
		{
			LOG4CXX_INFO(logger, "sql files path:" << sqlpath << ".");
		}
		else
		{
			return false;
		}

		for( size_t i = 1; i < sqlfiles.size(); i++ )
		{
			file         = sqlpath + "/" + sqlfiles[i];
			LOG4CXX_INFO(logger, "Executing query in file: " << file);
			std::string query = loadQueryFromFile(file);
			if( !execute(query) )
			{
				LOG4CXX_ERROR(logger, "Database error running query in file: " << file);
				syslog(LOG_ERR, "Database error running query in file: %s", file.c_str());
			}
		}
	}
	else
	{
		LOG4CXX_FATAL(logger, "ERROR: unable to retrieve sql files.");
		syslog(LOG_CRIT, "ERROR: unable to retrieve sql files.");
		return false;
	}

	return true;
}

/**
 * \fn		bool prepare_meteo_input(std::string date)
 * \brief	creates skeleton structure for meteo input grid referring to date
 * \param	date referring date as YYYYMMDD
 * \return	true on success else false
 */
bool prepare_meteo_input(std::string date)
{
	assert( conn != NULL );

	Grid<float> grid(GRD_ROWS, GRD_COLS);
	grid.initialize();
	grid.setType(NUMERIC);
	grid.setDate(date);
	grid.setTable("meteo_input");

	int nelem = grid.getElementsCount();
	std::string       sqlstmt;
	stringstream ss;

	for( int i = 0; i < nelem; i++ )
	{
		ss << "insert into " << grid.getTable() << " (point_id, dt) values(" << i + 1 << ", '" << date << "');\n";
	}

	sqlstmt = ss.str();

#ifdef DEBUG
	LOG4CXX_INFO(logger, sqlstmt << ".");
#endif

	return execute(sqlstmt);
}

/**
 * \fn		bool fill_nometeo_points()
 * \brief	fills grid table with no mete point flags
 * @see Grid
 */
bool fill_nometeo_points()
{
	assert( conn != NULL );

	std::string file    = "";
	std::string table   = "";
	std::string field   = "";
	std::string line    = "";
	std::string sql     = "";
	std::string sqlstmt = "";
	std::string pname   = "";
	int    pn           =  0;
	int    row          =  0;
	int    col          =  0;

	if( readConfig() )
	{
		if( cfg.lookupValue("fwidbmgr.files.setupfiles.nometeopoints.file",  file)  &&
			cfg.lookupValue("fwidbmgr.files.setupfiles.nometeopoints.table", table) &&
			cfg.lookupValue("fwidbmgr.files.setupfiles.nometeopoints.field", field) )
		{
			LOG4CXX_INFO(logger, "file: " << file << " table: " << table << " field: " << field << ".");
			ifstream in(file.c_str());
			if( in.is_open() )
			{
				while( in.good() )
				{
				    getline(in, line);
				    pn = atoi(line.c_str());
				    getline(in, line);
				    for( int i = 0; i < pn; i++ )
				    {
				    	getline(in, line);
				    	sscanf(line.c_str(), "%d %d", &row, &col);

				    	stringstream ss;
				    	ss << setw(3) << setfill('0') << row << "-" << setw(3) << setfill('0') << col;

				    	sqlstmt  = "update grid set nometeo = true where name = '";
				    	sqlstmt += ss.str();
				    	sqlstmt += "';\n";

				    	sql += sqlstmt;
				    }

				    execute(sql);
#ifdef DEBUG
				    LOG4CXX_INFO(logger, sql << ".");
#endif
				}
				in.close();
			}
			else
			{
				LOG4CXX_FATAL(logger, "Unable to open file " << file << ".");
				syslog(LOG_CRIT, "Unable to open file %s", file.c_str());
				return false;
			}
		}
		else
		{
			LOG4CXX_FATAL(logger, "Unable to get nometeo settings.");
			syslog(LOG_CRIT, "Unable to get nometeo settings.");
			return false;
		}

		return true;
	}
	else
	{
		LOG4CXX_FATAL(logger, "Unable to read config.");
		syslog(LOG_CRIT, "Unable to read config.");
	}

	return false;
}

/**
 * \fn		bool import_regions()
 * \brief	Imports regions polygons in database from file
 * \return	true on success else false
 */
bool import_regions()
{
	int    polygons_number         = 0;
	int    point_number            = 0;
	float  x                       = 0.0f;
	float  y                       = 0.0f;
	float  z                       = 0.0f;
	std::string line               = "";
	std::string fname              = "";
	std::string table              = "";
	std::string field              = "";
	std::string sqlstmt            = "";

	const GeometryFactory*             gf  = geos::geom::GeometryFactory::getDefaultInstance();
	assert( gf != NULL );
    const 	CoordinateSequenceFactory* csf = gf->getCoordinateSequenceFactory();
	assert( csf != NULL );

	if( !cfg.lookupValue("fwidbmgr.files.setupfiles.regions.file", fname) )
	{
		LOG4CXX_FATAL(logger, "Unable to determine regions file name.");
		syslog(LOG_CRIT, "Unable to determine regions file name.");
		return false;
	}
	if( !cfg.lookupValue("fwidbmgr.files.setupfiles.regions.table", table) )
	{
		LOG4CXX_FATAL(logger, "Unable to determine regions table name.");
		syslog(LOG_CRIT, "Unable to determine regions table name.");
		return false;
	}
	if( !cfg.lookupValue("fwidbmgr.files.setupfiles.regions.field", field) )
	{
		LOG4CXX_FATAL(logger, "Unable to determine regions field name.");
		syslog(LOG_CRIT, "Unable to determine regions field name.");
		return false;
	}

	std::string name = "";

	size_t pos = fname.rfind('/');
	size_t end = fname.rfind('.');

	if( pos != fname.npos )
	{
		name = fname.substr(pos + 1, end - pos - 1);
		name[0] += 'A' - 'a';
	}
	else
	{
		LOG4CXX_FATAL(logger, "Error parsing file path.");
		syslog(LOG_CRIT, "Error parsing file path.");
		return false;
	}

#ifdef __OPENSUSE_11_3__
	ifstream is(fname.c_str());
#else
	ifstream is(fname);
#endif

	assert( is.is_open() );

	getline(is, line);

	// read polygons number
	is >> line >> polygons_number;

	std::vector<Geometry*> polygons;

	for( int i = 0; i < polygons_number; i++ )
	{
		// read point number
		is >> point_number;
		CoordinateSequence* cs = csf->create(point_number, 3);
		assert( cs != NULL );

		stringstream ss;
		ss << "coord sequence size: " << cs->getSize() << ".";
		logger->info(ss.str());

		for( int j = 0; j < point_number; j++ )
		{
			is >> x >> y;
#ifdef DEBUG
			LOG4CXX_TRACE(logger, x << " " << y << "\n");
#endif

			cs->setAt(*new Coordinate(x, y, z), j);
		}

		cs->add(*new Coordinate(cs->getAt(0)));

		LinearRing* shell = gf->createLinearRing(cs);
		assert( shell != NULL );
		shell->setSRID(3003);
		Polygon*    p     = gf->createPolygon(shell, NULL);
		assert( p != NULL );
		p->setSRID(3003);
		polygons.push_back(p);
	}

	MultiPolygon* mp = gf->createMultiPolygon(polygons);
	assert( mp != NULL );

	mp->setSRID(3003);

	is.close();

	// now put row in regions table
	WKTWriter writer;

	writer.setOutputDimension(3);
	writer.setOld3D(true);

	stringstream ss;

	ss << "insert into regions (name, p) values ('" << name << "', geomfromewkt('SRID=3003; " << writer.write(mp) << "'));";

	sqlstmt = ss.str();

	return execute(sqlstmt);
}

/**
 * \fn		bool import_provinces()
 * \brief	Imports provinces polygons in database from file
 * \return	true on success else false
 */
bool import_provinces()
{
	int    provinces_number = 0;
	int    polygons_number  = 0;
	int    point_number     = 0;
	float  x                = 0.0;
	float  y                = 0.0;
	float  z                = 0.0;
	std::string sql;
	std::string sqlstmt;
	std::string cfgpath;
	std::string region;
	std::string file;
	std::string name;
	std::string line;

	const GeometryFactory*             gf  = geos::geom::GeometryFactory::getDefaultInstance();
	assert( gf != NULL );
	const 	CoordinateSequenceFactory* csf = gf->getCoordinateSequenceFactory();
	assert( csf != NULL );

	if( !cfg.lookupValue("fwidbmgr.files.setupfiles.provinces.number", provinces_number) )
	{
		LOG4CXX_FATAL(logger, "Unable to get provinces number.");
		syslog(LOG_CRIT, "Unable to get provinces number.");
		return false;
	}

	LOG4CXX_INFO(logger, "Got " << provinces_number << " province files" << ".");

	for( int i = 0; i < provinces_number; i++ )
	{
		cfgpath  = "fwidbmgr.files.setupfiles.provinces.names";

		try
		{
			Setting& cp = cfg.lookup(cfgpath)[i];

			if( !cp.lookupValue("region", region) )
			{
				LOG4CXX_FATAL(logger, "Unable to read province[" << i + 1 << "] region." << ".");
				syslog(LOG_CRIT, "Unable to read province[%d] region.", i + 1);
				return false;
			}

			// get region id
			stringstream s;

			s << "select id from regions where name = '" << region << "';";

			PGresult* result = PQexec(conn, s.str().c_str());

			if( PQresultStatus(result) != PGRES_TUPLES_OK )
			{
				LOG4CXX_FATAL(logger, "SQL statemet failed: " << PQerrorMessage(conn) << ".");
				syslog(LOG_CRIT, "SQL statemet failed: %s.", PQerrorMessage(conn));
				PQclear(result);
				return false;
			}

			int region_id = atoi(PQgetvalue(result, 0, 0));

			if( !cp.lookupValue("name", name) )
			{
				LOG4CXX_FATAL(logger, "Unable to read province[" << i + 1 << "] name." << ".");
				syslog(LOG_CRIT, "Unable to read province[%d] name.", i + 1);
				return false;
			}

			if( !cp.lookupValue("file", file) )
			{
				LOG4CXX_FATAL(logger, "Unable to read province[" << i + 1 << "] file." << ".");
				syslog(LOG_CRIT, "Unable to read province[%d] file.", i + 1);
				return false;
			}

#ifdef __OPENSUSE_11_3__
			ifstream is(file.c_str());
#else
	ifstream is(file);
#endif

			assert( is.is_open() );

			getline(is, line);

			// read polygons number
			is >> line >> polygons_number;

			std::vector<Geometry*> polygons;

			for( int i = 0; i < polygons_number; i++ )
			{
				// read point number
				is >> point_number;
				CoordinateSequence* cs = csf->create(point_number, 3);
				assert( cs != NULL );

				stringstream ss;
				ss <<"coord sequence size: " << cs->getSize() << ".";
				logger->info(ss.str());

				for( int j = 0; j < point_number; j++ )
				{
					is >> x >> y;
		#ifdef DEBUG
					LOG4CXX_TRACE(logger, x << " " << y << "\n");
		#endif

					cs->setAt(*new Coordinate(x, y, z), j);
				}

				cs->add(*new Coordinate(cs->getAt(0)));

				LinearRing* shell = gf->createLinearRing(cs);
				assert( shell != NULL );
				shell->setSRID(3003);
				Polygon*    p     = gf->createPolygon(shell, NULL);
				assert( p != NULL );
				p->setSRID(3003);
				polygons.push_back(p);
			}

			MultiPolygon* mp = gf->createMultiPolygon(polygons);
			assert( mp != NULL );

			mp->setSRID(3003);

			is.close();

			// now put row in regions table
			WKTWriter writer;

			writer.setOutputDimension(3);
			writer.setOld3D(true);

			stringstream ss;

			ss << "insert into provinces (region_id, name, p) values (" << region_id << ", '" << name << "', geomfromewkt('SRID=3003; " << writer.write(mp) << "'));";

			sqlstmt = ss.str();

			is.close();

			sql += sqlstmt + "\n";
		}
		catch( SettingNotFoundException* e)
		{
			LOG4CXX_FATAL(logger, "Setting exception: " << e->getPath() << ".");
			syslog(LOG_CRIT, "Setting exception: %s.", e->getPath());
			return false;
		}
	}

	return execute(/*conn,*/ sql);
}

/**
 * \fn		bool create_standard_grid()
 * \brief	create a standard 174 row x 177 columns grid
 * \return	true on success else false
 */
bool create_standard_grid(/*PGconn* conn, Config& cfg*/)
{

	assert( conn != NULL );

	bool   result = false;

	char   row [30];
	char   col [30];
	char   sx  [30];
	char   sy  [30];
	char   sz  [30];
	char   srid[30];

	bzero(row,  30);
	bzero(col,  30);
	bzero(sx,   30);
	bzero(sy,   30);
	bzero(sz,   30);
	bzero(srid, 30);

	std::string sqlstmt   = "";
	std::string sql       = "";
	std::string pointstmt = "";
	std::string pointsql  = "";
	std::string where     = "";

	PointGrid_t pointGrid;
	pointGrid.initialize();

	Grid<float> topography(GRD_ROWS, GRD_COLS);
	topography.setVarNum(TOPOGRAPHY_FIELDSNUM);
	topography.initialize();
	topography.setType(NUMERIC);
	if( topography.configure("topography", cfg) )
	{
		if( !topography.read() )
		{
			LOG4CXX_FATAL(logger, "Error: unable to read dat file.");
			syslog(LOG_CRIT, "Error: unable to read dat file.");
			return false;
		}

		int pidx = 1;

		float x = pointGrid.getXStart();
		float y = pointGrid.getYStart(); // + pointGrid.getYStep() * (pointGrid.getRows() - 1);


		// do update
		for( int i = 0; i < topography.getRows(); i++ )
		{
			for(int j = 0; j < topography.getCols(); j++ )
			{
				stringstream sss;
				sss << " where id = '" << pidx++ << "';\n";
				where = sss.str();
				sss.clear();

				stringstream ss;

				ss << "update " << topography.getTable() << " set ";

				for( int k = 0; k < topography.getVarNum(); k++ )
				{
					if( k == 0 )
					{
						float ffff = topography(i, j, 0);

						Point* p = geos::geom::GeometryFactory::getDefaultInstance()->createPoint(Coordinate(x, y, ffff));

						pointGrid(i, j, 0) = p;

						const Coordinate* c = p->getCoordinate();        //    ->getCoordinate();
						assert( c != NULL );

						sprintf(row, "%03d", i + 1);
						sprintf(col, "%03d", j + 1);
						sprintf(sx,   "%f", c->x);
						sprintf(sy,   "%f", c->y);
						sprintf(sz,   "%f", c->z);
						sprintf(srid, "%d", pointGrid.getSRID());

						// insert into grid(p, name) values( st_geomfromewkt(SRID=3003; 'POINT(47631800.000000 51112204.000000 0.000000)'),'174-177');
						// select id, st_asewkt(p) from grid where id = 45;
						pointstmt  = "insert into grid(p, z, name) values (st_geomfromewkt('SRID=";
						pointstmt += srid;
						pointstmt += ";POINT(";
						pointstmt += sx;
						pointstmt += " ";
						pointstmt += sy;
						pointstmt += " ";
						pointstmt += sz;
						pointstmt += ")'), ";
						pointstmt += sz;
						pointstmt += ", '";
						pointstmt += row;
						pointstmt += "-";
						pointstmt += col;
						pointstmt += "');\n";

#ifdef DEBUG
						LOG4CXX_TRACE(logger, pointstmt << "\n");
#endif

						x += pointGrid.getXStep();
					}
					else
					{
						if( topography.getFields()->at(k)->getFieldName() == "mask" ||
							topography.getFields()->at(k)->getFieldName() == "lake_mask"	)
						{
							ss << topography.getFields()->at(k)->getFieldName() << " = " << ((topography(i, j, k) == 1.0) ? "'t'" : "'f'");
						}
						else
						{
							ss << topography.getFields()->at(k)->getFieldName() << " = " << topography(i, j, k);
						}

						if( k != topography.getVarNum() - 1 )
						{
							ss << ", ";
						}
					}
				}

				ss << " " << where;

				sqlstmt = ss.str();

				ss.clear();

				pointsql += pointstmt;
				sql      += sqlstmt;

				if( i % 2 && j % 2 )
				{
					(topography(i, j, 1) == 1) ? cout << "+" : cout << ".";
				}
			}

			x  = pointGrid.getXStart();
			y += pointGrid.getYStep();

			if( i % 2 )
			{
				cout << endl;
			}
		}
	}
	else
	{
		LOG4CXX_FATAL(logger, "Error configuring grid.");
		syslog(LOG_CRIT, "Error configuring grid.");
		return false;
	}

	result = execute(pointsql);
	result = result && execute(sql);
	result = result && fill_nometeo_points();
	result = result && import_regions();
	result = result && import_provinces();

	return result;
}

/**
 * \fn		bool delete_meteo_input(CommandLineArguments& args)
 * \brief	deletes meteo input grid for date in <i>args</i> from database
 * \param	args command line arguments class
 * \return	true on success else false
 * @see CommandLineArguments
 */
bool delete_meteo_input(CommandLineArguments& args)
{
	std::string query = "";

	stringstream ss;

	ss << "delete from meteo_input where dt = '" << args.getDate() << "';";

	query = ss.str();

	return execute(query);
}

/**
 * \fn		bool store_meteo_input(CommandLineArguments& args)
 * \brief	stores meteo input grid for date in <i>args</i> reading from files
 * \param	args command line arguments class
 * \return	true on success else false
 * @see CommandLineArguments
 */
bool store_meteo_input(CommandLineArguments& args)
{
	Grid<float> snow;
	snow.setVarNum(1);
	snow.initialize();

#ifdef __OPENSUSE_11_3__
	snow.setXDir(DECREASING);
#else
	snow.setXDir(COORDINATE_DIRECTION::DECREASING);
#endif

	std::string path = "";

	if( snow.configure("snow", cfg) )
	{
		snow.setDate(args.getDate());
		std::string path = snow.getDatPath();
		path.replace(path.find(TAG_DATE), TAG_DATE_LEN, snow.getDate());
		snow.setDatPath(path);
		if( !snow.read() )
		{
			LOG4CXX_FATAL(logger, "Error: unable to read txt file: " << snow.getDatPath() << ".");
			syslog(LOG_CRIT, "Error: unable to read txt file: %s.", snow.getDatPath().c_str());
			return false;
		}
	}

	Grid<float> snow_covering;
	snow_covering.setVarNum(1);
	snow_covering.initialize();

#ifdef __OPENSUSE_11_3__
	snow_covering.setXDir(DECREASING);
#else
	snow_covering.setXDir(COORDINATE_DIRECTION::DECREASING);
#endif

	path = "";

	if( snow_covering.configure("snow_covering", cfg) )
	{
		snow_covering.setDate(args.getDate());
		std::string path = snow_covering.getDatPath();
		path.replace(path.find(TAG_DATE), TAG_DATE_LEN, snow_covering.getDate());
		snow_covering.setDatPath(path);
		if( !snow_covering.read() )
		{
			LOG4CXX_FATAL(logger, "Error: unable to read txt file: " << snow_covering.getDatPath() << ".");
			syslog(LOG_CRIT, "Error: unable to read txt file: %s.", snow_covering.getDatPath().c_str());
			return false;
		}
	}

	Grid<float> snow_dissolution;
	snow_dissolution.setVarNum(1);
	snow_dissolution.initialize();

#ifdef __OPENSUSE_11_3__
	snow_dissolution.setXDir(DECREASING);
#else
	snow_dissolution.setXDir(COORDINATE_DIRECTION::DECREASING);
#endif

	path = "";

	if( snow_dissolution.configure("snow_dissolution", cfg) )
	{
		snow_dissolution.setDate(args.getDate());
		path = snow_dissolution.getDatPath();
		path.replace(path.find(TAG_DATE), TAG_DATE_LEN, snow_dissolution.getDate());
		snow_dissolution.setDatPath(path);
		if( !snow_dissolution.read() )
		{
			LOG4CXX_FATAL(logger, "Error: unable to read txt file: " << snow_dissolution.getDatPath() << ".");
			syslog(LOG_CRIT, "Error: unable to read txt file: %s.", snow_dissolution.getDatPath().c_str());
			return false;
		}
	}

	Grid<float> temperature;
	temperature.setVarNum(TEMPERATURE_FIELDSNUM);
	temperature.initialize();

	Grid<float> humidity;
	humidity.setVarNum(HUMIDITY_FIELDSNUM);
	humidity.initialize();

	Grid<float> windspeed;
	windspeed.setVarNum(WINDSPEED_FIELDSNUM);
	windspeed.initialize();

	Grid<float> rain;
	rain.setVarNum(RAIN_FIELDSNUM);
	rain.initialize();

	if( temperature.configure("temperature", cfg) )
	{
		temperature.setDate(args.getDate());
		path = temperature.getDatPath();
		path.replace(path.find(TAG_DATE), TAG_DATE_LEN, temperature.getDate());
		temperature.setDatPath(path);
		if( !temperature.read() )
		{
			LOG4CXX_FATAL(logger, "Error: unable to read dat file: " << temperature.getDatPath() << ".");
			syslog(LOG_CRIT, "Error: unable to read dat file: %s.", temperature.getDatPath().c_str());
			return false;
		}
	}
	if( humidity.configure("humidity", cfg) )
	{
		humidity.setDate(args.getDate());
		path = humidity.getDatPath();
		path.replace(path.find(TAG_DATE), TAG_DATE_LEN, humidity.getDate());
		humidity.setDatPath(path);
		if( !humidity.read() )
		{
			LOG4CXX_FATAL(logger, "Error: unable to read dat file: " << humidity.getDatPath() << ".");
			syslog(LOG_CRIT, "Error: unable to read dat file: %s.", humidity.getDatPath().c_str());
			return false;
		}
	}
	if( windspeed.configure("windspeed", cfg) )
	{
		windspeed.setDate(args.getDate());
		path = windspeed.getDatPath();
		path.replace(path.find(TAG_DATE), TAG_DATE_LEN, windspeed.getDate());
		windspeed.setDatPath(path);
		if( !windspeed.read() )
		{
			LOG4CXX_FATAL(logger, "Error: unable to read dat file: " << windspeed.getDatPath() << ".");
			syslog(LOG_CRIT, "Error: unable to read dat file: %s.", windspeed.getDatPath().c_str());
			return false;
		}
	}
	if( rain.configure("rain", cfg) )
	{
		rain.setDate(args.getDate());
		path = rain.getDatPath();
		path.replace(path.find(TAG_DATE), TAG_DATE_LEN, rain.getDate());
		rain.setDatPath(path);
		if( !rain.read() )
		{
			LOG4CXX_FATAL(logger, "Error: unable to read dat file:" << rain.getDatPath() << ".");
			syslog(LOG_CRIT, "Error: unable to read dat file: %s.", rain.getDatPath().c_str());
			return false;
		}
	}

	Grid<float> cum_rain;
	cum_rain.setVarNum(CUMRAIN_FIELDSNUM);
	cum_rain.initialize();

#ifdef __OPENSUSE_11_3__
	cum_rain.setXDir(DECREASING);
#else
	cum_rain.setXDir(COORDINATE_DIRECTION::DECREASING);
#endif

	path = "";

	if( cum_rain.configure("cum_rain", cfg) )
	{
		cum_rain.setDate(args.getDate());
		path = cum_rain.getDatPath();
		path.replace(path.find(TAG_DATE), TAG_DATE_LEN, cum_rain.getDate());
		cum_rain.setDatPath(path);

		if( !cum_rain.read() )
		{
			LOG4CXX_FATAL(logger, "Error: unable to read txt file: " << cum_rain.getDatPath() << ".");
			syslog(LOG_CRIT, "Error: unable to read txt file: %s.", cum_rain.getDatPath().c_str());
			return false;
		}
	}

	Grid<float> res;
	res.setType(METEO_INPUT);
	res.setDate(args.getDate());
	res.setTable(temperature.getTable());
	res.setVarNum(0);

	if( !res.merge(temperature) )      return false;
	if( !res.merge(humidity) )         return false;
	if( !res.merge(windspeed) )        return false;
	if( !res.merge(cum_rain) )         return false;
	if( !res.merge(rain) )             return false;
	if( !res.merge(snow) )             return false;
	if( !res.merge(snow_covering) )    return false;
	if( !res.merge(snow_dissolution) ) return false;

	if( res.stored(conn) )
	{
		LOG4CXX_INFO(logger, "Meteo input for date " << args.getDate() << " already stored, delete it.");
		if( !delete_meteo_input(args) )
		{
			LOG4CXX_WARN(logger, "Unable to delete meteo input for date: " << args.getDate());
			syslog(LOG_WARNING, "Unable to delete meteo input for date: %s.", args.getDate().c_str());
		}
		else
		{
			LOG4CXX_INFO(logger, "Meteo input for date " << args.getDate() << " deleted.");
		}
	}

	LOG4CXX_INFO(logger, "Storing meteo input ...");
	return res.store(conn);
}

bool prepare_meteo_input_grid(CommandLineArguments& args, Grid<float>* res)
{
	Grid<float> snow;
	snow.setVarNum(GRD_DEFAULT_VARNUM);
	snow.initialize();
	snow.setType(NUMERIC);

	Grid<float> snow_covering;
	snow_covering.setVarNum(GRD_DEFAULT_VARNUM);
	snow_covering.initialize();
	snow_covering.setType(NUMERIC);

	Grid<float> snow_dissolution;
	snow_dissolution.setVarNum(GRD_DEFAULT_VARNUM);
	snow_dissolution.initialize();
	snow_dissolution.setType(NUMERIC);

	Grid<float> temperature;
	temperature.setVarNum(TEMPERATURE_FIELDSNUM);
	temperature.initialize();
	temperature.setType(NUMERIC);

	Grid<float> humidity;
	humidity.setVarNum(HUMIDITY_FIELDSNUM);
	humidity.initialize();
	humidity.setType(NUMERIC);

	Grid<float> windspeed;
	windspeed.setVarNum(WINDSPEED_FIELDSNUM);
	windspeed.initialize();
	windspeed.setType(NUMERIC);

	Grid<float> rain;
	rain.setVarNum(RAIN_FIELDSNUM);
	rain.initialize();
	rain.setType(NUMERIC);

	Grid<float> cum_rain;
	cum_rain.setVarNum(CUMRAIN_FIELDSNUM);
	cum_rain.initialize();
	cum_rain.setType(NUMERIC);

	if( !snow.configure("snow", cfg) )
	{
		LOG4CXX_FATAL(logger, "Error: unable to configure snow grid.");
		syslog(LOG_CRIT, "Error: unable to configure snow grid.");
		return false;
	}
	snow.setDate(args.getDate());

	if( !snow_covering.configure("snow_covering", cfg) )
	{
		LOG4CXX_FATAL(logger, "Error: unable to configure snow covering grid.");
		syslog(LOG_CRIT, "Error: unable to configure snow covering grid.");
		return false;
	}
	snow_covering.setDate(args.getDate());

	if( !snow_dissolution.configure("snow_dissolution", cfg) )
	{
		LOG4CXX_FATAL(logger, "Error: unable to configure snow dissolution grid.");
		syslog(LOG_CRIT, "Error: unable to configure snow dissolution grid.");
		return false;
	}
	snow_dissolution.setDate(args.getDate());

	if( !temperature.configure("temperature", cfg) )
	{
		LOG4CXX_FATAL(logger, "Error: unable to configure temperature grid.");
		syslog(LOG_CRIT, "Error: unable to configure temperature grid.");
		return false;
	}
	temperature.setDate(args.getDate());

	if( !humidity.configure("humidity", cfg) )
	{
		LOG4CXX_FATAL(logger, "Error: unable to configure humidity grid.");
		syslog(LOG_CRIT, "Error: unable to configure humidity grid.");
		return false;
	}
	humidity.setDate(args.getDate());

	if( !windspeed.configure("windspeed", cfg) )
	{
		LOG4CXX_FATAL(logger, "Error: unable to configure wind speed grid.");
		syslog(LOG_CRIT, "Error: unable to configure wind speed grid.");
		return false;
	}
	windspeed.setDate(args.getDate());

	if( !rain.configure("rain", cfg) )
	{
		LOG4CXX_FATAL(logger, "Error: unable to configure rain grid.");
		syslog(LOG_CRIT, "Error: unable to configure rain grid.");
		return false;
	}
	rain.setDate(args.getDate());

	if( !cum_rain.configure("cum_rain", cfg) )
	{
		LOG4CXX_FATAL(logger, "Error: unable to configure cumulative rain grid.");
		syslog(LOG_CRIT, "Error: unable to configure cumulative rain grid.");
		return false;
	}
	cum_rain.setDate(args.getDate());

	//Grid<float> res;
	res->setType(METEO_INPUT);
	res->setDate(args.getDate());
	res->setTable(temperature.getTable());
	res->setVarNum(0);

	if( !res->merge(temperature) )      return false;
	if( !res->merge(humidity) )         return false;
	if( !res->merge(windspeed) )        return false;
	if( !res->merge(cum_rain) )         return false;
	if( !res->merge(rain) )             return false;
	if( !res->merge(snow) )             return false;
	if( !res->merge(snow_covering) )    return false;
	if( !res->merge(snow_dissolution) ) return false;

	return true;
}

/**
 * \fn		bool retrieve_meteo_input(CommandLineArguments& args, Grid<float>* res)
 * \brief	retrieves meteo input grid for date in <i>args</i> reading from database
 * \param	args command line arguments class
 * \param	res resulting grid
 * \return	true on success else false
 * @see CommandLineArguments
 */
bool retrieve_meteo_input(CommandLineArguments& args, Grid<float>* res)
{
	/*Grid<float> snow_covering;
	snow_covering.setVarNum(GRD_DEFAULT_VARNUM);
	snow_covering.initialize();
	snow_covering.setType(NUMERIC);
	snow_covering.setDate(args.getDate());
	Grid<float> snow_dissolution;
	snow_dissolution.setVarNum(GRD_DEFAULT_VARNUM);
	snow_dissolution.initialize();
	snow_dissolution.setType(NUMERIC);
	snow_dissolution.setDate(args.getDate());
	Grid<float> temperature;
	temperature.setVarNum(TEMPERATURE_FIELDSNUM);
	temperature.initialize();
	temperature.setType(NUMERIC);
	temperature.setDate(args.getDate());
	Grid<float> humidity;
	humidity.setVarNum(HUMIDITY_FIELDSNUM);
	humidity.initialize();
	humidity.setType(NUMERIC);
	humidity.setDate(args.getDate());
	Grid<float> windspeed;
	windspeed.setVarNum(WINDSPEED_FIELDSNUM);
	windspeed.initialize();
	windspeed.setType(NUMERIC);
	windspeed.setDate(args.getDate());
	Grid<float> rain;
	rain.setVarNum(CUMRAIN_FIELDSNUM);
	rain.initialize();
	rain.setType(NUMERIC);
	rain.setDate(args.getDate());
	Grid<float> cum_rain;
	cum_rain.setVarNum(1);
	cum_rain.initialize();
	cum_rain.setType(NUMERIC);
	cum_rain.setDate(args.getDate());

	if( !snow_covering.configure("snow_covering", cfg) )
	{
		LOG4CXX_FATAL(logger, "Error: unable to configure snow covering grid.");
		return false;
	}
	if( !snow_dissolution.configure("snow_dissolution", cfg) )
	{
		LOG4CXX_FATAL(logger, "Error: unable to configure snow dissolution grid.");
		return false;
	}
	if( !temperature.configure("temperature", cfg) )
	{
		LOG4CXX_FATAL(logger, "Error: unable to configure temperature grid.");
		return false;
	}
	if( !humidity.configure("humidity", cfg) )
	{
		LOG4CXX_FATAL(logger, "Error: unable to configure humidity grid.");
		return false;
	}
	if( !windspeed.configure("windspeed", cfg) )
	{
		LOG4CXX_FATAL(logger, "Error: unable to configure wind speed grid.");
		return false;
	}
	if( !rain.configure("rain", cfg) )
	{
		LOG4CXX_FATAL(logger, "Error: unable to configure rain grid.");
		return false;
	}
	if( !cum_rain.configure("cum_rain", cfg) )
	{
		LOG4CXX_FATAL(logger, "Error: unable to configure cumulative rain grid.");
		return false;
	}

	//Grid<float> res;
	res->setType(METEO_INPUT);
	res->setDate(args.getDate());
	res->setTable(temperature.getTable());
	res->setVarNum(0);

	if( !res->merge(temperature) )      return false;
	if( !res->merge(humidity) )         return false;
	if( !res->merge(windspeed) )        return false;
	if( !res->merge(rain) )             return false;
	if( !res->merge(cum_rain) )         return false;
	if( !res->merge(snow_covering) )    return false;
	if( !res->merge(snow_dissolution) ) return false;*/

	if( !prepare_meteo_input_grid(args, res) )
	{
		return false;
	}

	return res->retrieve(conn);
}

/**
 * \fn		bool delete_fwi_indexes(CommandLineArguments& args)
 * \brief	deletes fwi indexes grid for date in <i>args</i> from database
 * \param	args command line arguments class
 * \return	true on success else false
 * @see CommandLineArguments
 */
bool delete_fwi_indexes(CommandLineArguments& args)
{
	std::string query = "";

	stringstream ss;

	ss << "delete from fwi_indexes where dt = '" << args.getDate() << "';";

	query = ss.str();

	return execute(query);
}

/**
 * \fn		bool store_fwi_indexes(CommandLineArguments& args)
 * \brief	stores fwi indexes grid for date in <i>args</i> reading from files
 * \param	args command line arguments class
 * \return	true on success else false
 * @see CommandLineArguments
 */
bool store_fwi_indexes(CommandLineArguments& args)
{
	Grid<float> isi;
	isi.setVarNum(1);
	isi.initialize();

#ifdef __OPENSUSE_11_3__
	isi.setXDir(DECREASING);
#else
	isi.setXDir(COORDINATE_DIRECTION::DECREASING);
#endif

	std::string path = "";

	if( isi.configure("isi", cfg) )
	{
		isi.setDate(args.getDate());
		path = isi.getDatPath();
		path.replace(path.find(TAG_DATE), TAG_DATE_LEN, args.getDate());
		isi.setDatPath(path);

		if( !isi.read() )
		{
			LOG4CXX_FATAL(logger, "Error: unable to read txt file." << isi.getDatPath() << ".");
			syslog(LOG_CRIT, "Error: unable to read txt file %s.", isi.getDatPath().c_str());
			return false;
		}
	}

	Grid<float> fwi;
	fwi.setVarNum(1);
	fwi.initialize();

#ifdef __OPENSUSE_11_3__
	fwi.setXDir(DECREASING);
#else
	fwi.setXDir(COORDINATE_DIRECTION::DECREASING);
#endif

	path = "";

	if( fwi.configure("fwi", cfg) )
	{
		fwi.setDate(args.getDate());
		path = fwi.getDatPath();
		path.replace(path.find(TAG_DATE), TAG_DATE_LEN, args.getDate());
		fwi.setDatPath(path);

		if( !fwi.read() )
		{
			LOG4CXX_FATAL(logger, "Error: unable to read txt file." << fwi.getDatPath() << ".");
			syslog(LOG_CRIT, "Error: unable to read txt file %s.", fwi.getDatPath().c_str());
			return false;
		}
	}

	Grid<float> ffmc;
	ffmc.setVarNum(1);
	ffmc.initialize();

#ifdef __OPENSUSE_11_3__
	ffmc.setXDir(DECREASING);
#else
	ffmc.setXDir(COORDINATE_DIRECTION::DECREASING);
#endif

	path = "";

	if( ffmc.configure("ffmc", cfg) )
	{
		ffmc.setDate(args.getDate());
		path = ffmc.getDatPath();
		path.replace(path.find(TAG_DATE), TAG_DATE_LEN, args.getDate());
		ffmc.setDatPath(path);

		if( ! ffmc.read() )
		{
			LOG4CXX_FATAL(logger, "Error: unable to read txt file." << ffmc.getDatPath() << ".");
			syslog(LOG_CRIT, "Error: unable to read txt file %s.", ffmc.getDatPath().c_str());
			return false;
		}
	}

	Grid<float> dmc;
	dmc.setVarNum(1);
	dmc.initialize();

#ifdef __OPENSUSE_11_3__
	dmc.setXDir(DECREASING);
#else
	dmc.setXDir(COORDINATE_DIRECTION::DECREASING);
#endif

	path = "";

	if( dmc.configure("dmc", cfg) )
	{
		dmc.setDate(args.getDate());
		path = dmc.getDatPath();
		path.replace(path.find(TAG_DATE), TAG_DATE_LEN, args.getDate());
		dmc.setDatPath(path);

		if( !dmc.read() )
		{
			LOG4CXX_FATAL(logger, "Error: unable to read txt file." << dmc.getDatPath() << ".");
			syslog(LOG_CRIT, "Error: unable to read txt file %s.", dmc.getDatPath().c_str());
			return false;
		}
	}

	Grid<float> dc;
	dc.setVarNum(1);
	dc.initialize();

#ifdef __OPENSUSE_11_3__
	dc.setXDir(DECREASING);
#else
	dc.setXDir(COORDINATE_DIRECTION::DECREASING);
#endif

	path = "";

	if( dc.configure("dc", cfg) )
	{
		dc.setDate(args.getDate());
		path = dc.getDatPath();
		path.replace(path.find(TAG_DATE), TAG_DATE_LEN, args.getDate());
		dc.setDatPath(path);

		if( !dc.read() )
		{
			LOG4CXX_FATAL(logger, "Error: unable to read txt file." << dc.getDatPath() << ".");
			syslog(LOG_CRIT, "Error: unable to read txt file %s.", dc.getDatPath().c_str());
			return false;
		}
	}

	Grid<float> bui;
	bui.setVarNum(1);
	bui.initialize();

#ifdef __OPENSUSE_11_3__
	bui.setXDir(DECREASING);
#else
	bui.setXDir(COORDINATE_DIRECTION::DECREASING);
#endif

	path = "";

	if( bui.configure("bui", cfg) )
	{
		bui.setDate(args.getDate());
		path = bui.getDatPath();
		path.replace(path.find(TAG_DATE), TAG_DATE_LEN, args.getDate());
		bui.setDatPath(path);

		if( !bui.read() )
		{
			LOG4CXX_FATAL(logger, "Error: unable to read txt file." << bui.getDatPath() << ".");
			syslog(LOG_CRIT, "Error: unable to read txt file %s.", bui.getDatPath().c_str());
			return false;
		}
	}

	Grid<float> ffmc_tmp;
	ffmc_tmp.setVarNum(1);
	ffmc_tmp.initialize();

#ifdef __OPENSUSE_11_3__
	ffmc_tmp.setXDir(DECREASING);
#else
	ffmc_tmp.setXDir(COORDINATE_DIRECTION::DECREASING);
#endif

	path = "";

	if( ffmc_tmp.configure("ffmc_tmp", cfg) )
	{
		ffmc_tmp.setDate(args.getDate());
		path = ffmc_tmp.getDatPath();
		path.replace(path.find(TAG_DATE), TAG_DATE_LEN, args.getDate());
		ffmc_tmp.setDatPath(path);

		if( !ffmc_tmp.read() )
		{
			LOG4CXX_FATAL(logger, "Error: unable to read txt file." << ffmc_tmp.getDatPath() << ".");
			syslog(LOG_CRIT, "Error: unable to read txt file %s.", ffmc_tmp.getDatPath().c_str());
			return false;
		}
	}

	Grid<float> dmc_tmp;
	dmc_tmp.setVarNum(1);
	dmc_tmp.initialize();

#ifdef __OPENSUSE_11_3__
	dmc_tmp.setXDir(DECREASING);
#else
	dmc_tmp.setXDir(COORDINATE_DIRECTION::DECREASING);
#endif

	path = "";

	if( dmc_tmp.configure("dmc_tmp", cfg) )
	{
		dmc_tmp.setDate(args.getDate());
		path = dmc_tmp.getDatPath();
		path.replace(path.find(TAG_DATE), TAG_DATE_LEN, args.getDate());
		dmc_tmp.setDatPath(path);

		if( !dmc_tmp.read() )
		{
			LOG4CXX_FATAL(logger, "Error: unable to read txt file." << dmc_tmp.getDatPath() << ".");
			syslog(LOG_CRIT, "Error: unable to read txt file %s.", dmc_tmp.getDatPath().c_str());
			return false;
		}
	}

	Grid<float> dc_tmp;
	dc_tmp.setVarNum(1);
	dc_tmp.initialize();

#ifdef __OPENSUSE_11_3__
	dc_tmp.setXDir(DECREASING);
#else
	dc_tmp.setXDir(COORDINATE_DIRECTION::DECREASING);
#endif

	path = "";

	if( dc_tmp.configure("dc_tmp", cfg) )
	{
		dc_tmp.setDate(args.getDate());
		path = dc_tmp.getDatPath();
		path.replace(path.find(TAG_DATE), TAG_DATE_LEN, args.getDate());
		dc_tmp.setDatPath(path);

		if( !dc_tmp.read() )
		{
			LOG4CXX_FATAL(logger, "Error: unable to read txt file." << dc_tmp.getDatPath() << ".");
			syslog(LOG_CRIT, "Error: unable to read txt file %s.", dc_tmp.getDatPath().c_str());
			return false;
		}
	}

	Grid<float> idi;
	idi.setVarNum(1);
	idi.initialize();

#ifdef __OPENSUSE_11_3__
	idi.setXDir(DECREASING);
#else
	idi.setXDir(COORDINATE_DIRECTION::DECREASING);
#endif

	path = "";

	if( idi.configure("idi", cfg) )
	{
		idi.setDate(args.getDate());
		path = idi.getDatPath();
		path.replace(path.find(TAG_DATE), TAG_DATE_LEN, args.getDate());
		idi.setDatPath(path);

		if( !idi.read() )
		{
			LOG4CXX_FATAL(logger, "Error: unable to read txt file." << idi.getDatPath() << ".");
			syslog(LOG_CRIT, "Error: unable to read txt file %s.", idi.getDatPath().c_str());
			return false;
		}
	}

	Grid<float> res;
	res.setType(FWI_INDEXES);
	res.setDate(args.getDate());
	res.setTable(isi.getTable());
	res.setVarNum(0);

	if( !res.merge(isi) )      return false;
	if( !res.merge(fwi) )      return false;
	if( !res.merge(ffmc) )     return false;
	if( !res.merge(dmc) )      return false;
	if( !res.merge(dc) )       return false;
	if( !res.merge(bui) )      return false;
	if( !res.merge(ffmc_tmp) ) return false;
	if( !res.merge(dmc_tmp) )  return false;
	if( !res.merge(dc_tmp) )   return false;
	if( !res.merge(idi) )      return false;

	if( res.stored(conn) )
	{
		LOG4CXX_INFO(logger, "FWI indexes for date " << args.getDate() << " already stored, delete them.");
		if( !delete_fwi_indexes(args) )
		{
			LOG4CXX_WARN(logger, "Unable to delete fwi indexes for date: " << args.getDate());
			syslog(LOG_WARNING, "Unable to delete fwi indexes for date: %s.", args.getDate().c_str());
		}
		else
		{
			LOG4CXX_INFO(logger, "FWI indexes for date " << args.getDate() << " deleted.");
			syslog(LOG_NOTICE, "FWI indexes for date %s deleted.", args.getDate().c_str());
		}
	}

	LOG4CXX_INFO(logger, "Storing FWI indexes ...");
	syslog(LOG_NOTICE, "Storing FWI indexes ...");
	return res.store(conn);

}

/**
 * \fn		bool prepare_fwi_indexes_grid(CommandLineArguments& args, Grid<float>* res)
 * \brief   prepares and configure fwi indexes grid
 * \param	args command line arguments class
 * \param	res resulting grid
 * \return	true on success else false
 * @see CommandLineArguments
 * @see Grid
 */
bool prepare_fwi_indexes_grid(CommandLineArguments& args, Grid<float>* res)
{
	assert( res != NULL );

	Grid<float> isi;
	isi.setVarNum(1);
	isi.initialize();
	isi.setType(NUMERIC);

	if( !isi.configure("isi", cfg) )
	{
		cout << "Error: unable to configure isi grid." << endl;
		syslog(LOG_ERR, "Error: unable to configure isi grid.");
		return false;
	}
	isi.setDate(args.getDate());

	Grid<float> fwi;
	fwi.setVarNum(1);
	fwi.initialize();
	fwi.setType(NUMERIC);

	if( !fwi.configure("fwi", cfg) )
	{
		cout << "Error: unable to configure fwi grid." << endl;
		syslog(LOG_ERR, "Error: unable to configure fwi grid.");
		return false;
	}
	fwi.setDate(args.getDate());

	Grid<float> ffmc;
	ffmc.setVarNum(1);
	ffmc.initialize();
	ffmc.setType(NUMERIC);

	if( !ffmc.configure("ffmc", cfg) )
	{
		cout << "Error: unable to configure ffmc grid." << endl;
		syslog(LOG_ERR, "Error: unable to configure ffmc grid.");
		return false;
	}
	ffmc.setDate(args.getDate());

	Grid<float> dmc;
	dmc.setVarNum(1);
	dmc.initialize();
	dmc.setType(NUMERIC);

	if( !dmc.configure("dmc", cfg) )
	{
		cout << "Error: unable to configure dmc grid." << endl;
		syslog(LOG_ERR, "Error: unable to configure dmc grid.");
		return false;
	}
	dmc.setDate(args.getDate());

	Grid<float> dc;
	dc.setVarNum(1);
	dc.initialize();
	dc.setType(NUMERIC);

	if( !dc.configure("dc", cfg) )
	{
		cout << "Error: unable to configure dc grid." << endl;
		syslog(LOG_ERR, "Error: unable to configure dc grid.");
		return false;
	}
	dc.setDate(args.getDate());

	Grid<float> bui;
	bui.setVarNum(1);
	bui.initialize();
	bui.setType(NUMERIC);

	if( !bui.configure("bui", cfg) )
	{
		cout << "Error: unable to configure bui grid." << endl;
		syslog(LOG_ERR, "Error: unable to configure bui grid.");
		return false;
	}
	bui.setDate(args.getDate());

	Grid<float> ffmc_tmp;
	ffmc_tmp.setVarNum(1);
	ffmc_tmp.initialize();
	ffmc_tmp.setType(NUMERIC);

#ifdef __OPENSUSE_11_3__
	ffmc_tmp.setXDir(DECREASING);
#else
	ffmc_tmp.setXDir(COORDINATE_DIRECTION::DECREASING);
#endif

	if( !ffmc_tmp.configure("ffmc_tmp", cfg) )
	{
		cout << "Error: unable to configure ffmc_tmp grid." << endl;
		syslog(LOG_ERR, "Error: unable to configure ffmc_tmp grid.");
		return false;
	}
	ffmc_tmp.setDate(args.getDate());

	Grid<float> dmc_tmp;
	dmc_tmp.setVarNum(1);
	dmc_tmp.initialize();
	dmc_tmp.setType(NUMERIC);

#ifdef __OPENSUSE_11_3__
	dmc_tmp.setXDir(DECREASING);
#else
	dmc_tmp.setXDir(COORDINATE_DIRECTION::DECREASING);
#endif

	if( !dmc_tmp.configure("dmc_tmp", cfg) )
	{
		cout << "Error: unable to configure dmc_tmp grid." << endl;
		syslog(LOG_ERR, "Error: unable to configure dmc_tmp grid.");
		return false;
	}
	dmc_tmp.setDate(args.getDate());

	Grid<float> dc_tmp;
	dc_tmp.setVarNum(1);
	dc_tmp.initialize();
	dc_tmp.setType(NUMERIC);

#ifdef __OPENSUSE_11_3__
	dc_tmp.setXDir(DECREASING);
#else
	dc_tmp.setXDir(COORDINATE_DIRECTION::DECREASING);
#endif

	if( !dc_tmp.configure("dc_tmp", cfg) )
	{
		cout << "Error: unable to configure dc_tmp grid." << endl;
		syslog(LOG_ERR, "Error: unable to configure dc_tmp grid.");
		return false;
	}
	dc_tmp.setDate(args.getDate());

	Grid<float> idi;
	idi.setVarNum(1);
	idi.initialize();
	idi.setType(NUMERIC);

#ifdef __OPENSUSE_11_3__
	idi.setXDir(DECREASING);
#else
	idi.setXDir(COORDINATE_DIRECTION::DECREASING);
#endif

	if( !idi.configure("idi", cfg) )
	{
		cout << "Error: unable to configure idi grid." << endl;
		syslog(LOG_ERR, "Error: unable to configure idi grid.");
		return false;
	}
	idi.setDate(args.getDate());

	Grid<float> angstrom;
	angstrom.setVarNum(1);
	angstrom.initialize();
	angstrom.setType(NUMERIC);

#ifdef __OPENSUSE_11_3__
	angstrom.setXDir(DECREASING);
#else
	angstrom.setXDir(COORDINATE_DIRECTION::DECREASING);
#endif

	if( !angstrom.configure("angstrom", cfg) )
	{
		cout << "Error: unable to configure angstrom grid." << endl;
		syslog(LOG_ERR, "Error: unable to configure angstrom grid.");
		return false;
	}
	angstrom.setDate(args.getDate());

	Grid<float> fmi;
	fmi.setVarNum(1);
	fmi.initialize();
	fmi.setType(NUMERIC);

#ifdef __OPENSUSE_11_3__
	fmi.setXDir(DECREASING);
#else
	fmi.setXDir(COORDINATE_DIRECTION::DECREASING);
#endif

	if( !fmi.configure("fmi", cfg) )
	{
		cout << "Error: unable to configure fmi grid." << endl;
		syslog(LOG_ERR, "Error: unable to configure fmi grid.");
		return false;
	}
	fmi.setDate(args.getDate());

	Grid<float> sharples;
	sharples.setVarNum(1);
	sharples.initialize();
	sharples.setType(NUMERIC);

#ifdef __OPENSUSE_11_3__
	sharples.setXDir(DECREASING);
#else
	sharples.setXDir(COORDINATE_DIRECTION::DECREASING);
#endif

	if( !sharples.configure("sharples", cfg) )
	{
		cout << "Error: unable to configure sharples grid." << endl;
		syslog(LOG_ERR, "Error: unable to configure sharples grid.");
		return false;
	}
	sharples.setDate(args.getDate());

	res->setType(FWI_INDEXES);
	res->setDate(args.getDate());
	res->setTable(isi.getTable());
	res->setVarNum(0);

	if( !res->merge(isi) )
	{
		LOG4CXX_FATAL(logger, "Unable to merge isi grid.");
		syslog(LOG_CRIT, "Unable to merge isi grid.");
		return false;
	}
	if( !res->merge(fwi) )
	{
		LOG4CXX_FATAL(logger, "Unable to merge fwi grid.");
		syslog(LOG_CRIT, "Unable to merge fwi grid.");
		return false;
	}
	if( !res->merge(ffmc) )
	{
		LOG4CXX_FATAL(logger, "Unable to merge ffmc grid.");
		syslog(LOG_CRIT, "Unable to merge ffmc grid.");
		return false;
	}
	if( !res->merge(dmc) )
	{
		LOG4CXX_FATAL(logger, "Unable to merge dmc grid.");
		syslog(LOG_CRIT, "Unable to merge dmc grid.");
		return false;
	}
	if( !res->merge(dc) )
	{
		LOG4CXX_FATAL(logger, "Unable to merge dc grid.");
		syslog(LOG_CRIT, "Unable to merge dc grid.");
		return false;
	}
	if( !res->merge(bui) )
	{
		LOG4CXX_FATAL(logger, "Unable to merge bui grid.");
		syslog(LOG_CRIT, "Unable to merge bui grid.");
		return false;
	}
	if( !res->merge(ffmc_tmp) )
	{
		LOG4CXX_FATAL(logger, "Unable to merge ffmc_tmp grid.");
		syslog(LOG_CRIT, "Unable to merge ffmc_tmp grid.");
		return false;
	}
	if( !res->merge(dmc_tmp) )
	{
		LOG4CXX_FATAL(logger, "Unable to merge dmc_tmp grid.");
		syslog(LOG_CRIT, "Unable to merge dmc_tmp grid.");
		return false;
	}
	if( !res->merge(dc_tmp) )
	{
		LOG4CXX_FATAL(logger, "Unable to merge dc_tmp grid.");
		syslog(LOG_CRIT, "Unable to merge dc_tmp grid.");
		return false;
	}
	if( !res->merge(idi) )
	{
		LOG4CXX_FATAL(logger, "Unable to merge idi grid.");
		syslog(LOG_CRIT, "Unable to merge idi grid.");
		return false;
	}
	if( !res->merge(angstrom) )
	{
		LOG4CXX_FATAL(logger, "Unable to merge angstrom grid.");
		syslog(LOG_CRIT, "Unable to merge angstrom grid.");
		return false;
	}
	if( !res->merge(fmi) )
	{
		LOG4CXX_FATAL(logger, "Unable to merge fmi grid.");
		syslog(LOG_CRIT, "Unable to merge fmi grid.");
		return false;
	}
	if( !res->merge(sharples) )
	{
		LOG4CXX_FATAL(logger, "Unable to merge sharples grid.");
		syslog(LOG_CRIT, "Unable to merge sharples grid.");
		return false;
	}

	return true;
}

/**
 * \fn		bool retrieve_fwi_indexes(CommandLineArguments& args, Grid<float>* res)
 * \brief	retrieves fwi indexes grid for date in <i>args</i> reading from database
 * \param	args command line arguments class
 * \param	res resulting grid
 * \return	true on success else false
 * @see CommandLineArguments
 * @see Grid
 */
bool retrieve_fwi_indexes(CommandLineArguments& args, Grid<float>* res)
{
	/*assert( res != NULL );

	Grid<float> isi;
	isi.setVarNum(1);
	isi.initialize();
	isi.setType(NUMERIC);
	isi.setDate(args.getDate());

	if( !isi.configure("isi", cfg) )
	{
		cout << "Error: unable to configure isi grid." << endl;
		return false;
	}

	Grid<float> fwi;
	fwi.setVarNum(1);
	fwi.initialize();
	fwi.setType(NUMERIC);
	fwi.setDate(args.getDate());

	if( !fwi.configure("fwi", cfg) )
	{
		cout << "Error: unable to configure fwi grid." << endl;
		return false;
	}

	Grid<float> ffmc;
	ffmc.setVarNum(1);
	ffmc.initialize();
	ffmc.setType(NUMERIC);
	ffmc.setDate(args.getDate());

	if( !ffmc.configure("ffmc", cfg) )
	{
		cout << "Error: unable to configure ffmc grid." << endl;
		return false;
	}

	Grid<float> dmc;
	dmc.setVarNum(1);
	dmc.initialize();
	dmc.setType(NUMERIC);
	dmc.setDate(args.getDate());

	if( !dmc.configure("dmc", cfg) )
	{
		cout << "Error: unable to configure dmc grid." << endl;
		return false;
	}

	Grid<float> dc;
	dc.setVarNum(1);
	dc.initialize();
	dc.setType(NUMERIC);
	dc.setDate(args.getDate());

	if( !dc.configure("dc", cfg) )
	{
		cout << "Error: unable to configure dc grid." << endl;
		return false;
	}

	Grid<float> bui;
	bui.setVarNum(1);
	bui.initialize();
	bui.setType(NUMERIC);
	bui.setDate(args.getDate());

	if( !bui.configure("bui", cfg) )
	{
		cout << "Error: unable to configure bui grid." << endl;
		return false;
	}

	Grid<float> ffmc_tmp;
	ffmc_tmp.setVarNum(1);
	ffmc_tmp.initialize();
	ffmc_tmp.setType(NUMERIC);
	ffmc_tmp.setDate(args.getDate());
	ffmc_tmp.setXDir(COORDINATE_DIRECTION::DECREASING);

	if( !ffmc_tmp.configure("ffmc_tmp", cfg) )
	{
		cout << "Error: unable to configure ffmc_tmp grid." << endl;
		return false;
	}

	Grid<float> dmc_tmp;
	dmc_tmp.setVarNum(1);
	dmc_tmp.initialize();
	dmc_tmp.setType(NUMERIC);
	dmc_tmp.setDate(args.getDate());
	dmc_tmp.setXDir(COORDINATE_DIRECTION::DECREASING);

	if( !dmc_tmp.configure("dmc_tmp", cfg) )
	{
		cout << "Error: unable to configure dmc_tmp grid." << endl;
		return false;
	}

	Grid<float> dc_tmp;
	dc_tmp.setVarNum(1);
	dc_tmp.initialize();
	dc_tmp.setType(NUMERIC);
	dc_tmp.setDate(args.getDate());
	dc_tmp.setXDir(COORDINATE_DIRECTION::DECREASING);

	if( !dc_tmp.configure("dc_tmp", cfg) )
	{
		cout << "Error: unable to configure dc_tmp grid." << endl;
		return false;
	}

	Grid<float> idi;
	idi.setVarNum(1);
	idi.initialize();
	idi.setType(NUMERIC);
	idi.setDate(args.getDate());
	idi.setXDir(COORDINATE_DIRECTION::DECREASING);

	if( !idi.configure("idi", cfg) )
	{
		cout << "Error: unable to configure idi grid." << endl;
		return false;
	}

	Grid<float> angstrom;
	angstrom.setVarNum(1);
	angstrom.initialize();
	angstrom.setType(NUMERIC);
	angstrom.setDate(args.getDate());
	angstrom.setXDir(COORDINATE_DIRECTION::DECREASING);

	if( !angstrom.configure("angstrom", cfg) )
	{
		cout << "Error: unable to configure angstrom grid." << endl;
		return false;
	}

	Grid<float> fmi;
	fmi.setVarNum(1);
	fmi.initialize();
	fmi.setType(NUMERIC);
	fmi.setDate(args.getDate());
	fmi.setXDir(COORDINATE_DIRECTION::DECREASING);

	if( !fmi.configure("fmi", cfg) )
	{
		cout << "Error: unable to configure fmi grid." << endl;
		return false;
	}

	Grid<float> sharples;
	sharples.setVarNum(1);
	sharples.initialize();
	sharples.setType(NUMERIC);
	sharples.setDate(args.getDate());
	sharples.setXDir(COORDINATE_DIRECTION::DECREASING);

	if( !sharples.configure("sharples", cfg) )
	{
		cout << "Error: unable to configure sharples grid." << endl;
		return false;
	}

	res->setType(FWI_INDEXES);
	res->setDate(args.getDate());
	res->setTable(isi.getTable());
	res->setVarNum(0);

	if( !res->merge(isi) )
	{
		LOG4CXX_FATAL(logger, "Unable to merge isi grid.");
		return false;
	}
	if( !res->merge(fwi) )
	{
		LOG4CXX_FATAL(logger, "Unable to merge fwi grid.");
		return false;
	}
	if( !res->merge(ffmc) )
	{
		LOG4CXX_FATAL(logger, "Unable to merge ffmc grid.");
		return false;
	}
	if( !res->merge(dmc) )
	{
		LOG4CXX_FATAL(logger, "Unable to merge dmc grid.");
		return false;
	}
	if( !res->merge(dc) )
	{
		LOG4CXX_FATAL(logger, "Unable to merge dc grid.");
		return false;
	}
	if( !res->merge(bui) )
	{
		LOG4CXX_FATAL(logger, "Unable to merge bui grid.");
		return false;
	}
	if( !res->merge(ffmc_tmp) )
	{
		LOG4CXX_FATAL(logger, "Unable to merge ffmc_tmp grid.");
		return false;
	}
	if( !res->merge(dmc_tmp) )
	{
		LOG4CXX_FATAL(logger, "Unable to merge dmc_tmp grid.");
		return false;
	}
	if( !res->merge(dc_tmp) )
	{
		LOG4CXX_FATAL(logger, "Unable to merge dc_tmp grid.");
		return false;
	}
	if( !res->merge(idi) )
	{
		LOG4CXX_FATAL(logger, "Unable to merge idi grid.");
		return false;
	}
	if( !res->merge(angstrom) )
	{
		LOG4CXX_FATAL(logger, "Unable to merge angstrom grid.");
		return false;
	}
	if( !res->merge(fmi) )
	{
		LOG4CXX_FATAL(logger, "Unable to merge fmi grid.");
		return false;
	}
	if( !res->merge(sharples) )
	{
		LOG4CXX_FATAL(logger, "Unable to merge sharples grid.");
		return false;
	}*/

	if( !prepare_fwi_indexes_grid(args, res) )
	{
		return false;
	}

	return res->retrieve(conn);

}

/**
 * \fn		bool getFileBytea(std::string file, char** buffer, int& size)
 * \brief	Reads file, returns file contents in buffer and file size in size.
 * \param	file file absolute path
 * \param	buffer file contents buffer
 * \param	size file size
 * \return	true on success else false
 */
bool getFileBytea(std::string file, char** buffer, int& size)
{
	ifstream::pos_type sz = 0;;

	ifstream is (file.c_str(), ios::in|ios::binary|ios::ate);
	if (is.is_open())
	{
	  sz      = is.tellg();
	  size    = (int)sz;
	  *buffer = new char [size];
	  is.seekg (0, ios::beg);
	  is.read (*buffer, (long int)sz);
	  is.close();
	}
	else
	{
		LOG4CXX_ERROR(logger, "Unable to open file" << file);
		syslog(LOG_ERR, "Unable to open file %s.", file.c_str());
		return false;
	}
	return true;
}

/**
 * \fn		bool delete_images(CommandLineArguments& args)
 * \brief	deletes fwi indexes grid for date in <i>args</i> from database
 * \param	args command line arguments class
 * \return	true on success else false
 * @see CommandLineArguments
 */
bool delete_images(CommandLineArguments& args)
{
	std::string query = "";

	stringstream ss;

	ss << "delete from images where dt = '" << args.getDate() << "';";

	query = ss.str();

	return execute(query);
}

/**
 * \fn		bool store_images(CommandLineArguments& args)
 * \brief	stores fwi images for date in <i>args</i> reading from disk.
 * \param	args command line arguments class
 * \return	true on success else false
 * @see CommandLineArguments
 */
bool store_images(CommandLineArguments& args)
{
	const char* paramValues [7];
	int         paramLengths[7];
	int         paramFormats[7];
	PGresult*   res              = NULL;
	std::string fwi_page         = "";
	std::string meteo_page       = "";
	std::string snow             = "";
	char*       fwi_page_bytea   = NULL;
	char*       meteo_page_bytea = NULL;
	char*       snow_bytea       = NULL;
	int         fwi_page_size    = 0;
	int         meteo_page_size  = 0;
	int         snow_size        = 0;

	if( !delete_images(args) )
	{
		LOG4CXX_WARN(logger, "Unable to delete images for date: " << args.getDate() << " may be they are not present.");
		syslog(LOG_WARNING, "Unable to delete images for date: %s may be they are not present.", args.getDate().c_str());
	}

	if( !cfg.lookupValue("fwidbmgr.files.images.fwi", fwi_page) )
	{
		LOG4CXX_ERROR(logger, "Unable to get fwi image path.");
		syslog(LOG_ERR, "Unable to get fwi image path.");
		return false;
	}
	else
	{
		fwi_page.replace(fwi_page.find(TAG_DATE), TAG_DATE_LEN, args.getDate());
		// get fwi image contents
		if( !getFileBytea(fwi_page, &fwi_page_bytea, fwi_page_size) )
		{
			LOG4CXX_ERROR(logger, "Unable to load " << fwi_page << " contents.");
			syslog(LOG_ERR, "Unable to load %s contents.", fwi_page.c_str());
			return false;
		}

	}
	if( !cfg.lookupValue("fwidbmgr.files.images.meteo", meteo_page) )
	{
		LOG4CXX_ERROR(logger, "Unable to get meteo image path.");
		syslog(LOG_ERR, "Unable to get meteo image path.");
		return false;
	}
	else
	{
		meteo_page.replace(meteo_page.find(TAG_DATE), TAG_DATE_LEN, args.getDate());
		// get meteo image contents
		if( !getFileBytea(meteo_page, &meteo_page_bytea, meteo_page_size) )
		{
			LOG4CXX_ERROR(logger, "Unable to load " << meteo_page << " contents.");
			syslog(LOG_ERR, "Unable to load %s contents.", meteo_page.c_str());
			return false;
		}
	}
	if( !cfg.lookupValue("fwidbmgr.files.images.snow", snow) )
	{
		LOG4CXX_ERROR(logger, "Unable to get snow image path.");
		syslog(LOG_ERR, "Unable to get snow image path.");
		return false;
	}
	else
	{
		snow.replace(snow.find(TAG_DATE), TAG_DATE_LEN, args.getDate());
		// get snow image contents
		if( !getFileBytea(snow, &snow_bytea, snow_size) )
		{
			LOG4CXX_ERROR(logger, "Unable to load " << snow << " contents.");
			syslog(LOG_ERR, "Unable to load %s contents.", snow.c_str());
			return false;
		}
	}

	/* Set up parameter arrays for PQexecParams */
	paramValues[0]  = args.getDate().c_str();
	paramLengths[0] = args.getDate().size();
	paramFormats[0] = 0;        /* text */

	paramValues[1]  = fwi_page.c_str();
	paramLengths[1] = fwi_page.size();
	paramFormats[1] = 1;		/* binary */

	paramValues[2]  = fwi_page_bytea;
	paramLengths[2] = fwi_page_size;
	paramFormats[2] = 1;

	paramValues[3]  = meteo_page.c_str();
	paramLengths[3] = meteo_page.size();
	paramFormats[3] = 1;

	paramValues[4]  = meteo_page_bytea;
	paramLengths[4] = meteo_page_size;
	paramFormats[4] = 1;

	paramValues[5]  = snow.c_str();
	paramLengths[5] = snow.size();
	paramFormats[5] = 1;

	paramValues[6]  = snow_bytea;
	paramLengths[6] = snow_size;
	paramFormats[6] = 1;

	res = PQexecParams(conn,
					   "INSERT INTO images (dt, fwi_page, fwi_page_bytea, meteo_page, meteo_page_bytea, snow, snow_bytea) values($1::date, $2::varchar, $3::bytea, $4::varchar, $5::bytea, $6::varchar, $7::bytea)",
					   7,       /* one param */
					   NULL,    /* let the backend deduce param type */
					   paramValues,
					   paramLengths,
					   paramFormats,
					   1);      /* ask for binary results */

	if (PQresultStatus(res) != PGRES_COMMAND_OK)
	{
		fprintf(stderr, "Command failed: %s", PQerrorMessage(conn));
		syslog(LOG_ERR, "Command failed: %s", PQerrorMessage(conn));
		PQclear(res);
		return false;
	}

	return true;
}

/**
 * \fn		bool retrieve_images(CommandLineArguments& args)
 * \brief	retrieves fwi images for date in <i>args</i> reading from database
 * \param	args command line arguments class
 * \return	true on success else false
 * @see CommandLineArguments
 */
bool retrieve_images(CommandLineArguments& args)
{
	int               size     = 0;
	const char*       contents = NULL;
	PGresult*         result   = NULL;
	std::string       item     = "";
	std::stringstream ss;
	std::ofstream     os;

	std::string query = "select fwi_page from images where dt = '" + args.getDate() + "';";

	result = PQexec(conn, query.c_str());

	item = PQgetvalue(result, 0, 0);

	query = "select fwi_page_bytea from images where dt = '" + args.getDate() + "';";

	result = PQexecParams(conn,
	            query.c_str(),
	            0, NULL,NULL,NULL,NULL,   /* no input parameters */
	            1  /* output in binary format */ );

	if (result && PQresultStatus(result)==PGRES_TUPLES_OK)
	{
	  size = PQgetlength(result, 0, 0);
	  contents = PQgetvalue(result, 0, 0);	/* binary representation */

	  ss << item << " points to " << size << " bytes.";

	  LOG4CXX_INFO(logger, ss.str());

	  ss.str("");
	  ss.clear();

	  try
	  {
		  os.open(item.c_str(), ios::binary);
		  {
			  //os << contents;
			  os.write(contents, size);
			  os.close();
		  }
	  }
	  catch( std::exception& e )
	  {
		  LOG4CXX_ERROR(logger, e.what());
		  syslog(LOG_ERR, e.what());
	  }
	}
	else
	{
		LOG4CXX_ERROR(logger, "Error reading fwi page bytea");
		syslog(LOG_ERR, "Error reading fwi page bytea");
		return false;
	}

	query = "select meteo_page from images where dt = '" + args.getDate() + "';";

	result = PQexec(conn, query.c_str());

	item = PQgetvalue(result, 0, 0);

	query = "select meteo_page_bytea from images where dt = '" + args.getDate() + "';";

	result = PQexecParams(conn,
				query.c_str(),
				0, NULL,NULL,NULL,NULL,   /* no input parameters */
				1  /* output in binary format */ );

	if (result && PQresultStatus(result)==PGRES_TUPLES_OK)
	{
	  size = PQgetlength(result, 0, 0);
	  contents = PQgetvalue(result, 0, 0);	/* binary representation */

	  ss << item << " points to " << size << " bytes.";

	  LOG4CXX_INFO(logger, ss.str());

	  ss.str("");
	  ss.clear();

	  try
	  {
		  os.open(item.c_str(), ios::binary);
		  {
			  //os << contents;
			  os.write(contents, size);
			  os.close();
		  }
	  }
	  catch( std::exception& e )
	  {
		  LOG4CXX_ERROR(logger, e.what());
		  syslog(LOG_ERR, e.what());
	  }
	}
	else
	{
		LOG4CXX_ERROR(logger, "Error reading meteo page bytea");
		syslog(LOG_ERR, "Error reading meteo page bytea");
		return false;
	}

	query = "select snow from images where dt = '" + args.getDate() + "';";

	result = PQexec(conn, query.c_str());

	item = PQgetvalue(result, 0, 0);

	query = "select snow_bytea from images where dt = '" + args.getDate() + "';";

	result = PQexecParams(conn,
				query.c_str(),
				0, NULL,NULL,NULL,NULL,   /* no input parameters */
				1  /* output in binary format */ );

	if (result && PQresultStatus(result)==PGRES_TUPLES_OK)
	{
	  size = PQgetlength(result, 0, 0);
	  contents = PQgetvalue(result, 0, 0);	/* binary representation */

	  ss << item << " points to " << size << " bytes.";

	  LOG4CXX_INFO(logger, ss.str());

	  ss.str("");
	  ss.clear();

	  try
	  {
		  os.open(item.c_str(), ios::binary);
		  {
			  //os << contents;
			  os.write(contents, size);
			  os.close();
		  }
	  }
	  catch( std::exception& e )
	  {
		  LOG4CXX_ERROR(logger, e.what());
		  syslog(LOG_ERR, e.what());
	  }
	}
	else
	{
		LOG4CXX_ERROR(logger, "Error reading snow bytea");
		syslog(LOG_ERR, "Error reading snow bytea");
		return false;
	}

	return true;
}

/**
 * \fn		bool export_images(COmmandLineArguments& args)
 * \brief	exports stored images for date in <i>args</i> from database to files
 * \param	args command line arguments class
 * \return	true on success else false
 * @see CommandLineArguments
 */

bool export_images(CommandLineArguments& args)
{
	return retrieve_images(args);
}

/**
 * \fn		bool export_indexes(CommandLineArguments& args)
 * \brief	exports fwi indexes grid for date in <i>args</i> from database
 * \param	args command line arguments class
 * \return	true on success else false
 * @see CommandLineArguments
 */
bool export_indexes(CommandLineArguments& args)
{
	// FIXME - fix indexes export order that must be:
	//  1. isi
	//  2. fwi
	//  3. ffmc
	//  4. dmc
	//  5. dc
	//  6. bui
	//  7. ffmc_tmp
	//  8. dmc_tmp
	//  9. dc_tmp
	// 10. check if idi export has to be done
	// 11. angstrom
	// 12. fmi
	// 13. sharples

	bool result = true;

	std::string table;
	std::vector<std::string> fieldnames;

	cfg.lookup("fwidbmgr.files.grads.fwi").lookupValue("table", table);

	Grid<float> res;
	res.setType(FWI_INDEXES);
	res.setDate(args.getDate());
	res.setTable(table);
	res.setVarNum(0);

	result = retrieve_fwi_indexes(args, &res);

	// isi
	Grid<float> isi;
	isi.initialize();
	isi.setType(NUMERIC);

	if( !isi.configure("isi", cfg) )
	{
		cout << "Error: unable to configure isi grid." << endl;
		syslog(LOG_ERR, "Error: unable to configure isi grid.");
		result = false;
	}
	isi.setDate(args.getDate());

	fieldnames.push_back("isi");
	if( !res.subgrid(fieldnames, isi) )
	{
		cout << "Error getting isi subgrid from indexes" << endl;
		syslog(LOG_ERR, "Error getting isi subgrid from indexes");
		result = false;
	}
	else
	{
		std::string date;
		std::string out_ctl;
		std::string out_dat;
		std::string cfgpath;
		date = args.getDate();
		out_ctl = isi.getExportCtlPath();
		out_dat = isi.getExportDatPath();

		if( isi.getExpIOFormat() == GRD_FORMAT_BINARY )
		{
			out_ctl.replace(out_ctl.find(TAG_DATE), TAG_DATE_LEN, date);
			out_dat.replace(out_dat.find(TAG_DATE), TAG_DATE_LEN, date);

#ifdef __OPENSUSE_11_3__
			ofstream ctl(out_ctl.c_str(), ios::trunc);
#else
			ofstream ctl(out_ctl, ios::trunc);
#endif
			isi.writeCtrl(ctl);
			ctl.close();

#ifdef __OPENSUSE_11_3__
			ofstream dat(out_dat.c_str(), ios::trunc | ios::binary);
#else
			ofstream dat(out_dat, ios::trunc | ios::binary);
#endif
			isi.writeBin(dat);
#ifdef DEBUG
			isi.raw_dump();
#endif
			dat.close();
		}
		else if( isi.getExpIOFormat() == GRD_FORMAT_TEXT )
		{
			out_dat.replace(out_dat.find(TAG_DATE), TAG_DATE_LEN, date);
#ifdef __OPENSUSE_11_3__
			ofstream dat(out_dat.c_str(), ios::trunc);
#else
			ofstream dat(out_dat, ios::trunc);
#endif
			isi.writeTxt(dat, true);
#ifdef DEBUG
			isi.raw_dump();
#endif
			dat.close();
		}
	}

	fieldnames.clear();

	// fwi
	Grid<float> fwi;
	fwi.initialize();
	fwi.setType(NUMERIC);

	if( !fwi.configure("fwi", cfg) )
	{
		cout << "Error: unable to configure isi grid." << endl;
		syslog(LOG_ERR, "Error: unable to configure isi grid.");
		result = false;
	}

	fwi.setDate(args.getDate());

	fieldnames.push_back("fwi");
	if( !res.subgrid(fieldnames, fwi) )
	{
		cout << "Error getting isi subgrid from indexes" << endl;
		syslog(LOG_ERR, "Error getting isi subgrid from indexes");
		result = false;
	}
	else
	{
		std::string date;
		std::string out_ctl;
		std::string out_dat;
		std::string cfgpath;
		date = args.getDate();
		out_ctl = fwi.getExportCtlPath();
		out_dat = fwi.getExportDatPath();

		if( fwi.getExpIOFormat() == GRD_FORMAT_BINARY )
		{
			out_ctl.replace(out_ctl.find(TAG_DATE), TAG_DATE_LEN, date);
			out_dat.replace(out_dat.find(TAG_DATE), TAG_DATE_LEN, date);
#ifdef __OPENSUSE_11_3__
			ofstream ctl(out_ctl.c_str(), ios::trunc);
#else
			ofstream ctl(out_ctl, ios::trunc);
#endif
			fwi.writeCtrl(ctl);
			ctl.close();
#ifdef __OPENSUSE_11_3__
			ofstream dat(out_dat.c_str(), ios::trunc | ios::binary);
#else
			ofstream dat(out_dat, ios::trunc | ios::binary);
#endif
			fwi.writeBin(dat);
#ifdef DEBUG
			fwi.raw_dump();
#endif
			dat.close();
		}
		else if( fwi.getExpIOFormat() == GRD_FORMAT_TEXT )
		{
			out_dat.replace(out_dat.find(TAG_DATE), TAG_DATE_LEN, date);
#ifdef __OPENSUSE_11_3__
			ofstream dat(out_dat.c_str(), ios::trunc);
#else
			ofstream dat(out_dat, ios::trunc);
#endif
			fwi.writeTxt(dat, true);
#ifdef DEBUG
			fwi.raw_dump();
#endif
			dat.close();
		}
	}

	fieldnames.clear();

	// ffmc
	Grid<float> ffmc;
	ffmc.initialize();
	ffmc.setType(NUMERIC);

	if( !ffmc.configure("ffmc", cfg) )
	{
		cout << "Error: unable to configure ffmc grid." << endl;
		syslog(LOG_ERR, "Error: unable to configure ffmc grid.");
		result = false;
	}
	ffmc.setDate(args.getDate());

	fieldnames.push_back("ffmc");
	if( !res.subgrid(fieldnames, ffmc) )
	{
		cout << "Error getting ffmc subgrid from indexes" << endl;
		syslog(LOG_ERR, "Error getting ffmc subgrid from indexes");
		result = false;
	}
	else
	{
		std::string date;
		std::string out_ctl;
		std::string out_dat;
		std::string cfgpath;
		date = args.getDate();
		out_ctl = ffmc.getExportCtlPath();
		out_dat = ffmc.getExportDatPath();

		if( ffmc.getExpIOFormat() == GRD_FORMAT_BINARY )
		{
			out_ctl.replace(out_ctl.find(TAG_DATE), TAG_DATE_LEN, date);
			out_dat.replace(out_dat.find(TAG_DATE), TAG_DATE_LEN, date);
#ifdef __OPENSUSE_11_3__
			ofstream ctl(out_ctl.c_str(), ios::trunc);
#else
			ofstream ctl(out_ctl, ios::trunc);
#endif
			ffmc.writeCtrl(ctl);
			ctl.close();
#ifdef __OPENSUSE_11_3__
			ofstream dat(out_dat.c_str(), ios::trunc | ios::binary);
#else
			ofstream dat(out_dat, ios::trunc | ios::binary);
#endif
			ffmc.writeBin(dat);
#ifdef DEBUG
			ffmc.raw_dump();
#endif
			dat.close();
		}
		else if( ffmc.getExpIOFormat() == GRD_FORMAT_TEXT )
		{
			out_dat.replace(out_dat.find(TAG_DATE), TAG_DATE_LEN, date);
#ifdef __OPENSUSE_11_3__
			ofstream dat(out_dat.c_str(), ios::trunc);
#else
			ofstream dat(out_dat, ios::trunc);
#endif
			ffmc.writeTxt(dat, true);
#ifdef DEBUG
			ffmc.raw_dump();
#endif
			dat.close();
		}
	}

	fieldnames.clear();

	// dmc
	Grid<float> dmc;
	dmc.initialize();
	dmc.setType(NUMERIC);

	if( !dmc.configure("dmc", cfg) )
	{
		cout << "Error: unable to configure dmc grid." << endl;
		syslog(LOG_ERR, "Error: unable to configure dmc grid.");
		result = false;
	}
	dmc.setDate(args.getDate());

	fieldnames.push_back("dmc");
	if( !res.subgrid(fieldnames, dmc) )
	{
		cout << "Error getting dmc subgrid from indexes" << endl;
		syslog(LOG_ERR, "Error getting dmc subgrid from indexes");
		result = false;
	}
	else
	{
		std::string date;
		std::string out_ctl;
		std::string out_dat;
		std::string cfgpath;
		date = args.getDate();
		out_ctl = dmc.getExportCtlPath();
		out_dat = dmc.getExportDatPath();

		if( dmc.getExpIOFormat() == GRD_FORMAT_BINARY )
		{
			out_ctl.replace(out_ctl.find(TAG_DATE), TAG_DATE_LEN, date);
			out_dat.replace(out_dat.find(TAG_DATE), TAG_DATE_LEN, date);
#ifdef __OPENSUSE_11_3__
			ofstream ctl(out_ctl.c_str(), ios::trunc);
#else
			ofstream ctl(out_ctl, ios::trunc);
#endif
			dmc.writeCtrl(ctl);
			ctl.close();
#ifdef __OPENSUSE_11_3__
			ofstream dat(out_dat.c_str(), ios::trunc | ios::binary);
#else
			ofstream dat(out_dat, ios::trunc | ios::binary);
#endif
			dmc.writeBin(dat);
#ifdef DEBUG
			dmc.raw_dump();
#endif
			dat.close();
		}
		else if( dmc.getExpIOFormat() == GRD_FORMAT_TEXT )
		{
			out_dat.replace(out_dat.find(TAG_DATE), TAG_DATE_LEN, date);
#ifdef __OPENSUSE_11_3__
			ofstream dat(out_dat.c_str(), ios::trunc);
#else
			ofstream dat(out_dat, ios::trunc);
#endif
			dmc.writeTxt(dat, true);
#ifdef DEBUG
			dmc.raw_dump();
#endif
			dat.close();
		}
	}

	fieldnames.clear();

	// dc
	Grid<float> dc;
	dc.initialize();
	dc.setType(NUMERIC);

	if( !dc.configure("dc", cfg) )
	{
		cout << "Error: unable to configure dc grid." << endl;
		syslog(LOG_ERR, "Error: unable to configure dc grid.");
		result = false;
	}
	dc.setDate(args.getDate());

	fieldnames.push_back("dc");
	if( !res.subgrid(fieldnames, dc) )
	{
		cout << "Error getting dc subgrid from indexes" << endl;
		syslog(LOG_ERR, "Error getting dc subgrid from indexes");
		result = false;
	}
	else
	{
		std::string date;
		std::string out_ctl;
		std::string out_dat;
		std::string cfgpath;
		date = args.getDate();
		out_ctl = dc.getExportCtlPath();
		out_dat = dc.getExportDatPath();

		if( dc.getExpIOFormat() == GRD_FORMAT_BINARY )
		{
			out_ctl.replace(out_ctl.find(TAG_DATE), TAG_DATE_LEN, date);
			out_dat.replace(out_dat.find(TAG_DATE), TAG_DATE_LEN, date);
#ifdef __OPENSUSE_11_3__
			ofstream ctl(out_ctl.c_str(), ios::trunc);
#else
			ofstream ctl(out_ctl, ios::trunc);
#endif
			dc.writeCtrl(ctl);
			ctl.close();
#ifdef __OPENSUSE_11_3__
			ofstream dat(out_dat.c_str(), ios::trunc | ios::binary);
#else
			ofstream dat(out_dat, ios::trunc | ios::binary);
#endif
			dc.writeBin(dat);
#ifdef DEBUG
			dc.raw_dump();
#endif
			dat.close();
		}
		else if( dc.getExpIOFormat() == GRD_FORMAT_TEXT )
		{
			out_dat.replace(out_dat.find(TAG_DATE), TAG_DATE_LEN, date);
#ifdef __OPENSUSE_11_3__
			ofstream dat(out_dat.c_str(), ios::trunc);
#else
			ofstream dat(out_dat, ios::trunc);
#endif
			dc.writeTxt(dat, true);
#ifdef DEBUG
			dc.raw_dump();
#endif
			dat.close();
		}
	}

	fieldnames.clear();

	// bui
	Grid<float> bui;
	bui.initialize();
	bui.setType(NUMERIC);

	if( !bui.configure("bui", cfg) )
	{
		cout << "Error: unable to configure bui grid." << endl;
		syslog(LOG_ERR, "Error: unable to configure bui grid.");
		result = false;
	}
	bui.setDate(args.getDate());

	fieldnames.push_back("bui");
	if( !res.subgrid(fieldnames, bui) )
	{
		cout << "Error getting bui subgrid from indexes" << endl;
		syslog(LOG_ERR, "Error getting bui subgrid from indexes");
		result = false;
	}
	else
	{
		std::string date;
		std::string out_ctl;
		std::string out_dat;
		std::string cfgpath;
		date = args.getDate();
		out_ctl = bui.getExportCtlPath();
		out_dat = bui.getExportDatPath();

		if( bui.getExpIOFormat() == GRD_FORMAT_BINARY )
		{
			out_ctl.replace(out_ctl.find(TAG_DATE), TAG_DATE_LEN, date);
			out_dat.replace(out_dat.find(TAG_DATE), TAG_DATE_LEN, date);
#ifdef __OPENSUSE_11_3__
			ofstream ctl(out_ctl.c_str(), ios::trunc);
#else
			ofstream ctl(out_ctl, ios::trunc);
#endif
			bui.writeCtrl(ctl);
			ctl.close();
#ifdef __OPENSUSE_11_3__
			ofstream dat(out_dat.c_str(), ios::trunc | ios::binary);
#else
			ofstream dat(out_dat, ios::trunc | ios::binary);
#endif
			bui.writeBin(dat);
#ifdef DEBUG
			bui.raw_dump();
#endif
			dat.close();
		}
		else if( bui.getExpIOFormat() == GRD_FORMAT_TEXT )
		{
			out_dat.replace(out_dat.find(TAG_DATE), TAG_DATE_LEN, date);
#ifdef __OPENSUSE_11_3__
			ofstream dat(out_dat.c_str(), ios::trunc);
#else
			ofstream dat(out_dat, ios::trunc);
#endif
			bui.writeTxt(dat, true);
#ifdef DEBUG
			bui.raw_dump();
#endif
			dat.close();

		}
	}

	fieldnames.clear();

	// ffmc_tmp
	Grid<float> ffmc_tmp;
	ffmc_tmp.initialize();
	ffmc_tmp.setType(NUMERIC);

	if( !ffmc_tmp.configure("ffmc_tmp", cfg) )
	{
		cout << "Error: unable to configure ffmc_tmp grid." << endl;
		syslog(LOG_ERR, "Error: unable to configure ffmc_tmp grid.");
		result = false;
	}
	ffmc_tmp.setDate(args.getDate());

	fieldnames.push_back("ffmc_tmp");
	if( !res.subgrid(fieldnames, ffmc_tmp) )
	{
		cout << "Error getting dmc_tmp subgrid from indexes" << endl;
		syslog(LOG_ERR, "Error getting dmc_tmp subgrid from indexes");
		result = false;
	}
	else
	{
		std::string date;
		std::string out_ctl;
		std::string out_dat;
		std::string cfgpath;
		date = args.getDate();
		out_ctl = ffmc_tmp.getExportCtlPath();
		out_dat = ffmc_tmp.getExportDatPath();

		if( ffmc_tmp.getExpIOFormat() == GRD_FORMAT_BINARY )
		{
			out_ctl.replace(out_ctl.find(TAG_DATE), TAG_DATE_LEN, date);
			out_dat.replace(out_dat.find(TAG_DATE), TAG_DATE_LEN, date);
#ifdef __OPENSUSE_11_3__
			ofstream ctl(out_ctl.c_str(), ios::trunc);
#else
			ofstream ctl(out_ctl, ios::trunc);
#endif
			ffmc_tmp.writeCtrl(ctl);
			ctl.close();
#ifdef __OPENSUSE_11_3__
			ofstream dat(out_dat.c_str(), ios::trunc | ios::binary);
#else
			ofstream dat(out_dat, ios::trunc | ios::binary);
#endif
			ffmc_tmp.writeBin(dat);
#ifdef DEBUG
			ffmc_tmp.raw_dump();
#endif
			dat.close();
		}
		else if( ffmc_tmp.getExpIOFormat() == GRD_FORMAT_TEXT )
		{
			out_dat.replace(out_dat.find(TAG_DATE), TAG_DATE_LEN, date);
#ifdef __OPENSUSE_11_3__
			ofstream dat(out_dat.c_str(), ios::trunc);
#else
			ofstream dat(out_dat, ios::trunc);
#endif
			ffmc_tmp.writeTxt(dat, true);
#ifdef DEBUG
			ffmc_tmp.raw_dump();
#endif
			dat.close();

		}
	}

	fieldnames.clear();

	// dmc_tmp
	Grid<float> dmc_tmp;
	dmc_tmp.initialize();
	dmc_tmp.setType(NUMERIC);

	if( !dmc_tmp.configure("dmc_tmp", cfg) )
	{
		cout << "Error: unable to configure dmc_tmp grid." << endl;
		syslog(LOG_ERR, "Error: unable to configure dmc_tmp grid.");
		result = false;
	}
	dmc_tmp.setDate(args.getDate());

	fieldnames.push_back("dmc_tmp");
	if( !res.subgrid(fieldnames, dmc_tmp) )
	{
		cout << "Error getting dmc_tmp subgrid from indexes" << endl;
		syslog(LOG_ERR, "Error getting dmc_tmp subgrid from indexes");
		result = false;
	}
	else
	{
		std::string date;
		std::string out_ctl;
		std::string out_dat;
		std::string cfgpath;
		date = args.getDate();
		out_ctl = dmc_tmp.getExportCtlPath();
		out_dat = dmc_tmp.getExportDatPath();

		if( dmc_tmp.getExpIOFormat() == GRD_FORMAT_BINARY )
		{
			out_ctl.replace(out_ctl.find(TAG_DATE), TAG_DATE_LEN, date);
			out_dat.replace(out_dat.find(TAG_DATE), TAG_DATE_LEN, date);
#ifdef __OPENSUSE_11_3__
			ofstream ctl(out_ctl.c_str(), ios::trunc);
#else
			ofstream ctl(out_ctl, ios::trunc);
#endif
			dmc_tmp.writeCtrl(ctl);
			ctl.close();
#ifdef __OPENSUSE_11_3__
			ofstream dat(out_dat.c_str(), ios::trunc | ios::binary);
#else
			ofstream dat(out_dat, ios::trunc | ios::binary);
#endif
			dmc_tmp.writeBin(dat);
#ifdef DEBUG
			dmc_tmp.raw_dump();
#endif
			dat.close();
		}
		else if( dmc_tmp.getExpIOFormat() == GRD_FORMAT_TEXT )
		{
			out_dat.replace(out_dat.find(TAG_DATE), TAG_DATE_LEN, date);
#ifdef __OPENSUSE_11_3__
			ofstream dat(out_dat.c_str(), ios::trunc);
#else
			ofstream dat(out_dat, ios::trunc);
#endif
			dmc_tmp.writeTxt(dat, true);
#ifdef DEBUG
			dmc_tmp.raw_dump();
#endif
			dat.close();
		}
	}

	fieldnames.clear();

	// dc_tmp
	Grid<float> dc_tmp;
	dc_tmp.initialize();
	dc_tmp.setType(NUMERIC);

	if( !dc_tmp.configure("dc_tmp", cfg) )
	{
		cout << "Error: unable to configure dc_tmp grid." << endl;
		syslog(LOG_ERR, "Error: unable to configure dc_tmp grid.");
		result = false;
	}
	dc_tmp.setDate(args.getDate());

	fieldnames.push_back("dc_tmp");
	if( !res.subgrid(fieldnames, dc_tmp) )
	{
		cout << "Error getting dc_tmp subgrid from indexes" << endl;
		syslog(LOG_ERR, "Error getting dc_tmp subgrid from indexes");
		result = false;
	}
	else
	{
		std::string date;
		std::string out_ctl;
		std::string out_dat;
		std::string cfgpath;
		date = args.getDate();
		out_ctl = dc_tmp.getExportCtlPath();
		out_dat = dc_tmp.getExportDatPath();

		if( dc_tmp.getExpIOFormat() == GRD_FORMAT_BINARY )
		{
			out_ctl.replace(out_ctl.find(TAG_DATE), TAG_DATE_LEN, date);
			out_dat.replace(out_dat.find(TAG_DATE), TAG_DATE_LEN, date);
#ifdef __OPENSUSE_11_3__
			ofstream ctl(out_ctl.c_str(), ios::trunc);
#else
			ofstream ctl(out_ctl, ios::trunc);
#endif
			dc_tmp.writeCtrl(ctl);
			ctl.close();
#ifdef __OPENSUSE_11_3__
			ofstream dat(out_dat.c_str(), ios::trunc | ios::binary);
#else
			ofstream dat(out_dat, ios::trunc | ios::binary);
#endif
			dc_tmp.writeBin(dat);
#ifdef DEBUG
			dc_tmp.raw_dump();
#endif
			dat.close();
		}
		else if( dc_tmp.getExpIOFormat() == GRD_FORMAT_TEXT )
		{
			out_dat.replace(out_dat.find(TAG_DATE), TAG_DATE_LEN, date);
#ifdef __OPENSUSE_11_3__
			ofstream dat(out_dat.c_str(), ios::trunc);
#else
			ofstream dat(out_dat, ios::trunc);
#endif
			dc_tmp.writeTxt(dat, true);
#ifdef DEBUG
			dc_tmp.raw_dump();
#endif
			dat.close();
		}
	}

	fieldnames.clear();

	// angstrom
	Grid<float> angstrom;
	angstrom.initialize();
	angstrom.setType(NUMERIC);

	if( !angstrom.configure("angstrom", cfg) )
	{
		cout << "Error: unable to configure angstrom grid." << endl;
		syslog(LOG_ERR, "Error: unable to configure angstrom grid.");
		result = false;
	}
	angstrom.setDate(args.getDate());

	fieldnames.push_back("angstrom");
	if( !res.subgrid(fieldnames, angstrom) )
	{
		cout << "Error getting angstrom subgrid from indexes" << endl;
		syslog(LOG_ERR, "Error getting angstrom subgrid from indexes");
		result = false;
	}
	else
	{
		std::string date;
		std::string out_ctl;
		std::string out_dat;
		std::string cfgpath;
		date = args.getDate();
		out_ctl = angstrom.getExportCtlPath();
		out_dat = angstrom.getExportDatPath();

		if( angstrom.getExpIOFormat() == GRD_FORMAT_BINARY )
		{
			out_ctl.replace(out_ctl.find(TAG_DATE), TAG_DATE_LEN, date);
			out_dat.replace(out_dat.find(TAG_DATE), TAG_DATE_LEN, date);
#ifdef __OPENSUSE_11_3__
			ofstream ctl(out_ctl.c_str(), ios::trunc);
#else
			ofstream ctl(out_ctl, ios::trunc);
#endif
			angstrom.writeCtrl(ctl);
			ctl.close();
#ifdef __OPENSUSE_11_3__
			ofstream dat(out_dat.c_str(), ios::trunc | ios::binary);
#else
			ofstream dat(out_dat, ios::trunc | ios::binary);
#endif
			angstrom.writeBin(dat);
#ifdef DEBUG
			angstrom.raw_dump();
#endif
			dat.close();
		}
		else if( angstrom.getExpIOFormat() == GRD_FORMAT_TEXT )
		{
			out_dat.replace(out_dat.find(TAG_DATE), TAG_DATE_LEN, date);
#ifdef __OPENSUSE_11_3__
			ofstream dat(out_dat.c_str(), ios::trunc);
#else
			ofstream dat(out_dat, ios::trunc);
#endif
			angstrom.writeTxt(dat, true);
#ifdef DEBUG
			angstrom.raw_dump();
#endif
			dat.close();
		}
	}

	fieldnames.clear();

	// sharples
	Grid<float> sharples;
	sharples.initialize();
	sharples.setType(NUMERIC);

	if( !sharples.configure("sharples", cfg) )
	{
		cout << "Error: unable to configure sharples grid." << endl;
		syslog(LOG_ERR, "Error: unable to configure sharples grid.");
		result = false;
	}
	sharples.setDate(args.getDate());

	fieldnames.push_back("sharples");
	if( !res.subgrid(fieldnames, sharples) )
	{
		cout << "Error getting sharples subgrid from indexes" << endl;
		syslog(LOG_ERR, "Error getting sharples subgrid from indexes");
		result = false;
	}
	else
	{
		std::string date;
		std::string out_ctl;
		std::string out_dat;
		std::string cfgpath;
		date = args.getDate();
		out_ctl = sharples.getExportCtlPath();
		out_dat = sharples.getExportDatPath();

		if( sharples.getExpIOFormat() == GRD_FORMAT_BINARY )
		{
			out_ctl.replace(out_ctl.find(TAG_DATE), TAG_DATE_LEN, date);
			out_dat.replace(out_dat.find(TAG_DATE), TAG_DATE_LEN, date);
#ifdef __OPENSUSE_11_3__
			ofstream ctl(out_ctl.c_str(), ios::trunc);
#else
			ofstream ctl(out_ctl, ios::trunc);
#endif
			sharples.writeCtrl(ctl);
			ctl.close();
#ifdef __OPENSUSE_11_3__
			ofstream dat(out_dat.c_str(), ios::trunc | ios::binary);
#else
			ofstream dat(out_dat, ios::trunc | ios::binary);
#endif
			sharples.writeBin(dat);
#ifdef DEBUG
			sharples.raw_dump();
#endif
			dat.close();
		}
		else if( sharples.getExpIOFormat() == GRD_FORMAT_TEXT )
		{
			out_dat.replace(out_dat.find(TAG_DATE), TAG_DATE_LEN, date);
#ifdef __OPENSUSE_11_3__
			ofstream dat(out_dat.c_str(), ios::trunc);
#else
			ofstream dat(out_dat, ios::trunc);
#endif
			sharples.writeTxt(dat, true);
#ifdef DEBUG
			sharples.raw_dump();
#endif
			dat.close();
		}
	}

	fieldnames.clear();

	// fmi
	Grid<float> fmi;
	fmi.initialize();
	fmi.setType(NUMERIC);

	if( !fmi.configure("fmi", cfg) )
	{
		cout << "Error: unable to configure fmi grid." << endl;
		syslog(LOG_ERR, "Error: unable to configure fmi grid.");
		result = false;
	}
	fmi.setDate(args.getDate());

	fieldnames.push_back("fmi");
	if( !res.subgrid(fieldnames, fmi) )
	{
		cout << "Error getting fmi subgrid from indexes" << endl;
		syslog(LOG_ERR, "Error getting fmi subgrid from indexes");
		result = false;
	}
	else
	{
		std::string date;
		std::string out_ctl;
		std::string out_dat;
		std::string cfgpath;
		date = args.getDate();
		out_ctl = fmi.getExportCtlPath();
		out_dat = fmi.getExportDatPath();

		if( fmi.getExpIOFormat() == GRD_FORMAT_BINARY )
		{
			out_ctl.replace(out_ctl.find(TAG_DATE), TAG_DATE_LEN, date);
			out_dat.replace(out_dat.find(TAG_DATE), TAG_DATE_LEN, date);
#ifdef __OPENSUSE_11_3__
			ofstream ctl(out_ctl.c_str(), ios::trunc);
#else
			ofstream ctl(out_ctl, ios::trunc);
#endif
			fmi.writeCtrl(ctl);
			ctl.close();
#ifdef __OPENSUSE_11_3__
			ofstream dat(out_dat.c_str(), ios::trunc | ios::binary);
#else
			ofstream dat(out_dat, ios::trunc | ios::binary);
#endif
			fmi.writeBin(dat);
#ifdef DEBUG
			fmi.raw_dump();
#endif
			dat.close();
		}
		else if( fmi.getExpIOFormat() == GRD_FORMAT_TEXT )
		{
			out_dat.replace(out_dat.find(TAG_DATE), TAG_DATE_LEN, date);
#ifdef __OPENSUSE_11_3__
			ofstream dat(out_dat.c_str(), ios::trunc);
#else
			ofstream dat(out_dat, ios::trunc);
#endif
			fmi.writeTxt(dat, true);
#ifdef DEBUG
			fmi.raw_dump();
#endif
			dat.close();
		}
	}

	fieldnames.clear();

	return result;
}

/**
 * \fn		bool load_computation_indexes(std::vector<std::string>& indexes)
 * \brief	Loads from configuration the list of index names to be computed
 * \param	indexes the list of index names
 * \return	true on success else false
 */
bool load_computation_indexes(std::vector<std::string>& indexes)
{
	bool        result      = true;
	int         int_setting = 0;
	int         indexesnum  = 0;
	std::string cfgpath     = "";
	std::string index       = "";
	char       s[20];

	if( cfg.lookupValue("fwidbmgr.computation.indexesnum", int_setting) )
	{
		indexesnum = int_setting;
		for( int i = 0; i < indexesnum; i++ )
		{
			cfgpath  = "fwidbmgr.computation.indexes.[";
			sprintf(s, "%d", i);
			cfgpath += s;
			cfgpath += "]";

			if( cfg.lookupValue(cfgpath, index) )
			{
				indexes.push_back(index);
			}
			else
			{
				return false;
			}
		}
	}

	return result;
}

/**
 * \fn		bool compute_index(std::string& index_name, Grid<float>* indexes, Grid<float>* meteo)
 * \brief	Compute a single index given its name
 * \param	index_name the index name
 * \param	indexes the already loaded indexes grid
 * \param	meteo the already loaded meteo input grid
 * \return	true on success else false
 */
bool compute_index(std::string& index_name, Grid<float>* indexes, Grid<float>* meteo)
{
	bool result = true;

	assert( indexes != NULL );
	assert( meteo   != NULL );

	// Determine index position in grid fields list
	int idx_pos = indexes->getFields()->getFieldPosition(index_name) - 1;
	if( idx_pos <= NOT_FOUND )
	{
		LOG4CXX_ERROR(logger, "Unable to find field " << index_name << " among indexes grid fields");
		syslog(LOG_ERR, "Unable to find field %s among indexes grid fields", index_name.c_str());
		return false;
	}
	// Got index-field position
	//cout << "Index " << index_name << " at " << idx_pos << " in fields list" << endl;
	//LOG4CXX_INFO(logger, "Index " << index_name.c_str() << " at " << idx_pos << " in fields list")

	/* FIXME -- This is cabled code: something has to be done to specify which meteo parameters/indexes the computed index depends on */
	std::string rha             = "rha";
	std::string air_temperature = "xa";
	std::string ws_u            = "au";
	std::string ws_v            = "av";
	std::string fmi             = "fmi";
	float       U0              = 1.0f;

	int r_pos = meteo->getFields()->getFieldPosition(rha) - 1;
	if( r_pos <= NOT_FOUND )
	{
		cout << "Unable to find rha field among meteo grid fields" << endl;
		syslog(LOG_ERR, "Unable to find rha field among meteo grid fields");
		return false;
	}

	int t_pos = meteo->getFields()->getFieldPosition(air_temperature) - 1;
	if( t_pos <= NOT_FOUND )
	{
		cout << "Unable to find xa field among meteo grid fields" << endl;
		syslog(LOG_ERR, "Unable to find xa field among meteo grid fields");
		return false;
	}

	int u_pos = meteo->getFields()->getFieldPosition(ws_u) - 1;
	if( u_pos <= NOT_FOUND )
	{
		cout << "Unable to find au field among meteo grid fields" << endl;
		syslog(LOG_ERR, "Unable to find au field among meteo grid fields");
		return false;
	}

	int v_pos = meteo->getFields()->getFieldPosition(ws_v) - 1;
	if( v_pos <= NOT_FOUND )
	{
		cout << "Unable to find av field among meteo grid fields" << endl;
		syslog(LOG_ERR, "Unable to find av field among meteo grid fields");
		return false;
	}

	int fmi_pos = indexes->getFields()->getFieldPosition(fmi) - 1;
	if( fmi_pos <= NOT_FOUND )
	{
		cout << "Unable to find fmi field among indexes grid fields" << endl;
		syslog(LOG_ERR, "Unable to find fmi field among indexes grid fields");
		return false;
	}

	// Got meteo-parameter field positions
	float idx_value = 0.0;
	float u_value   = 0.0;
	float v_value   = 0.0;
	float u         = 0.0;
	float r         = 0.0;
	float t         = 0.0;

	for( int i = 0; i < meteo->getRows(); i++ )
	//for( int i = meteo->getRows() - 1; i >= 0; i-- )
	{
		for( int j = 0; j < meteo->getCols(); j++ )
		{
			if( index_name == "angstrom" )
			{
				r = (*meteo)(i, j, r_pos);
				t = (*meteo)(i, j, t_pos);
				if( r != GRD_DEFAULT_UNDEF_VALUE && t != GRD_DEFAULT_UNDEF_VALUE )
				{
					idx_value = r / 20.0 + (27 - t) / 10.0;
				}
				else
				{
					idx_value = GRD_DEFAULT_UNDEF_VALUE;
				}
			}
			else if( index_name == "fmi" )
			{
				r = (*meteo)(i, j, r_pos);
				t = (*meteo)(i, j, t_pos);
				if( r != GRD_DEFAULT_UNDEF_VALUE && t != GRD_DEFAULT_UNDEF_VALUE )
				{
					idx_value = 10.0 - 0.25 * (t - r);
				}
				else
				{
					idx_value = GRD_DEFAULT_UNDEF_VALUE;
				}
			}
			else if( index_name == "sharples" )
			{
				u_value = (*meteo)(i, j, u_pos);
				v_value = (*meteo)(i, j, v_pos);
				if( u_value != GRD_DEFAULT_UNDEF_VALUE && v_value != GRD_DEFAULT_UNDEF_VALUE )
				{
					u       = sqrt(u_value * u_value + v_value * v_value) * 3.6;
					idx_value = max(U0, u) / (*indexes)(i, j, fmi_pos);
				}
				else
				{
					idx_value = GRD_DEFAULT_UNDEF_VALUE;
				}
			}

			(*indexes)(i, j, idx_pos) = idx_value;
		}
	}

	return result;
}

/**
 * \fn		bool compute_indexes(CommandLineArguments& args)
 * \brief	Computes the new three indexes angstroem, fmi and sharples as an experimental feature.
 *          Requires the previous import of the standard indexes in database.
 * \param	args command line arguments class
 * \return	true on success else false
 * @see	CommandLineArguments
 */
bool compute_indexes(CommandLineArguments& args)
{
	bool                     result  = false;
	std::vector<std::string> index_names;

	Grid<float> indexes;
	Grid<float> meteo;

	if( !(result = retrieve_fwi_indexes(args, &indexes)) )
	{
		//cout << "Error retrieving fwi indexes for " << args.getDate() << endl;
		LOG4CXX_ERROR(logger, "Error retrieving fwi indexes for " << args.getDate());
		syslog(LOG_ERR, "Error retrieving fwi indexes for %s.", args.getDate().c_str());
		return result;
	}

	if( !(result = retrieve_meteo_input(args, &meteo)) )
	{
		//cout << "Error retrieving meteo input for " << args.getDate() << endl;
		LOG4CXX_ERROR(logger, "Error retrieving meteo input for " << args.getDate());
		syslog(LOG_ERR, "Error retrieving meteo input for %s.", args.getDate().c_str());
		return result;
	}

	// Get indexes list
	if( !(result = load_computation_indexes(index_names)) )
	{
		cout << "Error retrieving indexes list." << endl;
		syslog(LOG_ERR, "Error retrieving indexes list.");
		return result;
	}

	// Do computation
	for( size_t i = 0; i < index_names.size(); i++ )
	{
		result = result & compute_index(index_names[i], &indexes, &meteo);
		if( !result )
		{
			//cout << "Error computing index " << index_names[i] << endl;
			LOG4CXX_ERROR(logger, "Error computing index " << index_names[i]);
			syslog(LOG_ERR, "Error computing index %s.", index_names[i].c_str());
			return result;
		}
	}

	// Save indexes
	result = indexes.store(conn);

	return result;
}

bool compute_indexes_24(CommandLineArguments& args)
{
	bool result = true;

	Grid<float>              temperature;
	Grid<float>              humidity;
	Grid<float>              windspeed;
	Grid<float>              rain;
	std::vector<std::string> index_names;
	std::vector<std::string> fieldnames;
	std::string              inpath24;
	std::string              outpath24;
	std::string              indexname;

	if( !cfg.lookupValue("fwidbmgr.paths.inpath24", inpath24) )
	{
		LOG4CXX_ERROR(logger, "Unable to get input path 24 from config file");
		syslog(LOG_ERR, "Unable to get input path 24 from config file");
		return false;
	}
	if( !cfg.lookupValue("fwidbmgr.paths.outpath24", outpath24) )
	{
		LOG4CXX_ERROR(logger, "Unable to get output path 24 from config file");
		syslog(LOG_ERR, "Unable to get output path 24 from config file");
		return false;
	}

	// load temperature data
	temperature.initialize();
	temperature.setType(NUMERIC);
	if( temperature.configure(METEO_PARAM_TEMPERATURE , cfg) && result )
	{
		temperature.setDate(args.getDate());
		LOG4CXX_INFO(logger, "Configured " << METEO_PARAM_TEMPERATURE << " grid");
		syslog(LOG_NOTICE, "Configured %s grid.", METEO_PARAM_TEMPERATURE);
	}
	else
	{
		LOG4CXX_ERROR(logger, "Error configuring meteo parameter: " << METEO_PARAM_TEMPERATURE);
		syslog(LOG_ERR, "Error configuring meteo parameter: %s.", METEO_PARAM_TEMPERATURE);
		result = false;
	}

	// load humidity data
	humidity.initialize();
	humidity.setType(NUMERIC);
	if( humidity.configure(METEO_PARAM_HUMIDITY, cfg) && result )
	{
		humidity.setDate(args.getDate());
		LOG4CXX_INFO(logger, "Configured " << METEO_PARAM_HUMIDITY << " grid");
		syslog(LOG_NOTICE, "Configured %s grid", METEO_PARAM_HUMIDITY);
	}
	else
	{
		LOG4CXX_ERROR(logger, "Error configuring meteo parameter: " << METEO_PARAM_HUMIDITY);
		syslog(LOG_ERR, "Error configuring meteo parameter: %s.", METEO_PARAM_HUMIDITY);
		result = false;
	}

	// load wind speed data
	windspeed.initialize();
	windspeed.setType(NUMERIC);
	if( windspeed.configure(METEO_PARAM_WINDSPEED, cfg) && result )
	{
		windspeed.setDate(args.getDate());
		LOG4CXX_INFO(logger, "Configured " << METEO_PARAM_WINDSPEED << " grid");
		syslog(LOG_NOTICE, "Configured %s grid", METEO_PARAM_WINDSPEED);
	}
	else
	{
		LOG4CXX_ERROR(logger, "Error configuring meteo parameter: " << METEO_PARAM_WINDSPEED);
		syslog(LOG_ERR, "Error configuring meteo parameter: %s.", METEO_PARAM_WINDSPEED);
		result = false;
	}

	// load rain data
	rain.initialize();
	rain.setType(NUMERIC);
	if( rain.configure(METEO_PARAM_RAIN, cfg) && result )
	{
		rain.setDate(args.getDate());
		LOG4CXX_INFO(logger, "Configured " << METEO_PARAM_RAIN << " grid");
		syslog(LOG_NOTICE, "Configured %s grid.", METEO_PARAM_RAIN);
	}
	else
	{
		LOG4CXX_ERROR(logger, "Error configuring meteo parameter: " << METEO_PARAM_RAIN);
		syslog(LOG_ERR, "Error configuring meteo parameter: %s.", METEO_PARAM_RAIN);
		result = false;
	}

	// Get indexes list
	if( !(result = load_computation_indexes(index_names)) )
	{
		LOG4CXX_ERROR(logger, "Error retrieving indexes list.");
		syslog(LOG_ERR, "Error retrieving indexes list.");
	}

	if( result )
	{
		std::string   dd = args.getDate();
		dd.insert(6, "-");
		dd.insert(4, "-");
		dd += " 00:00:00.0000";
		ptime t(time_from_string(dd));
		LOG4CXX_INFO(logger, "date: " << to_iso_extended_string(t));
		time_duration dt = duration_from_string(temperature.getStartTime());
		LOG4CXX_INFO(logger, "time duration: " << dt.hours() << dt.minutes() << dt.seconds());
		time_duration h(1, 0, 0, 0);
		LOG4CXX_INFO(logger, "delta time: " << h.hours() << h.minutes() << h.seconds());

		// Set start time to
		t = t + hours(dt.hours());

		// Here all data will be loaded
		// For each hour time band retrieve data from the grids,
		// compute the indexes and then save them to disk.
		for( int i = 0; i < temperature.getTimeBandsNumber(); i++ )
		{
			Grid<float> indexes;
			indexes.initialize();
			if( !prepare_fwi_indexes_grid(args, &indexes) )
			{
				result = false;
			}

			// reset meteo grids
			temperature.initialize();
			humidity.initialize();
			windspeed.initialize();
			rain.initialize();

			// get the right time band
			temperature.setTimeBand(i);
			humidity.setTimeBand(i);
			windspeed.setTimeBand(i);
			rain.setTimeBand(i);

			if( !temperature.read() )
			{
				LOG4CXX_ERROR(logger, "Error reading temperature file: " << temperature.getDatPath());
				syslog(LOG_ERR, "Error reading temperature file: %s.", temperature.getDatPath().c_str());
				result = false;
				break;
			}
			if( !humidity.read() )
			{
				LOG4CXX_ERROR(logger, "Error reading humidity file: " << humidity.getDatPath());
				syslog(LOG_ERR, "Error reading humidity file: %s.", humidity.getDatPath().c_str());
				result = false;
				break;
			}
			if( !windspeed.read() )
			{
				LOG4CXX_ERROR(logger, "Error reading wind speed file: " << windspeed.getDatPath());
				syslog(LOG_ERR, "Error reading wind speed file: %s.", windspeed.getDatPath().c_str());
				result = false;
				break;
			}
			if( !rain.read() )
			{
				LOG4CXX_ERROR(logger, "Error reading rain file: " << rain.getDatPath());
				syslog(LOG_ERR, "Error reading rain file: %s.", rain.getDatPath().c_str());
				result = false;
			}

			// merge meteo grids
			Grid<float> meteo;
			meteo.setType(METEO_INPUT);
			meteo.setDate(args.getDate());
			meteo.setTable(temperature.getTable());
			meteo.setVarNum(0);

			meteo.merge(temperature);
			meteo.merge(humidity);
			meteo.merge(windspeed);
			meteo.merge(rain);
			//res.merge(snow_covering);
			//res.merge(snow_dissolution);

			// Do computation
			for( size_t j = 0; j < index_names.size(); j++ )
			{
				result = result & compute_index(index_names[j], &indexes, &meteo);
				if( !result )
				{
					//cout << "Error computing index " << index_names[j] << endl;
					LOG4CXX_ERROR(logger, "Error computing index " << index_names[j]);
					syslog(LOG_ERR, "Error computing index %s.", index_names[j].c_str());
					return result;
				}
			}

			Grid<float> angstrom;
			Grid<float> fmi;
			Grid<float> sharples;

			if( !(result = angstrom.configure("angstrom", cfg)) )
			{
				LOG4CXX_ERROR(logger, "Unable to configure angstrom grid");
				syslog(LOG_ERR, "Unable to configure angstrom grid");
				return result;
			}
			if( !(result = fmi.configure("fmi", cfg)) )
			{
				LOG4CXX_ERROR(logger, "Unable to configure fmi grid");
				syslog(LOG_ERR, "Unable to configure fmi grid");
				return result;
			}
			if( !(result = sharples.configure("sharples", cfg)) )
			{
				LOG4CXX_ERROR(logger, "Unable to configure sharples grid");
				syslog(LOG_ERR, "Unable to configure sharples grid");
				return result;
			}

			std::string filename = "";

			fieldnames.clear();
			fieldnames.push_back("angstrom");
			if( indexes.subgrid(fieldnames, angstrom) )
			{
				std::stringstream ss;
				ss << outpath24 << "/"
				   << setw(4) << setfill('0') << t.date().year()
				   << setw(2) << setfill('0') << t.date().month().as_number()
				   << setw(2) << setfill('0') << t.date().day().as_number()
				   << setw(2) << setfill('0') << t.time_of_day().hours()
				   << setw(2) << setfill('0') << t.time_of_day().minutes()
				   << setw(2) << setfill('0') << t.time_of_day().seconds() << "_angstrom_"
				   << setw(2) << setfill('0') << (i + 12) % 23 << ".txt";
				filename = ss.str();
				std::ofstream o(filename.c_str(), ios::trunc);
				angstrom.writeTxt(o, true);
				o.flush();
				o.close();
			}
			else
			{
				LOG4CXX_ERROR(logger, "Unable to get angstroem subgrid");
				syslog(LOG_ERR, "Unable to get angstroem subgrid");
				return false;
			}

			fieldnames.clear();
			fieldnames.push_back("fmi");
			if( indexes.subgrid(fieldnames, fmi) )
			{
				std::stringstream ss;
				ss << outpath24 << "/"
				   << setw(4) << setfill('0') << t.date().year()
				   << setw(2) << setfill('0') << t.date().month().as_number()
				   << setw(2) << setfill('0') << t.date().day().as_number()
				   << setw(2) << setfill('0') << t.time_of_day().hours()
				   << setw(2) << setfill('0') << t.time_of_day().minutes()
				   << setw(2) << setfill('0') << t.time_of_day().seconds() << "_fmi_"
				   << setw(2) << setfill('0') << (i + 12) % 23 << ".txt";
				filename = ss.str();
				std::ofstream o(filename.c_str(), ios::trunc);
				fmi.writeTxt(o, true);
				o.flush();
				o.close();
			}
			else
			{
				LOG4CXX_ERROR(logger, "Unable to get fmi subgrid");
				syslog(LOG_ERR, "Unable to get fmi subgrid");
				return false;
			}

			fieldnames.clear();
			fieldnames.push_back("sharples");
			if( indexes.subgrid(fieldnames, sharples) )
			{
				std::stringstream ss;
				ss << outpath24 << "/"
				   << setw(4) << setfill('0') << t.date().year()
				   << setw(2) << setfill('0') << t.date().month().as_number()
				   << setw(2) << setfill('0') << t.date().day().as_number()
				   << setw(2) << setfill('0') << t.time_of_day().hours()
				   << setw(2) << setfill('0') << t.time_of_day().minutes()
				   << setw(2) << setfill('0') << t.time_of_day().seconds() << "_sharples_"
				   << setw(2) << setfill('0') << (i + 12) % 23 << ".txt";
				filename = ss.str();
				std::ofstream o(filename.c_str(), ios::trunc);
				sharples.writeTxt(o, true);
				o.flush();
				o.close();
			}
			else
			{
				LOG4CXX_ERROR(logger, "Unable to get sharples subgrid");
				syslog(LOG_ERR, "Unable to get sharples subgrid");
				return false;
			}

			t = t + h;
		}
	}

	return result;
}

/**
 * \fn		bool export_snow_default(CommandLineArguments& args)
 * \brief	exports snow grids in default way for date in <i>args</i> from database
 * \param	args command line arguments class
 * \return	true on success else false
 * @see CommandLineArguments
 */
bool export_snow_default(CommandLineArguments& args)
{
	bool result = true;

	std::string table;
	std::vector<std::string> fieldnames;

	cfg.lookup("fwidbmgr.files.grads.temperature").lookupValue("table", table);

	Grid<float> res;
	res.setType(METEO_INPUT);
	res.setDate(args.getDate());
	res.setTable(table);
	res.setVarNum(0);

	result = retrieve_meteo_input(args, &res);

	// cum rain
	Grid<float> cum_rain;
	cum_rain.initialize();
	cum_rain.setType(NUMERIC);

	if( !cum_rain.configure("cum_rain", cfg) )
	{
		LOG4CXX_ERROR(logger, "Error: unable to configure cum_rain grid.");
		syslog(LOG_ERR, "Error: unable to configure cum_rain grid.");
		result = false;
	}
	cum_rain.setDate(args.getDate());

	fieldnames.push_back("cum_rain");
	if( !res.subgrid(fieldnames, cum_rain) )
	{
		LOG4CXX_ERROR(logger, "Error getting cum_rain subgrid from indexes");
		syslog(LOG_ERR, "Error getting cum_rain subgrid from indexes");
		result = false;
	}
	else
	{
		std::string date;
		std::string out_ctl;
		std::string out_dat;
		std::string cfgpath;
		date = args.getDate();
		out_ctl = cum_rain.getExportCtlPath();
		out_dat = cum_rain.getExportDatPath();

		if( cum_rain.getExpIOFormat() == GRD_FORMAT_BINARY )
		{
			out_ctl.replace(out_ctl.find(TAG_DATE), TAG_DATE_LEN, date);
			out_dat.replace(out_dat.find(TAG_DATE), TAG_DATE_LEN, date);
#ifdef __OPENSUSE_11_3__
			ofstream ctl(out_ctl.c_str(), ios::trunc);
#else
			ofstream ctl(out_ctl, ios::trunc);
#endif
			cum_rain.writeCtrl(ctl);
			ctl.close();

#ifdef __OPENSUSE_11_3__
			ofstream dat(out_dat.c_str(), ios::trunc | ios::binary);
#else
			ofstream dat(out_dat, ios::trunc | ios::binary);
#endif
			cum_rain.writeBin(dat);
#ifdef DEBUG
			cum_rain.raw_dump();
#endif
			dat.close();
		}
		else if( cum_rain.getExpIOFormat() == GRD_FORMAT_TEXT )
		{
			out_dat.replace(out_dat.find(TAG_DATE), TAG_DATE_LEN, date);
#ifdef __OPENSUSE_11_3__
			ofstream dat(out_dat.c_str(), ios::trunc);
#else
			ofstream dat(out_dat, ios::trunc);
#endif
			cum_rain.writeTxt(dat, true);
#ifdef DEBUG
			cum_rain.raw_dump();
#endif
			dat.close();
		}
	}

	fieldnames.clear();

	// snow covering
	Grid<float> snow_covering;
	snow_covering.initialize();
	snow_covering.setType(NUMERIC);

	if( !snow_covering.configure("snow_covering", cfg) )
	{
		LOG4CXX_ERROR(logger, "Error: unable to configure snow covering grid.");
		syslog(LOG_ERR, "Error: unable to configure snow covering grid.");
		result = false;
	}
	snow_covering.setDate(args.getDate());

	fieldnames.push_back("snow_covering");
	if( !res.subgrid(fieldnames, snow_covering) )
	{
		LOG4CXX_ERROR(logger, "Error getting snow_covering subgrid from indexes");
		syslog(LOG_ERR, "Error getting snow_covering subgrid from indexes");
		result = false;
	}
	else
	{
		std::string date;
		std::string out_ctl;
		std::string out_dat;
		std::string cfgpath;
		date = args.getDate();
		out_ctl = snow_covering.getExportCtlPath();
		out_dat = snow_covering.getExportDatPath();

		if( snow_covering.getExpIOFormat() == GRD_FORMAT_BINARY )
		{
			out_ctl.replace(out_ctl.find(TAG_DATE), TAG_DATE_LEN, date);
			out_dat.replace(out_dat.find(TAG_DATE), TAG_DATE_LEN, date);
#ifdef __OPENSUSE_11_3__
			ofstream ctl(out_ctl.c_str(), ios::trunc);
#else
			ofstream ctl(out_ctl, ios::trunc);
#endif
			snow_covering.writeCtrl(ctl);
			ctl.close();

#ifdef __OPENSUSE_11_3__
			ofstream dat(out_dat.c_str(), ios::trunc | ios::binary);
#else
			ofstream dat(out_dat, ios::trunc | ios::binary);
#endif
			snow_covering.writeBin(dat);
#ifdef DEBUG
			snow_covering.raw_dump();
#endif
			dat.close();
		}
		else if( snow_covering.getExpIOFormat() == GRD_FORMAT_TEXT )
		{
			out_dat.replace(out_dat.find(TAG_DATE), TAG_DATE_LEN, date);
#ifdef __OPENSUSE_11_3__
			ofstream dat(out_dat.c_str(), ios::trunc);
#else
			ofstream dat(out_dat, ios::trunc);
#endif
			snow_covering.writeTxt(dat, true, true);
#ifdef DEBUG
			snow_covering.raw_dump();
#endif
			dat.close();
		}
	}

	fieldnames.clear();

	// snow dissolution
	Grid<float> snow_dissolution;
	snow_dissolution.initialize();
	snow_dissolution.setType(NUMERIC);

	if( !snow_dissolution.configure("snow_dissolution", cfg) )
	{
		LOG4CXX_ERROR(logger, "Error: unable to configure snow dissolution grid.");
		syslog(LOG_ERR, "Error: unable to configure snow dissolution grid.");
		result = false;
	}
	snow_dissolution.setDate(args.getDate());

	fieldnames.push_back("snow_dissolution");
	if( !res.subgrid(fieldnames, snow_dissolution) )
	{
		LOG4CXX_ERROR(logger, "Error getting snow_dissolution subgrid from indexes");
		syslog(LOG_ERR, "Error getting snow_dissolution subgrid from indexes");
		result = false;
	}
	else
	{
		std::string date;
		std::string out_ctl;
		std::string out_dat;
		std::string cfgpath;
		date = args.getDate();
		out_ctl = snow_dissolution.getExportCtlPath();
		out_dat = snow_dissolution.getExportDatPath();

		if( snow_dissolution.getExpIOFormat() == GRD_FORMAT_BINARY )
		{
			out_ctl.replace(out_ctl.find(TAG_DATE), TAG_DATE_LEN, date);
			out_dat.replace(out_dat.find(TAG_DATE), TAG_DATE_LEN, date);
#ifdef __OPENSUSE_11_3__
			ofstream ctl(out_ctl.c_str(), ios::trunc);
#else
			ofstream ctl(out_ctl, ios::trunc);
#endif
			snow_dissolution.writeCtrl(ctl);
			ctl.close();

#ifdef __OPENSUSE_11_3__
			ofstream dat(out_dat.c_str(), ios::trunc | ios::binary);
#else
			ofstream dat(out_dat, ios::trunc | ios::binary);
#endif
			snow_dissolution.writeBin(dat);
#ifdef DEBUG
			snow_dissolution.raw_dump();
#endif
			dat.close();
		}
		else if( snow_dissolution.getExpIOFormat() == GRD_FORMAT_TEXT )
		{
			out_dat.replace(out_dat.find(TAG_DATE), TAG_DATE_LEN, date);
#ifdef __OPENSUSE_11_3__
			ofstream dat(out_dat.c_str(), ios::trunc);
#else
			ofstream dat(out_dat, ios::trunc);
#endif
			snow_dissolution.writeTxt(dat, true, true);
#ifdef DEBUG
			snow_dissolution.raw_dump();
#endif
			dat.close();
		}
	}

	fieldnames.clear();

	return result;
}

/**
 * \fn		bool export_snow_all(CommandLineArguments& args)
 * \brief	exports all snow grids for date in <i>args</i> from database
 * \param	args command line arguments class
 * \return	true on success else false
 * @see CommandLineArguments
 */
bool export_snow_all(CommandLineArguments& args)
{
	bool                     result = true;
	std::string              table;
	std::vector<std::string> fieldnames;
	std::string              old_date;
	std::string              d;
	std::string              d_1;
	boost::posix_time::ptime t;
	boost::posix_time::ptime t_1;
	std::stringstream        ss;

	// do default snow export
	LOG4CXX_INFO(logger, "Exporting snow default for " << args.getDate());
	result  = export_snow_default(args);

	// get day before args.date
	old_date = args.getDate();
	d        = args.getDate();
	d       += "T000000";
	t        = from_iso_string(d);
	t_1      = t - days(1);

	struct tm tm_1 = to_tm(t_1);
	int       yyyy = tm_1.tm_year + 1900;
	int       mm   = tm_1.tm_mon  + 1;
	ss << setw(4)                   << yyyy;
	ss << setw(2) << setfill('0') << mm;
	ss << setw(2) << setfill('0') << tm_1.tm_mday;
	d_1 = ss.str();

	cfg.lookup("fwidbmgr.files.grads.temperature").lookupValue("table", table);

	Grid<float> res;
	res.setType(METEO_INPUT);
	res.setDate(args.getDate());
	res.setTable(table);
	res.setVarNum(0);

	LOG4CXX_INFO(logger, "Retrieve meteo input for " << args.getDate());
	result = retrieve_meteo_input(args, &res);

	// snow
	Grid<float> snow;
	snow.initialize();
	snow.setType(NUMERIC);

	if( !snow.configure("snow", cfg) )
	{
		LOG4CXX_ERROR(logger, "Error: unable to configure snow grid.");
		syslog(LOG_ERR, "Error: unable to configure snow grid.");
		result = false;
	}
	snow.setDate(args.getDate());

	fieldnames.push_back("snow");
	if( !res.subgrid(fieldnames, snow) )
	{
		LOG4CXX_ERROR(logger, "Error getting snow subgrid from indexes");
		syslog(LOG_ERR, "Error getting snow subgrid from indexes");
		result = false;
	}
	else
	{
		std::string date;
		std::string out_ctl;
		std::string out_dat;
		std::string cfgpath;
		date = args.getDate();
		out_ctl = snow.getExportCtlPath();
		out_dat = snow.getExportDatPath();

		if( snow.getExpIOFormat() == GRD_FORMAT_BINARY )
		{
			out_ctl.replace(out_ctl.find(TAG_DATE), TAG_DATE_LEN, date);
			out_dat.replace(out_dat.find(TAG_DATE), TAG_DATE_LEN, date);
#ifdef __OPENSUSE_11_3__
			ofstream ctl(out_ctl.c_str(), ios::trunc);
#else
			ofstream ctl(out_ctl, ios::trunc);
#endif
			snow.writeCtrl(ctl);
			ctl.close();

#ifdef __OPENSUSE_11_3__
			ofstream dat(out_dat.c_str(), ios::trunc | ios::binary);
#else
			ofstream dat(out_dat, ios::trunc | ios::binary);
#endif
			snow.writeBin(dat);
#ifdef DEBUG
			snow.raw_dump();
#endif
			dat.close();
		}
		else if( snow.getExpIOFormat() == GRD_FORMAT_TEXT )
		{
			out_dat.replace(out_dat.find(TAG_DATE), TAG_DATE_LEN, date);
#ifdef __OPENSUSE_11_3__
			ofstream dat(out_dat.c_str(), ios::trunc);
#else
			ofstream dat(out_dat, ios::trunc);
#endif
			snow.writeTxt(dat, true, true);
#ifdef DEBUG
			snow.raw_dump();
#endif
			dat.close();
		}
	}

	fieldnames.clear();

	res.initialize();
	args.setDate(d_1);
	res.setDate(args.getDate());
	res.setTable(table);
	res.setVarNum(0);

	// do default snow export
	LOG4CXX_INFO(logger, "Exporting snow default for " << args.getDate());
	result  = export_snow_default(args);

	LOG4CXX_INFO(logger, "Retrieve meteo input for " << args.getDate());
	result = retrieve_meteo_input(args, &res);

	snow.initialize();
	snow.setType(NUMERIC);

	if( !snow.configure("snow", cfg) )
	{
		LOG4CXX_ERROR(logger, "Error: unable to configure snow grid.");
		syslog(LOG_ERR, "Error: unable to configure snow grid.");
		result = false;
	}
	snow.setDate(args.getDate());

	fieldnames.push_back("snow");
	if( !res.subgrid(fieldnames, snow) )
	{
		LOG4CXX_ERROR(logger, "Error getting snow subgrid from indexes");
		syslog(LOG_ERR, "Error getting snow subgrid from indexes");
		result = false;
	}
	else
	{
		std::string date;
		std::string out_ctl;
		std::string out_dat;
		std::string cfgpath;
		date = args.getDate();
		out_ctl = snow.getExportCtlPath();
		out_dat = snow.getExportDatPath();

		if( snow.getExpIOFormat() == GRD_FORMAT_BINARY )
		{
			out_ctl.replace(out_ctl.find(TAG_DATE), TAG_DATE_LEN, date);
			out_dat.replace(out_dat.find(TAG_DATE), TAG_DATE_LEN, date);
#ifdef __OPENSUSE_11_3__
			ofstream ctl(out_ctl.c_str(), ios::trunc);
#else
			ofstream ctl(out_ctl, ios::trunc);
#endif
			snow.writeCtrl(ctl);
			ctl.close();

#ifdef __OPENSUSE_11_3__
			ofstream dat(out_dat.c_str(), ios::trunc | ios::binary);
#else
			ofstream dat(out_dat, ios::trunc | ios::binary);
#endif
			snow.writeBin(dat);
#ifdef DEBUG
			snow.raw_dump();
#endif
			dat.close();
		}
		else if( snow.getExpIOFormat() == GRD_FORMAT_TEXT )
		{
			out_dat.replace(out_dat.find(TAG_DATE), TAG_DATE_LEN, date);
#ifdef __OPENSUSE_11_3__
			ofstream dat(out_dat.c_str(), ios::trunc);
#else
			ofstream dat(out_dat, ios::trunc);
#endif
			snow.writeTxt(dat, true, true);
#ifdef DEBUG
			snow.raw_dump();
#endif
			dat.close();
		}
	}

	fieldnames.clear();

	args.setDate(old_date);

	return result;
}

bool update_snow(CommandLineArguments args)
{
	bool result = true;

	const char* paramValues [3];
	int         paramLengths[3];
	int         paramFormats[3];
	PGresult*   res        = NULL;
	std::string snow_image = "";
	char*       snow_bytea = NULL;
	int         snow_size  = 0;

	// snow
	Grid<float> snow;
	snow.initialize();
	snow.setType(NUMERIC);
	snow.setDate(args.getDate());

	if( !snow.configure("snow", cfg) )
	{
		cout << "Error: unable to configure snow grid." << endl;
		syslog(LOG_ERR, "Error: unable to configure snow grid.");
		result = false;
	}
	snow.setDate(args.getDate());

	if( snow.read() )
	{
		LOG4CXX_INFO(logger, "Snow grid on " << args.getDate() << " read.");
		if( PQstatus(conn) != CONNECTION_BAD )
		{
			if( snow.store(conn) )
			{
				LOG4CXX_INFO(logger, "Snow grid on " << args.getDate() << " updated.");
			}
			else
			{
				LOG4CXX_ERROR(logger, "Unable to update snow for " << args.getDate());
				syslog(LOG_ERR, "Unable to update snow for %s.", args.getDate().c_str());
				result = false;
			}
		}
		else
		{
			LOG4CXX_FATAL(logger, "Bad database connection.");
			syslog(LOG_CRIT, "Bad database connection.");
			result = false;
		}
	}

	if( !cfg.lookupValue("fwidbmgr.files.images.snow", snow_image) )
	{
		LOG4CXX_ERROR(logger, "Unable to get snow image path.");
		syslog(LOG_ERR, "Unable to get snow image path.");
		return false;
	}
	else
	{
		snow_image.replace(snow_image.find(TAG_DATE), TAG_DATE_LEN, args.getDate());
		// get snow image contents
		if( !getFileBytea(snow_image, &snow_bytea, snow_size) )
		{
			LOG4CXX_ERROR(logger, "Unable to load " << snow_image << " contents.");
			syslog(LOG_ERR, "Unable to load %s contents.", snow_image.c_str());
			return false;
		}
	}

	/* Set up parameter arrays for PQexecParams */
	paramValues[0]  = args.getDate().c_str();
	paramLengths[0] = args.getDate().size();
	paramFormats[0] = 0;        /* text */

	paramValues[1]  = snow_image.c_str();
	paramLengths[1] = snow_image.size();
	paramFormats[1] = 0;		/* text */

	paramValues[2]  = snow_bytea;
	paramLengths[2] = snow_size;
	paramFormats[2] = 1;		/* binary */

	res = PQexecParams(conn,
					   "UPDATE images SET (dt, snow, snow_bytea) = ($1::date, $2::varchar, $3::bytea) where dt = $1::date",
					   3,       /* one param */
					   NULL,    /* let the backend deduce param type */
					   paramValues,
					   paramLengths,
					   paramFormats,
					   1);      /* ask for binary results */

	if (PQresultStatus(res) != PGRES_COMMAND_OK)
	{
		//fprintf(stderr, "Command failed: %s", PQerrorMessage(conn));
		LOG4CXX_ERROR(logger, "Command failed: " << PQerrorMessage(conn));
		syslog(LOG_ERR, "Command failed: %s.", PQerrorMessage(conn));
		PQclear(res);
		result = false;
	}

	return result;
}


//#ifdef DEBUG
void test(CommandLineArguments& args)
{
	std::stringstream ss;
	std::string   dd = "2002-11-01 00:00:00.0000";
	ptime         t(time_from_string(dd));
	LOG4CXX_INFO(logger, "date: " << to_iso_extended_string(t));
	time_duration dt = duration_from_string("13:00");

	ss << "time duration: " << setw(2) << setfill('0') << dt.hours() << ":" << setw(2) << setfill('0') << dt.minutes() << ":" << setw(2) << setfill('0') << dt.seconds();

	LOG4CXX_INFO(logger, ss.str());
	time_duration h(1, 0, 0, 0);
	ss.str("");
	ss.clear();
	ss << "delta time: " << setw(2) << setfill('0') << h.hours() << ":" << setw(2) << setfill('0') << h.minutes() << ":" << setw(2) << setfill('0') << h.seconds();
	LOG4CXX_INFO(logger, ss.str());
	ss.str("");
	ss.clear();

	// Set start time to
	t = t + hours(dt.hours());
	LOG4CXX_INFO(logger, "date: " << to_iso_extended_string(t));


	/*
	Grid<float> indexes;
	std::string datPath     = "";
	std::string export_path = "";

	if( !cfg.lookupValue("fwidbmgr.paths.export", export_path) )
	{
		cout << "Error retrieving export path." << endl;
	}

	if( !retrieve_fwi_indexes(args, &indexes) )
	{
		cout << "Error retrieving indexes for " << args.getDate() << endl;
	}

	std::vector<std::string> idx;
	if( !load_computation_indexes(idx) )
	{
		cout << "Unable to retrieve indexes list" << endl;
	}

	cout << " exporting new indexes" << endl;

	for( size_t i = 0; i < idx.size(); i++ )
	{
		std::vector<std::string> fieldNames;
		fieldNames.push_back(idx[i]);
		Grid<float> sg;
		indexes.subgrid(fieldNames, sg);

		//datPath = "/home/buck/dev/arpa/data/export/" + idx[i] + "_" + args.getDate() + ".txt";
		datPath = export_path + "/" + idx[i] + "_" + args.getDate() + ".txt";

		cout << datPath << endl;

		sg.setDatPath(datPath);
		ofstream o;
		o.open(sg.getDatPath().c_str());
		sg.writeTxt(o, true);
		o.close();

		fieldNames.clear();
	}
    */

	/*std::vector<std::string> lines;

	for( int i = 0; i < 8; i++ )
	{
		lines.push_back(*new std::string());
	}

	std::back_insert_iterator<std::string> iterator_dset(lines[0]);
	std::back_insert_iterator<std::string> iterator_title(lines[1]);
	std::back_insert_iterator<std::string> iterator_undef(lines[2]);
	std::back_insert_iterator<std::string> iterator_xdef(lines[3]);
	std::back_insert_iterator<std::string> iterator_ydef(lines[4]);
	std::back_insert_iterator<std::string> iterator_zdef(lines[5]);
	std::back_insert_iterator<std::string> iterator_tdef(lines[6]);
	std::back_insert_iterator<std::string> iterator_vars(lines[7]);

	Grid<float> grid;
	grid.setVarNum(TEMPERATURE_FIELDSNUM);
	grid.initialize();
	grid.setDate(args.getDate());

	if( grid.configure("temperature", cfg) )
	{
		std::string ctlpath = grid.getExportCtlPath();

		size_t pos = ctlpath.find("<<date>>");

		if( pos != ctlpath.npos )
		{
			ctlpath.replace(pos, 8, grid.getDate());
			grid.setExportCtlPath(ctlpath);
		}

		if( generate_dset(iterator_dset, grid) )
		{
			cout << "dset generated: " << lines[0].c_str() << endl;
		}
		else
		{
			cout << "ERROR generating dset" << endl;
		}

		if( generate_title(iterator_title, grid) )
		{
			cout << "title generated: " << lines[1].c_str() << endl;
		}
		else
		{
			cout << "ERROR generating title" << endl;
		}

		if( generate_undef(iterator_undef, grid) )
		{
			cout << "undef value generated: " << lines[2].c_str() << endl;
		}
		else
		{
			cout << "ERROR generating undef value" << endl;
		}

		if( generate_xdef(iterator_xdef, grid) )
		{
			cout << "xdef generated: " << lines[3].c_str() << endl;
		}
		else
		{
			cout << "ERROR generating xdef" << endl;
		}

		if( generate_ydef(iterator_ydef, grid) )
		{
			cout << "ydef generated: " << lines[4].c_str() << endl;
		}
		else
		{
			cout << "ERROR generating ydef" << endl;
		}

		if( generate_zdef(iterator_zdef, grid) )
		{
			cout << "zdef generated: " << lines[5].c_str() << endl;
		}
		else
		{
			cout << "ERROR generating ydef" << endl;
		}
		if( generate_tdef(iterator_tdef, grid) )
		{
			cout << "tdef generated: " << lines[6].c_str() << endl;
		}
		else
		{
			cout << "ERROR generating tdef" << endl;
		}
		if( generate_vars(iterator_vars, *(grid.getFields())) )
		{
			cout << "vars generated: " << lines[7].c_str() << endl;
		}
		else
		{
			cout << "ERROR generating vars" << endl;
		}
	}*/


	/*if( !store_images(conn, cfg, args) )
	{
		LOG4CXX_ERROR(logger, "Unable to store images.");
	}*/

	/*if( !import_provinces(conn, cfg) )
	{
		cout << "Error importing regions." << endl;
	}*/



	/*Grid<float> snow_covering;
	snow_covering.setVarNum(1);
	snow_covering.initialize();
	snow_covering.setType(NUMERIC);
	snow_covering.setDate(args.getDate());

	string path = "";
	size_t pos  = -1;

	if( snow_covering.configure("snow_covering", cfg) )
	{
		string path = snow_covering.getDatPath();
		size_t pos  = path.find("<<date>>");

		if( pos != path.npos )
		{
			path.replace(pos, 8, args.getDate());
			snow_covering.setDatPath(path);
		}

		ifstream is(snow_covering.getDatPath());
		if( !snow_covering.readTxt(is) )
		{
			cout << "Error: unable to read txt file." << endl;
			return;
		}
		is.close();
	}

	Grid<float> snow_dissolution;
	snow_dissolution.setVarNum(1);
	snow_dissolution.initialize();
	snow_dissolution.setType(NUMERIC);
	snow_dissolution.setDate(args.getDate());

	path = "";
	pos  = -1;

	if( snow_dissolution.configure("snow_dissolution", cfg) )
	{
		path = snow_dissolution.getDatPath();
		pos  = path.find("<<date>>");

		if( pos != path.npos )
		{
			path.replace(pos, 8, args.getDate());
			snow_dissolution.setDatPath(path);
		}

		ifstream is(snow_dissolution.getDatPath());
		if( !snow_dissolution.readTxt(is) )
		{
			cout << "Error: unable to read txt file." << endl;
			return;
		}
		is.close();
	}

	Grid<float> temperature;
	temperature.setVarNum(TEMPERATURE_FIELDSNUM);
	temperature.initialize();
	temperature.setType(NUMERIC);
	temperature.setDate(args.getDate());
	Grid<float> humidity;
	humidity.setVarNum(HUMIDITY_FIELDSNUM);
	humidity.initialize();
	humidity.setType(NUMERIC);
	humidity.setDate(args.getDate());
	Grid<float> windspeed;
	windspeed.setVarNum(WINDSPEED_FIELDSNUM);
	windspeed.initialize();
	windspeed.setType(NUMERIC);
	windspeed.setDate(args.getDate());
	Grid<float> rain;
	rain.setVarNum(CUMRAIN_FIELDSNUM);
	rain.initialize();
	rain.setType(NUMERIC);
	rain.setDate(args.getDate());


	if( temperature.configure("temperature", cfg) )
	{
		if( !temperature.read() )
		{
			cout << "Error: unable to read dat file." << endl;
			return;
		}
	}
	if( humidity.configure("humidity", cfg) )
	{
		if( !humidity.read() )
		{
			cout << "Error: unable to read dat file." << endl;
			return;
		}
	}
	if( windspeed.configure("windspeed", cfg) )
	{
		if( !windspeed.read() )
		{
			cout << "Error: unable to read dat file." << endl;
			return;
		}
	}
	if( rain.configure("rain", cfg) )
	{
		if( !rain.read() )
		{
			cout << "Error: unable to read dat file." << endl;
			return;
		}
	}

	Grid<float> res;
	res.setType(NUMERIC);
	res.setDate(args.getDate());
	res.setTable(temperature.getTable());
	res.setVarNum(0);

	res.merge(temperature);
	res.merge(humidity);
	res.merge(windspeed);
	res.merge(rain);
	res.merge(snow_covering);
	res.merge(snow_dissolution);

	//res.raw_dump();

	//res.store(conn);

	//res.init(0.0);

	res.retrieve(conn);

	//cout << res;

	return;

	*/

	/*Grid<float> grid(GRD_ROWS, GRD_COLS);
	grid.setVarNum(TOPOGRAPHY_FIELDSNUM);
	grid.initialize();
	grid.setType(NUMERIC);
	if( grid.configure("topography", cfg) )
	{
		if( !grid.readDat() )
		{
			cout << "Error: unable to read dat file." << endl;
		}
	}
	else
	{
		cout << "Error configuring grid" << endl;
	}*/
}

//#endif

/**
 * \brief main function
 * @see usage()
 */
int main(int argc, char** argv)
{
	CommandLineArguments args;  		// command line arguments
	std::string          home;			// application home folder
	std::string          str_setting;	// setting of string type
	int                  int_setting;	// setting of int type
	std::string          cfgpath;       // config file absolute path
	struct tm            tp;			// struct tm

	setlogmask(LOG_UPTO (LOG_NOTICE));
	openlog("AIB", LOG_CONS | LOG_PID |LOG_NDELAY, LOG_LOCAL1);
	syslog(LOG_NOTICE, "FWIDBMGR started by User %d", getuid());

	try
	{
		// Set up a simple configuration that logs on the console.
		// BasicConfigurator::configure();
		cfgpath  = getProgramHome();
		cfgpath += "/config/LogConfig.xml";
		DOMConfigurator::configure(cfgpath);
		logger->setLevel(log4cxx::Level::getInfo());
	}
	catch(Exception&)
	{
		cout << "Unable to setup logging configuration." << endl;
		exit(EXIT_FAILURE);
	}

	LOG4CXX_INFO(logger, "fwi db manager");
	syslog(LOG_INFO, "fwi db manager");
	home = getProgramHome();

	LOG4CXX_INFO(logger, "Program home: " << home);
	syslog(LOG_INFO, "Program home: %s", home.c_str());

	cfg.setAutoConvert(true);
	LOG4CXX_INFO(logger, "Auto convert: " << cfg.getAutoConvert());
	syslog(LOG_INFO, "Auto convert: %d", cfg.getAutoConvert());

	if( !process_cmd_line(argc, argv, &args) )
	{
		LOG4CXX_FATAL(logger, "Unable to parse command line arguments.");
		cout << "Unable to parse command line arguments." << endl;
		syslog(LOG_CRIT, "Unable to parse command line arguments.");
		closelog();
		exit(EXIT_FAILURE);
	}
	else
	{
		if( default_config )
		{
			if( !readConfig() )
			{
				LOG4CXX_FATAL(logger, "ERROR: unable to read config file.");
				syslog(LOG_CRIT, "ERROR: unable to read config file.");
				closelog();
				exit(-1);
			}
			else
			{
				LOG4CXX_INFO(logger, "Configuration parsing: OK.");
				syslog(LOG_NOTICE, "Configuration parsing: OK.");
			}
		}
		if( args.isSetHelp() )
		{
			closelog();
			exit(EXIT_SUCCESS);
		}
		if( !args.isSetDate() )
		{
			char dt[11];
			bzero(&dt, 11);
			// date not set: get current;
			time_t t;
			time(&t);
			struct tm* tp = localtime(&t);
			strftime(dt, 11, "%Y-%m-%d", tp);
			args.setDate(dt);
			LOG4CXX_INFO(logger, "Date not set, got current: " << dt << ".");
			syslog(LOG_NOTICE, "Date not set, got current: %s", dt);
		}
		if( !args.isSetDbName() )
		{
			if( cfg.lookupValue("fwidbmgr.dbconnection.dbname", str_setting) )
			{
				args.setDbName(str_setting.c_str());
			}
			else
			{
				args.setDbName("fwidb");
			}
		}
		if( !args.isSetHost() )
		{
			if( cfg.lookupValue("fwidbmgr.dbconnection.host", str_setting) )
			{
				args.setHost(str_setting.c_str());
			}
			else
			{
				args.setHost("localhost");
			}
		}
		if( !args.isSetPort() )
		{
			if( cfg.lookupValue("fwidbmgr.dbconnection.port", int_setting) )
			{
				args.setPort(int_setting);
			}
			else
			{
				args.setPort(5432);
			}
		}
		if( !args.isSetUser() )
		{
			if( cfg.lookupValue("fwidbmgr.dbconnection.user", str_setting) )
			{
				args.setUser(str_setting.c_str());
			}
			else
			{
				args.setUser("meteo");
			}
		}
		if( !args.isSetPassword() )
		{
			if( cfg.lookupValue("fwidbmgr.dbconnection.password", str_setting) )
			{
				args.setPassword(str_setting.c_str());
			}
			else
			{
				args.setPassword("meteo");
			}
		}

		if( args.canTryDbConnection() )
		{
			if( argc > 1 )
			{
				conn = args.getPGConnection(cfg, args.getAction() == "create");
				if( PQstatus(conn) != CONNECTION_BAD )
				{
					LOG4CXX_INFO(logger, "Connected to database");
					syslog(LOG_NOTICE, "Connected to database");
					LOG4CXX_INFO(logger, "Manage data for date: " << args.getDate() << ".");
					syslog(LOG_NOTICE, "Manage data for date: %s.", args.getDate().c_str());
					tp = parseDate(args.getDate());
					tp.tm_hour = 0;

					ptime begin(second_clock::local_time());

					if( args.getAction() == ACTION_CREATE )
					{
						LOG4CXX_INFO(logger, "Must create database.");
						syslog(LOG_NOTICE, "Must create database.");
						if( create_database(/*conn, cfg*/) )
						{
							LOG4CXX_INFO(logger, "fwi database created.");
							syslog(LOG_NOTICE, "fwi database created.");
						}
						else
						{
							LOG4CXX_FATAL(logger, "ERROR: unable to create fwi database.");
							syslog(LOG_CRIT, "ERROR: unable to create fwi database.");
							closelog();
							exit(FAILURE);
						}
						LOG4CXX_INFO(logger, "Now fill its structure.");
						syslog(LOG_NOTICE, "Now fill its structure.");
						args.closePGConnection();
						conn = args.getPGConnection(cfg);
						if( fill_database(/*conn, cfg*/) )
						{
							LOG4CXX_INFO(logger, "Database structure filled.");
							syslog(LOG_NOTICE, "Database structure filled.");
						}
						else
						{
							LOG4CXX_FATAL(logger, "ERROR: unable to fill database structure.");
							syslog(LOG_CRIT, "ERROR: unable to fill database structure.");
						}
					}
					else if( args.getAction() == ACTION_CREATE_STD_GRID )
					{
						LOG4CXX_INFO(logger, "Must create standard 177x174 point grid.");
						syslog(LOG_NOTICE, "Must create standard 177x174 point grid.");
						if( !create_standard_grid(/*conn, cfg*/) )
						{
							LOG4CXX_FATAL(logger, "Unable to create standard grid.");
							syslog(LOG_CRIT, "Unable to create standard grid.");
						}
						else
						{
							LOG4CXX_INFO(logger, "Standard grid created.");
							syslog(LOG_NOTICE, "Standard grid created.");
						}
					}
					else if( args.getAction() == ACTION_IN )
					{

						LOG4CXX_INFO(logger, "Importing meteo data in database for day: " << args.getDate() << ".");
						syslog(LOG_NOTICE, "Importing meteo data in database for day: %s.", args.getDate().c_str());
						if( store_meteo_input(/*conn, cfg,*/ args) )
						{
							LOG4CXX_INFO(logger, "OK --> " << args.getDate() << " data imported.");
							syslog(LOG_NOTICE, "OK --> %s data imported.", args.getDate().c_str());
						}
						else
						{
							LOG4CXX_FATAL(logger, "ERROR --> " << args.getDate() << " data not imported.");
							syslog(LOG_CRIT, "ERROR --> %s data not imported.", args.getDate().c_str());
						}
					}
					else if( args.getAction() == ACTION_OUT )
					{
						LOG4CXX_INFO(logger, "Importing fwi indexes data in database for day: " << args.getDate() << ".");
						syslog(LOG_NOTICE, "Importing fwi indexes data in database for day: %s.", args.getDate().c_str());
						if( store_fwi_indexes(/*conn, cfg,*/ args) )
						{
							LOG4CXX_INFO(logger, "OK --> " << args.getDate() << " data imported.");
							syslog(LOG_NOTICE, "OK --> %s data imported.", args.getDate().c_str());
						}
						else
						{
							LOG4CXX_FATAL(logger, "ERROR --> " << args.getDate() << " data not imported.");
							syslog(LOG_CRIT, "ERROR --> %s data not imported.", args.getDate().c_str());
						}
					}
					else if( args.getAction() == ACTION_OUT_IMG )
					{
						LOG4CXX_INFO(logger, "Importing fwi indexes images in database.");
						syslog(LOG_NOTICE, "Importing fwi indexes images in database.");
						if( store_images(/*conn, cfg,*/ args) )
						{
							LOG4CXX_INFO(logger, "OK --> " << args.getDate() << " images imported.");
							syslog(LOG_NOTICE, "OK --> %s images imported.", args.getDate().c_str());
						}
						else
						{
							LOG4CXX_FATAL(logger, "ERROR --> " << args.getDate() << " images not imported.");
							syslog(LOG_CRIT, "ERROR --> %s images not imported.", args.getDate().c_str());
						}
					}
					else if( args.getAction() == ACTION_EXPORT_IMAGES )
					{
						LOG4CXX_INFO(logger, "Exporting images");
						syslog(LOG_NOTICE, "Exporting images");
						if( export_images(args) )
						{
							LOG4CXX_INFO(logger, "OK --> " << args.getDate() << " images exported to files.");
							syslog(LOG_NOTICE, "OK --> %s images exported to files.", args.getDate().c_str());
						}
						else
						{
							LOG4CXX_FATAL(logger, "ERROR --> " << args.getDate() << " images not exported to files.");
							syslog(LOG_CRIT, "ERROR --> %s images not exported to files.", args.getDate().c_str());
						}
					}
					else if( args.getAction() == ACTION_EXPORT_INDEXES )
					{
						LOG4CXX_INFO(logger, "Exporting indexes.");
						syslog(LOG_NOTICE, "Exporting indexes.");
						if( export_indexes(/*conn, cfg,*/ args) )
						{
							LOG4CXX_INFO(logger, "OK --> " << args.getDate() << " indexes exported to files.");
							syslog(LOG_NOTICE, "OK --> %s indexes exported to files.", args.getDate().c_str());
						}
						else
						{
							LOG4CXX_FATAL(logger, "ERROR --> " << args.getDate() << " indexes not exported to files.");
							syslog(LOG_CRIT, "ERROR --> %s indexes not exported to files.", args.getDate().c_str());
						}
					}
					else if( args.getAction() == ACTION_EXPORT_SNOW_DEFAULT )
					{
						LOG4CXX_INFO(logger, "Exporting snow in default way.");
						syslog(LOG_NOTICE, "Exporting snow in default way.");
						if( export_snow_default(args) )
						{
							LOG4CXX_INFO(logger, "OK --> " << args.getDate() << " snow exported to files in default way.");
							syslog(LOG_NOTICE, "OK --> %s snow exported to files in default way.", args.getDate().c_str());
						}
						else
						{
							LOG4CXX_FATAL(logger, "ERROR --> " << args.getDate() << " snow not exported to files in default way.");
							syslog(LOG_CRIT, "ERROR --> %s snow not exported to files in default way.",args.getDate().c_str());
						}
					}
					else if( args.getAction() == ACTION_EXPORT_SNOW_ALL )
					{
						LOG4CXX_INFO(logger, "Exporting all snow.");
						syslog(LOG_NOTICE, "Exporting all snow.");
						if( export_snow_all(args) )
						{
							LOG4CXX_INFO(logger, "OK --> " << args.getDate() << " all snow exported to files.");
							syslog(LOG_NOTICE, "OK --> %s all snow exported to files.", args.getDate().c_str());
						}
						else
						{
							LOG4CXX_FATAL(logger, "ERROR --> " << args.getDate() << " all snow not exported to files.");
							syslog(LOG_CRIT, "ERROR --> %s all snow not exported to files.", args.getDate().c_str());
						}
					}
					else if( args.getAction() == ACTION_UPDATE_SNOW )
					{
						LOG4CXX_INFO(logger, "Updating snow.");
						syslog(LOG_NOTICE, "Updating snow.");
						if( update_snow(args) )
						{
							LOG4CXX_INFO(logger, "OK --> " << args.getDate() << " snow updated.");
							syslog(LOG_NOTICE, "OK --> %s snow updated.", args.getDate().c_str());
						}
						else
						{
							LOG4CXX_FATAL(logger, "ERROR --> " << args.getDate() << "snow not updated.");
							syslog(LOG_CRIT, "ERROR --> %s snow not updated.", args.getDate().c_str());
						}
					}
					else if( args.getAction() == ACTION_COMPUTE_INDEXES )
					{
						LOG4CXX_INFO(logger, "Computing indexes.");
						syslog(LOG_NOTICE, "Computing indexes.");
						if( compute_indexes(args) )
						{
							LOG4CXX_INFO(logger, "OK --> " << args.getDate() << " indexes computed.");
							syslog(LOG_NOTICE, "OK --> %s indexes computed.", args.getDate().c_str());
						}
						else
						{
							LOG4CXX_FATAL(logger, "ERROR --> " << args.getDate() << " indexes not computed.");
							syslog(LOG_CRIT, "ERROR --> %s indexes not computed.", args.getDate().c_str());
						}
					}
					else if( args.getAction() == ACTION_COMPUTE_INDEXES_24 )
					{
						LOG4CXX_INFO(logger, "computing indexes 24.");
						syslog(LOG_NOTICE, "computing indexes 24.");
						if( compute_indexes_24(args) )
						{
							LOG4CXX_INFO(logger, "OK --> " << args.getDate() << " indexes computed for 24 time slots.");
							syslog(LOG_NOTICE, "OK --> %s indexes computed for 24 time slots.", args.getDate().c_str());
						}
						else
						{
							LOG4CXX_FATAL(logger, "ERROR --> " << args.getDate() << " indexes 24 not computed.");
							syslog(LOG_CRIT, "ERROR --> %s indexes 24 not computed.", args.getDate().c_str());
						}
					}
	//#ifdef DEBUG
					else if( args.getAction() == ACTION_TEST )
					{
						test(args);
					}
	//#endif
					ptime end(second_clock::local_time());

					time_period duration(begin, end);
					std::string total_seconds = boost::lexical_cast<std::string, int>(duration.length().total_seconds());

					LOG4CXX_INFO(logger, "action " << args.getAction() << " took about " << total_seconds << " seconds.");
					syslog(LOG_NOTICE, "action %s took about %s seconds.", args.getAction().c_str(), total_seconds.c_str());

					args.closePGConnection();
					LOG4CXX_INFO(logger, "Disconnected from database.");
					syslog(LOG_NOTICE, "Disconnected from database.");
				}
			}
			else
			{
				LOG4CXX_INFO(logger, "Please view usage info.");
				syslog(LOG_INFO, "Please view usage info.");
			}
		}
		else
		{
			LOG4CXX_WARN(logger, "Please control your db connection parameters.");
			syslog(LOG_WARNING, "Please control your db connection parameters.");
		}
	}

	syslog(LOG_NOTICE, "FWIDBMGR ended.");
	closelog();

	return EXIT_SUCCESS;
}