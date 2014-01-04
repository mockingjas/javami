-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

require "sqlite3"
local lfs = require "lfs"
local path = system.pathForFile("JaVaMiaDb.sqlite3", system.ResourceDirectory)
db = sqlite3.open( path )   
local file
local option
local storyboard = require "storyboard"

storyboard.gotoScene( "startmenu")

print("Table Structure:")
for row in db:nrows("SELECT name FROM sqlite_master WHERE type='table';") do
	print(row.name)
end

print("print")
for row in db:nrows("SELECT * FROM FirstGame where category = 'medium';") do
	print(row.id..row.category..row.name)
end





