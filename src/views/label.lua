local CreateBasicView = require("views.basic") 

return function(values)
    if not values then values = {} end
    local view = CreateBasicView(values)

    view.text = tostring(values.text) or ""
    view.width = values.width or #view.text
    view.height = values.height or 1

    view.setText = function(text)
        view.text = text
    end

    view.draw = function()
        if not view.active then return end
        view.drawInWindow(function()
            term.setCursorPos(1, 1)
            term.setBackgroundColor(view.backgroundColor)
            term.setTextColor(view.textColor)
            term.write(view.text)
        end)
    end

    return view
end