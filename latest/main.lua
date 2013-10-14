-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

require "sqlite3"
local lfs = require "lfs"
--local db = sqlite3.open("Game1_DB.sqlite3")
local path = system.pathForFile("Game1_DB.sqlite3", system.ResourceDirectory)
local db = sqlite3.open( path )
local file

local storyboard = require "storyboard"
storyboard.gotoScene( "startmenu" )