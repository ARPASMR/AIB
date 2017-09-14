/*
 * Grid.h
 *
 *  Created on: 25/mar/2012
 *      Author: buck
 */

/**
 * \file	Grid.h
 * \brief	2-dimensions grid class
 */

#ifndef GRID_H_
#define GRID_H_

#include "fwi_define.h"
#include "GridField.h"

#include <iostream>
#include <fstream>
#include <vector>
#include <list>
#include <map>

#include <geos/geom/Point.h>

#include "boost/multi_array.hpp"

// boost ptime support
#include "boost/date_time/posix_time/posix_time.hpp" //include all types plus i/o
#include <boost/date_time/date_facet.hpp>

#include<cassert>

extern log4cxx::LoggerPtr logger;

//#define __OPENSUSE_11_3__
//#undef __OPENSUSE_11_3__

// postgresql support
#ifdef __OPENSUSE_11_3__
#include <pgsql/libpq-fe.h>
#else
#include <libpq-fe.h>
#endif

namespace fwi{ namespace grid { template<typename T> class Grid; } }

#include <ctlgen.hpp>

using namespace boost;
using namespace boost::posix_time;
using namespace boost::gregorian;

using namespace geos::geom;

namespace fwi
{
	namespace grid
	{
		using namespace libconfig;
		using namespace fwi::generators;

		/* \typedef	enum { INCREASING = 0, DECREASING = 1 } COORDINATE_DIRECTION
		 * \brief	How coordinate varies reading grid from file
		 */
		typedef enum { INCREASING = 0, DECREASING = 1 } COORDINATE_DIRECTION;

		/**
		 * \class	Grid
		 * \brief	3-dimensional grid
		 */
		template<typename T>
		class Grid
		{

		private:

			/**
			 * \var	int cols
			 * \brief	columns number
			 */
			int                  cols;

			/**
			 * \var		int rows
			 * \brief	rows number
			 */
			int                  rows;

			/**
			 * \var		std::string table
			 * \brief	database table
			 */
			std::string          table;

			/**
			 * \var		std::string date
			 * \brief	data date
			 */
			std::string          date;

			/**
			 * \var		std::string ctlpath
			 * \brief	ctl file path
			 */
			std::string          ctlpath;

			/**
			 * \var		std::string datpath
			 * \brief	dat file path
			 */
			std::string          datpath;

			/**
			 * \var		std::string expctlpath
			 * \brief	export ctl file path
			 */
			std::string			 expctlpath;

			/**
			 * \var		std::string expdatpath
			 * \brief	export dat file path
			 */
			std::string			 expdatpath;

			/**
			 * \var		std::string title;
			 * \brief   short data description (see TITLE in grib files)
			 */
			std::string          title;

			/**
			 * \var		int type
			 * \brief	grid type
			 */
			int                  type;

			/**
			 * \var		int timeBand
			 * \brief	time band
			 */
			int                  timeBand;

			/**
			 * \var		int timeBandsNumber
			 * \brief   grid time bands number
			 */
			int					 timeBandsNumber;

			/**
			 * \var		std::string startTime
			 * \brief	grid start time
			 *
			 * Must be specified in GrADS absolute time format:
			 * <i>hh:mm</i>
			 * where:
			 * + <i>hh</i> = hour (two digit integer)
			 * + <i>mm</i> = minute (two digit integer);
			 * @see		http://www.iges.org/grads/
			 */
			std::string          startTime;

			/**
			 * \var		std::string timeIncrement
			 * \brief	grid time increment as specified in GrADS absolute time increment format
			 *
			 *     <i>vvkk</i>
			 *     where:
			 *
			 *     <i>vv</i> = an integer number, 1 or 2 digits
			 *     <i>kk</i> = <b>mn</b> (minute)
			 *                 <b>hr</b> (hour)
			 *                 <b>dy</b> (day)
			 *                 <b>mo</b> (month)
			 *                 <b>yr</b> (year)
			 * @see		http://www.iges.org/grads/
			 */
			std::string          timeIncrement;

			/**
			 * \var				 int fileNameDateOffset
			 * \brief			 file name date offset expressed in day (can be negative)
			 * 					 versus fwidbmgr -d date switch.
			 * 					 (ex. given d the date in the indexes file names the corresponding
			 * 					 meteo dat files have a date offset of -1 from d)
			 */
			int					 fileNameDateOffset;

			/**
			 * \var		int ioFormat
			 * \brief	grid I/O format
			 *
			 * - GRD_FORMAT_TEXT = 0 means text I/O format
			 * - GRD_FORMAT_BINARY = 1 means binary I/O format
			 */
			int                  ioFormat;

			/**
			 * \var		int expIoFormat
			 * \brief	grid export I/O format
			 * - GRD_FORMAT_TEXT = 0 means text I/O format
			 * - GRD_FORMAT_BINARY = 1 means binary I/O format
			 */
			int                  expIoFormat;

			/**
			 * \var		float xStart
			 * \brief	start point x coordinate
			 */
			float                xStart;

			/**
			 * \var		float yStart
			 * \brief	start point y coordinate
			 */
			float                yStart;

			/**
			 * \var		float xStep
			 * \brief	step in x direction
			 */
			float                xStep;

			/**
			 * \var		float yStep
			 * \brief	step in y direction
			 */
			float                yStep;

			/**
			 * \var		COORDINATE_DIRECTION xDir
			 * \brief	How x coordinate varies reading from file
			 */
			COORDINATE_DIRECTION xDir;

			/**
			 * \var		COORDINATE_DIRECTION yDir
			 * \brief	How y coordinate varies reading from file
			 */
			COORDINATE_DIRECTION yDir;

			/**
			 * \var		int varNum
			 * \brief	plane number
			 */
			int                  varNum;

			/**
			 * \var		int slotSize
			 * \brief	slot size
			 */
			int                  slotSize;

			/**
			 * \var		int srid
			 * \brief	grid serid
			 */
			int                  srid;

			/**
			 * \var		float undefValue
			 * \brief	grid undefined value
			 */
			float                undefValue;

			/**
			 * \typedef	typedef multi_array<T, 3> grid_t;
			 * \brief	typedef helper
			 */
			typedef     multi_array<T, 3> grid_t;

			/**
			 * \var		grid_t* data
			 * \brief	the real data container
			 */
			grid_t               data;

			/**
			 * \var		GridFields* fields
			 * \brief	fields descriptors vector
			 */
			GridFields*          fields;

		protected:

			/**
			 * \fn		bool readTxt(ifstream& in)
			 * \brief	reads grid data from text file
			 * \param	in input stream
			 * \return	true on success else false
			 */
			bool                 readTxt(ifstream& in);

			/**
			 * \fn		bool readBin(ifstream& in)
			 * \brief	reads grid data from binary file
			 * \param	in input stream
			 * \return	true on success else false
			 */
			bool		         readBin(ifstream& in);

			/**
			 * \fn      bool readBand(ifstream& in)
			 * \brief   reads data from a grid time band (stream must be opened in binary mode)
			 *          not appliable to text streams
			 * \param	in input stream
			 * \return  true on success else false
			 */
			bool                 readBand(ifstream& in);

			/**
			 * \fn      void skipBand(ifstream& in)
			 * \brief   skip the next timeband from reading
			 * \param	in input stream
			 */
			void                 skipBand(ifstream& in);

		public:

			/**
			 * \fn		Grid(int varnum = GRD_DEFAULT_VARNUM)
			 * \brief	Standard constructor
			 */
			Grid(int varnum = GRD_DEFAULT_VARNUM);

