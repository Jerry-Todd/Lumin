local Lumin = require("build.Lumin")
local terminalWidth, terminalHeight = term.getSize()

-- Create the main view for the application
local MainView = Lumin.CreateSection()
Lumin.setMainView(MainView)

-- Create a text input field
local input = Lumin.CreateTextInput({
    x = 2, y = 2,
    width = 44,
    placeholderText = "Type here",
    placeholderTextColor = colors.lightGray,
    backgroundColor = colors.gray,
    textColor = colors.white,
    onSubmit = function(text)
        -- Handle the submitted text.
    end,
})

-- Create a scrollable list section
local list = Lumin.CreateScrollSection({
    x = 2,
    y = 4,
    width = terminalWidth - 2,
    height = terminalHeight - 4,
    backgroundColor = colors.gray,
})

-- Add 30 items to the scroll section
for index = 1, 30 do
    list.addChildren(Lumin.CreateLabel({
        text = "Item " .. index,
        x = 1,
        y = index,
        width = list.width,
        backgroundColor = colors.gray,
        textColor = colors.white,
    }))
end

-- Create a close button
local closeButton = Lumin.CreateButton({
    text = "Quit",
    backgroundColor = colors.red,
    textColor = colors.white,
    x = terminalWidth - 4,
    y = 2,
    onClick = Lumin.Stop
})

-- Add the input, list, and close button to the main view
MainView.addChildren(input, list, closeButton)

-- Start the Lumin application
Lumin.Start(function()
    MainView.draw()
end)
