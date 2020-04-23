/*
 * CommandLineArguments.h
 *
 *  Created on: 26/mar/2012
 *      Author: buck
 */

/**
 * \file	CommandLineArguments.h
 * \brief	Command line arguments class
 */

#ifndef COMMANDLINEARGUMENTS_H_
#define COMMANDLINEARGUMENTS_H_

//#define __OPENSUSE_11_3__
//#undef __OPENSUSE_11_3__

// postgresql support
#ifdef __OPENSUSE_11_3__
#include <pgsql/libpq-fe.h>
#else
#include <libpq-fe.h>
#endif

// libconfig support
#include <libconfig.h++>

#include <string>

using namespace std;
using namespace libconfig;

namespace fwi
{

	/**
	 * \class	CommandLineArguments
	 * \brief	Command line arguments class
	 * 			This class stores and manages command line arguments passed to fwidbmgr.
	 *
	 * 			<h2>fwidbmgr synopsys</h2>
	 * 			<i>fwidbmgr -a action [-d date] [-D database] [-H host] [-P port] [-U user] [-p password] [-h]</i><br />
	 * 			The possible actions for <b>fwidbmgr</b> are:<br />
	 * 			<table border="0">
	 *            <tr><td><b>create</b></td><td>create an empty database structure</td></tr>
	 *            <tr><td><b>createstdgrid</b></td><td>creates the standard 177x174 point grid</td></tr>
	 *            <tr><td><b>fillnometeo</b></td><td>fills nometeo field in standard grid</td></tr>
	 *            <tr><td><b>fillregionmask</b></td><td>fills mask field in standard grid</td></tr>
	 *            <tr><td><b>in</b></td><td>save in db input data for date given by option date</td></tr>
	 *            <tr><td><b>out</b></td><td>save in db output data of fwi indexes computation</td></tr>
	 *            <tr><td><b>outimg</b></td><td>save in db output images</td></tr>
	 *          </table>
	 *
	 * - <i>date</i> must be a valid date in ISO 8601 format ex. (2012-03-22)
	 * - <i>database</i> is the database name to be used
	 * - <i>host</i> is the database host name or IP address
	 * - <i>port</i> is the postgresql port
	 * - <i>user</i> is the database user that has the proper rights
	 * - <i>where</i> password is the user password
	 *
	 *  <b>h</b> --> prints this text
	 */
	class CommandLineArguments
	{
		string  configFilePath;
		string  action;
		string  date;
		string  dbname;
		string  host;
		int     port;
		string  user;
		string  password;
		bool    help;
		PGconn* conn;

		string  getSuperUserConnectionString(Config& cfg);

	public:

		/**
		 * \fn		CommandLineArguments()
		 * \brief	Standard constructor.
		 */
		CommandLineArguments();

		/**
		 * \fn		~CommandLineArguments()
		 * \brief	Destructor
		 */
		virtual ~CommandLineArguments();

		/**
		 * \fn		string getConfigFilePath() const
		 * \brief	Config file path getter.
		 * \return	configFilePath argument
		 */
		string getConfigFilePath() const;

		/**
		 * \fn		string getAction() const
		 * \brief	Action getter.
		 * \return	action argument
		 */
		string getAction() const;

		/**
		 * \fn		string getDate()
		 * \brief	Date getter.
		 * \return	date argument
		 */
		string getDate() const;

		/**
		 * \fn		string getDbName()
		 * \brief	Database name getter.
		 * \return	database name argument
		 */
		string getDbName() const;

		/**
		 * \fn		string getHost()
		 * \brief	Host getter.
		 * \return	host argument
		 */
		string getHost() const;

		/**
		 * \fn		int getPort()
		 * \brief	Port getter.
		 * \return	port argument
		 */
		int    getPort() const;

		/**
		 * \fn		string getUser()
		 * \brief	User getter.
		 * \return	user argument
		 */
		string getUser() const;

		/**
		 * \fn		string getPassword()
		 * \brief	Password getter.
		 * \return	password argument
		 */
		string getPassword() const;

