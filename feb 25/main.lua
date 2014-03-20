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

--for row in db:nrows("DROP TABLE ThirdGameAnalytics")do end
--for row in db:nrows("ALTER TABLE FirstGame ADD COLUMN age") do end
--[[for row in db:nrows("DELETE FROM SecondGame") do end
for row in db:nrows("DELETE FROM SecondGameAnalytics") do end
for row in db:nrows("DELETE FROM ThirdGame") do end
for row in db:nrows("DELETE FROM FirstGameAnalytics") do end
for row in db:nrows("DELETE FROM ThirdGameAnalytics") do end
for row in db:nrows("DELETE FROM FirstGame") do end]]

for row in db:nrows("SELECT COUNT(*) as count FROM SecondGame") do
	if row.count == 0 then
		for row in db:nrows("UPDATE SQLITE_SEQUENCE SET seq = -1 WHERE name = 'SecondGame' ") do end		
	end
end

for row in db:nrows("PRAGMA table_info(SecondGameAnalytics);") do print(row.name) end

print("**DATABASE**")
for row in db:nrows("SELECT name FROM sqlite_master WHERE type='table';") do
	print(row.name)
end

--for row in db:nrows("UPDATE Words SET colorCategory = 'blue' where name ='blanket'") do	print(row.name) end
--for row in db:nrows("UPDATE Words SET livingThingCategory = '1' where name ='keep'") do	print(row.name) end
--for row in db:nrows("UPDATE Words SET colorCategory = 'yellow' where name ='pizza'") do	print(row.name) end