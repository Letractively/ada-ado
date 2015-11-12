## Session Factory ##

The session factory is the entry point to obtain a database session.

```
with ADO.Sessions;
with ADO.Sessions.Factory;
   ...
   Sess_Factory : ADO.Sessions.Factory.Session_Factory;
```

## Factory Initialization ##

The factory can be initialized by giving a URI string that identifies the
driver and the information to connect to the database.

```
   ADO.Sessions.Factory.Create (Sess_Factory, "mysql://localhost:3306/ado_test?user=test");
```

## Opening a Session ##

The session is created by using the `Get_Session` function of the factory.
The session is associated with a database connection.

```
   S : ADO.Sessions.Session := Sess_Factory.Get_Session;
```