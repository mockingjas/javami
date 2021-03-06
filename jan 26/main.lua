-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

require "sqlite3"
local lfs = require "lfs"
local storyboard = require "storyboard"
local path = system.pathForFile("JaVaMiaDb.sqlite3", system.ResourceDirectory)
db = sqlite3.open( path )

storyboard.gotoScene( "startmenu")

--for row in db:nrows("ALTER TABLE ThirdGame ADD COLUMN pausecount") do end
--local createTableGame2= [[CREATE TABLE IF NOT EXISTS SecondGame(id INTEGER PRIMARY KEY autoincrement, category, score, name, timestamp);]]
--db:exec(createTableGame2)
--local createTableGame3= [[CREATE TABLE IF NOT EXISTS ThirdGame(id INTEGER PRIMARY KEY autoincrement, category, score, name, timestamp);]]
--db:exec(createTableGame3)
--for row in db:nrows("DROP TABLE Profile")do end
--for row in db:nrows("ALTER TABLE FirstGame ADD COLUMN pausecount") do end
--local game2analytics= [[CREATE TABLE IF NOT EXISTS SecondGameAnalytics(id INTEGER PRIMARY KEY autoincrement, gamenumber, roundnumber, word, category, isCorrect, speed);]]
--db:exec(game2analytics)

--local game3analytics= [[CREATE TABLE IF NOT EXISTS ThirdGameAnalytics(id INTEGER PRIMARY KEY autoincrement, gamenumber, roundnumber, score, speed);]]
--db:exec(game3analytics)

for row in db:nrows("PRAGMA table_info(Profile);") do print(row.name) end

-- BAGO
local profile= [[CREATE TABLE IF NOT EXISTS Profile(id INTEGER PRIMARY KEY autoincrement, name, age);]]
db:exec(profile)

print("**DATABASE**")
for row in db:nrows("SELECT name FROM sqlite_master WHERE type='table';") do
	print(row.name)
end

for row in db:nrows("SELECT * FROM Profile") do	print(row.age..row.name) end
--for row in db:nrows("SELECT * FROM SecondGameAnalytics") do	print(row.id..row.gamenumber..row.roundnumber) end
--for row in db:nrows("SELECT COUNT(*) as count FROM SecondGameAnalytics") do	print(row.count) end



