-----------------------------------------------------------------------
--  ado-drivers-tests -- Unit tests for database drivers
--  Copyright (C) 2014 Stephane Carrez
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

with Util.Tests;
package ADO.Drivers.Tests is

   procedure Add_Tests (Suite : in Util.Tests.Access_Test_Suite);

   type Test is new Util.Tests.Test with null record;

   --  Test the Get_Config operation.
   procedure Test_Get_Config (T : in out Test);

   --  Test the Get_Driver operation.
   procedure Test_Get_Driver (T : in out Test);

   --  Test loading some invalid database driver.
   procedure Test_Load_Invalid_Driver (T : in out Test);

   --  Test the Get_Driver_Index operation.
   procedure Test_Get_Driver_Index (T : in out Test);

end ADO.Drivers.Tests;
