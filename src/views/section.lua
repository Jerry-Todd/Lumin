local CreateBasicView = require("views.basic")

return function(values)
    if not values then values = {} end
    local view = CreateBasicView(values)

    view.children = {}
    local termWidth, termHeight = term.getSize()
    view.width = values.width or termWidth
    view.height = values.height or termHeight

    view.addChildren = function(...)
        local children = {...}
        for _, child in ipairs(children) do
            table.insert(view.children, child)
        end
    end

    view.removeChild = function(child)
        for i, c in ipairs(view.children) do
            if c == child then
                table.remove(view.children, i)
                break
            end
        end
    end

    view.clear = function()
        view.children = {}
    end

    view.handleClick = function(mouseButton, x, y)
        if not view.active then return end

        local localX = x - view.x + 1
        local localY = y - view.y + 1

        for _, child in ipairs(view.children) do
            if child.handleClick then
                child.handleClick(mouseButton, localX, localY)
            end
        end
    end

    view.handleScroll = function(direction, x, y)
        if not view.active then return end

        local localX = x - view.x + 1
        local localY = y - view.y + 1

        for _, child in ipairs(view.children) do
            if child.handleScroll then
                child.handleScroll(direction, localX, localY)
            end
        end
    end

    view.handleTextEvent = function(event, value)
        if not view.active then return end

        for _, child in ipairs(view.children) do
            if child.handleTextEvent then
                child.handleTextEvent(event, value)
            end
        end
    end

    view.draw = function()
        if not view.active then return end
        view.drawInWindow(function()
            for _, child in ipairs(view.children) do
                if child.draw then child.draw() end
            end
        end)
    end

    return view
end
