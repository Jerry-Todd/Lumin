return function(values)
    if not values then values = {} end
    local view = {}

    view.active = values.active ~= false
    view.x = values.x or 1
    view.y = values.y or 1

    view.backgroundColor = values.backgroundColor or colors.black
    view.textColor = values.textColor or colors.white

    view.draw = nil

    view.drawInWindow = function(drawContent)
        local parentWindow = term.current()
        local parentChanged = view.windowParent ~= parentWindow

        if parentChanged and view.window then
            view.window.setVisible(false)
            view.window = nil
        end

        local parentWidth, parentHeight = parentWindow.getSize()
        local windowX = view.x + (view.parentOffsetX or 0)
        local windowY = view.y + (view.parentOffsetY or 0)
        local outsideParent = windowX > parentWidth
            or windowY > parentHeight
            or windowX + view.width - 1 < 1
            or windowY + view.height - 1 < 1
        if outsideParent then
            if view.window then
                view.window.setVisible(false)
            end
            return
        end

        if not view.window then
            view.window = window.create(
                parentWindow,
                windowX,
                windowY,
                view.width,
                view.height
            )
            view.windowParent = parentWindow
        else
            view.window.reposition(windowX, windowY, view.width, view.height)
        end

        local viewWindow = view.window
        term.redirect(viewWindow)
        viewWindow.setVisible(false)
        viewWindow.setBackgroundColor(view.backgroundColor)
        viewWindow.setTextColor(view.textColor)
        viewWindow.clear()
        drawContent()
        viewWindow.redraw()
        viewWindow.setVisible(true)
        term.redirect(parentWindow)
    end

    view.redraw = function()
        if not view.draw or not view.windowParent then return end

        local currentWindow = term.current()
        term.redirect(view.windowParent)
        view.draw()
        term.redirect(currentWindow)
    end

    view.setBackgroundColor = function(color) view.backgroundColor = color end

    view.setTextColor = function(color) view.textColor = color end

    view.setPos = function(x, y)
        view.x = x
        view.y = y
    end

    view.setX = function(x) view.x = x end

    view.setY = function(y) view.y = y end

    view.movePos = function(dx, dy)
        view.x = view.x + dx
        view.y = view.y + dy
    end

    view.setSize = function(width, height)
        view.width = width
        view.height = height
    end

    return view
end