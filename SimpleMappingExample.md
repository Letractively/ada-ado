# Introduction #

The XML mapping file defines how the SQL columns are mapped in the Ada record.
From the XML mapping, the [Ada Generator](http://code.google.com/p/ada-gen) will generate the package specification and body that will hold the Ada record declaration.

The XML mapping definition comes from the [Hibernate](http://www.hibernate.org) java framework.  The [Hibernate Mapping](http://docs.jboss.org/hibernate/core/3.6/reference/en-US/html/mapping.html) documentation gives the details of the mapping.  The Ada ADO runtime and Ada Generator only support a subset of Hibernate mapping.

## Entity Declaration ##

The entity declaration is defined by the **class** element in the XML file:
```
<?xml version="1.0" encoding="UTF-8"?>
<hibernate-mapping default-cascade="none">
    <class name="Samples.User.Model.User_Ref"
           table="user">
        <comment>Record representing a user</comment>
        ...
    </class>
</hibernate-mapping>
```

The **name** attribute indicates the Ada type name and the **table** attribute refers to the database table name.  The Ada type name also specifies the package name (the `User_Ref` tagged record in the `Samples.User.Model` package).

## Entity Identifier ##

The entity identifier represents the primary key that allows to retrieve
an object from the database.  The identifier is specified by the **id** element as follows:

```
  <id name="id" type="ADO.Identifier" unsaved-value="0">
    <comment>the user identifier</comment>
    <column name="ID" not-null="true" unique="true" sql-type="BIGINT"/>
    <generator class="sequence"/>
  </id>
```

The **name** attribute defines the name of the identifier.  The generator will generate a `Get_XXX` function and a `Set_XXX` procedure.  The identifier type is defined by the **type** attribute.  The ADO runtime only supports `ADO.Identifier` (to be used for integer based columns) and `String`.

The SQL column associated with the identifier is defined by the **name** attribute in the **column** element.  The **sql-type** attribute indicates the SQL type.

The **generator** element defines how the identifier is allocated.
The ADO runtime supports:

  * **none**: the identifier is allocated by the application.
  * **sequence**: the identifier is allocated by the database (auto-increment).
  * **hilo**: the identifier is allocated by an efficient sequence generator.

## Optimistic Locking Property ##

The ADO runtime provides a support for optimistic locking based on an object version number (timestamp optimistic locking is not supported).  To enable this mechanism you must declare a **version** element with a column name that will hold the object version.

```
  <version name="version" type="int" column="object_version"/>
```

## Entity Properties ##

Each entity property has to be declared by using the **property** specification.

```
  <property name="name" type="String">
    <comment>the user name</comment>
    <column name="NAME" not-null="false" unique="false" sql-type="VARCHAR(256)"/>
    <type name="String"/>
  </property>
```

The **name** attribute indicates the property name.  The generator will use this name for the generation of the `Get_XXX` and `Set_XXX` accessors.

The **type** attribute indicates the property type.

The SQL column is represented by the **column** element.

The Ada generator and runtime support the following types:

  * **String**: mapped to Ada.Strings.Unbounded.Unbounded\_String
  * **Integer**: mapped to Integer
  * **Time**: mapped to Ada.Calendar.Time

## Generation ##

The Ada files are generated from the hibernate mapping file with the command:

```
dynamo generate db/samples
```

## Links ##

[user.hbm.xml](http://code.google.com/p/ada-ado/source/browse/trunk/db/samples/user.hbm.xml)

[samples-user-model.ads](http://code.google.com/p/ada-ado/source/browse/trunk/samples/model/samples-user-model.ads) (Generated package specification)