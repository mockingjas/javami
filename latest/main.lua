-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

require "sqlite3"
local lfs = require "lfs"
local path = system.pathForFile("javami.sqlite3", system.ResourceDirectory)
db = sqlite3.open( path )   

--local db = sqlite3.open("javami_DB.sqlite3")
local file

local storyboard = require "storyboard"
storyboard.gotoScene( "startmenu" )