			/**
			 * \fn		Grid(int rows, int cols, std::string table = GRD_DEFAULT_TABLE, int type = GEOGRID, float xstart = GRD_X_START, float ystart = GRD_Y_START, float xstep = GRD_X_STEP, float ystep = GRD_Y_STEP, COORDINATE_DIRECTION xdir = INCREASING, COORDINATE_DIRECTION ydir = INCREASING, int varnum = GRD_DEFAULT_VARNUM, int srid = GIS_DEFAULT_SRID, float undefValue = GRD_DEFAULT_UNDEF_VALUE, int slotSize = GRD_DEFAULT_SLOTSIZE);
			 * \brief	Parameterized constructor
			 * \param	rows rows number
			 * \param	cols columns number
			 * \param	table grid table name
			 * \param	type grid type
			 * \param	xstart grid start x coordinate
			 * \param	ystart grid y start coordinate
			 * \param	xstep grid step in x direction
			 * \param	ystep grid step in y direction
			 * \param   xdir x coordinate changing direction
			 * \param   ydir y coordinate changing direction
			 * \param	varnum variables number
			 * \param	srid grid srid
			 * \param	undefValue undefined value
			 * \param	slotSize slot size
			 */
			Grid(
					int rows,
					int cols,
					std::string table = GRD_DEFAULT_TABLE,
					int type = GEOGRID,
					float xstart = GRD_X_START,
					float ystart = GRD_Y_START,
					float xstep = GRD_X_STEP,
					float ystep = GRD_Y_STEP,
					COORDINATE_DIRECTION xdir = INCREASING,
					COORDINATE_DIRECTION ydir = INCREASING,
					int varnum = GRD_DEFAULT_VARNUM,
					int srid = GIS_DEFAULT_SRID,
					float undefValue = GRD_DEFAULT_UNDEF_VALUE,
					int slotSize = GRD_DEFAULT_SLOTSIZE
				);

			/**
			 * \fn		~Grid()
			 * \brief	Destructor
			 */
			virtual              ~Grid();

			/**
			 * \fn		void initialize()
			 * \brief	Initialize grid memory
			 */
			void                 initialize();

			/**
			 * \fn		void init(T t)
			 * \brief	set all grid elements to t
			 */
			void                 init(T t);

			/**
			 * \fn		int getRows() const
			 * \brief	rows number getter
			 * \return	grid rows number
			 */
			int                  getRows() const;

			/**
			 * \fn		int getCols() const
			 * \brief	cols number getter
			 * \return	grid cols number
			 */
			int                  getCols() const;

			/**
			 * \fn		std::string getTable() const
			 * \brief	grid database table name getter
			 * \return 	table name
			 */
			std::string          getTable() const;

			/**
			 * \fn		std::string getDate() const
			 * \brief	date getter
			 * \return	date current value
			 */
			std::string			 getDate() const;

			/**
			 * \fn		std::string getGradsDate() const
			 * \brief	date in GrADS format getter
			 * \return	date current value
			 */
			std::string          getGradsDate() const;

			/**
			 * \fn		std::string getCtlPath() const
			 * \brief	grid ctl file path getter
			 * \return	grid ctl file full path
			 */
			std::string          getCtlPath() const;

			/**
			 * \fn		std::string getDatPath() const
			 * \brief	grid dat file path getter
			 * \return	grid datfile full path
			 */
			std::string          getDatPath() const;

			/**
			 * \fn		std::string getExportDatPath() const
			 * \brief	grid export dat file path getter
			 * \return	grid export datfile full path
			 */
			std::string			 getExportDatPath() const;

			/**
			 * \fn		std::string getExportCtlPath() const
			 * \brief	grid export ctl file path getter
			 * \return	grid export ctl file full path
			 */
			std::string          getExportCtlPath() const;

			/**
			 * \fn      std::string getTitle() const
			 * \brief   grid title getter
			 * \return  the grid title as in grib files
			 */
			std::string          getTitle() const;

			/**
			 * \fn		int getType() const
			 * \brief	grid type getter
			 * \return	grid type
			 * @see fwi_define.h
			 */
			int                  getType() const;

			/**
			 * \fn		int getTimeBand() const
			 * \brief	grid time band
			 * \return  the grid time band
			 */
			int                  getTimeBand() const;

			/**
			 * \fn		int getTimeBandsNumber() const
			 * \brief	grid time bands number
			 * \return  the grid time bands number
			 */
			int                  getTimeBandsNumber() const;

			/**
			 * \fn		std::string getStartTime() const
			 * \brief	grid start time getter
			 * \return	the grid start time in GrADS format
			 */
			std::string          getStartTime() const;

			/**
			 * \fn		std::string getTimeIncrement() const
			 * \brief	grid time increment getter
			 * \return	the grid time increment in GrADS format
			 */
			std::string          getTimeIncrement() const;

			/**
			 * \fn		int getFileNameDateOffset() const
			 * \brief   grid file name date offset getter
			 * \return	the grid file name date offset in days (+/-)
			 */
			int                  getFileNameDateOffset() const;

			/**
			 * \fn		int getIOFormat() const
			 * \brief	grid I/O format getter
			 * \return	grid I/O format
			 * @see fwi_define.h
			 */
			int				     getIOFormat() const;

			/**
			 * \fn		int getExpIOFormat() const
			 * \brief	grid export I/O format getter
			 * \return	grid export I/O format
			 * @see fwi_define.h
			 */
			int				     getExpIOFormat() const;

			/**
			 * \fn		float getXStart() const
			 * \brief	grid start x coordinate getter
			 * \return	grid start x coordinate
			 */
			float                getXStart() const;

			/**
			 * \fn		float getXStep() const
			 * \brief	grid step in x direction getter
			 * \return	grid step in x direction
			 */
			float                getXStep() const;

			/**
			 * \fn		float getYStart() const
			 * \brief	grid start y coordinate getter
			 * \return	grid start y coordinate
			 */
			float                getYStart() const;

			/**
			 * \fn		float getYStep() const
			 * \brief	grid step in y direction getter
			 * \return	grid step in y direction
			 */
			float                getYStep() const;

			/**
			 * \fn		COORDINATE_DIRECTION getXDir() const
			 * \brief	xDir getter
			 * \return	current value for xDir
			 */
			COORDINATE_DIRECTION getXDir() const;

			/**
			 * \fn		COORDINATE_DIRECTION getYDir() const
			 * \brief	yDir getter
			 * \return	current value for yDir
			 */
			COORDINATE_DIRECTION getYDir() const;

			/**
			 * \fn		int getVarNum() const
			 * \brief	variables number getter
			 * \return	variables number
			 */
			int                  getVarNum() const;

			/**
			 * \fn		int getSRID() const
			 * \brief	grid srid getter
			 * \return grid srid
			 */
			int                  getSRID() const;

			/**
			 * \fn		float getUndefValue() const
			 * \brief	grid undefindined value getter
			 * \return	grid undefined value
			 */
			float                getUndefValue() const;

			/**
			 * \fn		int getSlotSize() const
			 * \brief	grid slot size getter
			 * \return	grid slot size
			 */
			int                  getSlotSize() const;

			/**
			 * \fn		grid_t* getData()
			 * \brief	grid internal data pointer getter
			 * \return	internal data representation
			 */
			grid_t               getData();

			/**
			 * \fn		GridFields* getFields() const
			 * \brief	grid fields list getter
			 * \return	grid fields list
			 * @see GridFields
			 */
			GridFields*          getFields() const;

			/**
			 * \fn		int getElementsCount()
			 * \brief	gets the element count as rows x cols
			 * \return	element number only x and y dimensions
			 */
			int                  getElementsCount();

			/**
			 * \fn		int getTotalElementsCount()
			 * \brief	gets the total element count as rows x cols x varNum
			 * \return	element total number
			 */
			int				     getTotalElementsCount();

			/**
			 * \fn		void setRows(int rows)
			 * \brief	grid rows number setter
			 * \param	rows new rows number value
			 */
			void                 setRows(int rows);

			/**
			 * \fn		void setCols(int cols)
			 * \brief	grid columns number setter
			 * \param	cols new columns number value
			 */
			void                 setCols(int cols);

			/**
			 * \fn		void setTable(std::string table)
			 * \brief	grid table name setter
			 * \param	table new table name value
			 */
			void                 setTable(std::string table);

			/**
			 * \fn		void   setDate(std::string date, int offset = 0)
			 * \brief	date   setter
			 * \param	date   date value expressed as YYYYMMDD
			 */
			void			     setDate(std::string date);

			/**
			 * \fn		void setCtlPath(std::string filepath)
			 * \brief	grid ctl file path setter
			 * \param	filepath new ctl file path value
			 */
			void                 setCtlPath(std::string filepath);

			/**
			 * \fn		void setDatPath(std::string filepath)
			 * \brief	grid dat file path setter
			 * \param	filepath new dat file path value
			 */
			void                 setDatPath(std::string filepath);

			/**
			 * \fn		void setExportCtlPath(std::string filepath)
			 * \brief	grid export ctl file path setter
			 * \param	filepath new ctl export file path value
			 */
			void                 setExportCtlPath(std::string filepath);

