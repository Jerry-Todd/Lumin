local CreateBasicView = require("views.basic")

return function(values)
    if not values then values = {} end
    local view = CreateBasicView(values)

    view.text = values.text == nil and "" or tostring(values.text)
    view.placeholderText = values.placeholderText == nil and "" or tostring(values.placeholderText)
    view.placeholderTextColor = values.placeholderTextColor or colors.gray
    view.width = values.width or math.max(1, #view.text)
    view.height = values.height or 1
    view.maxLength = values.maxLength
    view.cursorPosition = #view.text + 1
    view.focused = false
    view.cursorVisible = false
    view.onChange = values.onChange or function(text) end
    view.onSubmit = values.onSubmit or function(text) end
    view.onFocus = values.onFocus or function() end
    view.onBlur = values.onBlur or function() end

    local function getVisibleStart()
        return math.max(1, view.cursorPosition - view.width + 1)
    end

    local function redraw()
        if view.redraw then view.redraw() end
    end

    local function insertText(text)
        if not view.focused or text == "" then return end

        local available = view.maxLength and view.maxLength - #view.text or #text
        if available <= 0 then return end
        if #text > available then text = text:sub(1, available) end

        view.text = view.text:sub(1, view.cursorPosition - 1)
            .. text
            .. view.text:sub(view.cursorPosition)
        view.cursorPosition = view.cursorPosition + #text
        view.cursorVisible = true
        view.onChange(view.text)
        redraw()
    end

    view.setText = function(text)
        view.text = tostring(text or "")
        if view.maxLength then
            view.text = view.text:sub(1, view.maxLength)
        end
        view.cursorPosition = #view.text + 1
        redraw()
    end

    view.handleClick = function(mouseButton, x, y)
        if not view.active then return end

        local inside = x >= view.x and x < view.x + view.width
            and y >= view.y and y < view.y + view.height
        local wasFocused = view.focused
        view.focused = inside

        if inside then
            local visibleStart = getVisibleStart()
            view.cursorPosition = math.min(
                #view.text + 1,
                visibleStart + x - view.x
            )
            view.cursorVisible = true
            if not wasFocused then view.onFocus() end
        elseif wasFocused then
            view.cursorVisible = false
            view.onBlur()
        end

        redraw()
    end

    view.handleTextEvent = function(event, value)
        if not view.active or not view.focused then return end

        if event == "char" or event == "paste" then
            insertText(value)
        elseif event == "key" then
            local previousText = view.text
            if value == keys.backspace and view.cursorPosition > 1 then
                view.text = view.text:sub(1, view.cursorPosition - 2)
                    .. view.text:sub(view.cursorPosition)
                view.cursorPosition = view.cursorPosition - 1
            elseif value == keys.delete and view.cursorPosition <= #view.text then
                view.text = view.text:sub(1, view.cursorPosition - 1)
                    .. view.text:sub(view.cursorPosition + 1)
            elseif value == keys.left then
                view.cursorPosition = math.max(1, view.cursorPosition - 1)
            elseif value == keys.right then
                view.cursorPosition = math.min(#view.text + 1, view.cursorPosition + 1)
            elseif value == keys.home then
                view.cursorPosition = 1
            elseif value == keys["end"] then
                view.cursorPosition = #view.text + 1
            elseif value == keys.enter then
                view.onSubmit(view.text)
                return
            else
                return
            end

            view.cursorVisible = true
            if view.text ~= previousText then
                view.onChange(view.text)
            end
            redraw()
        elseif event == "blink" then
            view.cursorVisible = not view.cursorVisible
            redraw()
        end
    end

    view.draw = function()
        if not view.active then return end
        view.drawInWindow(function()
            term.setCursorPos(1, 1)
            local showingPlaceholder = view.text == ""
            local displayText = view.text
            if showingPlaceholder then
                displayText = view.placeholderText
            end

            local visibleStart = getVisibleStart()
            displayText = displayText:sub(visibleStart, visibleStart + view.width - 1)
            if view.focused and view.cursorVisible then
                local cursorColumn = view.cursorPosition - visibleStart + 1
                if cursorColumn >= 1 and cursorColumn <= view.width then
                    local lineColor = showingPlaceholder
                        and view.placeholderTextColor
                        or view.textColor
                    term.setTextColor(lineColor)
                    term.write(displayText:sub(1, cursorColumn - 1))
                    term.setTextColor(view.textColor)
                    term.write("_")
                    term.setTextColor(lineColor)
                    term.write(displayText:sub(cursorColumn + 1))
                else
                    term.setTextColor(showingPlaceholder
                        and view.placeholderTextColor
                        or view.textColor)
                    term.write(displayText)
                end
            else
                term.setTextColor(showingPlaceholder
                    and view.placeholderTextColor
                    or view.textColor)
                term.write(displayText)
            end
        end)
    end

    return view
end