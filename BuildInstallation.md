# Introduction #

Before building ADO, you will need:

  * Ada Util (http://code.google.com/p/ada-util)
  * XML/Ada  (http://libre.adacore.com/libre/tools/xmlada/)

The following databases are supported:

  * SQLite
  * MySQL

# Database Drivers #

The MySQL and SQLite development headers and runtime are necessary for building the ADO driver.  The configure script will use them to enable the ADO drivers.

## MySQL Development installation ##

> sudo apt-get install libmysqlclient-dev


## SQLite Development installation ##

> sudo apt-get install libsqlite3-dev


For Windows, check win32/README to install the libraries.

# Configure #


> ./configure
> make