			/**
			 * \fn		void setExportDatPath(std::string filepath)
			 * \brief	grid export dat file path setter
			 * \param	filepath new dat export file path value
			 */
			void                 setExportDatPath(std::string filepath);

			/**
			 * \fn		void setTitle(std::string title)
			 * \brief	grid title setter
			 * \param	title new title value
			 */
			void                 setTitle(std::string title);

			/**
			 * \fn		void setType(int type)
			 * \brief	grid type setter
			 * \param	type new type value
			 */
			void                 setType(int type);

			/**
			 * \fn		void setTimeBand(int band)
			 * \brief	grid time band setter
			 * \param	band new time band value
			 */
			void                 setTimeBand(int band);

			/**
			 * \fn		void setTimeBandsNumber(int bandsNumber)
			 * \brief	grid time bands number setter
			 * \param	bandsNumber new time bands number value
			 */
			void                 setTimeBandsNumber(int bandsNumber);

			/**
			 * \fn		void setStartTime(std::string t)
			 * \brief	grid start time setter
			 * \param	t grid new start time value in GrADS format
			 * @see		http://www.iges.org/grads/
			 */
			void                 setStartTime(std::string t);

			/**
			 * \fn		void setTimeIncrement(std::string increment)
			 * \brief	grid time increment setter
			 * \param	increment new time increment value
			 */
			void                 setTimeIncrement(std::string increment);

			/**
			 * \fn		void setFileNameDateOffset(int offset)
			 * \brief	grid file name date offset setter
			 * \param	offset file name date offset value
			 */
			void                 setFileNameDateOffset(int offset);

			/**
			 * \fn		void setIOFormat(int format)
			 * \brief	grid I/O format setter
			 * \param	format new I/O format value
			 */
			void                 setIOFormat(int format);

			/**
			 * \fn		void setExpIOFormat(int format)
			 * \brief	grid export I/O format setter
			 * \param	format new export I/O format value
			 */
			void                 setExpIOFormat(int format);

			/**
			 * \fn		void setXStart(float xstart)
			 * \brief	grid start x coordinate setter
			 * \param	xstart new xtsrat value
			 */
			void                 setXStart(float xstart);

			/**
			 * \fn		void setXStep(float xstep)
			 * \brief	grid step in x direction setter
			 * \param	xstep new xstep value
			 */
			void                 setXStep(float xstep);

			/**
			 * \fn		void setYStart(float ystart)
			 * \brief	grid start y coordinate setter
			 * \param	ystart new ystart value
			 */
			void                 setYStart(float ystart);

			/**
			 * \fn		void setYStep(float ystep)
			 * \brief	grid step in y direction setter
			 * \param	ystep new ystep value
			 */
			void                 setYStep(float ystep);

			/**
			 * \fn		void setXDir(COORDINATE_DIRECTION xDir)
			 * \brief	xDir setter
			 * \param	xDir new xDir value
			 */
			void                 setXDir(COORDINATE_DIRECTION xDir);

			/**
			 * \fn		void setYDir(COORDINATE_DIRECTION yDir)
			 * \brief	yDir setter
			 * \param	yDir new yDir value
			 */
			void                 setYDir(COORDINATE_DIRECTION yDir);

			/**
			 * \fn		void setVarNum(int varnum);
			 * \brief	grid variables number setter
			 *
			 * 			Implies grid resize. Elements are preserved only if the new value for
			 * 			<i>varNum</i> is greater than or equal to the old one.
			 *
			 * \param	varnum new variables number value
			 */
			void                 setVarNum(int varnum);

			/**
			 * \fn		void setSRID(int srid)
			 * \brief	grid srid setter
			 * \param	srid new srid value
			 */
			void                 setSRID(int srid);

			/**
			 * \fn		void setUndefValue(float undefValue)
			 * \brief	grid undefined value setter
			 * \param	undefValue new grid undefined value
			 */
			void                 setUndefValue(float undefValue);

			/**
			 * \fn		void setSlotSize(int slotSize)
			 * \brief	grid slot size setter
			 * \param	slotSize new grid slot size value
			 */
			void                 setSlotSize(int slotSize);

			/**
			 * \fn		void setFields(GridFields* fields)
			 * \brief	grid fields list setter
			 * \param	fields new grid fields list
			 */
			void                 setFields(GridFields* fields);

			/**
			 * \fn		T& operator() (int i, int j, int k)
			 * \brief	grid element access helper
			 * \param	i row number
			 * \param	j column number
			 * \param	k plane number
			 * \return	grid element at row <i>i</i> column <i>j</i>
			 */
			T&                   operator() (int i, int j, int k);

			/**
			 * \fn		Grid<T, U>& operator = (const Grid<T, U>& grid);
			 * \brief	grid assignement operator
			 * \param	grid grid to be assigned
			 * \return	this grid after assignement
			 */
			Grid<T>&             operator = (const Grid<T>& grid);

			// dump
			/**
			 * \fn		void raw_dump()
			 * \brief	raw dump helper
			 */
			void                 raw_dump();

			/**
			 * \fn		bool configure(std::string name, Config& cfg)
			 * \brief	configure grid from config file
			 * \param	name grid name as present in config file
			 * \param	cfg configuration class from libconfig++
			 * \return	true on success else false
			 * @see libconfig++ documentation at http://www.hyperrealm.com/libconfig/
			 */
			bool                 configure(std::string name, Config& cfg);

			/**
			 * \fn		bool merge(Grid<T>& other);
			 * \brief	merges <i>other</i> whith <b>this</b>
			 * \param	other second grid
			 *
			 * 			merge can be done only if
			 * 			rows     == other.getRows()     && cols       == other.getCols()       and
			 * 			xStart   == other.getXStart()   && yStart     == other.getYStart()     and
			 * 			xStep    == other.getXStep()    && yStep      == other.getYStep()      and
			 * 			type     == other.getType()     && srid       == other.getSRID()       and
			 * 			slotSize == other.getSlotSize() && undefValue == other.getUndefValue() and
			 * 			table    == other.getTable()
			 *
			 * \return	true on success else false
			 */
			bool			     merge(Grid<T>& other);

			/**
			 * \fn		bool subgrid(std::vector<std::string> fieldnames)
			 * \brief	Extracts a subgrid from <i>this</i> having fields contained in <i>fieldnames</i>
			 * \param	fieldnames array containing the field names to extract from <i>this</i> grid.
			 * \param	sg the computed subgrid
			 * \return	true on success else false
			 */
			bool				 subgrid(std::vector<std::string> fieldnames, Grid<T>& sg);

			// file i/o
			/**
			 * \fn		bool readCtrl(ifstream& in)
			 * \brief	reads grid control file
			 * \param	in input stream
			 * \return	true on success else false
			 */
			bool                 readCtrl(ifstream& in);

			/**
			 * \fn		bool read()
			 * \brief	reads grid binary file
			 * \return	true on success else false
			 */
			bool                 read();

			/**
			 * \fn		bool writeCtrl(ofstream& out);
			 * \brief	write grid ctl file
			 * \param	out output stream
			 * \return	true on success else false
			 */
			bool                 writeCtrl(ofstream& out);

			/**
			 * \fn		bool write(ofstream& out)
			 * \brief	writes grid binary file
			 * \param	out output stream
			 * \return	true on success else false
			 */
			//bool                 write(ofstream& out);
			bool                 write();

			/**
			 * \fn		bool writeTxt(ofstream& out, bool esri = false)
			 * \brief	writes grid text file
			 * \param	out output stream
			 * \param	esri flag for ESRI grid format
			 * \return	true on success else false
			 */
			bool                 writeTxt(ofstream& out, bool esri = false, bool toint = false);

			/**
			 * \fn		bool writeBin(ofstream& out)
			 * \brief	writes grid binary file
			 * \param	out output stream
			 * \return	true on success else false
			 */
			bool                 writeBin(ofstream& out);

			// db
			/**
			 * \fn		bool stored(PGconn* conn)
			 * \brief	verify if <b>this</b> is already stored in database
			 *
			 * 			The existence check is based on the element number: if there aren't
			 * 			elements for <b>this</b> grid he grid is not present
			 *
			 * \param	conn postgresql connection
			 * \return	true if grid is present else false
			 * @see postgresql documentation at http://www.postgresql.org/
			 */
			bool			     stored(PGconn* conn);

			/**
			 * \fn		bool store(PGconn* conn)
			 * \brief	stores grid in database
			 * \param	conn postgresql connection
			 * \return	true on success else false
			 * @see postgresql documentation at http://www.postgresql.org/
			 */
			bool                 store(PGconn* conn);

