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

--for row in db:nrows("DELETE from FirstGame") do	print(row.name) end
--for row in db:nrows("DROP TABLE FirstGameAnalytics")do end

--for row in db:nrows("ALTER TABLE FirstGame ADD COLUMN pausecount") do end


local game2analytics= [[CREATE TABLE IF NOT EXISTS SecondGameAnalytics(id INTEGER PRIMARY KEY autoincrement, gamenumber, roundnumber, word, category, isCorrect, speed);]]
db:exec(game2analytics)

local game1analytics= [[CREATE TABLE IF NOT EXISTS FirstGameAnalytics(id INTEGER PRIMARY KEY autoincrement, gamenumber, roundnumber, speed, hintcount, triescount, word);]]
db:exec(game1analytics)

print("print")
for row in db:nrows("SELECT * FROM FirstGame where category = 'easy';") do
--	print(row.id..row.category..row.name..row.pausecount)
end

for row in db:nrows("SELECT * FROM FirstGameAnalytics") do
	print(row.id..row.gamenumber)
end

print("Table Structure:")
for row in db:nrows("SELECT name FROM sqlite_master WHERE type='table';") do
	print(row.name)
end


for row in db:nrows("PRAGMA table_info(FirstGameAnalytics);") do print(row.name) end

