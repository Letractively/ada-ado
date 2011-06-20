-----------------------------------------------------------------------
--  ADO Drivers -- Database Drivers
--  Copyright (C) 2010, 2011 Stephane Carrez
--  Written by Stephane Carrez (Stephane.Carrez@gmail.com)
--
--  Licensed under the Apache License, Version 2.0 (the "License");
--  you may not use this file except in compliance with the License.
--  You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
--  Unless required by applicable law or agreed to in writing, software
--  distributed under the License is distributed on an "AS IS" BASIS,
--  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--  See the License for the specific language governing permissions and
--  limitations under the License.
-----------------------------------------------------------------------

with Util.Log.Loggers;

with Ada.IO_Exceptions;
with Ada.Strings.Fixed;
with Ada.Containers.Doubly_Linked_Lists;

with ADO.Queries.Loaders;
package body ADO.Drivers is

   use Util.Log;
   use Ada.Strings.Fixed;

   Log : constant Loggers.Logger := Loggers.Create ("ADO.Drivers");

   --  Global configuration properties (loaded by Initialize).
   Global_Config : Util.Properties.Manager;

   --  ------------------------------
   --  Initialize the drivers and the library by reading the property file
   --  and configure the runtime with it.
   --  ------------------------------
   procedure Initialize (Config : in String) is
   begin
      Log.Info ("Initialize using property file {0}", Config);

      begin
         Util.Properties.Load_Properties (Global_Config, Config);
      exception
         when Ada.IO_Exceptions.Name_Error =>
            Log.Error ("Configuration file '{0}' does not exist", Config);
      end;

      Initialize (Global_Config);
   end Initialize;

   --  ------------------------------
   --  Initialize the drivers and the library and configure the runtime with the given properties.
   --  ------------------------------
   procedure Initialize (Config : in Util.Properties.Manager'Class) is
   begin
      Global_Config := Util.Properties.Manager (Config);

      --  Configure the XML query loader.
      ADO.Queries.Loaders.Initialize (Global_Config.Get ("ado.queries.paths", ".;db"),
                                      Global_Config.Get ("ado.queries.load", "false") = "true");

      --  Initialize the drivers.
      ADO.Drivers.Initialize;
   end Initialize;

   --  ------------------------------
   --  Get the global configuration property identified by the name.
   --  If the configuration property does not exist, returns the default value.
   --  ------------------------------
   function Get_Config (Name    : in String;
                        Default : in String := "") return String is
   begin
      return Global_Config.Get (Name, Default);
   end Get_Config;

   --  ------------------------------
   --  Set the connection URL to connect to the database.
   --  The driver connection is a string of the form:
   --
   --   driver://[host][:port]/[database][?property1][=value1]...
   --
   --  If the string is invalid or if the driver cannot be found,
   --  the Connection_Error exception is raised.
   --  ------------------------------
   procedure Set_Connection (Controller : in out Configuration;
                             URI        : in String) is

      Pos, Pos2, Slash_Pos, Next : Natural;
   begin
      Log.Info ("Set connection URI: {0}", URI);

      Controller.URI := To_Unbounded_String (URI);
      Pos := Index (URI, "://");
      if Pos <= 1 then
         Log.Error ("Invalid connection URI: {0}", URI);
         raise Connection_Error
           with "Invalid URI: '" & URI & "'";
      end if;
      Controller.Driver := Get_Driver (URI (URI'First .. Pos - 1));
      if Controller.Driver = null then
         Log.Error ("No driver found for connection URI: {0}", URI);
         raise Connection_Error
           with "Driver '" & URI (URI'First .. Pos - 1) & "' not found";
      end if;

      Pos := Pos + 3;
      Slash_Pos := Index (URI, "/", Pos);
      if Slash_Pos < Pos then
         Log.Error ("Invalid connection URI: {0}", URI);
         raise Connection_Error
           with "Invalid connection URI: '" & URI & "'";
      end if;

      --  Extract the server and port.
      Pos2 := Index (URI, ":", Pos);
      if Pos2 > Pos then
         Controller.Server := To_Unbounded_String (URI (Pos .. Pos2 - 1));
         Controller.Port := Integer'Value (URI (Pos2 + 1 .. Slash_Pos - 1));

      else
         Controller.Port := 0;
         Controller.Server := To_Unbounded_String (URI (Pos .. Slash_Pos - 1));
      end if;

      --  Extract the database name.
      Pos := Index (URI, "?", Slash_Pos);
      if Pos - 1 > Slash_Pos + 1 then
         Controller.Database := To_Unbounded_String (URI (Slash_Pos + 1 .. Pos - 1));
      elsif Pos = 0 and Slash_Pos + 1 < URI'Last then
         Controller.Database := To_Unbounded_String (URI (Slash_Pos + 1 .. URI'Last));
      else
         Controller.Database := Null_Unbounded_String;
      end if;

      --  Parse the optional properties
      if Pos > Slash_Pos then
         while Pos < URI'Last loop
            Pos2 := Index (URI, "=", Pos + 1);
            if Pos2 > Pos then
               Next := Index (URI, "&", Pos2 + 1);
               if Next > 0 then
                  Controller.Properties.Set (URI (Pos + 1 .. Pos2 - 1),
                                             URI (Pos2 + 1 .. Next - 1));
                  Pos := Next;
               else
                  Controller.Properties.Set (URI (Pos + 1 .. Pos2 - 1),
                                             URI (Pos2 + 1 .. URI'Last));
                  Pos := URI'Last;
               end if;
            else
               Controller.Properties.Set (URI (Pos + 1 .. URI'Last), "");
               Pos := URI'Last;
            end if;
         end loop;
      end if;
   end Set_Connection;

   --  ------------------------------
   --  Set a property on the datasource for the driver.
   --  The driver can retrieve the property to configure and open
   --  the database connection.
   --  ------------------------------
   procedure Set_Property (Controller : in out Configuration;
                           Name       : in String;
                           Value      : in String) is
   begin
      Controller.Properties.Set (Name, Value);
   end Set_Property;

   --  ------------------------------
   --  Get a property from the datasource configuration.
   --  If the property does not exist, an empty string is returned.
   --  ------------------------------
   function Get_Property (Controller : in Configuration;
                          Name       : in String) return String is
   begin
      return Controller.Properties.Get (Name, "");
   end Get_Property;

   --  ------------------------------
   --  Get the server hostname.
   --  ------------------------------
   function Get_Server (Controller : in Configuration) return String is
   begin
      return To_String (Controller.Server);
   end Get_Server;

   --  ------------------------------
   --  Get the server port.
   --  ------------------------------
   function Get_Port (Controller : in Configuration) return Integer is
   begin
      return Controller.Port;
   end Get_Port;

   --  ------------------------------
   --  Get the database name.
   --  ------------------------------
   function Get_Database (Controller : in Configuration) return String is
   begin
      return To_String (Controller.Database);
   end Get_Database;

   --  ------------------------------
   --  Create a new connection using the configuration parameters.
   --  ------------------------------
   procedure Create_Connection (Config : in Configuration'Class;
                                Result : out Database_Connection_Access) is
   begin
      Log.Info ("Create connection to '{0}'", Config.URI);
      if Config.Driver = null then
         Log.Error ("No driver found for connection {0}", To_String (Config.URI));
         raise Connection_Error with "Data source is not initialized: driver not found";
      end if;
      Config.Driver.Create_Connection (Config, Result);
   end Create_Connection;

   package Driver_List is
     new Ada.Containers.Doubly_Linked_Lists (Element_Type => Driver_Access);

   Drivers : Driver_List.List;

   --  ------------------------------
   --  Register a database driver.
   --  ------------------------------
   procedure Register (Driver : in Driver_Access) is
   begin
      Log.Info ("Register driver {0}", Driver.Name.all);

      Driver_List.Prepend (Container => Drivers, New_Item => Driver);
   end Register;

   --  ------------------------------
   --  Get a database driver given its name.
   --  ------------------------------
   function Get_Driver (Name : in String) return Driver_Access is
      Iter : Driver_List.Cursor := Driver_List.First (Drivers);
   begin
      Log.Info ("Get driver {0}", Name);

      while Driver_List.Has_Element (Iter) loop
         declare
            D : constant Driver_Access := Driver_List.Element (Iter);
         begin
            if Name = D.Name.all then
               return D;
            end if;
         end;
         Driver_List.Next (Iter);
      end loop;
      return null;
   end Get_Driver;

   --  Initialize the drivers which are available.
   procedure Initialize is separate;

end ADO.Drivers;