			/**
			 * \fn		bool insert(PGconn* conn)
			 * \brief	insert grid in database
			 * \param	conn postgresql connection
			 * \return	true on success else false
			 * @see postgresql documentation at http://www.postgresql.org/
			 */
			bool			     insert(PGconn* conn);

			/**
			 * \fn		bool update(PGconn* conn)
			 * \brief	updates grid in database
			 * \param	conn postgresql connection
			 * \return	true on success else false
			 * @see postgresql documentation at http://www.postgresql.org/
			 */
			bool                 update(PGconn* conn);

			/**
			 * \fn		bool retrieve(PGconn* conn)
			 * \brief	retrieves grid from database
			 * \param	conn postgresql connection
			 * \return	true on success else false
			 * @see postgresql documentation at http://www.postgresql.org/
			 */
			bool                 retrieve(PGconn* conn);

			/**
			 * \typedef typedef typename Grid<T>::grid_t::index index;
			 * \brief	typedef helper
			 */
			typedef typename grid_t::index index;

			// stream i/o

			/**
			 * \fn		friend ostream& operator << (ostream& stream, Point& p)
			 * \brief	output stream operator for Point data type
			 */
			friend ostream& operator << (ostream& stream, Point& p);

			/**
			 * \fn		friend ostream& operator << (ostream& stream, Point* p)
			 * \brief	output stream operator for Point* data type
			 */
			friend ostream& operator << (ostream& stream, Point* p);

			/**
			 * \fn		friend istream& operator >> (istream& stream, Point& p)
			 * \brief	input stream operator for Point data type
			 */
			friend istream& operator >> (istream& stream, Point& p);

			/**
			 * \fn		friend istream& operator >> (istream& stream, Point* p)
			 * \brief	input stream operator for Point* data type
			 */
			friend istream& operator >> (istream& stream, Point* p);
		};

		template<typename T>
		Grid<T>::Grid(int varnum)
		{
			rows               = GRD_ROWS;
			cols               = GRD_COLS;
			table              = GRD_DEFAULT_TABLE;
			type               = GEOGRID;
			timeBand           = 0;
			timeBandsNumber    = 1;
			timeIncrement      = "";
			fileNameDateOffset = 0;
			ioFormat           = GRD_FORMAT_BINARY;
			expIoFormat        = GRD_FORMAT_BINARY;
			xStart             = GRD_X_START;
			yStart             = GRD_Y_START;
			xStep              = GRD_X_STEP;
			yStep              = GRD_Y_STEP;
			xDir               = INCREASING;
			yDir               = INCREASING;
			varNum             = varnum;
			slotSize           = GRD_DEFAULT_SLOTSIZE;
			srid               = GIS_DEFAULT_SRID;
			undefValue         = GRD_DEFAULT_UNDEF_VALUE;
			fields             = new GridFields(varNum);
		}


		template<typename T>
		Grid<T>::Grid(
						int rows,
						int cols,
						std::string table,
						int type,
						float xstart,
						float ystart,
						float xstep,
						float ystep,
						COORDINATE_DIRECTION xdir,
						COORDINATE_DIRECTION ydir,
						int varnum,
						int srid,
						float undefValue,
						int slotSize)
		{
			this->rows               = rows;
			this->cols               = cols;
			this->table              = table;
			this->type               = type;
			this->timeBand           = 0;
			this->timeBandsNumber    = 1;
			this->timeIncrement      = "";
			this->fileNameDateOffset = 0;
			this->ioFormat           = GRD_FORMAT_BINARY;
			this->expIoFormat        = GRD_FORMAT_BINARY;
			this->xStart             = xstart;
			this->yStart             = ystart;
			this->xStep              = xstep;
			this->yStep              = ystep;
			this->xDir               = xdir;
			this->yDir               = ydir;
			this->varNum             = varnum;
			this->slotSize           = slotSize;
			this->srid               = srid;
			this->undefValue         = undefValue;
			fields                   = new GridFields();
		}

		template<typename T>
		Grid<T>::~Grid()
		{
			if( fields != NULL )
			{
				delete fields;
				fields = NULL;
			}
		}

		template<typename T>
		int Grid<T>::getRows() const
		{
			return rows;
		}

		template<typename T>
		int Grid<T>::getCols() const
		{
			return cols;
		}

		template<typename T>
		std::string Grid<T>::getTable() const
		{
			return table;
		}

		template<typename T>
		std::string Grid<T>::getDate() const
		{
			return date;
		}

		std::string get_month(int m)
		{
			std::string result;
			switch( m )
			{
				case  1: result = "jan"; break;    case  2: result = "feb"; break;
				case  3: result = "mar"; break;    case  4: result = "apr"; break;
				case  5: result = "may"; break;    case  6: result = "jun"; break;
				case  7: result = "jul"; break;    case  8: result = "aug"; break;
				case  9: result = "sep"; break;    case 10: result = "oct"; break;
				case 11: result = "nov"; break;    case 12: result = "dec"; break;
			}
			return result;
		}

		template<typename T>
		std::string Grid<T>::getGradsDate() const
		{
			// FIXME -- this should be done with karma
			std::string result;
			int         month;

			if( date.size() > 8 )
			{
				result  = date.substr(8, 2);
				month   = atoi(date.substr(5, 2).c_str());
				assert( month >= 1 && month <= 12);
				result += get_month(month);
				result += date.substr(0, 4);
			}
			else
			{
				result  = date.substr(6, 2);
				month   = atoi(date.substr(4, 2).c_str());
				assert( month >= 1 && month <= 12);
				result += get_month(month);
				result += date.substr(0, 4);
			}

			return result;
		}


		template<typename T>
		std::string Grid<T>::getCtlPath() const
		{
			return ctlpath;
		}

		template<typename T>
		std::string Grid<T>::getDatPath() const
		{
			return datpath;
		}

		template<typename T>
		std::string Grid<T>::getExportCtlPath() const
		{
			return expctlpath;
		}

		template<typename T>
		std::string Grid<T>::getExportDatPath() const
		{
			return expdatpath;
		}

		template<typename T>
		std::string Grid<T>::getTitle() const
		{
			return title;
		}

		template<typename T>
		int Grid<T>::getType() const
		{
			return type;
		}

		template<typename T>
		int Grid<T>::getTimeBand() const
		{
			return timeBand;
		}

		template<typename T>
		int Grid<T>::getTimeBandsNumber() const
		{
			return timeBandsNumber;
		}

		template<typename T>
		std::string Grid<T>::getStartTime() const
		{
			return startTime;
		}

		template<typename T>
		std::string Grid<T>::getTimeIncrement() const
		{
			return timeIncrement;
		}

		template<typename T>
		int Grid<T>::getFileNameDateOffset() const
		{
			return fileNameDateOffset;
		}

		template<typename T>
		int Grid<T>::getIOFormat() const
		{
			return ioFormat;
		}

		template<typename T>
		int Grid<T>::getExpIOFormat() const
		{
			return expIoFormat;
		}

		template<typename T>
		float Grid<T>::getXStart() const
		{
			return xStart;
		}

		template<typename T>
		float Grid<T>::getXStep() const
		{
			return xStep;
		}

		template<typename T>
		float Grid<T>::getYStart() const
		{
			return yStart;
		}

		template<typename T>
		float Grid<T>::getYStep() const
		{
			return yStep;
		}

		template<typename T>
		COORDINATE_DIRECTION Grid<T>::getXDir() const
		{
			return xDir;
		}

		template<typename T>
		COORDINATE_DIRECTION Grid<T>::getYDir() const
		{
			return yDir;
		}

		template<typename T>
		int Grid<T>::getVarNum() const
		{
			return varNum;
		}

		template<typename T>
		int Grid<T>::getSRID() const
		{
			return srid;
		}

		template<typename T>
		float Grid<T>::getUndefValue() const
		{
			return undefValue;
		}

		template<typename T>
		int Grid<T>::getSlotSize() const
		{
			return slotSize;
		}

		template<typename T>
		typename Grid<T>::grid_t Grid<T>::getData()
		{
			return data;
		}

		template<typename T>
		GridFields* Grid<T>::getFields() const
		{
			return fields;
		}

		template<typename T>
		int Grid<T>::getElementsCount()
		{
			return rows * cols;
		}

		template<typename T>
		int Grid<T>::getTotalElementsCount()
		{
			return rows * cols * varNum;
		}

