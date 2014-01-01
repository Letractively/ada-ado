-----------------------------------------------------------------------
--  ADO Drivers -- Database Drivers initialization
--  Copyright (C) 2010, 2011, 2012, 2013 Stephane Carrez
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

--  The <tt>Initializer</tt> procedure must be instantiated and called to register
--  the available database drivers and configure them.
generic
   type Config_Type (<>) is limited private;
   with procedure Initialize (Config : in Config_Type) is <>;
procedure ADO.Drivers.Initializer (Config : in Config_Type);