# Lumin

Lumin is a small Lua GUI framework for CC:Tweaked. It provides composable views for terminal-based interfaces, including sections, scrollable sections, labels, buttons, and text inputs.

## Requirements

- CC:Tweaked / ComputerCraft
- `Lumin.lua` installed in the computer's current directory or Lua path

Lumin uses CC:Tweaked APIs such as `term`, `window`, `colors`, `keys`, and `parallel`.

## Installation

Run this command in the CC:Tweaked shell to download the bundled framework:

```sh
wget https://raw.githubusercontent.com/Jerry-Todd/Lumin/main/Lumin.lua Lumin.lua
```

Then load it in a Lua program:

```lua
local Lumin = require("Lumin")
```

If you change Lumin's source modules, regenerate the bundle from the repository root with `npx @justjurt/bcc@latest`.

## Quick Start

```lua
-- Optional: redirect output before creating any Lumin views.
-- term.redirect(peripheral.wrap("monitor_0"))
local Lumin = require("Lumin")
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
```

Click the text input to focus it. It accepts typed and pasted text, supports backspace, delete, left/right arrows, Home, and End, and displays a blinking underscore cursor. Scroll over the list to move through its children; its scrollbar track can also be clicked.

## Views

All constructors accept an options table. Common options include `x`, `y`, `width`, `height`, `backgroundColor`, `textColor`, and `active`. Positions are relative to the parent view and start at 1. Views are active by default; set `active = false` to disable drawing and input handling.

- `Lumin.CreateSection(options)` creates a container. Add child views with `section.addChildren(...)`; remove one with `section.removeChild(view)` or remove all with `section.clear()`.
- `Lumin.CreateScrollSection(options)` creates a container with mouse-wheel scrolling and a scrollbar. `scrollLimit` optionally caps the scroll offset; scrollbar colors can be set with `scrollbarBackgroundColor` and `scrollbarForegroundColor`.
- `Lumin.CreateLabel(options)` displays `text`.
- `Lumin.CreateButton(options)` displays text and calls `onClick(mouseButton, x, y)` when clicked.
- `Lumin.CreateTextInput(options)` accepts `text`, `placeholderText`, `placeholderTextColor`, and `maxLength`. It supports `onChange(text)`, `onSubmit(text)`, `onFocus()`, and `onBlur()` callbacks. Use `input.setText(text)` to replace its contents.
- `Lumin.CreateBasicView(options)` creates the base view object used by other views.

## Runtime

Lumin renders to the terminal currently selected by `term.redirect`; it does not choose or change the output device. Redirect to a monitor before creating views, then use the framework as usual. For example, call `term.redirect(peripheral.wrap("monitor_0"))` before constructing the root view. This also ensures `term.getSize()` returns the redirected device's dimensions when the layout is created.

Call `Lumin.setMainView(view)` to register the root view, draw it, then call `Lumin.Start(function() ... end)` to start the event loop. The loop forwards mouse, keyboard, paste, and timer events to the registered root. Call `Lumin.Stop()` to stop the loop.

`testing.lua` contains a sample screen with a text input and a long scrollable list.
