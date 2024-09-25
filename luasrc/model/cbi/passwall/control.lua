m = Map("passwall")
s = m:section(TypedSection, "passwall")

-- 在控制面板中显示 sing-box 的运行状态
status = s:option(DummyValue, "status", translate("状态"))
status.rawhtml = true
status.cfgvalue = function(self, section)
    return getSingBoxStatus()
end

-- 在控制面板中控制 sing-box 的运行
o = s:option(ListValue, "control", "控制")

-- 定义选项的值
o:value("stop", "停止")
o:value("start", "启动")
o:value("restart", "重启")

-- 定义根据选项执行不同的函数
function o.write(self, section, value)
    if value == "start" then
        startSingBox()
    elseif value == "stop" then
        stopSingBox()
    elseif value == "restart" then
        restartSingBox()
    end
    return ListValue.write(self, section, value)
end

-- 定义不同选项对应的函数
function startSingBox()
    luci.sys.call("/etc/init.d/singbox start")
    luci.http.redirect(luci.dispatcher.build_url("admin", "services", "passwall"))
end

function stopSingBox()
    luci.sys.call("/etc/init.d/singbox stop")
    luci.http.redirect(luci.dispatcher.build_url("admin", "services", "passwall"))
end

function restartSingBox()
    luci.sys.call("/etc/init.d/singbox restart")
    luci.http.redirect(luci.dispatcher.build_url("admin", "services", "passwall"))
end

-- 添加检查 sing-box 运行状态的函数
function getSingBoxStatus()
    local running = luci.sys.call("pgrep sing-box >/dev/null") == 0
    if running then
        return "<span style='color: green;'><strong>Sing-Box 正在运行</strong></span>"
    else
        return "<span style='color: red;'><strong>Sing-Box 未运行</strong></span>"
    end
end

return m