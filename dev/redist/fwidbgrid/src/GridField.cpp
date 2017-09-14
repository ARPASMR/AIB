/*
 * GridField.cpp
 *
 *  Created on: 26/mar/2012
 *      Author: buck
 */

/**
 * \file	GridField.cpp
 * \brief	Grid field class implementation
 */

#include <iostream>
#include <assert.h>
#include <algorithm>
#include "GridField.h"

namespace fwi
{
	namespace grid
	{

		GridField::GridField()
		{
			position = 0;
			name     = "nomame";
			type     = FLOAT;
			units    = 0;
		}

		GridField::GridField(int position, string name, string field_name, levels_t levels, int units, string description, GRID_VALUE_TYPE type)
		{
			this->position    = position;
			this->name        = name;
			this->field_name  = field_name;
			this->levels      = levels;
			this->units       = units;
			this->description = description;
			this->type        = type;
		}

		GridField::GridField(const GridField& field)
		{
			if( &field != this )
			{
				position    = field.position;
				name        = field.name;
				field_name  = field.field_name;
				levels      = field.levels;
				units       = field.units;
				description = field.description;
				type        = field.type;
			}
		}

		int GridField::getPosition() const
		{
			return position;
		}

		string GridField::getName() const
		{
			return name;
		}

		string GridField::getFieldName() const
		{
			return field_name;
		}

		levels_t GridField::getLevels() const
		{
			return levels;
		}

		int GridField::getUnits() const
		{
			return units;
		}

		string GridField::getDescription() const
		{
			return description;
		}

		GRID_VALUE_TYPE GridField::getType() const
		{
			return type;
		}

		void GridField::setPosition(int position)
		{
			this->position = position;
		}

		void GridField::setName(string name)
		{
			this->name = name;
		}

		void GridField::setFieldName(string fieldname)
		{
			field_name = fieldname;
		}

		void GridField::setLevels(levels_t levels)
		{
			this->levels = levels;
		}

		void GridField::setUnits(int units)
		{
			this->units = units;
		}

		void GridField::setDescription(string description)
		{
			this->description = description;
		}

		void GridField::setType(GRID_VALUE_TYPE type)
		{
			this->type = type;
		}

		GridField::~GridField()
		{
		}

		GridField& GridField::operator = (GridField& field)
		{
			if( &field != this )
			{
				position    = field.position;
				name        = field.name;
				field_name  = field.field_name;
				levels      = field.levels;
				units       = field.units;
				description = field.description;
				type        = field.type;
			}

			return *this;
		}

		GridField& GridField::operator = (GridField* field)
		{
			assert( field != NULL );

			if( field != this )
			{
				position    = field->position;
				name        = field->name;
				field_name  = field->field_name;
				levels      = field->levels;
				units       = field->units;
				description = field->description;
				type        = field->type;
			}

			return *this;
		}

		bool GridField::operator == (GridField& field)
		{
			return ( (position == field.position) && (name == field.name) && (type == field.type) &&
					 (units    == field.units)    && (description == field.description));
		}

		bool GridField::operator == (GridField* field)
		{
			assert( field != NULL );

			return ( *this == *field );
		}

		ostream& operator<<(ostream &stream, GridField gfd)
		{
		  stream << gfd.position << ' ' << gfd.name << ' ' << gfd.units << ' ' << gfd.description << endl;

		  return stream;
		}

		ostream& operator<<(ostream &stream, GridField* gfd)
		{
		  stream << gfd->name << ' ' << gfd->levels[0] << ' ' << gfd->units << ' ' << gfd->description;

		  return stream;
		}

		istream& operator >> (istream& stream, GRID_VALUE_TYPE& t)
		{
			stream >> t;

			return stream;
		}

		istream& operator>>(istream &stream, GridField& gfd)
		{
		  stream >> gfd.position >> gfd.name >> gfd.units >> gfd.description;

		  return stream;
		}


		// GridFields

		GridFields::GridFields()
		{
		}

		GridFields::GridFields(int fieldsNum)
		{
			for( int i = 0; i < fieldsNum; i++ )
			{
				GridField* p = new GridField();
				p->setPosition(i);
			}
		}

		GridFields::GridFields(int fieldsNum, GRID_VALUE_TYPE type)
		{
			for( int i = 0; i < fieldsNum; i++ )
			{
				GridField* p = new GridField();
				p->setPosition(i);
				p->setType(type);
			}
		}

		GridFields::~GridFields()
		{
			for( size_t i = 0; i < size(); i++ )
			{
				delete at(i);
			}

			clear();
		}

		int  GridFields::getFieldsNum() const
		{
			return size();
		}

		void GridFields::addField(GridField* field)
		{
			push_back(field);
		}

		void GridFields::addField(int position, string name, string field_name, levels_t levels, int units, string description, GRID_VALUE_TYPE type)
		{
			GridField* f = new GridField(position, name, field_name, levels, units, description, type);
			assert( f != NULL );
			push_back(f);
		}

		void GridFields::removeField(GridField* field)
		{
			assert( field != NULL );
			fields_iterator_t i = find(this->begin(), this->end(), field);

			if( i != this->end() )
			{
				erase(i);
			}
		}

		void GridFields::removeField(string name)
		{
			for( vector<GridField*>::iterator i = begin(); i != end(); i++ )
			{
				if( (*i)->getName() == name )
				{
					erase(i);
					break;
				}
			}
		}

		bool GridFields::hasField(GridField* field)
		{
			fields_iterator_t i = find(this->begin(), this->end(), field);
			return (i != this->end());
		}

		bool GridFields::hasField(string name)
		{
			for( fields_iterator_t i = begin(); i != end(); i++ )
			{
				if( (*i)->getName() == name )
				{
					return true;
				}
			}

			return false;
		}

		GridField* GridFields::getFieldByName(string& name)
		{
			GridField* result = NULL;

			for( fields_iterator_t i = begin(); i != end(); i++ )
			{
				if( (*i)->getName() == name )
				{
					result = *i;
					break;
				}
			}

			return result;
		}

		int GridFields::getFieldPosition(string& name)
		{
			int result = NOT_FOUND;

			GridField* field = NULL;

			field = getFieldByName(name);

			if( field != NULL )
			{
				result = field->getPosition();
			}

			return result;
		}

		int GridFields::getFieldNamePosition(string& fname)
		{
			int result = NOT_FOUND;

			GridField* field = NULL;

			field = getFieldByFieldName(fname);

			if( field != NULL )
			{
				result = field->getPosition();
			}

			return result;
		}

		GridField* GridFields::getFieldByFieldName(string& fname)
		{
			GridField* result = NULL;

			for( fields_iterator_t i = begin(); i != end(); i++ )
			{
				if( (*i)->getFieldName() == fname )
				{
					result = *i;
					break;
				}
			}

			return result;
		}

		void GridFields::raw_dump()
		{
			for( fields_iterator_t i = begin(); i != end(); i++ )
			{
				cout << "[" << (*i)->getPosition() << "] " << (*i)->getName() << " " << (*i)->getType() << endl;
			}
		}

	}	// namespace grid

} /* namespace fwi */