		template<typename T>
		void Grid<T>::setRows(int rows)
		{
			this->rows = rows;
		}

		template<typename T>
		void Grid<T>::setCols(int cols)
		{
			this->cols = cols;
		}

		template<typename T>
		void Grid<T>::setTable( std::string table)
		{
			this->table = table;
		}

		template<typename T>
		void Grid<T>::setDate(std::string date)
		{
			boost::posix_time::ptime t;

			if( date.find('-') > 0 )
			{
				// have to remove '-'
				date.erase(std::remove(date.begin(), date.end(), '-'), date.end());
			}

			t = ptime(from_iso_string(date));
			t = t + days(fileNameDateOffset);
			date = to_iso_string(t);

			this->date = date.substr(0, 8);
		}

		template<typename T>
		void Grid<T>::setCtlPath(std::string filepath)
		{
			this->ctlpath = filepath;
		}

		template<typename T>
		void Grid<T>::setDatPath(std::string filepath)
		{
			this->datpath = filepath;
		}

		template<typename T>
		void Grid<T>::setExportCtlPath(std::string filepath)
		{
			this->expctlpath = filepath;
		}

		template<typename T>
		void Grid<T>::setExportDatPath(std::string filepath)
		{
			this->expdatpath = filepath;
		}

		template<typename T>
		void Grid<T>::setTitle(std::string title)
		{
			this->title = title;
		}

		template<typename T>
		void Grid<T>::setType(int type)
		{
			this->type = type;
		}

		template<typename T>
		void Grid<T>::setTimeBand(int band)
		{
			this->timeBand = band;
		}

		template<typename T>
		void Grid<T>::setTimeBandsNumber(int bandsNumber)
		{
			this->timeBandsNumber = bandsNumber;
		}

		template<typename T>
		void Grid<T>::setStartTime(std::string t)
		{
			this->startTime = t;
		}

		template<typename T>
		void Grid<T>::setTimeIncrement(std::string increment)
		{
			this->timeIncrement = increment;
		}

		template<typename T>
		void Grid<T>::setFileNameDateOffset(int offset)
		{
			this->fileNameDateOffset = offset;
		}

		template<typename T>
		void Grid<T>::setIOFormat(int format)
		{
			this->ioFormat = format;
		}

		template<typename T>
		void Grid<T>::setExpIOFormat(int format)
		{
			this->expIoFormat = format;
		}

		template<typename T>
		void Grid<T>::setXStart(float xstart)
		{
			this->xStart = xstart;
		}

		template<typename T>
		void Grid<T>::setXStep(float xstep)
		{
			this->xStep = xstep;
		}

		template<typename T>
		void Grid<T>::setYStart(float ystart)
		{
			this->yStart = ystart;
		}

		template<typename T>
		void Grid<T>::setYStep(float ystep)
		{
			this->yStep = ystep;
		}

		template<typename T>
		void Grid<T>::setXDir(COORDINATE_DIRECTION xDir)
		{
			this->xDir = xDir;
		}

		template<typename T>
		void Grid<T>::setYDir(COORDINATE_DIRECTION yDir)
		{
			this->yDir = yDir;
		}

		template<typename T>
		void Grid<T>::setVarNum(int varnum)
		{
			varNum = varnum;
			data.resize(boost::extents[rows][cols][varNum]);
		}

		template<typename T>
		void Grid<T>::setSRID(int srid)
		{
			this->srid = srid;
		}

		template<typename T>
		void Grid<T>::setUndefValue(float undefValue)
		{
			this->undefValue = undefValue;
		}

		template<typename T>
		void Grid<T>::setSlotSize(int slotSize)
		{
			this->slotSize = slotSize;
		}

		template<typename T>
		void Grid<T>::setFields(GridFields* fields)
		{
			if( this->fields != NULL )
			{
				this->fields->clear();
			}
			this->fields = fields;
		}

		template<typename T>
		T& Grid<T>::operator() (int i, int j, int k)
		{
			//assert( data != NULL );
			//return (*data)[i][j][k];
			return data[i][j][k];
		}

		template<typename T>
		Grid<T>& Grid<T>::operator = (const Grid<T>& grid)
		{
			cols            = grid.cols;	// numero di colonne
			rows            = grid.rows;	// numero di righe
			table           = grid.table;
			ctlpath         = grid.ctlpath;
			datpath         = grid.datpath;
			expctlpath      = grid.expctlpath;
			expdatpath      = grid.expdatpath;
			title           = grid.title;
			ioFormat        = grid.ioFormat;
			expIoFormat     = grid.expIoFormat;
			timeBand        = grid.timeBand;
			timeBandsNumber = grid.timeBandsNumber;
			type            = grid.type;
			xStart          = grid.xStart;
			yStart          = grid.yStart;
			xStep           = grid.xStep;
			yStep           = grid.yStep;
			varNum          = grid.varNum;
			slotSize        = grid.slotSize;
			srid            = grid.srid;
			undefValue      = grid.undefValue;
			data            = grid.data;

			fields          = grid.fields;

			return *this;
		}

		// dump
		template<typename T>
		void Grid<T>::raw_dump()
		{
			for( int i = 0; i < rows; i++ )
			{
				for( int j = 0; j < cols; j++ )
				{
					for( int k = 0; k < varNum; k++ )
					{
						T t = data[i][j][k];
						if( type != GEOGRID )
						{
							cout << "[" << i << "," << j << "," << k << "]=" << t << " ";
						}
						else
						{
							//cout << "[" << i << "," << j << "," << k << "]=" << t->toString() << " ";
							//cout << "<no value>";
						}
					}
				}
				cout << endl;
			}
		}

		template<typename T>
		void Grid<T>::initialize()
		{
			data.resize(boost::extents[rows][cols][varNum]);
		}

		template<typename T>
		void Grid<T>::init(T t)
		{
			for( int i = 0; i < rows; i++ )
			{
				for( int j = 0; j < cols; j++ )
				{
					for( int k = 0; k < varNum; k++ )
					{
						data[i][j][k] = t;
					}
				}
			}
		}

