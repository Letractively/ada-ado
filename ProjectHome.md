The Ada Database Objects is an [Object Relational Mapping](http://en.wikipedia.org/wiki/Object-relational_mapping) for the Ada05 programming language.  It allows to map database
objects into Ada records and access databases content easily.

The ORM uses an XML mapping file or a UML model, a code generator and a runtime library for the implementation.  It provides a database driver for [MySQL](http://www.mysql.com/)
and [SQLite](http://www.sqlite.org/).

## This project was moved to `GitHub`. ##

The new location is: https://github.com/stcarrez/ada-util/wiki

The Git repository is: https://github.com/stcarrez/ada-util.git

## NEWS ##


Version 1.0.1 released on Jul 2014 is available http://download.vacs.fr/ada-ado/ada-ado-1.0.1.tar.gz

  * Fix minor configuration issue with GNAT 2014

Version 1.0 released on Apr 2014 is available http://download.vacs.fr/ada-ado/ada-ado-1.0.0.tar.gz

  * Support to load query results in Ada bean datasets
  * Added support to load dynamic database drivers
  * Port on FreeBSD
  * Support for the creation of Debian packages

[Older news](NEWS.md)

# Tutorial #

  * [Using ADO](http://code.google.com/p/ada-ado/wiki/UsingADO)
  * [Simple Mapping Example](SimpleMappingExample.md)
  * [Query Mapping](QueryMapping.md)