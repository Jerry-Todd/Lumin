
local CreateSection = require("views.section")

-- Scrollable section view
return function(values)
    if not values then values = {} end
    local view = CreateSection(values)

    view.text = tostring(values.text) or ""
    view.width = values.width or #view.text
    view.height = values.height or 1
    view.scrollLimit = values.scrollLimit
    view.scrollbarBackgroundColor = values.scrollbarBackgroundColor or colors.gray
    view.scrollbarForegroundColor = values.scrollbarForegroundColor or colors.lightGray
    view.scrollPosition = 0

    local function getContentHeight()
        local contentHeight = 0
        for _, child in ipairs(view.children) do
            contentHeight = math.max(contentHeight, child.y + (child.height or 1) - 1)
        end
        return contentHeight
    end

    local function getMaxScroll()
        local maxScroll = math.max(0, getContentHeight() - view.height)
        if view.scrollLimit then
            maxScroll = math.min(maxScroll, math.max(0, view.scrollLimit))
        end
        return maxScroll
    end

    view.handleScroll = function(direction, x, y)
        if not view.active then return end

        local localX = x - view.x + 1
        local localY = y - view.y + 1
        local inside = localX >= 1 and localX <= view.width
            and localY >= 1 and localY <= view.height
        if not inside then return end

        local newPosition = math.max(0, math.min(
            getMaxScroll(),
            view.scrollPosition + direction
        ))
        if newPosition ~= view.scrollPosition then
            view.scrollPosition = newPosition
            view.redraw()
        end
    end

    view.handleClick = function(mouseButton, x, y)
        if not view.active then return end

        local localX = x - view.x + 1
        local localY = y - view.y + 1
        if localX < 1 or localX > view.width
            or localY < 1 or localY > view.height then
            return
        end

        local maxScroll = getMaxScroll()
        if localX == view.width and maxScroll > 0 then
            local newPosition = math.floor(
                (localY - 1) / math.max(1, view.height - 1) * maxScroll + 0.5
            )
            if newPosition ~= view.scrollPosition then
                view.scrollPosition = newPosition
                view.redraw()
            end
            return
        end

        local contentY = localY + view.scrollPosition
        for _, child in ipairs(view.children) do
            if child.handleClick then
                child.handleClick(mouseButton, localX, contentY)
            end
        end
    end

    view.draw = function()
        if not view.active then return end
        view.scrollPosition = math.min(view.scrollPosition, getMaxScroll())
        view.drawInWindow(function()
            for _, child in ipairs(view.children) do
                if child.draw then
                    child.parentOffsetY = -view.scrollPosition
                    child.draw()
                end
            end

            local maxScroll = getMaxScroll()
            if maxScroll > 0 then
                local contentHeight = getContentHeight()
                local thumbHeight = math.max(1, math.floor(
                    view.height * view.height / contentHeight
                ))
                local thumbTop = math.floor(
                    view.scrollPosition / maxScroll * (view.height - thumbHeight)
                ) + 1

                for y = 1, view.height do
                    term.setCursorPos(view.width, y)
                    if y >= thumbTop and y < thumbTop + thumbHeight then
                        term.setBackgroundColor(view.scrollbarForegroundColor)
                    else
                        term.setBackgroundColor(view.scrollbarBackgroundColor)
                    end
                    term.write(" ")
                end
            end
        end)
    end

    return view
end