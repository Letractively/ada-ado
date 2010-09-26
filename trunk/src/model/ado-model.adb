-----------------------------------------------------------------------
--  ADO.Model -- ADO.Model
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
with Ada.Unchecked_Deallocation;
with ADO.Databases;
package body ADO.Model is
   procedure Set_Field (Object : in out Sequence_Ref'Class;
                        Impl   : out Sequence_Ref_Access;
                        Field  : in Positive) is
   begin
      Object.Set_Field (Field);
      Impl := Sequence_Ref_Impl (Object.Get_Object.all)'Access;
   end Set_Field;
   --  Internal method to allocate the Object_Record instance
   procedure Allocate (Object : in out Sequence_Ref) is
      Impl : Sequence_Ref_Access;
   begin
      Impl := new Sequence_Ref_Impl;
      ADO.Objects.Set_Object (Object, Impl.all'Access);
   end Allocate;
   -- ----------------------------------------
   --  Data object: Sequence_Ref
   -- ----------------------------------------
   procedure Set_Name (Object : in out Sequence_Ref;
                        Value : in String) is
   begin
      Object.Set_Name (To_Unbounded_String (Value));
   end Set_Name;
   procedure Set_Name (Object : in out Sequence_Ref;
                        Value  : in Unbounded_String) is
      Impl : Sequence_Ref_Access;
   begin
      Set_Field (Object, Impl, 1);
      Impl.Name := Value;
   end Set_Name;
   function Get_Name (Object : in Sequence_Ref)
                 return String is
   begin
      return To_String (Object.Get_Name);
   end Get_Name;
   function Get_Name (Object : in Sequence_Ref)
                  return Unbounded_String is
      Impl : constant Sequence_Ref_Access := Sequence_Ref_Impl (Object.Get_Object.all)'Access;
   begin
      return Impl.Name;
   end Get_Name;
   procedure Set_Value (Object : in out Sequence_Ref;
                         Value  : in ADO.Identifier) is
      Impl : Sequence_Ref_Access;
   begin
      Set_Field (Object, Impl, 3);
      Impl.Value := Value;
   end Set_Value;
   function Get_Value (Object : in Sequence_Ref)
                  return ADO.Identifier is
      Impl : constant Sequence_Ref_Access := Sequence_Ref_Impl (Object.Get_Object.all)'Access;
   begin
      return Impl.Value;
   end Get_Value;
   procedure Set_Block_Size (Object : in out Sequence_Ref;
                              Value  : in ADO.Identifier) is
      Impl : Sequence_Ref_Access;
   begin
      Set_Field (Object, Impl, 4);
      Impl.Block_Size := Value;
   end Set_Block_Size;
   function Get_Block_Size (Object : in Sequence_Ref)
                  return ADO.Identifier is
      Impl : constant Sequence_Ref_Access := Sequence_Ref_Impl (Object.Get_Object.all)'Access;
   begin
      return Impl.Block_Size;
   end Get_Block_Size;
   --  Copy of the object.
   function Copy (Object : Sequence_Ref) return Sequence_Ref is
      Result : Sequence_Ref;
   begin
      if not Object.Is_Null then
         declare
            Impl : constant Sequence_Ref_Access
              := Sequence_Ref_Impl (Object.Get_Object.all)'Access;
            Copy : constant Sequence_Ref_Access
              := new Sequence_Ref_Impl;
         begin
            ADO.Objects.Set_Object (Result, Copy.all'Access);
            Copy.Name := Impl.Name;
            Copy.Object_Version := Impl.Object_Version;
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
      Impl  : constant Sequence_Ref_Access := new Sequence_Ref_Impl;
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
                   Id      : in Unbounded_String) is
      Impl  : constant Sequence_Ref_Access := new Sequence_Ref_Impl;
      Found : Boolean;
      Query : ADO.SQL.Query;
   begin
      Query.Bind_Param (Position => 1, Value => Id);
      Query.Set_Filter ("name = ?");
      Impl.Find (Session, Query, Found);
      if not Found then
         Destroy (Impl);
         raise ADO.Databases.NOT_FOUND;
      end if;
      ADO.Objects.Set_Object (Object, Impl.all'Access);
   end Load;
   procedure Save (Object  : in out Sequence_Ref;
                   Session : in out ADO.Sessions.Master_Session'Class) is
      Impl : ADO.Objects.Object_Record_Access := Object.Get_Object;
   begin
      if Impl = null then
         Impl := new Sequence_Ref_Impl;
         ADO.Objects.Set_Object (Object, Impl);
      end if;
      if not Is_Created (Impl.all) then
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
   procedure Destroy (Object : access Sequence_Ref_Impl) is
      type Sequence_Ref_Impl_Ptr is access all Sequence_Ref_Impl;
      procedure Unchecked_Free is new Ada.Unchecked_Deallocation
              (Sequence_Ref_Impl, Sequence_Ref_Impl_Ptr);
      Ptr : Sequence_Ref_Impl_Ptr := Sequence_Ref_Impl (Object.all)'Access;
   begin
      Unchecked_Free (Ptr);
   end Destroy;
   procedure Find (Object  : in out Sequence_Ref_Impl;
                   Session : in out ADO.Sessions.Session'Class;
                   Query   : in ADO.SQL.Query'Class;
                   Found   : out Boolean) is
      Stmt : ADO.Statements.Query_Statement
          := Session.Create_Statement (SEQUENCE_REF_TABLE'Access);
   begin
      Stmt.Set_Parameters (Query);
      Stmt.Execute;
      if Stmt.Has_Elements then
         Object.Load (Stmt);
         Stmt.Next;
         Found := not Stmt.Has_Elements;
      else
         Found := False;
      end if;
   end Find;
   procedure Save (Object  : in out Sequence_Ref_Impl;
                   Session : in out ADO.Sessions.Master_Session'Class) is
      Stmt : ADO.Statements.Update_Statement := Session.Create_Statement (SEQUENCE_REF_TABLE'Access);
   begin
      if Object.Is_Modified (1) then
         Stmt.Save_Field (Name  => "name",
                          Value => Object.Name);
         Object.Clear_Modified (1);
      end if;
      if Object.Is_Modified (3) then
         Stmt.Save_Field (Name  => "value",
                          Value => Object.Value);
         Object.Clear_Modified (3);
      end if;
      if Object.Is_Modified (4) then
         Stmt.Save_Field (Name  => "block_size",
                          Value => Object.Block_Size);
         Object.Clear_Modified (4);
      end if;
      if Stmt.Has_Save_Fields then
         Object.Object_Version := Object.Object_Version + 1;
         Stmt.Save_Field (Name  => "object_version",
                          Value => Object.Object_Version);
         Stmt.Set_Filter (Filter => "name = ? and object_version = ?");
         Stmt.Add_Param (Value => Object.Name);
         Stmt.Add_Param (Value => Object.Object_Version - 1);
         declare
            Result : Integer;
         begin
            Stmt.Execute (Result);
            if Result /= 1 then
               if Result = 0 then
                  raise LAZY_LOCK;
               else
                  raise UPDATE_ERROR;
               end if;
            end if; 
         end;
      end if;
   end Save;
   procedure Create (Object  : in out Sequence_Ref_Impl;
                     Session : in out ADO.Sessions.Master_Session'Class) is
      Query : ADO.Statements.Insert_Statement
                  := Session.Create_Statement (SEQUENCE_REF_TABLE'Access);
      Result : Integer;
   begin
      Query.Save_Field (Name => "name", Value => Object.Name);

      Query.Save_Field (Name => "object_version", Value => Object.Object_Version);

      Query.Save_Field (Name => "value", Value => Object.Value);

      Query.Save_Field (Name => "block_size", Value => Object.Block_Size);
      Object.Object_Version := 1;
      Query.Save_Field (Name => "object_version", Value => Object.Object_Version);
      Query.Execute (Result);
      if Result /= 1 then
         raise INSERT_ERROR;
      end if;
      Set_Created (Object);
   end Create;
   procedure Delete (Object  : in out Sequence_Ref_Impl;
                     Session : in out ADO.Sessions.Master_Session'Class) is
      Stmt : ADO.Statements.Delete_Statement := Session.Create_Statement (SEQUENCE_REF_TABLE'Access);
   begin
      Stmt.Set_Filter (Filter => "name = ?");
      Stmt.Add_Param (Value => Object.Name);
      Stmt.Execute;
   end Delete;
   function Get_Value (Item : in Sequence_Ref;
                       Name : in String) return EL.Objects.Object is
      Impl : constant access Sequence_Ref_Impl := Sequence_Ref_Impl (Item.Get_Object.all)'Access;
   begin
      if Name = "name" then
         return EL.Objects.To_Object (Impl.Name);
      end if;
      if Name = "value" then
         return EL.Objects.To_Object (Long_Long_Integer (Impl.Value));
      end if;
      if Name = "block_size" then
         return EL.Objects.To_Object (Long_Long_Integer (Impl.Block_Size));
      end if;
      raise ADO.Databases.NOT_FOUND;
   end Get_Value;
   procedure List (Object  : in out Sequence_Ref_Vector;
                   Session : in out ADO.Sessions.Session'Class;
                   Query   : in ADO.SQL.Query'Class) is
      Stmt : ADO.Statements.Query_Statement := Session.Create_Statement (SEQUENCE_REF_TABLE'Access);
   begin
      Stmt.Set_Parameters (Query);
      Stmt.Execute;
      Sequence_Ref_Vectors.Clear (Object);
      while Stmt.Has_Elements loop
         declare
            Item : Sequence_Ref;
            Impl : constant Sequence_Ref_Access := new Sequence_Ref_Impl;
         begin
            Impl.Load (Stmt);
            ADO.Objects.Set_Object (Item, Impl.all'Access);
            Object.Append (Item);
         end;
         Stmt.Next;
      end loop;
   end List;
   --  ------------------------------
   --  Load the object from current iterator position
   --  ------------------------------
   procedure Load (Object : in out Sequence_Ref_Impl;
                   Stmt   : in out ADO.Statements.Query_Statement'Class) is
   begin
      Object.Name := Stmt.Get_Unbounded_String (0);
      Object.Object_Version := Stmt.Get_Integer (1);
      Object.Value := Stmt.Get_Identifier (2);
      Object.Block_Size := Stmt.Get_Identifier (3);
      Object.Object_Version := Stmt.Get_Integer (1);
      Set_Created (Object);
   end Load;
end ADO.Model;