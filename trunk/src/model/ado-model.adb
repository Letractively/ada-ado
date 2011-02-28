-----------------------------------------------------------------------
--  ADO.Model -- ADO.Model
-----------------------------------------------------------------------
--  File generated by ada-gen DO NOT MODIFY
--  Template used: templates/model/package-body.xhtml
-----------------------------------------------------------------------
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
with Ada.Unchecked_Deallocation;
with ADO.Databases;
with Util.Beans.Objects.Time;
package body ADO.Model is

   use type ADO.Objects.Object_Record_Access;
   use type ADO.Objects.Object_Ref;
   use type ADO.Objects.Object_Record;

   function Sequence_Key (Id : in ADO.Identifier) return ADO.Objects.Object_Key is
      Result : ADO.Objects.Object_Key (Of_Type  => ADO.Objects.KEY_STRING,
                                       Of_Class => SEQUENCE_TABLE'Access);
   begin
      ADO.Objects.Set_Value (Result, Id);
      return Result;
   end Sequence_Key;
   function Sequence_Key (Id : in String) return ADO.Objects.Object_Key is
      Result : ADO.Objects.Object_Key (Of_Type  => ADO.Objects.KEY_STRING,
                                       Of_Class => SEQUENCE_TABLE'Access);
   begin
      ADO.Objects.Set_Value (Result, Id);
      return Result;
   end Sequence_Key;
   function "=" (Left, Right : Sequence_Ref'Class) return Boolean is
   begin
      return ADO.Objects.Object_Ref'Class (Left) = ADO.Objects.Object_Ref'Class (Right);
   end "=";
   procedure Set_Field (Object : in out Sequence_Ref'Class;
                        Impl   : out Sequence_Access;
                        Field  : in Positive) is
   begin
      Object.Set_Field (Field);
      Impl := Sequence_Impl (Object.Get_Object.all)'Access;
   end Set_Field;
   --  Internal method to allocate the Object_Record instance
   procedure Allocate (Object : in out Sequence_Ref) is
      Impl : Sequence_Access;
   begin
      Impl := new Sequence_Impl;
      ADO.Objects.Set_Object (Object, Impl.all'Access);
   end Allocate;
 
   -- ----------------------------------------
   --  Data object: Sequence
   -- ----------------------------------------
   procedure Set_Name (Object : in out Sequence_Ref;
                        Value : in String) is
   begin
      Object.Set_Name (Ada.Strings.Unbounded.To_Unbounded_String (Value));
   end Set_Name;
   procedure Set_Name (Object : in out Sequence_Ref;
                        Value  : in Ada.Strings.Unbounded.Unbounded_String) is
      Impl : Sequence_Access;
   begin
      Set_Field (Object, Impl, 1);
      ADO.Objects.Set_Key_Value (Impl.all, Value);
   end Set_Name;
   function Get_Name (Object : in Sequence_Ref)
                 return String is
   begin
      return Ada.Strings.Unbounded.To_String (Object.Get_Name);
   end Get_Name;
   function Get_Name (Object : in Sequence_Ref)
                  return Ada.Strings.Unbounded.Unbounded_String is
      Impl : constant Sequence_Access := Sequence_Impl (Object.Get_Object.all)'Access;
   begin
      return Impl.Get_Key_Value;
   end Get_Name;
   function Get_Version (Object : in Sequence_Ref)
                  return Integer is
      Impl : constant Sequence_Access := Sequence_Impl (Object.Get_Load_Object.all)'Access;
   begin
      return Impl.Version;
   end Get_Version;
   procedure Set_Value (Object : in out Sequence_Ref;
                         Value  : in ADO.Identifier) is
      Impl : Sequence_Access;
   begin
      Set_Field (Object, Impl, 3);
      Impl.Value := Value;
   end Set_Value;
   function Get_Value (Object : in Sequence_Ref)
                  return ADO.Identifier is
      Impl : constant Sequence_Access := Sequence_Impl (Object.Get_Load_Object.all)'Access;
   begin
      return Impl.Value;
   end Get_Value;
   procedure Set_Block_Size (Object : in out Sequence_Ref;
                              Value  : in ADO.Identifier) is
      Impl : Sequence_Access;
   begin
      Set_Field (Object, Impl, 4);
      Impl.Block_Size := Value;
   end Set_Block_Size;
   function Get_Block_Size (Object : in Sequence_Ref)
                  return ADO.Identifier is
      Impl : constant Sequence_Access := Sequence_Impl (Object.Get_Load_Object.all)'Access;
   begin
      return Impl.Block_Size;
   end Get_Block_Size;
   --  Copy of the object.
   function Copy (Object : Sequence_Ref) return Sequence_Ref is
      Result : Sequence_Ref;
   begin
      if not Object.Is_Null then
         declare
            Impl : constant Sequence_Access
              := Sequence_Impl (Object.Get_Load_Object.all)'Access;
            Copy : constant Sequence_Access
              := new Sequence_Impl;
         begin
            ADO.Objects.Set_Object (Result, Copy.all'Access);
            Copy.Copy (Impl.all);
            Copy.all.Set_Key (Impl.all.Get_Key);
            Copy.Version := Impl.Version;
            Copy.Value := Impl.Value;
            Copy.Block_Size := Impl.Block_Size;
         end;
      end if;
      return Result;
   end Copy;
   procedure Find (Object  : in out Sequence_Ref;
                   Session : in out ADO.Sessions.Session'Class;
                   Query   : in ADO.SQL.Query'Class;
                   Found   : out Boolean) is
      Impl  : constant Sequence_Access := new Sequence_Impl;
   begin
      Impl.Find (Session, Query, Found);
      if Found then
         ADO.Objects.Set_Object (Object, Impl.all'Access);
      else
         ADO.Objects.Set_Object (Object, null);
         Destroy (Impl);
      end if;
   end Find;
   procedure Load (Object  : in out Sequence_Ref;
                   Session : in out ADO.Sessions.Session'Class;
                   Id      : in Ada.Strings.Unbounded.Unbounded_String) is
      Impl  : constant Sequence_Access := new Sequence_Impl;
      Found : Boolean;
      Query : ADO.SQL.Query;
   begin
      Query.Bind_Param (Position => 1, Value => Id);
      Query.Set_Filter ("name = ?");
      Impl.Find (Session, Query, Found);
      if not Found then
         Destroy (Impl);
         raise ADO.Objects.NOT_FOUND;
      end if;
      ADO.Objects.Set_Object (Object, Impl.all'Access);
   end Load;
   procedure Save (Object  : in out Sequence_Ref;
                   Session : in out ADO.Sessions.Master_Session'Class) is
      Impl : ADO.Objects.Object_Record_Access := Object.Get_Object;
   begin
      if Impl = null then
         Impl := new Sequence_Impl;
         ADO.Objects.Set_Object (Object, Impl);
      end if;
      if not ADO.Objects.Is_Created (Impl.all) then
         Impl.Create (Session);
      else
         Impl.Save (Session);
      end if;
   end Save;
   procedure Delete (Object  : in out Sequence_Ref;
                     Session : in out ADO.Sessions.Master_Session'Class) is
      Impl : constant ADO.Objects.Object_Record_Access := Object.Get_Object;
   begin
      if Impl /= null then
         Impl.Delete (Session);
      end if;
   end Delete;
   --  --------------------
   --  Free the object
   --  --------------------
   procedure Destroy (Object : access Sequence_Impl) is
      type Sequence_Impl_Ptr is access all Sequence_Impl;
      procedure Unchecked_Free is new Ada.Unchecked_Deallocation
              (Sequence_Impl, Sequence_Impl_Ptr);
      Ptr : Sequence_Impl_Ptr := Sequence_Impl (Object.all)'Access;
   begin
      Unchecked_Free (Ptr);
   end Destroy;
   procedure Find (Object  : in out Sequence_Impl;
                   Session : in out ADO.Sessions.Session'Class;
                   Query   : in ADO.SQL.Query'Class;
                   Found   : out Boolean) is
      Stmt : ADO.Statements.Query_Statement
          := Session.Create_Statement (SEQUENCE_TABLE'Access);
   begin
      Stmt.Set_Parameters (Query);
      Stmt.Execute;
      if Stmt.Has_Elements then
         Object.Load (Stmt, Session);
         Stmt.Next;
         Found := not Stmt.Has_Elements;
      else
         Found := False;
      end if;
   end Find;
   overriding
   procedure Load (Object  : in out Sequence_Impl;
                   Session : in out ADO.Sessions.Session'Class) is
      Found : Boolean;
      Query : ADO.SQL.Query;
      Id    : constant Ada.Strings.Unbounded.Unbounded_String := Object.Get_Key_Value;
   begin
      Query.Bind_Param (Position => 1, Value => Id);
      Query.Set_Filter ("name = ?");
      Object.Find (Session, Query, Found);
      if not Found then
         raise ADO.Objects.NOT_FOUND;
      end if;
   end Load;
   procedure Save (Object  : in out Sequence_Impl;
                   Session : in out ADO.Sessions.Master_Session'Class) is
      Stmt : ADO.Statements.Update_Statement := Session.Create_Statement (SEQUENCE_TABLE'Access);
   begin
      if Object.Is_Modified (1) then
         Stmt.Save_Field (Name  => COL_0_1_NAME, --  NAME
                          Value => Object.Get_Key);
         Object.Clear_Modified (1);
      end if;
      if Object.Is_Modified (3) then
         Stmt.Save_Field (Name  => COL_2_1_NAME, --  VALUE
                          Value => Object.Value);
         Object.Clear_Modified (3);
      end if;
      if Object.Is_Modified (4) then
         Stmt.Save_Field (Name  => COL_3_1_NAME, --  BLOCK_SIZE
                          Value => Object.Block_Size);
         Object.Clear_Modified (4);
      end if;
      if Stmt.Has_Save_Fields then
         Object.Version := Object.Version + 1;
         Stmt.Save_Field (Name  => "version",
                          Value => Object.Version);
         Stmt.Set_Filter (Filter => "name = ? and version = ?");
         Stmt.Add_Param (Value => Object.Get_Key);
         Stmt.Add_Param (Value => Object.Version - 1);
         declare
            Result : Integer;
         begin
            Stmt.Execute (Result);
            if Result /= 1 then
               if Result = 0 then
                  raise ADO.Objects.LAZY_LOCK;
               else
                  raise ADO.Objects.UPDATE_ERROR;
               end if;
            end if; 
         end;
      end if;
   end Save;
   procedure Create (Object  : in out Sequence_Impl;
                     Session : in out ADO.Sessions.Master_Session'Class) is
      Query : ADO.Statements.Insert_Statement
                  := Session.Create_Statement (SEQUENCE_TABLE'Access);
      Result : Integer;
   begin
      Object.Version := 1;
      Query.Save_Field (Name  => COL_0_1_NAME, --  NAME
                        Value => Object.Get_Key);
      Query.Save_Field (Name  => COL_1_1_NAME, --  version
                        Value => Object.Version);
      Query.Save_Field (Name  => COL_2_1_NAME, --  VALUE
                        Value => Object.Value);
      Query.Save_Field (Name  => COL_3_1_NAME, --  BLOCK_SIZE
                        Value => Object.Block_Size);
      Query.Execute (Result);
      if Result /= 1 then
         raise ADO.Objects.INSERT_ERROR;
      end if;
      ADO.Objects.Set_Created (Object);
   end Create;
   procedure Delete (Object  : in out Sequence_Impl;
                     Session : in out ADO.Sessions.Master_Session'Class) is
      Stmt : ADO.Statements.Delete_Statement := Session.Create_Statement (SEQUENCE_TABLE'Access);
   begin
      Stmt.Set_Filter (Filter => "name = ?");
      Stmt.Add_Param (Value => Object.Get_Key);
      Stmt.Execute;
   end Delete;
   function Get_Value (Item : in Sequence_Ref;
                       Name : in String) return Util.Beans.Objects.Object is
      Impl : constant access Sequence_Impl := Sequence_Impl (Item.Get_Load_Object.all)'Access;
   begin
      if Name = "name" then
         return ADO.Objects.To_Object (Impl.Get_Key);
      end if;
      if Name = "value" then
         return Util.Beans.Objects.To_Object (Long_Long_Integer (Impl.Value));
      end if;
      if Name = "block_size" then
         return Util.Beans.Objects.To_Object (Long_Long_Integer (Impl.Block_Size));
      end if;
      raise ADO.Objects.NOT_FOUND;
   end Get_Value;
   procedure List (Object  : in out Sequence_Vector;
                   Session : in out ADO.Sessions.Session'Class;
                   Query   : in ADO.SQL.Query'Class) is
      Stmt : ADO.Statements.Query_Statement := Session.Create_Statement (SEQUENCE_TABLE'Access);
   begin
      Stmt.Set_Parameters (Query);
      Stmt.Execute;
      Sequence_Vectors.Clear (Object);
      while Stmt.Has_Elements loop
         declare
            Item : Sequence_Ref;
            Impl : constant Sequence_Access := new Sequence_Impl;
         begin
            Impl.Load (Stmt, Session);
            ADO.Objects.Set_Object (Item, Impl.all'Access);
            Object.Append (Item);
         end;
         Stmt.Next;
      end loop;
   end List;
   --  ------------------------------
   --  Load the object from current iterator position
   --  ------------------------------
   procedure Load (Object  : in out Sequence_Impl;
                   Stmt    : in out ADO.Statements.Query_Statement'Class;
                   Session : in out ADO.Sessions.Session'Class) is
   begin
      Object.Set_Key_Value (Stmt.Get_Unbounded_String (0));
      Object.Value := Stmt.Get_Identifier (2);
      Object.Block_Size := Stmt.Get_Identifier (3);
      Object.Version := Stmt.Get_Integer (1);
      ADO.Objects.Set_Created (Object);
   end Load;
   function Entity_Type_Key (Id : in ADO.Identifier) return ADO.Objects.Object_Key is
      Result : ADO.Objects.Object_Key (Of_Type  => ADO.Objects.KEY_INTEGER,
                                       Of_Class => ENTITY_TYPE_TABLE'Access);
   begin
      ADO.Objects.Set_Value (Result, Id);
      return Result;
   end Entity_Type_Key;
   function Entity_Type_Key (Id : in String) return ADO.Objects.Object_Key is
      Result : ADO.Objects.Object_Key (Of_Type  => ADO.Objects.KEY_INTEGER,
                                       Of_Class => ENTITY_TYPE_TABLE'Access);
   begin
      ADO.Objects.Set_Value (Result, Id);
      return Result;
   end Entity_Type_Key;
   function "=" (Left, Right : Entity_Type_Ref'Class) return Boolean is
   begin
      return ADO.Objects.Object_Ref'Class (Left) = ADO.Objects.Object_Ref'Class (Right);
   end "=";
   procedure Set_Field (Object : in out Entity_Type_Ref'Class;
                        Impl   : out Entity_Type_Access;
                        Field  : in Positive) is
   begin
      Object.Set_Field (Field);
      Impl := Entity_Type_Impl (Object.Get_Object.all)'Access;
   end Set_Field;
   --  Internal method to allocate the Object_Record instance
   procedure Allocate (Object : in out Entity_Type_Ref) is
      Impl : Entity_Type_Access;
   begin
      Impl := new Entity_Type_Impl;
      ADO.Objects.Set_Object (Object, Impl.all'Access);
   end Allocate;
 
   -- ----------------------------------------
   --  Data object: Entity_Type
   -- ----------------------------------------
   procedure Set_Id (Object : in out Entity_Type_Ref;
                      Value  : in ADO.Identifier) is
      Impl : Entity_Type_Access;
   begin
      Set_Field (Object, Impl, 1);
      ADO.Objects.Set_Key_Value (Impl.all, Value);
   end Set_Id;
   function Get_Id (Object : in Entity_Type_Ref)
                  return ADO.Identifier is
      Impl : constant Entity_Type_Access := Entity_Type_Impl (Object.Get_Object.all)'Access;
   begin
      return Impl.Get_Key_Value;
   end Get_Id;
   function Get_Version (Object : in Entity_Type_Ref)
                  return Integer is
      Impl : constant Entity_Type_Access := Entity_Type_Impl (Object.Get_Load_Object.all)'Access;
   begin
      return Impl.Version;
   end Get_Version;
   procedure Set_Name (Object : in out Entity_Type_Ref;
                        Value : in String) is
   begin
      Object.Set_Name (Ada.Strings.Unbounded.To_Unbounded_String (Value));
   end Set_Name;
   procedure Set_Name (Object : in out Entity_Type_Ref;
                        Value  : in Ada.Strings.Unbounded.Unbounded_String) is
      Impl : Entity_Type_Access;
   begin
      Set_Field (Object, Impl, 3);
      Impl.Name := Value;
   end Set_Name;
   function Get_Name (Object : in Entity_Type_Ref)
                 return String is
   begin
      return Ada.Strings.Unbounded.To_String (Object.Get_Name);
   end Get_Name;
   function Get_Name (Object : in Entity_Type_Ref)
                  return Ada.Strings.Unbounded.Unbounded_String is
      Impl : constant Entity_Type_Access := Entity_Type_Impl (Object.Get_Load_Object.all)'Access;
   begin
      return Impl.Name;
   end Get_Name;
   --  Copy of the object.
   function Copy (Object : Entity_Type_Ref) return Entity_Type_Ref is
      Result : Entity_Type_Ref;
   begin
      if not Object.Is_Null then
         declare
            Impl : constant Entity_Type_Access
              := Entity_Type_Impl (Object.Get_Load_Object.all)'Access;
            Copy : constant Entity_Type_Access
              := new Entity_Type_Impl;
         begin
            ADO.Objects.Set_Object (Result, Copy.all'Access);
            Copy.Copy (Impl.all);
            Copy.Version := Impl.Version;
            Copy.Name := Impl.Name;
         end;
      end if;
      return Result;
   end Copy;
   procedure Find (Object  : in out Entity_Type_Ref;
                   Session : in out ADO.Sessions.Session'Class;
                   Query   : in ADO.SQL.Query'Class;
                   Found   : out Boolean) is
      Impl  : constant Entity_Type_Access := new Entity_Type_Impl;
   begin
      Impl.Find (Session, Query, Found);
      if Found then
         ADO.Objects.Set_Object (Object, Impl.all'Access);
      else
         ADO.Objects.Set_Object (Object, null);
         Destroy (Impl);
      end if;
   end Find;
   procedure Load (Object  : in out Entity_Type_Ref;
                   Session : in out ADO.Sessions.Session'Class;
                   Id      : in ADO.Identifier) is
      Impl  : constant Entity_Type_Access := new Entity_Type_Impl;
      Found : Boolean;
      Query : ADO.SQL.Query;
   begin
      Query.Bind_Param (Position => 1, Value => Id);
      Query.Set_Filter ("id = ?");
      Impl.Find (Session, Query, Found);
      if not Found then
         Destroy (Impl);
         raise ADO.Objects.NOT_FOUND;
      end if;
      ADO.Objects.Set_Object (Object, Impl.all'Access);
   end Load;
   procedure Save (Object  : in out Entity_Type_Ref;
                   Session : in out ADO.Sessions.Master_Session'Class) is
      Impl : ADO.Objects.Object_Record_Access := Object.Get_Object;
   begin
      if Impl = null then
         Impl := new Entity_Type_Impl;
         ADO.Objects.Set_Object (Object, Impl);
      end if;
      if not ADO.Objects.Is_Created (Impl.all) then
         Impl.Create (Session);
      else
         Impl.Save (Session);
      end if;
   end Save;
   procedure Delete (Object  : in out Entity_Type_Ref;
                     Session : in out ADO.Sessions.Master_Session'Class) is
      Impl : constant ADO.Objects.Object_Record_Access := Object.Get_Object;
   begin
      if Impl /= null then
         Impl.Delete (Session);
      end if;
   end Delete;
   --  --------------------
   --  Free the object
   --  --------------------
   procedure Destroy (Object : access Entity_Type_Impl) is
      type Entity_Type_Impl_Ptr is access all Entity_Type_Impl;
      procedure Unchecked_Free is new Ada.Unchecked_Deallocation
              (Entity_Type_Impl, Entity_Type_Impl_Ptr);
      Ptr : Entity_Type_Impl_Ptr := Entity_Type_Impl (Object.all)'Access;
   begin
      Unchecked_Free (Ptr);
   end Destroy;
   procedure Find (Object  : in out Entity_Type_Impl;
                   Session : in out ADO.Sessions.Session'Class;
                   Query   : in ADO.SQL.Query'Class;
                   Found   : out Boolean) is
      Stmt : ADO.Statements.Query_Statement
          := Session.Create_Statement (ENTITY_TYPE_TABLE'Access);
   begin
      Stmt.Set_Parameters (Query);
      Stmt.Execute;
      if Stmt.Has_Elements then
         Object.Load (Stmt, Session);
         Stmt.Next;
         Found := not Stmt.Has_Elements;
      else
         Found := False;
      end if;
   end Find;
   overriding
   procedure Load (Object  : in out Entity_Type_Impl;
                   Session : in out ADO.Sessions.Session'Class) is
      Found : Boolean;
      Query : ADO.SQL.Query;
      Id    : constant ADO.Identifier := Object.Get_Key_Value;
   begin
      Query.Bind_Param (Position => 1, Value => Id);
      Query.Set_Filter ("id = ?");
      Object.Find (Session, Query, Found);
      if not Found then
         raise ADO.Objects.NOT_FOUND;
      end if;
   end Load;
   procedure Save (Object  : in out Entity_Type_Impl;
                   Session : in out ADO.Sessions.Master_Session'Class) is
      Stmt : ADO.Statements.Update_Statement := Session.Create_Statement (ENTITY_TYPE_TABLE'Access);
   begin
      if Object.Is_Modified (1) then
         Stmt.Save_Field (Name  => COL_0_2_NAME, --  ID
                          Value => Object.Get_Key);
         Object.Clear_Modified (1);
      end if;
      if Stmt.Has_Save_Fields then
         Object.Version := Object.Version + 1;
         Stmt.Save_Field (Name  => "version",
                          Value => Object.Version);
         Stmt.Set_Filter (Filter => "id = ? and version = ?");
         Stmt.Add_Param (Value => Object.Get_Key);
         Stmt.Add_Param (Value => Object.Version - 1);
         declare
            Result : Integer;
         begin
            Stmt.Execute (Result);
            if Result /= 1 then
               if Result = 0 then
                  raise ADO.Objects.LAZY_LOCK;
               else
                  raise ADO.Objects.UPDATE_ERROR;
               end if;
            end if; 
         end;
      end if;
   end Save;
   procedure Create (Object  : in out Entity_Type_Impl;
                     Session : in out ADO.Sessions.Master_Session'Class) is
      Query : ADO.Statements.Insert_Statement
                  := Session.Create_Statement (ENTITY_TYPE_TABLE'Access);
      Result : Integer;
   begin
      Object.Version := 1;
      Session.Allocate (Id => Object);
      Query.Save_Field (Name  => COL_0_2_NAME, --  ID
                        Value => Object.Get_Key);
      Query.Save_Field (Name  => COL_1_2_NAME, --  version
                        Value => Object.Version);
      Query.Save_Field (Name  => COL_2_2_NAME, --  NAME
                        Value => Object.Name);
      Query.Execute (Result);
      if Result /= 1 then
         raise ADO.Objects.INSERT_ERROR;
      end if;
      ADO.Objects.Set_Created (Object);
   end Create;
   procedure Delete (Object  : in out Entity_Type_Impl;
                     Session : in out ADO.Sessions.Master_Session'Class) is
      Stmt : ADO.Statements.Delete_Statement := Session.Create_Statement (ENTITY_TYPE_TABLE'Access);
   begin
      Stmt.Set_Filter (Filter => "id = ?");
      Stmt.Add_Param (Value => Object.Get_Key);
      Stmt.Execute;
   end Delete;
   function Get_Value (Item : in Entity_Type_Ref;
                       Name : in String) return Util.Beans.Objects.Object is
      Impl : constant access Entity_Type_Impl := Entity_Type_Impl (Item.Get_Load_Object.all)'Access;
   begin
      if Name = "id" then
         return ADO.Objects.To_Object (Impl.Get_Key);
      end if;
      if Name = "name" then
         return Util.Beans.Objects.To_Object (Impl.Name);
      end if;
      raise ADO.Objects.NOT_FOUND;
   end Get_Value;
   procedure List (Object  : in out Entity_Type_Vector;
                   Session : in out ADO.Sessions.Session'Class;
                   Query   : in ADO.SQL.Query'Class) is
      Stmt : ADO.Statements.Query_Statement := Session.Create_Statement (ENTITY_TYPE_TABLE'Access);
   begin
      Stmt.Set_Parameters (Query);
      Stmt.Execute;
      Entity_Type_Vectors.Clear (Object);
      while Stmt.Has_Elements loop
         declare
            Item : Entity_Type_Ref;
            Impl : constant Entity_Type_Access := new Entity_Type_Impl;
         begin
            Impl.Load (Stmt, Session);
            ADO.Objects.Set_Object (Item, Impl.all'Access);
            Object.Append (Item);
         end;
         Stmt.Next;
      end loop;
   end List;
   --  ------------------------------
   --  Load the object from current iterator position
   --  ------------------------------
   procedure Load (Object  : in out Entity_Type_Impl;
                   Stmt    : in out ADO.Statements.Query_Statement'Class;
                   Session : in out ADO.Sessions.Session'Class) is
   begin
      Object.Set_Key_Value (Stmt.Get_Identifier (0));
      Object.Name := Stmt.Get_Unbounded_String (2);
      Object.Version := Stmt.Get_Integer (1);
      ADO.Objects.Set_Created (Object);
   end Load;
end ADO.Model;
