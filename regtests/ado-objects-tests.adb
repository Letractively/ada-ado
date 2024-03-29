-----------------------------------------------------------------------
--  ADO Objects Tests -- Tests for ADO.Objects
--  Copyright (C) 2011, 2012, 2013, 2014 Stephane Carrez
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

with Util.Test_Caller;
with ADO.Sessions;
with Regtests.Simple.Model;
with Regtests.Comments;
package body ADO.Objects.Tests is

   use Util.Tests;
   use type Ada.Containers.Hash_Type;

   function Get_Allocate_Key (N : Identifier) return Object_Key;

   function Get_Allocate_Key (N : Identifier) return Object_Key is
      Result : Object_Key (Of_Type  => KEY_INTEGER,
                           Of_Class => Regtests.Simple.Model.ALLOCATE_TABLE'Access);
   begin
      Set_Value (Result, N);
      return Result;
   end Get_Allocate_Key;

   --  ------------------------------
   --  Various tests on Hash and key comparison
   --  ------------------------------
   procedure Test_Key (T : in out Test) is
      K1 : constant Object_Key := Get_Allocate_Key (1);
      K2 : Object_Key (Of_Type  => KEY_STRING,
                       Of_Class => Regtests.Simple.Model.USER_TABLE'Access);
      K3 : Object_Key := K1;
      K4 : Object_Key (Of_Type  => KEY_INTEGER,
                       Of_Class => Regtests.Simple.Model.USER_TABLE'Access);
   begin
      T.Assert (not (K1 = K2), "Key on different tables must be different");
      T.Assert (not (K2 = K4), "Key with different type must be different");
      T.Assert (K1 = K3, "Keys are identical");
      T.Assert (Equivalent_Elements (K1, K3), "Keys are identical");
      T.Assert (Equivalent_Elements (K3, K1), "Keys are identical");

      T.Assert (Hash (K1) = Hash (K3), "Hash of identical keys should be identical");

      Set_Value (K3, 2);
      T.Assert (not (K1 = K3), "Keys should be different");
      T.Assert (Hash (K1) /= Hash (K3), "Hash should be different");
      T.Assert (Hash (K1) /= Hash (K2), "Hash should be different");

      Set_Value (K4, 1);
      T.Assert (Hash (K1) /= Hash (K4),
               "Hash on key with same value and different tables should be different");
      T.Assert (not (K4 = K1), "Key on different tables should be different");

      Set_Value (K2, 1);
      T.Assert (Hash (K1) /= Hash (K2), "Hash should be different");
   end Test_Key;

   --  ------------------------------
   --  Check:
   --    Object_Ref := (reference counting)
   --    Object_Ref.Copy
   --    Object_Ref.Get_xxx generated method
   --    Object_Ref.Set_xxx generated method
   --    Object_Ref.=
   --  ------------------------------
   procedure Test_Object_Ref (T : in out Test) is
      use type Regtests.Simple.Model.User_Ref;
      Obj1     : Regtests.Simple.Model.User_Ref;
      Null_Obj : Regtests.Simple.Model.User_Ref;
   begin
      T.Assert (Obj1 = Null_Obj, "Two null objects are identical");
      for I in 1 .. 10 loop
         Obj1.Set_Name ("User name");
         T.Assert (Obj1.Get_Name = "User name", "User_Ref.Set_Name invalid result");

         T.Assert (Obj1 /= Null_Obj, "Object is not identical as the null object");
         declare
            Obj2 : constant Regtests.Simple.Model.User_Ref := Obj1;
            Obj3 : Regtests.Simple.Model.User_Ref;
         begin
            Obj1.Copy (Obj3);
            Obj3.Set_Id (2);
            --  Check the copy
            T.Assert (Obj2.Get_Name = "User name", "Object_Ref.Copy invalid copy");
            T.Assert (Obj3.Get_Name = "User name", "Object_Ref.Copy invalid copy");
            T.Assert (Obj2 = Obj1, "Object_Ref.'=' invalid comparison after assignment");

            T.Assert (Obj3 /= Obj1, "Object_Ref.'=' invalid comparison after copy");

            --  Change original, make sure it's the same of Obj2.
            Obj1.Set_Name ("Second name");
            T.Assert (Obj2.Get_Name = "Second name", "Object_Ref.Copy invalid copy");
            T.Assert (Obj2 = Obj1, "Object_Ref.'=' invalid comparison after assignment");

            --  The copy is not modified
            T.Assert (Obj3.Get_Name = "User name", "Object_Ref.Copy invalid copy");
         end;
      end loop;
   end Test_Object_Ref;

   --  ------------------------------
   --  Test creation of an object with lazy loading.
   --  ------------------------------
   procedure Test_Create_Object (T : in out Test) is
      User : Regtests.Simple.Model.User_Ref;
      Cmt  : Regtests.Comments.Comment_Ref;
   begin
      --  Create an object within a transaction.
      declare
         S : ADO.Sessions.Master_Session := Regtests.Get_Master_Database;
      begin
         S.Begin_Transaction;
         User.Set_Name ("Joe");
         User.Set_Value (0);
         User.Save (S);
         S.Commit;
      end;

      --  Load it from another session.
      declare
         S  : ADO.Sessions.Master_Session := Regtests.Get_Master_Database;
         U2 : Regtests.Simple.Model.User_Ref;
      begin
         U2.Load (S, User.Get_Id);
         Assert_Equals (T, "Joe", Ada.Strings.Unbounded.To_String (U2.Get_Name),
                        "Cannot load created object");
         Assert_Equals (T, Integer (0), Integer (U2.Get_Value), "Invalid load");
         T.Assert (User.Get_Key = U2.Get_Key, "Invalid key after load");
      end;

      --  Create a comment for the user.
      declare
         S  : ADO.Sessions.Master_Session := Regtests.Get_Master_Database;
      begin
         S.Begin_Transaction;
         Cmt.Set_Message (Ada.Strings.Unbounded.To_Unbounded_String ("A comment from Joe"));
         Cmt.Set_User (User);
         Cmt.Set_Entity_Id (2);
         Cmt.Set_Entity_Type (1);
         --  Cmt.Set_Date (ADO.DEFAULT_TIME);
         Cmt.Set_Date (Ada.Calendar.Clock);
         Cmt.Save (S);
         S.Commit;
      end;

      --  Load that comment.
      declare
         S  : ADO.Sessions.Master_Session := Regtests.Get_Master_Database;
         C2 : Regtests.Comments.Comment_Ref;
      begin
         C2.Load (S, Cmt.Get_Id);
         T.Assert (not C2.Is_Null, "Loading of object failed");
         T.Assert (Cmt.Get_Key = C2.Get_Key, "Invalid key after load");
         T.Assert_Equals ("A comment from Joe", Ada.Strings.Unbounded.To_String (C2.Get_Message),
                          "Invalid message");

         T.Assert (not C2.Get_User.Is_Null, "User associated with the comment should not be null");
--           T.Assert (not C2.Get_Entity_Type.Is_Null, "Entity type was not set");

         --  Check that we can access the user name (lazy load)
         Assert_Equals (T, "Joe", Ada.Strings.Unbounded.To_String (C2.Get_User.Get_Name),
                        "Cannot load created object");
      end;
   end Test_Create_Object;

   --  ------------------------------
   --  Test creation and deletion of an object record
   --  ------------------------------
   procedure Test_Delete_Object (T : in out Test) is
      User : Regtests.Simple.Model.User_Ref;
   begin
      --  Create an object within a transaction.
      declare
         S : ADO.Sessions.Master_Session := Regtests.Get_Master_Database;
      begin
         S.Begin_Transaction;
         User.Set_Name ("Joe (delete)");
         User.Set_Value (0);
         User.Save (S);
         S.Commit;
      end;

      --  Load it and delete it from another session.
      declare
         S  : ADO.Sessions.Master_Session := Regtests.Get_Master_Database;
         U2 : Regtests.Simple.Model.User_Ref;
      begin
         U2.Load (S, User.Get_Id);

         S.Begin_Transaction;
         U2.Delete (S);
         S.Commit;
      end;

      --  Try to load the deleted object.
      declare
         S  : ADO.Sessions.Master_Session := Regtests.Get_Master_Database;
         U2 : Regtests.Simple.Model.User_Ref;
      begin
         U2.Load (S, User.Get_Id);
         T.Assert (False, "Load of a deleted object should raise NOT_FOUND");

      exception
         when ADO.Objects.NOT_FOUND =>
            null;
      end;
   end Test_Delete_Object;

   --  ------------------------------
   --  Test Is_Inserted and Is_Null
   --  ------------------------------
   procedure Test_Is_Inserted (T : in out Test) is
      User : Regtests.Simple.Model.User_Ref;
   begin
      T.Assert (not User.Is_Inserted, "A null object should not be marked as INSERTED");
      T.Assert (User.Is_Null, "A null object should be marked as NULL");

      --  Create an object within a transaction.
      declare
         S : ADO.Sessions.Master_Session := Regtests.Get_Master_Database;
      begin
         S.Begin_Transaction;
         User.Set_Name ("John");
         T.Assert (not User.Is_Null, "User should not be NULL");
         T.Assert (not User.Is_Inserted, "User was not saved and not yet inserted in database");

         User.Set_Value (1);
         User.Save (S);
         S.Commit;
         T.Assert (User.Is_Inserted, "After a save operation, the user should be marked INSERTED");
         T.Assert (not User.Is_Null, "User should not be NULL");
      end;

      declare
         S    : ADO.Sessions.Master_Session := Regtests.Get_Master_Database;
         John : Regtests.Simple.Model.User_Ref;
      begin
         John.Load (S, User.Get_Id);
         T.Assert (John.Is_Inserted, "After a load, the object should be marked INSERTED");
         T.Assert (not John.Is_Null, "After a load, the object should not be NULL");
      end;
   end Test_Is_Inserted;

   package Caller is new Util.Test_Caller (Test, "ADO.Objects");

   --  ------------------------------
   --  Add the tests in the test suite
   --  ------------------------------
   procedure Add_Tests (Suite : in Util.Tests.Access_Test_Suite) is
   begin
      Caller.Add_Test (Suite, "Test ADO.Objects.Hash", Test_Key'Access);
      Caller.Add_Test (Suite, "Test Object_Ref.Get/Set", Test_Object_Ref'Access);
      Caller.Add_Test (Suite, "Test ADO.Objects.Create", Test_Create_Object'Access);
      Caller.Add_Test (Suite, "Test ADO.Objects.Delete", Test_Delete_Object'Access);
      Caller.Add_Test (Suite, "Test ADO.Objects.Is_Created", Test_Is_Inserted'Access);
   end Add_Tests;

end ADO.Objects.Tests;
