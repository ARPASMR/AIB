/*
 * GridField.h
 *
 *  Created on: 26/mar/2012
 *      Author: buck
 */

/**
 * \file	GridField.h
 * \brief	Grid field description class
 */

#ifndef GRIDFIELD_H_
#define GRIDFIELD_H_

using namespace std;

#include "fwi_define.h"
#include <string>
#include <vector>

namespace fwi
{
	namespace grid
	{
		/**
		 * \typedef	GRID_VALUE_TYPE
		 * \brief	value type to be stored in grid
		 */
		typedef enum {
						INTEGER = 0,	/**< int type */
						FLOAT = 1,		/**< float type */
						STRING = 2,		/**< string type */
						POINT = 3 		/**< point type */
					 }
					GRID_VALUE_TYPE;

		/**
		 * \typedef	levels_t
		 * \brief	GrADS var levels
		 */
		typedef vector<int> levels_t;

		/**
		 * \class	GridField
		 * \brief	grid field descriptor class
		 */
		class GridField
		{
		public:



		private:

			int				position;
			string          name;
			string          field_name;
			levels_t		levels;
			int				units;
			string			description;
			GRID_VALUE_TYPE type;

		public:

			/**
			 * \fn		GridField()
			 * \brief	Standard constructor
			 */
			GridField();

			/**
			 * \fn		GridField(int position, string name, string field_name, levels_t levels, int units, string description, GRID_VALUE_TYPE type = FLOAT)
			 * \brief	Parameterized constructor
			 * \param	position position in field list
			 * \param	name field name
			 * \param	field_name database field name
			 * \param	levels levels vector
			 * \param	units GrADS units tag
			 * \param	description field description
			 * \param	type field type
			 */
			GridField(
						int             position,
						string          name,
						string          field_name,
						levels_t        levels,
						int             units,
						string          description,
					    GRID_VALUE_TYPE type = FLOAT
					 );

			/**
			 * \fn		GridField(const GridField& field)
			 * \brief	Copy constructor
			 */
			GridField(const GridField& field);

			/**
			 * \fn		~GridField()
			 * \brief	Destructor
			 */
			virtual ~GridField();

			/**
			 * \fn		int getPosition() const
			 * \brief	position getter
			 * \return	field position
			 */
			int	                 getPosition() const;

			/**
			 * \fn		string getName() const
			 * \brief	name getter
			 * \return	field name
			 */
			string               getName() const;

			/**
			 * \fn		string getFieldName() const
			 * \brief	field name getter
			 * \return  field name
			 */
			string               getFieldName() const;

			/**
			 * \fn		levels_t getLevels() const
			 * \brief	levels getter
			 * \return	levels
			 */
			levels_t             getLevels() const;

			/**
			 * \fn		int getUnits() const
			 * \brief	units getter
			 * \return	units
			 */
			int                  getUnits() const;

			/**
			 * \fn		string getDescription() const
			 * \brief	description getter
			 * \return	description
			 */
			string               getDescription() const;

			/**
			 * \fn		GRID_VALUE_TYPE      getType() const
			 * \brief	type getter
			 * \return	field type
			 */
			GRID_VALUE_TYPE      getType() const;

			/**
			 * \fn		void setPosition(in position)
			 * \brief	position setter
			 * \param	position new field position
			 */
			void                 setPosition(int position);

			/**
			 * \fn		void setName(string name)
			 * \brief	name setter
			 * \param	name new field name
			 */
			void                 setName(string name);

			void                 setFieldName(string fieldname);

			/**
			 * \fn		void setLevels(levels_t levels)
			 * \brief	levels setter
			 */
			void                 setLevels(levels_t levels);

			/**
			 * \fn		void setUnits(int units)
			 * \brief	units setter
			 */
			void                 setUnits(int units);

			/**
			 * \fn		void setDescription(string description)
			 * \brief	description setter
			 */
			void                 setDescription(string description);

			/**
			 * \fn		void setType(GRID_VALUE_TYPE type)
			 * \brief	type setter
			 * \param	type new field type
			 */
			void                 setType(GRID_VALUE_TYPE type);

			/**
			 * \fn		GridField& operator = (GridField& field)
			 * \brief	assignment operator
			 * \param	field assigned value
			 * \return	the changed object
			 */
			GridField& operator  = (GridField& field);

			/**
			 * \fn		GridField& operator = (GridField* field)
			 * \brief	assignment operator
			 * \param	field object to be assigned
			 * \return  <b>this</b> after assignment
			 */
			GridField& operator  = (GridField* field);

			/**
			 * \fn		bool operator == (GridField& field);
			 * \brief	equality operator
			 * \param	field object to test for equality
			 * \return	true on equality else false
			 */
			bool                 operator == (GridField& field);

			/**
			 * \fn		bool operator == (GridField* field);
			 * \brief	equality operator
			 * \param	field object to test for equality
			 * \return	true on equality else false
			 */
			bool                 operator == (GridField* field);