		template<typename T>
		bool Grid<T>::configure(std::string name, Config& cfg)
		{
			//int    fieldsnum   = 0;
			int    isetting    = 0;
			std::string setting     = "";
			std::string cfgpath     = "fwidbmgr.files.grads.";
			cfgpath += name;
			std::string field       = cfgpath;
			field += ".fields";
			std::string str_setting = cfgpath;

			if( cfg.exists(cfgpath) )
			{
				//cout << "Configuring grid: " << name << endl;
				LOG4CXX_INFO(logger, "Configuring grid: " << name);
				cfg.lookup(cfgpath).lookupValue("ctlfile", setting);
				ctlpath = setting;
				cfg.lookup(cfgpath).lookupValue("datfile", setting);
				datpath = setting;
				cfg.lookup(cfgpath).lookupValue("expctlfile", setting);
				expctlpath = setting;
				cfg.lookup(cfgpath).lookupValue("expdatfile", setting);
				expdatpath = setting;
				cfg.lookup(cfgpath).lookupValue("table", setting);
				table = setting;
				cfg.lookup(cfgpath).lookupValue("type", isetting);
				type = isetting;
				cfg.lookup(cfgpath).lookupValue("ioformat", isetting);
				ioFormat = isetting;
				cfg.lookup(cfgpath).lookupValue("expioformat", isetting);
				expIoFormat = isetting;
				cfg.lookup(cfgpath).lookupValue("title", setting);
				title = setting;
				cfg.lookup(cfgpath).lookupValue("timeband", isetting);
				timeBand = isetting;
				cfg.lookup(cfgpath).lookupValue("timebandsnumber", isetting);
				timeBandsNumber = isetting;
				cfg.lookup(cfgpath).lookupValue("starttime", setting);
				startTime = setting;
				cfg.lookup(cfgpath).lookupValue("timeincrement", setting);
				timeIncrement = setting;
				cfg.lookup(cfgpath).lookupValue("filenamedateoffset", isetting);
				fileNameDateOffset = isetting;

				cfg.lookup(cfgpath).lookupValue("fieldsnum", isetting);
				this->varNum = isetting;
#ifdef DEBUG
				//cout << "This grid has " << varNum << " fields and refers to ctl:" << ctlpath << endl << " and dat " << datpath << endl << " for table " << table << endl;
				LOG4CXX_INFO(logger, "This grid has " << varNum << " fields and refers to ctl:" << ctlpath << endl << " and dat " << datpath << endl << " for table " << table);
#endif

				fields->clear();
				for(int i = 0; i < varNum; i++ )
				{
					cfg.lookup(field)[i].lookupValue("name", setting);
					std::string fname = setting;
					Setting& s = cfg.lookup(field)[i];//, isetting);
					int level = 0;
#ifdef DEBUG
					//cout << s.getPath() << endl;
					LOG4CXX_INFO(logger, s.getPath());
#endif

					// FIXME -- there could be more than 1 level
					Setting& ln = cfg.lookup(s.getPath() + ".levelsnum");
					int levelsnum = ln;

					levels_t levels;
#ifdef DEBUG
					//cout << "has " << levelsnum << " levels" << endl;
					LOG4CXX_INFO(logger, "has " << levelsnum << " levels");
#endif
					for( int j = 0; j < levelsnum; j++ )
					{
						Setting& l = cfg.lookup(s.getPath() + ".levels")[j];
						level = l;
						levels.push_back(level);
					}

					s.lookupValue("units", isetting);
					int units = isetting;
					s.lookupValue("description", setting);
					std::string description = setting;
					s.lookupValue("fieldname", setting);
					std::string fieldname = setting;

#ifdef DEBUG
					//cout << "field[" << i << "]" << endl;
					LOG4CXX_INFO(logger, "field[" << i << "]");
					//cout << "name:        " << fname << endl;
					LOG4CXX_INFO(logger, "name:        " << fname);
					//cout << "level:       " << level << endl;
					LOG4CXX_INFO(logger, "level:       " << level);
					//cout << "units:       " << units << endl;
					LOG4CXX_INFO(logger, "units:       " << units);
					//cout << "description: " << description << endl;
					LOG4CXX_INFO(logger, "description: " << description);
#endif

#ifdef __OPENSUSE_11_3__
					GridField* f = new GridField(i + 1, fname, fieldname, levels, units, description, FLOAT);
#else
					GridField* f = new GridField(i + 1, fname, fieldname, levels, units, description, GRID_VALUE_TYPE::FLOAT);
#endif

					//GridField* f = new GridField(i + 1, fname, fieldname, levels, units, description, GRID_VALUE_TYPE::FLOAT);
					this->fields->push_back(f);
				}

	#ifdef DEBUG
				fields->raw_dump();
	#endif

				//cout << "Grid " << name << " configured." << endl;
				LOG4CXX_INFO(logger, "Grid " << name << " configured.");
				return true;
			}

			return false;
		}

		template<typename T>
		bool Grid<T>::merge(Grid<T>& other)
		{
			assert( rows     == other.getRows()     && cols       == other.getCols()       );
			assert( xStart   == other.getXStart()   && yStart     == other.getYStart()     );
			assert( xStep    == other.getXStep()    && yStep      == other.getYStep()      );
			assert( type     == other.getType()     && srid       == other.getSRID()       );
			assert( slotSize == other.getSlotSize() && undefValue == other.getUndefValue() );
			assert( table    == other.getTable() );

			// merge grid data
			data.resize(boost::extents[rows][cols][varNum + other.getVarNum()]);

			for( int i = 0; i < rows; i++ )
			{
				for( int j = 0; j < cols; j++ )
				{
					for( int k = 0; k < other.getVarNum(); k++ )
					{
						data[i][j][varNum + k] = other(i, j , k);
					}
				}
			}

			// merge fields
			GridFields* ff = other.getFields();

			assert( ff != NULL );

			for( int i = 0; i < other.getVarNum(); i++ )
			{
				GridField*  f  = new GridField();
				assert( f  != NULL );
				GridField* pf = ff->at(i);
				assert( pf != NULL );

				*f = *pf;

				fields->push_back(f);
			}

			// merge grid metadata
			// update variables numer
			varNum += other.getVarNum();

			// update field positions in grid fields vector
			int k = 1;
			for( fields_iterator_t i = fields->begin(); i != fields->end(); i++ )
			{
				(*i)->setPosition(k++);
			}

			return true;
		}

		template<typename T>
		bool Grid<T>::subgrid(std::vector<std::string> fieldnames, Grid<T>& sg)
		{
			typedef	std::vector<std::string>::iterator fi_t;
			typedef std::pair<std::string, GridField*> p_t;
			// FIXME - may be this map could be simply from string --> int instead of string --> GridField*
			typedef std::map<std::string, GridField*>  fmap_t;
			typedef fmap_t::iterator                   fmap_iterator_t;

			fi_t   i;
			fmap_t fmap;
			bool   found_all = true;

			sg.setDate(date);
			sg.setType(type);
			sg.setUndefValue(undefValue);
			sg.setCols(cols);
			sg.setRows(rows);
			sg.setVarNum(0);
			sg.initialize();

			// check if i already have all the fieldnames
			for( i = fieldnames.begin(); i != fieldnames.end(); i++ )
			{
				if( fields->hasField(*i) )
				{
					fmap[*i] = fields->getFieldByName(*i);
					//fmap.insert(p_t(*i, fields->getFieldByName(*i)));
					//sg.fields->addField(fmap[*i]);
				}
				else
				{
					found_all = false;
				}
			}

			// the starting grid has not all the requested fields
			if( !found_all )
			{
				return false;
			}

			// Initialize result map
			sg.setVarNum(fmap.size());
			sg.initialize();

			// put each single grid into result grid
			for( int k = 0; k < sg.getVarNum(); k++ )
			{
				int slice = fmap[fieldnames[k]]->getPosition() - 1;
				for( int i = 0; i < rows; i++ )
				{
					for( int j = 0; j < cols; j++ )
					{
						sg(i, j, k) = data[i][j][slice];
					}
				}
			}

			return true;
		}

		// file i/o
		template<typename T>
		bool Grid<T>::readCtrl(ifstream& in)
		{
			return false;
		}

		template<typename T>
		bool Grid<T>::read()
		{
			assert( !datpath.empty() );

			bool result = false;

			size_t pos = datpath.find("<<date>>");

			if( pos != datpath.npos )
			{
				datpath.replace(pos, 8, date);
			}

			//ifstream is(datpath, ios::in | ios::binary);

			if( ioFormat == GRD_FORMAT_TEXT )
			{
#ifdef __OPENSUSE_11_3__
				ifstream is(datpath.c_str(), ios::in);
#else
				ifstream is(datpath, ios::in);
#endif

				result = readTxt(is);
				is.close();
			}

			if( ioFormat == GRD_FORMAT_BINARY )
			{
#ifdef __OPENSUSE_11_3__
				ifstream is(datpath.c_str(), ios::in | ios::binary);
#else
				ifstream is(datpath, ios::in | ios::binary);
#endif
				result = readBin(is);
				is.close();
			}

			return result;

		}

		template<typename T>
		bool Grid<T>::readTxt(ifstream& in)
		{

			if( !in.is_open() )
			{
				return false;
			}

			std::string line = "";
			getline(in, line); getline(in, line); getline(in, line);
			getline(in, line); getline(in, line); getline(in, line);

			if( xDir == INCREASING )
			{
				float xxxx = 0;
				for( int k = 0; k < varNum; k++ )
				{
					for( int i = 0; i < rows; i++ )
					{
						for( int j = 0; j < cols; j++ )
						{

							in >> xxxx;
							data[i][j][k] = xxxx;

							//in >> data[i][j][k];
						}
					}
				}
			}

			if( xDir == DECREASING )
			{
				for( int k = 0; k < varNum; k++ )
				{
					for( int i = rows - 1; i >= 0; i-- )
					{
						for( int j = 0; j < cols; j++ )
						{
							in >> data[i][j][k];
						}
					}
				}
			}

			return true;
		}

		template<typename T>
		bool Grid<T>::readBin(ifstream& in)
		{
			assert( !datpath.empty() );

			/*size_t pos = datpath.find("<<date>>");

			if( pos != datpath.npos )
			{
				datpath.replace(pos, 8, date);
			}*/

			for(int i = 0; i < timeBand - 1; i++ )
			{
				skipBand(in);
			}

			/*ifstream is(datpath, ios::in | ios::binary);

			if( is.is_open() )
			{
				for( int k = 0; k < varNum; k++ )
				{
					for( int i = 0; i < rows; i++ )
					{
						for( int j = 0; j < cols; j++ )
						{
							T gd;
							is.read((char*)&gd, sizeof(T));
							data[i][j][k] = gd;

	#ifdef DEBUG
							if( type != GEOGRID )
							{
								cout << data[i][j][k] << " ";
							}
	#endif
						}
	#ifdef DEBUG
						cout << endl;
	#endif
					}
				}

				is.close();
			}
			else
			{
				cout << "Unable to open dat: " << datpath << endl;
				return false;
			}*/

			return readBand(in);
		}