		/**
		 * \fn		bool getHelp()
		 * \brief	Help argument presence.
		 * \return	true help argument passed to program else false
		 */
		bool   getHelp() const;

		/**
		 * \fn		PGconn *getPGConnection(Config& cfg, bool create = false)
		 * \brief	Gets postgresql connection
		 * \param	cfg configuration class from libconfig++
		 * \param	create if true create a new connection
		 * \return	postgresql connection
		 * @see libconfig++ documentation at http://www.hyperrealm.com/libconfig/
         * @see postgresql documentation at http://www.postgresql.org/
		 */
		PGconn *getPGConnection(Config& cfg, bool create = false);

		/**
		 * \fn		void closePGConnection()
		 * \brief	Gently close postgresql connection.
		 * @see postgresql documentation at http://www.postgresql.org/
		 */
		void    closePGConnection();

		/**
		 * \fn		void setConfigFilePath(string cfgpath)
		 * \brief	ConfigFilePath setter
		 * \param	cfgpath configFilePath to set
		 */
		void	setConfigFilePath(string cfgpath);

		/**
		 * \fn		void setAction(string action)
		 * \brief	Action setter.
		 * \param	action action to set
		 */
		void    setAction(string action);

		/**
		 * \fn		void setDate(string date)
		 * \brief	Date setter.
		 * \param	date date to set
		 */
		void    setDate(string date);

		/**
		 * \fn		void setHost(string host)
		 * \brief	Host setter.
		 * \param	host host to set
		 */
		void    setHost(string host);

		/**
		 * \fn		void setDbName(string dbname)
		 * \brief	Database name setter.
		 * \param	dbname databasee name to set
		 */
		void    setDbName(string dbname);

		/**
		 * \fn		void setPort(int port)
		 * \brief	Port setter.
		 * \param	port port to set
		 */
		void    setPort(int port);

		/**
		 * \fn		void setUser(string user)
		 * \brief	User setter.
		 * \param	user user to set
		 */
		void    setUser(string user);

		/**
		 * \fn		void setPassword(string password)
		 * \brief	Password setter.
		 * \param	password password to set
		 */
		void    setPassword(string password);

		/**
		 * \fn		void setHelp(bool help)
		 * \brief	Help flag setter.
		 * \param	help help flag to set
		 */
	    void    setHelp(bool help);

		/**
		 * \fn		bool isSetAction()
		 * \brief	Checks for action setting.
		 * \return	true if action is set else false
		 */
	    bool    isSetAction();

		/**
		 * \fn		bool isSetDate()
		 * \brief	Checks for date setting.
		 * \return	true if date is set else false
		 */
	    bool    isSetDate();

		/**
		 * \fn		bool isSetHost()
		 * \brief	Checks for host setting.
		 * \return	true if host is set else false
		 */
	    bool    isSetHost();

		/**
		 * \fn		bool isSetDbName()
		 * \brief	Checks for database name setting.
		 * \return	true if database name is set else false
		 */
	    bool    isSetDbName();

		/**
		 * \fn		bool isSetPort()
		 * \brief	Checks for port setting.
		 * \return	true if port is set else false
		 */
	    bool    isSetPort();

		/**
		 * \fn		bool isSetUser()
		 * \brief	Checks for user setting.
		 * \return	true if user is set else false
		 */
	    bool    isSetUser();

		/**
		 * \fn		bool isSetPassword()
		 * \brief	Checks for password setting.
		 * \return	true if password is set else false
		 */
	    bool    isSetPassword();

		/**
		 * \fn		bool isSetHelp()
		 * \brief	Checks for help setting.
		 * \return	true if help is set else false
		 */
	    bool    isSetHelp();

		/**
		 * \fn		bool canTryDbConnection()
		 * \brief	Checks if a database connection could be done based on current settings.
		 * \return	true if can try connection else false
		 */
	    bool    canTryDbConnection();

		/**
		 * \fn		string getConnectionString()
		 * \brief	Gets the connection string based on current settings.
		 * \return	the connection string
		 */
	    string  getConnectionString();

	};

} /* namespace fwi */
#endif /* COMMANDLINEARGUMENTS_H_ */