			/**
			 * \fn		friend ostream& operator << (ostream& stream, GridField  gfd)
			 * \brief	output stream operator
			 */
			friend ostream& operator << (ostream& stream, GridField  gfd);

			/**
			 * \fn		friend ostream& operator << (ostream& stream, GridField* gfd)
			 * \brief	output stream operator
			 */
			friend ostream& operator << (ostream& stream, GridField* gfd);

			/**
			 * \fn		friend istream& operator >> (istream& stream, GRID_VALUE_TYPE& t)
			 * \brief	input stream operator
			 */
			friend istream& operator >> (istream& stream, GRID_VALUE_TYPE& t);

			/**
			 * \fn		friend istream& operator >> (istream& stream, GridField& gfd)
			 * \brief	input stream operator
			 */
			friend istream& operator >> (istream& stream, GridField& gfd);
		};

		/**
		 * \typedef	fields_t
		 * \brief	shortcut for list<GridField*>
		 */
		typedef vector<GridField*> fields_t;

		/**
		 * \typedef	fields_iterator_t
		 * \brief	shortcut for list<GridField*>::iterator
		 */
		typedef vector<GridField*>::iterator fields_iterator_t;

		/**
		 * \class	GridFields
		 * \brief	Fields list class
		 */
		class GridFields : public fields_t
		{
		public:

			/**
			 * \fn		GridFields()
			 * \brief	Standard constructor
			 */
			GridFields();

			/**
			 * \fn		GridFields(int fieldsNum)
			 * \brief	Parameterized constructor
			 * \param	fieldsNum fields number
			 */
			GridFields(int fieldsNum);

			/**
			 * \fn		GridFields(int fieldsNum, GRID_VALUE_TYPE type)
			 * \brief	Parameterized constructor
			 * \param	fieldsNum fields number
			 * \param	type fields type
			 */
			GridFields(int fieldsNum, GRID_VALUE_TYPE type);

			/**
			 * \fn		virtual ~GridFields()
			 * \brief	Destructor
			 */
			virtual ~GridFields();

			// fields management
			/**
			 * \fn		int getFieldsNum() const
			 * \brief	fields number getter
			 * \return	fields number
			 */
			int getFieldsNum() const;

			/**
			 * \fn		void addField(GridField* field)
			 * \brief	adds a field to fields list
			 * \param	field new field
			 */
			void addField(GridField* field);

			/**
			 * \fn		void addField(int position, string name, string field_name, levels_t levels, int units, string description, GRID_VALUE_TYPE type = FLOAT)
			 * \brief	adds a field to fields list by its parameters
			 * \param	position field's position
			 * \param	name field's name
			 * \param	field_name database field's name
			 * \param	levels levels vector
			 * \param	units field units
			 * \param	description field description
			 * \param	type field's type
			 */
			void addField(int position, string name, string field_name, levels_t levels, int units, string description, GRID_VALUE_TYPE type = FLOAT);

			/**
			 * \fn		void removeField(GridField* field)
			 * \brief	removes field from fields list
			 * \param	field field to be removed
			 */
			void removeField(GridField* field);

			/**
			 * \fn		void removeField(string name)
			 * \brief	removes field by name
			 * \param	name name of field to be removed
			 */
			void removeField(string name);

			/**
			 * \fn		bool hasField(GridField* field)
			 * \brief	checks if field is in fields list
			 * \return	true if field is present else false
			 */
			bool hasField(GridField* field);

			/**
			 * \fn		bool hasField(string name)
			 * \brief	checks if field with name is present in fields list
			 * \param	name name to check for
			 * \return	true if field is present else false
			 */
			bool hasField(string name);

			/**
			 * \fn		GridField* getFieldByName(string& name)
			 * \brief   Gets a <i>GridField</i> given its name
			 * \param	name the searched field name
			 * \return	The <i>GridField</i> which name is <i>name</i> else NULL
			 */
			GridField* getFieldByName(string& name);

			/**
			 * \fn		getFieldPosition(string& name)
			 * \brief	Gets field <i>position</i> given its name
			 * \paran	name the searched field name
			 * 	return	The <i>GridField</i> position of field named with <i>name</i>.
			 * 	        If field's name is not found (NOT_FOUND = -1) is returned.
			 */
			int        getFieldPosition(string& name);

			/**
			 * \fn		GridField* getFieldByFieldName(string& fname)
			 * \brief   Gets a <i>GridField</i> given its field name
			 * \param	fname the searched field name
			 * \return	The <i>GridField</i> which fieldname is <i>name</i> else NULL
			 */
			GridField* getFieldByFieldName(string& fname);

			/**
			 * \fn		getFieldNamePosition(string& fname)
			 * \brief	Gets field <i>position</i> given its field name
			 * \paran	name the searched field field name
			 * 	return	The <i>GridField</i> position of field named with <i>fname</i>.
			 * 	        If field's fname is not found (NOT_FOUND = -1) is returned.
			 */
			int getFieldNamePosition(string& fname);

			void raw_dump();

		};

	}	// namespace grid

} /* namespace fwi */

#endif /* GRIDFIELD_H_ */
