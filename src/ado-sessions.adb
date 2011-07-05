-----------------------------------------------------------------------
--  ADO Sessions -- Sessions Management
--  Copyright (C) 2009, 2010, 2011 Stephane Carrez
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

with Util.Log;
with Util.Log.Loggers;
with Ada.Unchecked_Deallocation;
with ADO.Sequences;
package body ADO.Sessions is

   use Util.Log;

   Log : constant Loggers.Logger := Loggers.Create ("ADO.Sessions");

   procedure Check_Session (Database : in Session'Class) is
   begin
      if Database.Impl = null then
         Log.Error ("Session is closed or not initialized");
         raise NOT_OPEN;
      end if;
   end Check_Session;

   --  ---------
   --  Session
   --  ---------

   --  ------------------------------
   --  Get the session status.
   --  ------------------------------
   function Get_Status (Database : in Session) return ADO.Databases.Connection_Status is
   begin
      if Database.Impl = null then
         return ADO.Databases.CLOSED;
      end if;
      return Database.Impl.Database.Get_Status;
   end Get_Status;

   --  ------------------------------
   --  Close the session.
   --  ------------------------------
   procedure Close (Database : in out Session) is

      procedure Free is new
        Ada.Unchecked_Deallocation (Object => Session_Record,
                                    Name   => Session_Record_Access);

   begin
      Log.Info ("Closing session");
      if Database.Impl /= null then
         Database.Impl.Database.Close;
         Database.Impl.Counter := Database.Impl.Counter - 1;
         if Database.Impl.Counter = 0 then
            Free (Database.Impl);
         end if;
--
--           if Database.Impl.Proxy /= null then
--              Database.Impl.Proxy.Counter := Database.Impl.Proxy.Counter - 1;
--           end if;
         Database.Impl := null;

      end if;
   end Close;

   --  ------------------------------
   --  Get the database connection.
   --  ------------------------------
   function Get_Connection (Database : in Session) return ADO.Databases.Connection'Class is
   begin
      Check_Session (Database);
      return Database.Impl.Database;
   end Get_Connection;

   --  ------------------------------
   --  Attach the object to the session.
   --  ------------------------------
   procedure Attach (Database : in out Session;
                     Object   : in ADO.Objects.Object_Ref'Class) is
      pragma Unreferenced (Object);
   begin
      Check_Session (Database);
   end Attach;

   --  ------------------------------
   --  Check if the session contains the object identified by the given key.
   --  ------------------------------
   function Contains (Database : in Session;
                      Item     : in ADO.Objects.Object_Key) return Boolean is
   begin
      Check_Session (Database);
      return ADO.Objects.Cache.Contains (Database.Impl.Cache, Item);
   end Contains;

   --  ------------------------------
   --  Remove the object from the session cache.
   --  ------------------------------
   procedure Evict (Database : in out Session;
                    Item     : in ADO.Objects.Object_Key) is
   begin
      Check_Session (Database);
      ADO.Objects.Cache.Remove (Database.Impl.Cache, Item);
   end Evict;

   --  ------------------------------
   --  Create a query statement.  The statement is not prepared
   --  ------------------------------
   function Create_Statement (Database : in Session;
                              Table    : in ADO.Schemas.Class_Mapping_Access)
                              return Query_Statement is
   begin
      Check_Session (Database);
      return Database.Impl.Database.Create_Statement (Table);
   end Create_Statement;

   --  ------------------------------
   --  Create a query statement.  The statement is not prepared
   --  ------------------------------
   function Create_Statement (Database : in Session;
                              Query    : in String)
                              return Query_Statement is
   begin
      Check_Session (Database);
      return Database.Impl.Database.Create_Statement (Query);
   end Create_Statement;

   --  ------------------------------
   --  Create a query statement.  The statement is not prepared
   --  ------------------------------
   function Create_Statement (Database : in Session;
                              Query    : in ADO.Queries.Context'Class)
                              return Query_Statement is
   begin
      Check_Session (Database);
      declare
         SQL : constant String := Query.Get_SQL (Database.Impl.Database.Get_Driver_Index);
      begin
         return Database.Impl.Database.Create_Statement (SQL);
      end;
   end Create_Statement;

   --  ---------
   --  Master Session
   --  ---------

   --  ------------------------------
   --  Start a transaction.
   --  ------------------------------
   procedure Begin_Transaction (Database : in out Master_Session) is
   begin
      Log.Info ("Begin transaction");

      Check_Session (Database);
      Database.Impl.Database.Begin_Transaction;
   end Begin_Transaction;

   --  ------------------------------
   --  Commit the current transaction.
   --  ------------------------------
   procedure Commit (Database : in out Master_Session) is
   begin
      Log.Info ("Commit transaction");

      Check_Session (Database);
      Database.Impl.Database.Commit;
   end Commit;

   --  ------------------------------
   --  Rollback the current transaction.
   --  ------------------------------
   procedure Rollback (Database : in out Master_Session) is
   begin
      Log.Info ("Rollback transaction");

      Check_Session (Database);
      Database.Impl.Database.Rollback;
   end Rollback;

   --  ------------------------------
   --  Allocate an identifier for the table.
   --  ------------------------------
   procedure Allocate (Database : in out Master_Session;
                       Id       : in out ADO.Objects.Object_Record'Class) is
   begin
      Check_Session (Database);
      ADO.Sequences.Allocate (Database.Sequences.all, Id);
   end Allocate;

   --  ------------------------------
   --  Flush the objects that were modified.
   --  ------------------------------
   procedure Flush (Database : in out Master_Session) is
   begin
      Check_Session (Database);
   end Flush;

   overriding
   procedure Adjust (Object : in out Session) is
   begin
      if Object.Impl /= null then
         Object.Impl.Counter := Object.Impl.Counter + 1;
      end if;
   end Adjust;

   overriding
   procedure Finalize (Object : in out Session) is
   begin
      if Object.Impl /= null then
         if Object.Impl.Counter = 1 then
            Object.Close;
         else
            Object.Impl.Counter := Object.Impl.Counter - 1;
         end if;
      end if;
   end Finalize;

   --  ------------------------------
   --  Create a delete statement
   --  ------------------------------
   function Create_Statement (Database : in Master_Session;
                              Table    : in ADO.Schemas.Class_Mapping_Access)
                              return Delete_Statement is
   begin
      Check_Session (Database);
      return Database.Impl.Database.Create_Statement (Table);
   end Create_Statement;

   --  ------------------------------
   --  Create an update statement
   --  ------------------------------
   function Create_Statement (Database : in Master_Session;
                              Table    : in ADO.Schemas.Class_Mapping_Access)
                              return Update_Statement is
   begin
      Check_Session (Database);
      return Database.Impl.Database.Create_Statement (Table);
   end Create_Statement;

   --  ------------------------------
   --  Create an insert statement
   --  ------------------------------
   function Create_Statement (Database : in Master_Session;
                              Table    : in ADO.Schemas.Class_Mapping_Access)
                              return Insert_Statement is
   begin
      Check_Session (Database);
      return Database.Impl.Database.Create_Statement (Table);
   end Create_Statement;

   function Get_Session_Proxy (Database : in Session) return ADO.Objects.Session_Proxy_Access is
      use type ADO.Objects.Session_Proxy_Access;
   begin
      Check_Session (Database);
      if Database.Impl.Proxy = null then
         Database.Impl.Proxy := ADO.Objects.Create_Session_Proxy (Database.Impl);
      end if;
      return Database.Impl.Proxy;
   end Get_Session_Proxy;

end ADO.Sessions;
