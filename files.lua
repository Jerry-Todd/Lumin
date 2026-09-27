
local Lumin = require("Lumin")
local terminalWidth, terminalHeight = term.getSize()

-- Create the main view for the application
local MainView = Lumin.CreateSection({backgroundColor = colors.lightGray})
Lumin.setMainView(MainView)

-- TitleBar
local TitleBar = Lumin.CreateSection({
    backgroundColor = colors.white, textColor = colors.black, 
    width = MainView.width, height = 1})
local TitleLabel = Lumin.CreateLabel({
    text = "Files",
    backgroundColor = colors.white, textColor = colors.black,
    x = 2, y = 1
})
TitleBar.addChildren(TitleLabel, Lumin.CreateButton({
    text = " X ",
    backgroundColor = colors.red, textColor = colors.white,
    x = MainView.width - 2, y = 1,
    onClick = Lumin.Stop
}))
MainView.addChildren(TitleBar)

-- Files viewer
local FilesView = Lumin.CreateScrollSection({
    backgroundColor = colors.white,
    width = MainView.width-2, height = MainView.height - 3,
    x = 2, y = 3
})
local expandedFolders = {}
local renderFiles

local function joinPath(parent, name)
    return parent == "/" and "/" .. name or parent .. "/" .. name
end

local function addDirectory(path, depth, row)
    for _, name in ipairs(fs.list(path) or {}) do
        local childPath = joinPath(path, name)
        local isDirectory = fs.isDir(childPath)
        local prefix = string.rep("  ", depth)
        local marker = isDirectory and (expandedFolders[childPath] and "\31" or "\16") or " "
        local displayName = prefix .. marker .. " " .. name

        if isDirectory then
            FilesView.addChildren(Lumin.CreateButton({
                text = displayName,
                backgroundColor = colors.white, textColor = colors.black,
                x = 1, y = row, width = FilesView.width,
                onClick = function()
                    expandedFolders[childPath] = not expandedFolders[childPath]
                    renderFiles()
                end
            }))
        else
            FilesView.addChildren(Lumin.CreateLabel({
                text = displayName,
                backgroundColor = colors.white, textColor = colors.black,
                x = 1, y = row, width = FilesView.width
            }))
        end

        row = row + 1
        if isDirectory and expandedFolders[childPath] then
            row = addDirectory(childPath, depth + 1, row)
        end
    end
    return row
end

renderFiles = function()
    FilesView.clear()
    addDirectory("/", 0, 1)
    FilesView.redraw()
end

renderFiles()
MainView.addChildren(FilesView)

-- Start the Lumin application
Lumin.Start(function()
    MainView.draw()
end)