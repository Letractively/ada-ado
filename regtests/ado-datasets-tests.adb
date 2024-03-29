-----------------------------------------------------------------------
--  ado-datasets-tests -- Test executing queries and using datasets
--  Copyright (C) 2013, 2014 Stephane Carrez
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
with Util.Properties;

with Regtests.Simple.Model;
with ADO.Queries.Loaders;
package body ADO.Datasets.Tests is

   package Caller is new Util.Test_Caller (Test, "ADO.Datasets");

   package User_List_Query_File is
     new ADO.Queries.Loaders.File (Path => "regtests/files/user-list.xml",
                                   Sha1 => "");

   package User_List_Query is
     new ADO.Queries.Loaders.Query (Name => "user-list",
                                    File => User_List_Query_File.File'Access);

   package User_List_Count_Query is
     new ADO.Queries.Loaders.Query (Name => "user-list-count",
                                    File => User_List_Query_File.File'Access);

   procedure Add_Tests (Suite : in Util.Tests.Access_Test_Suite) is
   begin
      Caller.Add_Test (Suite, "Test ADO.Datasets.List (from <sql>)",
                       Test_List'Access);
      Caller.Add_Test (Suite, "Test ADO.Datasets.Get_Count (from <sql>)",
                       Test_Count'Access);
      Caller.Add_Test (Suite, "Test ADO.Datasets.Get_Count (from <sql-count>)",
                       Test_Count_Query'Access);
   end Add_Tests;

   procedure Test_List (T : in out Test) is
      DB     : ADO.Sessions.Master_Session := Regtests.Get_Master_Database;
      Query  : ADO.Queries.Context;
      Count  : Natural;
      Data   : ADO.Datasets.Dataset;
      Props  : constant Util.Properties.Manager := Util.Tests.Get_Properties;
   begin
      --  Configure the XML query loader.
      ADO.Queries.Loaders.Initialize (Props.Get ("ado.queries.paths", ".;db"),
                                      Props.Get ("ado.queries.load", "false") = "true");

      Query.Set_Count_Query (User_List_Query.Query'Access);
      Query.Bind_Param ("filter", String '("test-list"));
      Count := ADO.Datasets.Get_Count (DB, Query);
      for I in 1 .. 100 loop
         declare
            User : Regtests.Simple.Model.User_Ref;
         begin
            User.Set_Name ("John " & Integer'Image (I));
            User.Set_Select_Name ("test-list");
            User.Set_Value (ADO.Identifier (I));
            User.Save (DB);
         end;
      end loop;
      DB.Commit;

      Query.Set_Query (User_List_Query.Query'Access);
      ADO.Datasets.List (Data, DB, Query);
      Util.Tests.Assert_Equals (T, 100 + Count, Data.Get_Count, "Invalid dataset size");
   end Test_List;

   procedure Test_Count (T : in out Test) is
      DB     : constant ADO.Sessions.Master_Session := Regtests.Get_Master_Database;
      Query  : ADO.Queries.Context;
      Count  : Natural;
      Props  : constant Util.Properties.Manager := Util.Tests.Get_Properties;
   begin
      --  Configure the XML query loader.
      ADO.Queries.Loaders.Initialize (Props.Get ("ado.queries.paths", ".;db"),
                                      Props.Get ("ado.queries.load", "false") = "true");
      Query.Set_Query (User_List_Count_Query.Query'Access);
      Count := ADO.Datasets.Get_Count (DB, Query);
      T.Assert (Count > 0,
                "The ADO.Datasets.Get_Count query should return a positive count");
   end Test_Count;

   procedure Test_Count_Query (T : in out Test) is
      DB     : constant ADO.Sessions.Master_Session := Regtests.Get_Master_Database;
      Query  : ADO.Queries.Context;
      Count  : Natural;
      Props  : constant Util.Properties.Manager := Util.Tests.Get_Properties;
   begin
      --  Configure the XML query loader.
      ADO.Queries.Loaders.Initialize (Props.Get ("ado.queries.paths", ".;db"),
                                      Props.Get ("ado.queries.load", "false") = "true");
      Query.Set_Count_Query (User_List_Query.Query'Access);
      Query.Bind_Param ("filter", String '("test-list"));
      Count := ADO.Datasets.Get_Count (DB, Query);
      T.Assert (Count > 0,
                "The ADO.Datasets.Get_Count query should return a positive count");
   end Test_Count_Query;

end ADO.Datasets.Tests;
