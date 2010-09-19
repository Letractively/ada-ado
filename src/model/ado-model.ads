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

with ADO.Databases;
with ADO.Sessions;
with ADO.Objects;
with ADO.Statements;
with ADO.SQL;
with ADO.Schemas;

with Ada.Calendar;
with Ada.Containers.Vectors;
with Ada.Strings.Unbounded;

with EL.Objects;
package ADO.Model is

   use Ada.Calendar;
   use Ada.Strings.Unbounded;
   use ADO.Objects;
   use ADO.Databases;
   use ADO.Statements;

   --  --------------------
   --  Sequence generator
   --  --------------------
   type Sequence_Ref is new ADO.Objects.Object_Ref with null record;


   --  Set the sequence name
   procedure Set_Name (Object : in out Sequence_Ref;
                       Value  : in String);

   procedure Set_Name (Object : in out Sequence_Ref;
                       Value : in Unbounded_String);

   --  Get the sequence name
   function Get_Name (Object : in Sequence_Ref)
                 return String;

   function Get_Name (Object : in Sequence_Ref)
                 return Unbounded_String;






   --  Set the sequence value
   procedure Set_Value (Object : in out Sequence_Ref;
                        Value  : in ADO.Identifier);

   --  Get the sequence value
   function Get_Value (Object : in Sequence_Ref)
                 return ADO.Identifier;




   --  Set the sequence block size
   procedure Set_Block_Size (Object : in out Sequence_Ref;
                             Value  : in ADO.Identifier);

   --  Get the sequence block size
   function Get_Block_Size (Object : in Sequence_Ref)
                 return ADO.Identifier;




   --  Internal method to allocate the Object_Record instance
   procedure Allocate (Object : in out Sequence_Ref);

   --  Copy of the object.
   function Copy (Object : Sequence_Ref) return Sequence_Ref;

   --  Load the entity identified by 'Id'.
   --  Raises the NOT_FOUND exception if it does not exist.
   procedure Load (Object  : in out Sequence_Ref;
                   Session : in out ADO.Sessions.Session'Class;
                   Id      : in Unbounded_String);

   --  Find and load the entity.
   procedure Find (Object  : in out Sequence_Ref;
                   Session : in out ADO.Sessions.Session'Class;
                   Query   : in ADO.SQL.Query'Class;
                   Found   : out Boolean);

   --  Save the entity.  If the entity does not have an identifier, an identifier is allocated
   --  and it is inserted in the table.  Otherwise, only data fields which have been changed
   --  are updated.
   procedure Save (Object  : in out Sequence_Ref;
                   Session : in out ADO.Sessions.Master_Session'Class);

   --  Delete the entity.
   procedure Delete (Object  : in out Sequence_Ref;
                     Session : in out ADO.Sessions.Master_Session'Class);

   function Get_Value (Item : in Sequence_Ref;
                       Name : in String) return EL.Objects.Object;

   package Sequence_Ref_Vectors is
      new Ada.Containers.Vectors (Index_Type   => Natural,
                                  Element_Type => Sequence_Ref,
                                  "="          => "=");
   subtype Sequence_Ref_Vector is Sequence_Ref_Vectors.Vector;

   procedure List (Object  : in out Sequence_Ref_Vector;
                   Session : in out ADO.Sessions.Session'Class;
                   Query   : in ADO.SQL.Query'Class);


private

   SEQUENCE_REF_NAME : aliased constant String := "sequence";
   
   COL_0_1_NAME : aliased constant String := "name";
   
   COL_1_1_NAME : aliased constant String := "object_version";
   
   COL_2_1_NAME : aliased constant String := "value";
   
   COL_3_1_NAME : aliased constant String := "block_size";
   

   SEQUENCE_REF_TABLE : aliased constant ADO.Schemas.Class_Mapping :=
     (Count => 4,
      Table => SEQUENCE_REF_NAME'Access,
      Members => (
         COL_0_1_NAME'Access,
      
         COL_1_1_NAME'Access,
      
         COL_2_1_NAME'Access,
      
         COL_3_1_NAME'Access
      )
     );

   type Sequence_Ref_Impl is
      new ADO.Objects.Object_Record (Key_Type => ADO.Objects.KEY_INTEGER,
                                     Of_Class => SEQUENCE_REF_TABLE'Access)
   with record
       Name : Unbounded_String;
       Object_Version : Integer;
       Value : ADO.Identifier;
       Block_Size : ADO.Identifier;
   end record;

   type Sequence_Ref_Access is access all Sequence_Ref_Impl;

   overriding
   procedure Destroy (Object : access Sequence_Ref_Impl);

   overriding
   procedure Find (Object  : in out Sequence_Ref_Impl;
                   Session : in out ADO.Sessions.Session'Class;
                   Query   : in ADO.SQL.Query'Class;
                   Found   : out Boolean);
   
   procedure Load (Object  : in out Sequence_Ref_Impl;
                   Stmt   : in out ADO.Statements.Query_Statement'Class);

   overriding
   procedure Save (Object  : in out Sequence_Ref_Impl;
                   Session : in out ADO.Sessions.Master_Session'Class);
   
   procedure Create (Object  : in out Sequence_Ref_Impl;
                     Session : in out ADO.Sessions.Master_Session'Class);

   overriding
   procedure Delete (Object  : in out Sequence_Ref_Impl;
                     Session : in out ADO.Sessions.Master_Session'Class);


   procedure Set_Field (Object : in out Sequence_Ref'Class;
                        Impl   : out Sequence_Ref_Access;
                        Field  : in Positive);


end ADO.Model;
