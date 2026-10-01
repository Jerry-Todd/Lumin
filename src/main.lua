local Lumin = {}

local TerminateCheck = false

Lumin.CreateBasicView = require("views.basic")
Lumin.CreateSection = require("views.section")
Lumin.CreateScrollSection = require("views.scroll")
Lumin.CreateButton = require("views.button")
Lumin.CreateLabel = require("views.label")
Lumin.CreateTextInput = require("views.textinput")

local MainView = nil
function Lumin.setMainView(view)
    MainView = view
end

local function getTargetMonitor(target)
    if not target or (term.native and target == term.native()) then
        return nil, false
    end

    local isMonitor = target.setTextScale ~= nil
    local monitorName = nil

    if peripheral and peripheral.getName then
        local ok, name = pcall(peripheral.getName, target)
        if ok and type(name) == "string" then
            monitorName = name
            isMonitor = true
        end
    end

    if not monitorName and isMonitor and peripheral and peripheral.getNames then
        local monitors = {}
        for _, name in ipairs(peripheral.getNames()) do
            if peripheral.getType(name) == "monitor" then
                table.insert(monitors, name)
            end
        end
        if #monitors == 1 then
            monitorName = monitors[1]
        end
    end

    return monitorName, isMonitor
end

function Lumin.Start(mainFunction)
    TerminateCheck = false

    local targetTerminal = term.current()
    local monitorName, isMonitor = getTargetMonitor(targetTerminal)

    parallel.waitForAll(
        mainFunction,
        function()
            parallel.waitForAny(
                function()
                    while not TerminateCheck do sleep(0) end
                    term.setBackgroundColor(colors.black)
                    term.setTextColor(colors.white)
                    term.clear()
                    term.setCursorPos(1, 1)
                end,
                function ()
                    local cursorTimer = os.startTimer(0.5)
                    while true do
                        local event, param1, x, y = os.pullEvent()
                        if not isMonitor and term.current() ~= targetTerminal then
                            targetTerminal = term.current()
                            monitorName, isMonitor = getTargetMonitor(targetTerminal)
                        end

                        if event == "mouse_click" and MainView then
                            MainView.handleClick(1, x, y)
                        elseif event == "monitor_touch" and MainView then
                            if (monitorName and param1 == monitorName) or (not monitorName and isMonitor) then
                                MainView.handleClick(1, x, y)
                            end
                        elseif event == "mouse_scroll" and MainView and MainView.handleScroll then
                            MainView.handleScroll(param1, x, y)
                        elseif (event == "char" or event == "key" or event == "paste")
                            and MainView and MainView.handleTextEvent then
                            MainView.handleTextEvent(event, param1)
                        elseif event == "timer" and param1 == cursorTimer then
                            if MainView and MainView.handleTextEvent then
                                MainView.handleTextEvent("blink")
                            end
                            cursorTimer = os.startTimer(0.5)
                        end
                    end
                end
            )
        end
    )
end

function Lumin.Stop()
    TerminateCheck = true
end

return Lumin