		template<typename T>
		bool Grid<T>::readBand(ifstream& in)
		{
			assert( !datpath.empty() );

			/*size_t pos = datpath.find("<<date>>");

			if( pos != datpath.npos )
			{
				datpath.replace(pos, 8, date);
			}

			ifstream is(datpath, ios::in | ios::binary);*/

			if( in.is_open() )
			{
				for( int k = 0; k < varNum; k++ )
				{
					for( int i = 0; i < rows; i++ )
					{
						for( int j = 0; j < cols; j++ )
						{
							T gd;
							in.read((char*)&gd, sizeof(T));
							data[i][j][k] = gd;

	#ifdef DEBUG
							if( type != GEOGRID )
							{
								cout << data[i][j][k] << " ";
							}
	#endif
						}
	#ifdef DEBUG
						cout << endl;
	#endif
					}
				}

				//in.close();
			}
			else
			{
				//cout << "File not open: " << datpath << endl;
				LOG4CXX_ERROR(logger, "File not open: " << datpath);
				return false;
			}

			return true;
		}

		template<typename T>
		void Grid<T>::skipBand(ifstream& in)
		{
			ios::off_type pos = in.tellg();

			pos += (varNum * rows * cols) * slotSize;

			in.seekg(pos, ios::beg);
		}

		template<typename T>
		bool Grid<T>::writeCtrl(ofstream& out)
		{
			std::vector<std::string> lines;

			for( int i = 0; i < 8; i++ )
			{
				lines.push_back(*new std::string());
			}

			// FIXME -- tdef generation output incorrect value for tnum (number of time steps)
			std::back_insert_iterator<std::string> iterator_dset(lines[0]);
			std::back_insert_iterator<std::string> iterator_title(lines[1]);
			std::back_insert_iterator<std::string> iterator_undef(lines[2]);
			std::back_insert_iterator<std::string> iterator_xdef(lines[3]);
			std::back_insert_iterator<std::string> iterator_ydef(lines[4]);
			std::back_insert_iterator<std::string> iterator_zdef(lines[5]);
			std::back_insert_iterator<std::string> iterator_tdef(lines[6]);
			std::back_insert_iterator<std::string> iterator_vars(lines[7]);

			if( !generate_dset(iterator_dset, *this) )
			{
				//cout << "ERROR generating dset" << endl;
				LOG4CXX_ERROR(logger, "ERROR generating dset");
				return false;
			}
			else
			{
				lines[0].replace(lines[0].find(TAG_DATE), 8, date);
			}

			if( !generate_title(iterator_title, *this) )
			{
				//cout << "ERROR generating title" << endl;
				LOG4CXX_ERROR(logger, "ERROR generating title");
				return false;
			}

			if( !generate_undef(iterator_undef, *this) )
			{
				//cout << "ERROR generating undef value" << endl;
				LOG4CXX_ERROR(logger, "ERROR generating undef value");
				return false;
			}

			if( !generate_xdef(iterator_xdef, *this) )
			{
				//cout << "ERROR generating xdef" << endl;
				LOG4CXX_ERROR(logger, "ERROR generating xdef");
				return false;
			}

			if( !generate_ydef(iterator_ydef, *this) )
			{
				//cout << "ERROR generating ydef" << endl;
				LOG4CXX_ERROR(logger, "ERROR generating ydef");
				return false;
			}

			if( !generate_zdef(iterator_zdef, *this) )
			{
				//cout << "ERROR generating zdef" << endl;
				LOG4CXX_ERROR(logger, "ERROR generating zdef");
				return false;
			}
			if( !generate_tdef(iterator_tdef, *this) )
			{
				//cout << "ERROR generating tdef" << endl;
				LOG4CXX_ERROR(logger, "ERROR generating tdef");
				return false;
			}
			if( !generate_vars(iterator_vars, *fields) )
			{
				//cout << "ERROR generating vars" << endl;
				LOG4CXX_ERROR(logger, "ERROR generating vars");
				return false;
			}

			for( size_t i = 0; i < lines.size(); i++ )
			{
				out << lines[i] << endl;
			}

			return true;
		}

		template<typename T>
		bool Grid<T>::writeBin(ofstream& out)
		{
			if( out.is_open() )
			{
				for( int k = 0; k < varNum; k++ )
				{
					for( int i = 0; i < rows; i++ )
					{
						for( int j = 0; j < cols; j++ )
						{
							out.write((char*)&data[i][j][k], slotSize);
	#ifdef DEBUG
							if( type != GEOGRID )
							{
								cout << setw(10) << data[i][j][k] << " ";
							}
	#endif
						}
	#ifdef DEBUG
						cout << endl;
	#endif
					}
				}

				out.flush();
			}
			else
			{
				//cout << datpath << " not open" << endl;
				LOG4CXX_ERROR(logger, datpath << " not open");
				return false;
			}

			return true;
		}

		template<typename T>
		bool Grid<T>::write()
		{
			assert( !datpath.empty() );

			bool result = false;

			size_t pos = datpath.find("<<date>>");

			if( pos != datpath.npos )
			{
				datpath.replace(pos, 8, date);
			}

			//ifstream is(datpath, ios::in | ios::binary);

			if( expIoFormat == GRD_FORMAT_TEXT )
			{
#ifdef __OPENSUSE_11_3__
				ofstream os(datpath.c_str(), ios::out);
#else
				ofstream os(datpath, ios::out);
#endif

				result = writeTxt(os);
				os.close();
			}

			if( expIoFormat == GRD_FORMAT_BINARY )
			{
#ifdef __OPENSUSE_11_3__
				ofstream os(datpath.c_str(), ios::out | ios::binary);
#else
				ofstream os(datpath, ios::out | ios::binary);
#endif
				result = writeBin(os);
				os.close();
			}

			return result;





			/*
			if( out.is_open() )
			{
				for( int k = 0; k < varNum; k++ )
				{
					for( int i = 0; i < rows; i++ )
					{
						for( int j = 0; j < cols; j++ )
						{
							out.write((char*)&data[i][j][k], slotSize);
	#ifdef DEBUG
							if( type != GEOGRID )
							{
								cout << setw(10) << data[i][j][k] << " ";
							}
	#endif
						}
	#ifdef DEBUG
						cout << endl;
	#endif
					}
				}

				out.flush();
			}
			else
			{
				//cout << datpath << " not open" << endl;
				LOG4CXX_ERROR(logger, datpath << " not open");
				return false;
			}

			return true;
			*/
		}

		template<typename T>
		bool Grid<T>::writeTxt(ofstream& out, bool esri, bool toint)
		{
			if( out.is_open() )
			{
				if( esri )
				{
					/*
					 ncols 177
					 nrows 174
					 xllcorner 1436301.375
					 yllcorner 4916704.5
					 cellsize 1500.000000
					 NODATA_value -9999
					 */
					out << "ncols "        << cols                 << endl;
					out << "nrows "        << rows                 << endl;
					//out << "xllcorner "    << setw(12)   << xStart << endl;
					//out << "yllcorner "    << setw(12)   << yStart << endl;
					out << "xllcorner "    << setw(12)   << "1436301.375" << endl;
					out << "yllcorner "    << setw(12)   << "4916704.5" << endl;
					out << "cellsize "     << xStep                << endl;
					out << "NODATA_value " << undefValue           << endl;
				}
				for( int k = 0; k < varNum; k++ )
				{
					//for( int i = 0; i < rows; i++ )
					for( int i = rows - 1; i >= 0; i-- )
					{
						for( int j = 0; j < cols; j++ )
						{
							if( toint )
							{
								out << setw(10) << (int)data[i][j][k] << " ";
							}
							else
							{
								out << setw(10) << data[i][j][k] << " ";
							}
	#ifdef DEBUG
							if( type != GEOGRID )
							{
								cout << setw(10) << data[i][j][k] << " ";
							}
	#endif
						}
						out << endl;
					}
				}

				out.flush();
			}
			else
			{
				//cout << datpath << " not open" << endl;
				LOG4CXX_ERROR(logger, datpath << " not open");
				return false;
			}

			return true;

		}

