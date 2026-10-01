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

function Lumin.Start(mainFunction)
    TerminateCheck = false

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
                        local event, mouseButton, x, y = os.pullEvent()
                        if event == "mouse_click" and MainView then
                            MainView.handleClick(1, x, y)
                        elseif event == "mouse_scroll" and MainView and MainView.handleScroll then
                            MainView.handleScroll(mouseButton, x, y)
                        elseif (event == "char" or event == "key" or event == "paste")
                            and MainView and MainView.handleTextEvent then
                            MainView.handleTextEvent(event, mouseButton)
                        elseif event == "timer" and mouseButton == cursorTimer then
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
