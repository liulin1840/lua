local M         = {};
local modelName = ...;
_G[modelName]   = M;

require "syslog"
local json = require "cjson"

function M.syslog(message)
	syslog.openlog("lua syslog", syslog.LOG_PERROR + syslog.LOG_ODELAY, "LOG_USER")
	syslog.syslog("LOG_DEBUG", message)
	syslog.closelog()
end
--/ * *
--*  日志新增可以传入当前函数与行号,方便快速的定位
--   当前行号 :debug.getinfo(1).currentline
--   当前函数 :debug.getinfo(1).name
-- -- * /
function M.log(data,function_name,line_number)
    if data == nil then
        return
    end
    if function_name== nil or line_number == nil then
        function_name = "#########"
        line_number   = "*********"
    end
    
    if( type(function_name) == "number") then
        local  tmp    = ""
        tmp           =  function_name
        function_name = line_number
        line_number   = tmp
    end

    local dataType = type(data)

    if (dataType == "number") then
    	M.syslog("--name:"..function_name.."--line:"..line_number.."--data:"..tostring(data))
    elseif (dataType == "string") then
        M.syslog("--name:"..function_name.."--line:"..line_number.."--data:"..data)
    elseif (dataType == "table") then
        M.syslog("--name:"..function_name.."--line:"..line_number.."--data:"..json.encode(data))
    end
end

return M;