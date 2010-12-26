-----------------------------------------------------------------------
--  ADO Statements -- Database statements
--  Copyright (C) 2009, 2010 Stephane Carrez
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

with GNAT.Calendar.Time_IO;      use GNAT.Calendar.Time_IO;
with Util.Log;
with Util.Log.Loggers;
with System.Storage_Elements;
with Ada.Unchecked_Deallocation;
with Ada.Calendar.Formatting;
with ADO.Objects;
package body ADO.Statements is

   use Util.Log;
   use System.Storage_Elements;

   Log : constant Loggers.Logger := Loggers.Create ("ADO.Statements");

   function "+"(Str : in String)
                     return Unbounded_String renames To_Unbounded_String;

   function Get_Query (Query : Statement) return ADO.SQL.Query_Access is
   begin
      return Query.Query;
   end Get_Query;

   procedure Add_Parameter (Query : in out Statement;
                            Param : in ADO.Parameters.Parameter) is
   begin
      Query.Query.Add_Parameter (Param);
   end Add_Parameter;

   procedure Set_Parameters (Query : in out Statement;
                             From  : in ADO.Parameters.Abstract_List'Class) is
   begin
      Query.Query.Set_Parameters (From);
   end Set_Parameters;

   --  ------------------------------
   --  Return the number of parameters in the list.
   --  ------------------------------
   function Length (Query : in Statement) return Natural is
   begin
      return Query.Query.Length;
   end Length;

   --  ------------------------------
   --  Return the parameter at the given position
   --  ------------------------------
   function Element (Query    : in Statement;
                     Position : in Natural) return ADO.Parameters.Parameter is
   begin
      return Query.Query.Element (Position);
   end Element;

   --  ------------------------------
   --  Clear the list of parameters.
   --  ------------------------------
   procedure Clear (Query : in out Statement) is
   begin
      Query.Query.Clear;
   end Clear;

   procedure Add_Param (Params : in out Statement;
                        Value : in ADO.Objects.Object_Key) is
   begin
      case Value.Of_Type is
         when ADO.Objects.KEY_INTEGER =>
            declare
               V : constant Identifier := Objects.Get_Value (Value);
            begin
               Params.Query.Add_Param (V);
            end;

         when ADO.Objects.KEY_STRING =>
            declare
               V : constant Unbounded_String := Objects.Get_Value (Value);
            begin
               Params.Query.Add_Param (V);
            end;

      end case;
   end Add_Param;

   procedure Append (Query : in out Statement; SQL : in String) is
   begin
      ADO.SQL.Append (Target => Query.Query.SQL, SQL => SQL);
   end Append;

   procedure Append (Query : in out Statement; Value : in Integer) is
   begin
      ADO.SQL.Append_Value (Target => Query.Query.SQL, Value => Long_Integer (Value));
   end Append;

   procedure Append (Query : in out Statement; Value : in Long_Integer) is
   begin
      ADO.SQL.Append_Value (Target => Query.Query.SQL, Value => Value);
   end Append;

   procedure Append (Query : in out Statement; SQL : in Unbounded_String) is
   begin
      ADO.SQL.Append_Value (Target => Query.Query.SQL, Value => To_String (SQL));
   end Append;

   procedure Set_Filter (Query  : in out Statement;
                         Filter : in String) is
   begin
      Query.Query.Set_Filter (Filter);
   end Set_Filter;

   --  ------------------------------
   --  Get the filter condition or the empty string
   --  ------------------------------
   function Get_Filter (Parameters : in Statement) return String is
   begin
      return Parameters.Query.Get_Filter;
   end Get_Filter;

   procedure Execute (Query  : in out Statement;
                      SQL    : in Unbounded_String;
                      Params : in ADO.Parameters.Abstract_List'Class) is
   begin
      null;
   end Execute;

   --  ------------------------------
   --  Append the value to the SQL query string.
   --  ------------------------------
   procedure Append_Escape (Query : in out Statement; Value : in String) is
   begin
      ADO.SQL.Append_Value (Query.Query.SQL, Value);
   end Append_Escape;

   --  ------------------------------
   --  Append the value to the SQL query string.
   --  ------------------------------
   procedure Append_Escape (Query : in out Statement; Value : in Unbounded_String) is
   begin
      ADO.SQL.Append_Value (Query.Query.SQL, To_String (Value));
   end Append_Escape;

   function "+" (Left : Chars_Ptr; Right : Size_T) return Chars_Ptr is
   begin
      return To_Chars_Ptr (To_Address (Left) + Storage_Offset (Right));
   end "+";

   function Get_Result_Integer (Query : Query_Statement) return Integer is
   begin
      if not Query_Statement'Class (Query).Has_Elements then
         return 0;
      end if;
      return Query_Statement'Class (Query).Get_Integer (1);
   end Get_Result_Integer;

   --  ------------------------------
   --  Get an unsigned 64-bit number from a C string terminated by \0
   --  ------------------------------
   function Get_Uint64 (Str : Chars_Ptr) return unsigned_long is
      C      : Character;
      P      : Chars_Ptr := Str;
      Result : unsigned_long := 0;
   begin
      loop
         C := P.all;
         if C /= ' ' then
            exit;
         end if;
         P := P + 1;
      end loop;
      while C >= '0' and C <= '9' loop
         Result := Result * 10 + unsigned_long (Character'Pos (C) - Character'Pos ('0'));
         P := P + 1;
         C := P.all;
      end loop;
      return Result;
   end Get_Uint64;

   --  ------------------------------
   --  Get a signed 64-bit number from a C string terminated by \0
   --  ------------------------------
   function Get_Int64 (Str : Chars_Ptr) return Int64 is
      C : Character;
      P : Chars_Ptr := Str;
   begin
      if P = null then
         return 0;
      end if;
      loop
         C := P.all;
         if C /= ' ' then
            exit;
         end if;
         P := P + 1;
      end loop;
      if C = '+' then
         P := P + 1;
         return Int64 (Get_Uint64 (P));

      elsif C = '-' then
         P := P + 1;
         return -Int64 (Get_Uint64 (P));

      else
         return Int64 (Get_Uint64 (P));
      end if;
   end Get_Int64;

   --  ------------------------------
   --  Execute the query
   --  ------------------------------
   overriding
   procedure Execute (Query : in out Query_Statement) is
   begin
      if Query.Proxy = null then
         raise Invalid_Statement with "Query statement is not initialized";
      end if;
      Query.Proxy.Execute;
   end Execute;

   --  ------------------------------
   --  Get the number of rows returned by the query
   --  ------------------------------
   function Get_Row_Count (Query : in Query_Statement) return Natural is
   begin
      if Query.Proxy = null then
         return 0;
      else
         return Query.Proxy.Get_Row_Count;
      end if;
   end Get_Row_Count;

   --  ------------------------------
   --  Returns True if there is more data (row) to fetch
   --  ------------------------------
   function Has_Elements (Query : in Query_Statement) return Boolean is
   begin
      if Query.Proxy = null then
         return False;
      else
         return Query.Proxy.Has_Elements;
      end if;
   end Has_Elements;

   --  ------------------------------
   --  Fetch the next row
   --  ------------------------------
   procedure Next (Query : in out Query_Statement) is
   begin
      if Query.Proxy = null then
         raise Invalid_Statement with "Query statement is not initialized";
      end if;
      Query.Proxy.Next;
   end Next;

   --  ------------------------------
   --  Get the column value at position <b>Column</b> and
   --  return it as an <b>Int64</b>.
   --  Raises <b>Invalid_Type</b> if the value cannot be converted.
   --  Raises <b>Invalid_Column</b> if the column does not exist.
   --  ------------------------------
   function Get_Int64 (Query  : Query_Statement;
                       Column : Natural) return Int64 is
   begin
      if Query.Proxy = null then
         raise Invalid_Statement with "Query statement is not initialized";
      end if;
      return Query.Proxy.Get_Int64 (Column);
   end Get_Int64;

   --  ------------------------------
   --  Get the column value at position <b>Column</b> and
   --  return it as an <b>Integer</b>.
   --  Raises <b>Invalid_Type</b> if the value cannot be converted.
   --  Raises <b>Invalid_Column</b> if the column does not exist.
   --  ------------------------------
   function Get_Integer (Query  : Query_Statement;
                         Column : Natural) return Integer is
   begin
      if Query.Proxy = null then
         return Integer (Query_Statement'Class (Query).Get_Int64 (Column));
      else
         return Query.Proxy.Get_Integer (Column);
      end if;
   end Get_Integer;

   --  ------------------------------
   --  Get the column value at position <b>Column</b> and
   --  return it as an <b>Identifier</b>.
   --  Raises <b>Invalid_Type</b> if the value cannot be converted.
   --  Raises <b>Invalid_Column</b> if the column does not exist.
   --  ------------------------------
   function Get_Identifier (Query  : Query_Statement;
                            Column : Natural) return Identifier is
   begin
      if Query.Proxy = null then
         return Identifier (Query_Statement'Class (Query).Get_Int64 (Column));
      else
         return Query.Proxy.Get_Identifier (Column);
      end if;
   end Get_Identifier;

   --  ------------------------------
   --  Get the column value at position <b>Column</b> and
   --  return it as an <b>Unbounded_String</b>.
   --  Raises <b>Invalid_Type</b> if the value cannot be converted.
   --  Raises <b>Invalid_Column</b> if the column does not exist.
   --  ------------------------------
   function Get_Unbounded_String (Query  : Query_Statement;
                                  Column : Natural) return Unbounded_String is
   begin
      if Query.Proxy = null then
         raise Invalid_Statement with "Query statement is not initialized";
      end if;
      return Query.Proxy.Get_Unbounded_String (Column);
   end Get_Unbounded_String;

   --  ------------------------------
   --  Get the column value at position <b>Column</b> and
   --  return it as an <b>Unbounded_String</b>.
   --  Raises <b>Invalid_Type</b> if the value cannot be converted.
   --  Raises <b>Invalid_Column</b> if the column does not exist.
   --  ------------------------------
   function Get_String (Query  : Query_Statement;
                        Column : Natural) return String is
   begin
      if Query.Proxy = null then
         return To_String (Query_Statement'Class (Query).Get_Unbounded_String (Column));
      else
         return Query.Proxy.Get_String (Column);
      end if;
   end Get_String;

   --  ------------------------------
   --  Get the column value at position <b>Column</b> and
   --  return it as an <b>Time</b>.
   --  Raises <b>Invalid_Type</b> if the value cannot be converted.
   --  Raises <b>Invalid_Column</b> if the column does not exist.
   --  ------------------------------
   function Get_Time (Query  : Query_Statement;
                      Column : Natural) return Ada.Calendar.Time is
   begin
      if Query.Proxy = null then
         raise Invalid_Statement with "Query statement is not initialized";
      end if;
      return Query.Proxy.Get_Time (Column);
   end Get_Time;

   --  ------------------------------
   --  Get the column type
   --  Raises <b>Invalid_Column</b> if the column does not exist.
   --  ------------------------------
   function Get_Column_Type (Query  : Query_Statement;
                             Column : Natural)
                             return ADO.Schemas.Column_Type is
   begin
      if Query.Proxy = null then
         raise Invalid_Statement with "Query statement is not initialized";
      end if;
      return Query.Proxy.Get_Column_Type (Column);
   end Get_Column_Type;

   overriding
   procedure Adjust (Stmt : in out Query_Statement) is
   begin
      if Stmt.Proxy /= null then
         Stmt.Proxy.Ref_Counter := Stmt.Proxy.Ref_Counter + 1;
      end if;
   end Adjust;

   overriding
   procedure Finalize (Stmt : in out Query_Statement) is

      procedure Free is new
        Ada.Unchecked_Deallocation (Object => Query_Statement'Class,
                                    Name   => Query_Statement_Access);

   begin
      if Stmt.Proxy /= null then
         Stmt.Proxy.Ref_Counter := Stmt.Proxy.Ref_Counter - 1;
         if Stmt.Proxy.Ref_Counter = 0 then
            Free (Stmt.Proxy);
         end if;
      end if;
   end Finalize;

   --  Execute the delete query.
   overriding
   procedure Execute (Query  : in out Delete_Statement) is
      Result : Natural;
   begin
      Log.Info ("Delete statement");

      if Query.Proxy = null then
         raise Invalid_Statement with "Delete statement not initialized";
      end if;
      Query.Proxy.Execute (Result);
   end Execute;

   --  ------------------------------
   --  Execute the query
   --  Returns the number of rows deleted.
   --  ------------------------------
   procedure Execute (Query  : in out Delete_Statement;
                      Result : out Natural) is
   begin
      Log.Info ("Delete statement");

      if Query.Proxy = null then
         raise Invalid_Statement with "Delete statement not initialized";
      end if;
      Query.Proxy.Execute (Result);
   end Execute;

   --  ------------------------------
   --  Get the update query object associated with this update statement.
   --  ------------------------------
   function Get_Update_Query (Update : in Update_Statement)
                              return ADO.SQL.Update_Query_Access is
   begin
      return Update.Update;
   end Get_Update_Query;

   --  ------------------------------
   --  Prepare the update/insert query to save the table field
   --  identified by <b>Name</b> and set it to the <b>Value</b>.
   --  ------------------------------
   procedure Save_Field (Update : in out Update_Statement;
                         Name   : in String;
                         Value  : in Boolean) is
   begin
      Update.Update.Save_Field (Name => Name, Value => Value);
   end Save_Field;

   --  ------------------------------
   --  Prepare the update/insert query to save the table field
   --  identified by <b>Name</b> and set it to the <b>Value</b>.
   --  ------------------------------
   procedure Save_Field (Update : in out Update_Statement;
                         Name   : in String;
                         Value  : in Integer) is
   begin
      Update.Update.Save_Field (Name => Name, Value => Value);
   end Save_Field;

   --  ------------------------------
   --  Prepare the update/insert query to save the table field
   --  identified by <b>Name</b> and set it to the <b>Value</b>.
   --  ------------------------------
   procedure Save_Field (Update : in out Update_Statement;
                         Name   : in String;
                         Value  : in Long_Integer) is
   begin
      Update.Update.Save_Field (Name => Name, Value => Value);
   end Save_Field;

   --  ------------------------------
   --  Prepare the update/insert query to save the table field
   --  identified by <b>Name</b> and set it to the <b>Value</b>.
   --  ------------------------------
   procedure Save_Field (Update : in out Update_Statement;
                         Name   : in String;
                         Value  : in Identifier) is
   begin
      Update.Update.Save_Field (Name => Name, Value => Value);
   end Save_Field;

   --  ------------------------------
   --  Prepare the update/insert query to save the table field
   --  identified by <b>Name</b> and set it to the <b>Value</b>.
   --  ------------------------------
   procedure Save_Field (Update : in out Update_Statement;
                         Name   : in String;
                         Value  : in Ada.Calendar.Time) is
   begin
      Update.Update.Save_Field (Name => Name, Value => Value);
   end Save_Field;

   --  ------------------------------
   --  Prepare the update/insert query to save the table field
   --  identified by <b>Name</b> and set it to the <b>Value</b>.
   --  ------------------------------
   procedure Save_Field (Update : in out Update_Statement;
                         Name   : in String;
                         Value  : in String) is
   begin
      Update.Update.Save_Field (Name => Name, Value => Value);
   end Save_Field;

   --  ------------------------------
   --  Prepare the update/insert query to save the table field
   --  identified by <b>Name</b> and set it to the <b>Value</b>.
   --  ------------------------------
   procedure Save_Field (Update : in out Update_Statement;
                         Name   : in String;
                         Value  : in Unbounded_String) is
   begin
      Update.Update.Save_Field (Name => Name, Value => Value);
   end Save_Field;

   --  ------------------------------
   --  Prepare the update/insert query to save the table field
   --  identified by <b>Name</b> and set it to the <b>Value</b>.
   --  ------------------------------
   procedure Save_Field (Update : in out Update_Statement;
                         Name   : in String;
                         Value  : in ADO.Objects.Object_Key) is
   begin
      case Value.Of_Type is
         when ADO.Objects.KEY_INTEGER =>
            declare
               V : constant Identifier := Objects.Get_Value (Value);
            begin
               Update.Update.Save_Field (Name => Name, Value => V);
            end;

         when ADO.Objects.KEY_STRING =>
            declare
               V : constant Unbounded_String := Objects.Get_Value (Value);
            begin
               Update.Update.Save_Field (Name => Name, Value => V);
            end;

      end case;
   end Save_Field;

   --  ------------------------------
   --  Check if the update/insert query has some fields to update.
   --  ------------------------------
   function Has_Save_Fields (Update : in Update_Statement) return Boolean is
   begin
      return Update.Update.Has_Save_Fields;
   end Has_Save_Fields;

   --  ------------------------------
   --  Execute the query
   --  ------------------------------
   overriding
   procedure Execute (Query : in out Update_Statement) is
   begin
      if Query.Proxy = null then
         raise Invalid_Statement with "Update statement not initialized";
      end if;
      Query.Proxy.Execute;
   end Execute;

   procedure Update_Field (Update : in out Update_Statement;
                           Name   : in String;
                           Value  : in Unbounded_String) is
   begin
      Update.Update.Save_Field (Name, Value);
   end Update_Field;

   --  ------------------------------
   --  Execute the query
   --  ------------------------------
   overriding
   procedure Execute (Query : in out Insert_Statement) is
   begin
      if Query.Proxy = null then
         raise Invalid_Statement with "Insert statement not initialized";
      end if;
      Query.Proxy.Execute;
   end Execute;

   --  ------------------------------
   --  Execute the query
   --  ------------------------------
   procedure Execute (Query : in out Update_Statement;
                      Result : out Integer) is
   begin
      if Query.Proxy = null then
         raise Invalid_Statement with "Update statement not initialized";
      end if;
      Query.Proxy.Execute (Result);
   end Execute;

   function Create_Statement (Proxy : Query_Statement_Access) return Query_Statement is
   begin
      return Result : Query_Statement do
         Result.Query := Proxy.Get_Query;
         Result.Proxy := Proxy;
         Result.Proxy.Ref_Counter := 1;
      end return;
   end Create_Statement;

   function Create_Statement (Proxy : Delete_Statement_Access) return Delete_Statement is
   begin
      return Result : Delete_Statement do
         Result.Proxy := Proxy;
         Result.Proxy.Ref_Counter := 1;
      end return;
   end Create_Statement;

   function Create_Statement (Proxy : Update_Statement_Access) return Update_Statement is
   begin
      return Result : Update_Statement do
         Result.Update := Proxy.Get_Update_Query;
         Result.Query := Result.Update.all'Access;
         Result.Proxy := Proxy;
         Result.Proxy.Ref_Counter := 1;
      end return;
   end Create_Statement;

   function Create_Statement (Proxy : Update_Statement_Access) return Insert_Statement is
   begin
      return Result : Insert_Statement do
         Result.Update := Proxy.Get_Update_Query;
         Result.Query := Result.Update.all'Access;
         Result.Proxy := Proxy;
         Result.Proxy.Ref_Counter := 1;
      end return;
   end Create_Statement;

   overriding
   procedure Adjust (Stmt : in out Delete_Statement) is
   begin
      if Stmt.Proxy /= null then
         Stmt.Proxy.Ref_Counter := Stmt.Proxy.Ref_Counter + 1;
      end if;
   end Adjust;

   overriding
   procedure Finalize (Stmt : in out Delete_Statement) is

      procedure Free is new
        Ada.Unchecked_Deallocation (Object => Delete_Statement'Class,
                                    Name   => Delete_Statement_Access);
   begin
      if Stmt.Proxy /= null then
         Stmt.Proxy.Ref_Counter := Stmt.Proxy.Ref_Counter - 1;
         if Stmt.Proxy.Ref_Counter = 0 then
            Free (Stmt.Proxy);
         end if;
      end if;
   end Finalize;

   overriding
   procedure Adjust (Stmt : in out Update_Statement) is
   begin
      if Stmt.Proxy /= null then
         Stmt.Proxy.Ref_Counter := Stmt.Proxy.Ref_Counter + 1;
      end if;
   end Adjust;

   overriding
   procedure Finalize (Stmt : in out Update_Statement) is

      procedure Free is new
        Ada.Unchecked_Deallocation (Object => Update_Statement'Class,
                                    Name   => Update_Statement_Access);
   begin
      if Stmt.Proxy /= null then
         Stmt.Proxy.Ref_Counter := Stmt.Proxy.Ref_Counter - 1;
         if Stmt.Proxy.Ref_Counter = 0 then
            Free (Stmt.Proxy);
         end if;
      end if;
   end Finalize;

end ADO.Statements;