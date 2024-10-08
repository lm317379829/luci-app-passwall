local fs = require "nixio.fs"
local passwallPath = "/usr/local/bin/passwall"

-- 检查文件是否存在
if not fs.stat(passwallPath) then
    local tpl = require("luci.template")
    tpl.render_string([[<script type="text/javascript">
        alert('未找到sing-box，下载后重命名为passwall后放置与/usr/local/bin并给与权限');
    </script>]])
end

m = Map("passwall")
s = m:section(TypedSection, "passwall")

-- 在控制面板中显示 passwall 的运行状态
status = s:option(DummyValue, "status", translate("状态"))
status.rawhtml = true
status.cfgvalue = function(self, section)
    return getSingBoxStatus()
end

-- 在控制面板中控制 passwall 的运行
o = s:option(ListValue, "control", "控制")

-- 定义选项的值
o:value("start", "启动")
o:value("stop", "停止")
o:value("restart", "重启")

-- 定义根据选项执行不同的函数
function o.write(self, section, value)
    if value == "start" then
        startPassWall()
    elseif value == "stop" then
        stopPassWall()
    elseif value == "restart" then
        restartPassWall()
        value = "start"
    end
    return ListValue.write(self, section, value)
end

-- 定义不同选项对应的函数
function startPassWall()
    luci.sys.call("/etc/init.d/passwall enable && /etc/init.d/passwall start")
    luci.http.redirect(luci.dispatcher.build_url("admin", "services", "passwall"))
end

function stopPassWall()
    luci.sys.call("/etc/init.d/passwall stop && /etc/init.d/passwall disable")
    luci.http.redirect(luci.dispatcher.build_url("admin", "services", "passwall"))
end

function restartPassWall()
    luci.sys.call("/etc/init.d/passwall restart")
    luci.http.redirect(luci.dispatcher.build_url("admin", "services", "passwall"))
end

-- 添加检查 passwall 运行状态的函数
function getSingBoxStatus()
    local running = luci.sys.call("pgrep passwall >/dev/null") == 0
    if running then
        return "<span style='color: green;'><strong>Sing-Box 正在运行</strong></span>"
    else
        return "<span style='color: red;'><strong>Sing-Box 未运行</strong></span>"
    end
end

return m
