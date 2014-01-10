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

--for row in db:nrows("ALTER TABLE FirstGame ADD COLUMN timestamp") do end
--local createTableGame2= [[CREATE TABLE IF NOT EXISTS SecondGame(id INTEGER PRIMARY KEY autoincrement, category, score, name, timestamp);]]
--db:exec(createTableGame2)

--local createTableGame3= [[CREATE TABLE IF NOT EXISTS ThirdGame(id INTEGER PRIMARY KEY autoincrement, category, score, name, timestamp);]]
--db:exec(createTableGame3)

for row in db:nrows("DELETE from FirstGame") do
	print(row.name)
end

print("Table Structure:")
for row in db:nrows("SELECT name FROM sqlite_master WHERE type='table';") do
	print(row.name)
end

print("print")
for row in db:nrows("SELECT * FROM FirstGame where category = 'easy';") do
	print(row.id..row.category..row.name)
end

for row in db:nrows("PRAGMA table_info(FirstGame);") do print(row.name) end
