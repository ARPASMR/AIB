/*
 * CommandLineArguments.cpp
 *
 *  Created on: 26/mar/2012
 *      Author: buck
 */

/**
 * \file	CommandLineArguments.cpp
 * \brief	command line argument class implementation
 */

#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <string>

#include "CommandLineArguments.h"

using namespace std;

namespace fwi
{

	CommandLineArguments::CommandLineArguments()
	{
		action   = "";
		date     = "";
		dbname   = "";
		host     = "";
		port     = 0;
		user     = "";
		password = "";
		help     = false;
		conn     = NULL;
	}

	string CommandLineArguments::getConfigFilePath() const
	{
		return configFilePath;
	}

    string CommandLineArguments::getAction() const
    {
        return action;
    }

    string CommandLineArguments::getDate() const
    {
        return date;
    }

    string CommandLineArguments::getDbName() const
    {
    	return dbname;
    }

    string CommandLineArguments::getHost() const
    {
        return host;
    }

    string CommandLineArguments::getPassword() const
    {
        return password;
    }

    int CommandLineArguments::getPort() const
    {
        return port;
    }

    string CommandLineArguments::getUser() const
    {
        return user;
    }

    bool CommandLineArguments::getHelp() const
    {
    	return help;
    }

    PGconn *CommandLineArguments::getPGConnection(Config& cfg, bool create)
    {

    	if( conn == NULL )
    	{
    		string conn_str;
    		if( create )
    		{
    			conn_str = getSuperUserConnectionString(cfg);
    		}
    		else
    		{
    			conn_str = getConnectionString();
    		}
    		conn = PQconnectdb(conn_str.c_str());
			if( PQstatus(conn) == CONNECTION_BAD )
			{
				cout << "Unable to connect to the database" << endl;
			}
    	}
    	return conn;
    }

    void CommandLineArguments::closePGConnection()
    {
    	if( conn != NULL )
    	{
    		PQfinish(conn);
    		conn = NULL;
    	}
    }

    void CommandLineArguments::setConfigFilePath(string cfgpath)
    {
    	this->configFilePath = cfgpath;
    }

    void CommandLineArguments::setAction(string action)
    {
        this->action = action;
    }

    void CommandLineArguments::setDate(string date)
    {
        this->date = date;
    }

    void CommandLineArguments::setDbName(string dbname)
    {
    	this->dbname = dbname;
    }

    void CommandLineArguments::setHost(string host)
    {
        this->host = host;
    }

    void CommandLineArguments::setPassword(string password)
    {
        this->password = password;
    }

    void CommandLineArguments::setPort(int port)
    {
        this->port = port;
    }

    void CommandLineArguments::setUser(string user)
    {
        this->user = user;
    }

    void CommandLineArguments::setHelp(bool help)
    {
    	this->help = help;
    }

    bool CommandLineArguments::isSetAction()
    {
    	return !this->action.empty();
    }

    bool CommandLineArguments::isSetDate()
    {
    	return !this->date.empty();
    }

	bool CommandLineArguments::isSetHost()
	{
		return !this->host.empty();
	}

	bool CommandLineArguments::isSetDbName()
	{
		return !this->dbname.empty();
	}

	bool CommandLineArguments::isSetPassword()
	{
		return !this->password.empty();
	}

	bool CommandLineArguments::isSetPort()
	{
		return this->port != 0;
	}

	bool CommandLineArguments::isSetUser()
	{
		return !this->user.empty();
	}

	bool CommandLineArguments::isSetHelp()
	{
		return help;
	}

	CommandLineArguments::~CommandLineArguments()
	{
	}

	bool CommandLineArguments::canTryDbConnection()
	{
		return (
				!host.empty()    &&
				!dbname.empty()  &&
				port     != 0    &&
				!user.empty()    &&
				!password.empty() );
	}

	string CommandLineArguments::getConnectionString()
	{
		char   s[10];
		string result = "";
		// dbname=fwidb host=localhost user=meteo password=chi66rone
		result  = "dbname=";
		result += dbname;
		result += " host=";
		result += host;
		result += " port=";
		sprintf(s, "%d", port);
		result += s;
		result += " user=";
		result += user;
		result += " password=";
		result += password;

		return result;
	}

	string CommandLineArguments::getSuperUserConnectionString(Config& cfg)
	{
		// dbname=fwidb host=localhost user=meteo password=chi66rone

		char   s[10];
		string result = "";

		string superuser = cfg.lookup("fwidbmgr.dbconnection.superuser").c_str();
		string superpwd  = cfg.lookup("fwidbmgr.dbconnection.superpwd").c_str();

		result  = "dbname=postgres";

		result += " host=";
		result += host;
		result += " port=";
		sprintf(s, "%d", port);
		result += s;
		result += " user=";
		result += superuser;
		result += " password=";
		result += superpwd;

		return result;
	}

} // namespace fwi
