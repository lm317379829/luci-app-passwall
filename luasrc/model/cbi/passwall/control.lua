local fs = require "nixio.fs"
local sys = require "luci.sys"
local http = require "luci.http"
local dispatcher = require "luci.dispatcher"
local passwallPath = "/usr/local/bin/passwall"

m = Map("passwall", "Passwall控制面板")
s = m:section(TypedSection, "passwall", "设置")
s.anonymous = true

-- 检查文件是否存在
if not fs.stat(passwallPath) then
    local tpl = require("luci.template")
    tpl.render_string([[
        <script type="text/javascript">
            alert('未找到 sing-box，请下载后重命名为 passwall 放置于 /usr/local/bin，并确保有执行权限');
        </script>
    ]])
end

-- 显示 passwall 的运行状态
status = s:option(DummyValue, "status", translate("状态"))
status.rawhtml = true
status.cfgvalue = function(self, section)
    return getSingBoxStatus()
end

-- 控制 passwall 的启动、停止和重启
control = s:option(ListValue, "control", "控制")
control:value("start", "启动")
control:value("stop", "停止")
control:value("restart", "重启")

-- 根据选项执行不同的操作
function control.write(self, section, value)
    if value == "start" then
        startPassWall()
    elseif value == "stop" then
        stopPassWall()
    elseif value == "restart" then
        restartPassWall()
        value = "start"
    end
    ListValue.write(self, section, value)
end

-- 定义启动、停止和重启函数
function startPassWall()
    sys.call("/etc/init.d/passwall enable && /etc/init.d/passwall start")
    http.redirect(dispatcher.build_url("admin", "services", "passwall"))
end

function stopPassWall()
    sys.call("/etc/init.d/passwall stop && /etc/init.d/passwall disable")
    http.redirect(dispatcher.build_url("admin", "services", "passwall"))
end

function restartPassWall()
    sys.call("/etc/init.d/passwall restart")
    http.redirect(dispatcher.build_url("admin", "services", "passwall"))
end

-- 检查 passwall 的运行状态
function getSingBoxStatus()
    local running = sys.call("pgrep passwall >/dev/null") == 0
    if running then
        return "<span style='color: green;'><strong>Sing-Box 正在运行</strong></span>"
    else
        return "<span style='color: red;'><strong>Sing-Box 未运行</strong></span>"
    end
end

return m
