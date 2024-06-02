local addRelPath = function(dir)
	local spath = debug.getinfo(1, "S").source:sub(2):gsub("^([^/])", "./%1"):gsub("[^/]*$", "")
	dir = dir and (dir .. "/") or ""
	spath = spath .. dir
	package.path = spath .. "?.lua;" .. spath .. "?/init.lua" .. package.path
end

addRelPath()

require("bootstrap")
require("config")