		// db
		template<typename T>
		bool Grid<T>::stored(PGconn* conn)
		{
			assert( conn != NULL );
			assert( PQstatus(conn) != CONNECTION_BAD );

			long long int n = -1;
			stringstream ss;

			ss << "select count(*) as num from " << table << " where dt = '" << date << "';";

			std::string query = ss.str();

			PGresult* result = PQexec(conn, query.c_str());

			if( PQresultStatus(result) != PGRES_TUPLES_OK )
			{
				//cout << "command failed: " << PQerrorMessage(conn) << endl;
				LOG4CXX_ERROR(logger, "command failed: " << PQerrorMessage(conn));
				//cout << "reason: " << PQresStatus(PQresultStatus(result)) << endl;
				LOG4CXX_INFO(logger, "reason: " << PQresStatus(PQresultStatus(result)));
				PQclear(result);
				return false;
			}
			else
			{
				std::string res = PQgetvalue(result, 0, 0);
				n = atoll(res.c_str());
			}

			return (n > 0) && (n != -1);
		}

		template<typename T>
		bool Grid<T>::store(PGconn* conn)
		{
			assert( conn != NULL );
			assert( PQstatus(conn) != CONNECTION_BAD );

			bool result = false;

			if( stored(conn) )
			{
				result = update(conn);
			}
			else
			{
				result = insert(conn);
			}

			return result;
		}

		template<typename T>
		bool Grid<T>::insert(PGconn* conn)
		{
			assert( conn != NULL );
			assert( PQstatus(conn) != CONNECTION_BAD );

			std::string  sql     = "";
			int          pidx    = 1;
			stringstream ss;

			for( int i = 0; i < rows; i++ )
			{
				for( int j = 0; j < cols; j++ )
				{
					ss << "insert into " << table << "(";

					if( table != "grid" )
					{
						ss << "point_id, dt,";
					}
					else
					{
						ss << "p, ";
					}

					for( int k = 0; k < varNum; k++ )
					{
						ss << fields->at(k)->getFieldName();
						if( k != varNum - 1 )
						{
							ss << ", ";
						}
					}

					if( table != "grid" )
					{
						ss << ") values(" << pidx++ << ", '" << date << "',";
					}
					else
					{
						ss << ") values (";
					}

					for( int k = 0; k < varNum; k++ )
					{
						if( type != GEOGRID )
						{
							ss << data[i][j][k];
						}
						else
						{
							//ss << (data[i][j][k])->asewkt();
						}

						if( k != varNum - 1 )
						{
							ss << ", ";
						}
					}

					ss << ");\n";
				}
			}

			sql = ss.str();

	#ifdef DEBUG
			cout << sql << endl;
	#endif

			PGresult* result = PQexec(conn, sql.c_str());

			if( PQresultStatus(result) != PGRES_COMMAND_OK )
			{
				//cout << "BEGIN command failed: " << PQerrorMessage(conn) << endl;
				LOG4CXX_ERROR(logger, "BEGIN command failed: " << PQerrorMessage(conn));
				PQclear(result);
				return false;
			}

			return true;

		}

		template<typename T>
		bool Grid<T>::update(PGconn* conn)
		{
			assert( conn != NULL );
			assert( PQstatus(conn) != CONNECTION_BAD );

			PGresult*    result  = NULL;
			bool         res     = true;
			std::string  sql     = "";
			int          pidx    = 1;

			for( int i = 0; i < rows; i++ )
			{
				stringstream ss;

				for( int j = 0; j < cols; j++ )
				{

					ss << "update " << table << " set ";

					for( int k = 0; k < varNum; k++ )
					{
						ss << fields->at(k)->getFieldName() << " = " << data[i][j][k];
						if( k != varNum - 1 )
						{
							ss << ", ";
						}
					}

					ss << " where point_id = " << pidx++ << " and dt = '" << date << "';\n";

				}

				sql = ss.str();
#ifdef DEBUG
				cout << sql << endl;
#endif

				result = PQexec(conn, sql.c_str());

				if( PQresultStatus(result) != PGRES_COMMAND_OK )
				{
					//cout << "BEGIN command failed: " << PQerrorMessage(conn) << endl;
					LOG4CXX_ERROR(logger, "BEGIN command failed: " << PQerrorMessage(conn));
					PQclear(result);
					res = false;
				}

				ss.clear();

			}

			return res;
		}

		template<typename T>
		bool Grid<T>::retrieve(PGconn* conn)
		{
			int    nrow    = 0;
			std::string sql     = "";
			std::string sqlstmt = "";

			std::vector<int> field_names;

			stringstream ss;

			ss << " select * from " << table << " where dt = '" << date << "' order by point_id;";

			sql = ss.str();

			PGresult* result = PQexec(conn, sql.c_str());

			if( PQresultStatus(result) != PGRES_TUPLES_OK )
			{
				//cout << "BEGIN command failed: " << PQerrorMessage(conn) << endl;
				LOG4CXX_ERROR(logger, "BEGIN command failed: " << PQerrorMessage(conn));
				PQclear(result);
				return false;
			}

			for( int k = 0; k < varNum; k++ )
			{
				int f = PQfnumber(result, fields->at(k)->getFieldName().c_str());
				field_names.push_back(f);
			}

			std::string item = "";

			for( int i = 0; i < rows; i++ )
			{
				for( int j = 0; j < cols; j++ )
				{
					for( int k = 0; k < varNum; k++ )
					{
						item = PQgetvalue(result, nrow, field_names[k]);
						data[i][j][k] = atof(item.c_str());
#ifdef DEBUG
						cout << data[i][j][k] << endl;
#endif
					}
					nrow++;
				}
			}

			return true;
		}

		template<typename T>
		ostream& operator << (ostream& stream, Grid<T>& g)
		{
			/*stream << "\nRows:            " << g.getRows()
				   << "\nColumns:         " << g.getCols()
				   << "\nTable:           " << g.getTable()
				   << "\nDate:            " << g.getDate()
				   << "\nCtl path:        " << g.getCtlPath()
				   << "\nDat path:        " << g.getDatPath()
				   << "\ntype:            " << g.getType()
				   << "\nX start:         " << g.getXStart()
				   << "\nY start:         " << g.getYStart()
				   << "\nX step:          " << g.getXStep()
				   << "\nY step:          " << g.getYStep()
				   << "\nVar number:      " << g.getVarNum()
				   << "\nSlot size:       " << g.getSlotSize()
				   << "\nSRID:            " << g.getSRID()
				   << "\nUndefined value: " << g.getUndefValue()
				   << "\n\n";*/

			for( int i = 0; i < g.getRows(); i++ )
			{
				for( int j = 0; j < g.getCols(); j++ )
				{
					for( int k = 0; k < g.getVarNum(); k++ )
					{
						stream << g(i, j, k);
					}

				}
			}

			return stream;
		}

		template<typename T>
		istream& operator >> (istream& stream, Grid<T>& g)
		{

			for( int i = 0; i < g.getRows(); i++ )
			{
				for( int j = 0; j < g.getCols(); j++ )
				{
					for( int k = 0; k < g.getVarNum(); k++ )
					{
						stream >> g(i, j, k);
					}
				}
			}

			return stream;
		}

		ostream& operator << (ostream& stream, Point& p)
		{
			stream << p;

			return stream;
		}

		ostream& operator << (ostream& stream, Point* p)
		{
			assert( p != NULL );

			stream << *p;

			return stream;
		}

		istream& operator >> (istream& stream, Point& p)
		{
			stream >> p;

			return stream;
		}

		istream& operator >> (istream& stream, Point* p)
		{
			assert( p != NULL );

			stream >> *p;

			return stream;
		}

		/**
		 * \typedef	typedef Grid<Point*> PointGrid_t
		 * \brief	standard grid with 1 Point* variable
		 */
		typedef Grid<Point*> PointGrid_t;

		/**
		 * \typedef	typedef Grid<float> Float1Grid_t
		 * \brief	standard grid with 1 float variable
		 */
		typedef Grid<float>  Float1Grid_t;

		/**
		 * \typedef	typedef Grid<int> Int1Grid_t;
		 * \brief	standard grid with 1 int variable
		 */
		typedef Grid<int>    Int1Grid_t;

	}	// namespace grid

}	// namespace fwi

#endif /* GRID_H_ */
