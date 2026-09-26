local CreateLabel = require("views.label")

return function(values)
    if not values then values = {} end
    local view = CreateLabel(values)

    view.onClick = values.onClick or function(mouseButton, x, y) end

    view.handleClick = function(mouseButton, x, y)
        if not view.active then return end

        local inside = x >= view.x
            and x < view.x + view.width
            and y >= view.y
            and y < view.y + view.height

        if inside then
            view.onClick(mouseButton, x, y)
        end
    end

    return view
end