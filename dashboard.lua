-- Computercraft os 1.7 Dashboard working with 4x3 monitors

-- Config
local dev = true
local version = "Alpha 0.1"
local author = "Levi"

-- Variables
local monitor = peripheral.wrap("top")
local mW, mH = monitor.getSize()

-- redirect console to monitor
term.redirect(monitor)

-- Functions
function clear()
  monitor.clear()
  monitor.setCursorPos(1,1)
end

function setBackgroundColor(color)
  monitor.setBackgroundColor(color)
  monitor.clear()
end

function printCentered(m, y, text, color, background)
  local x = math.floor((mW - string.len(text)) / 2)
  printText(m, x, y, text, color, background)
end

function printText(m, x, y, text, color, background)
  m.setCursorPos(x, y)
  m.setTextColor(color)
  m.setBackgroundColor(background)
  m.write(text)
end

function printBack(m)
  m.setCursorPos(2, mH-1)
  m.setTextColor(colors.white)
  m.setBackgroundColor(colors.black)
  m.write("<- Back to Menu")
end

function checkTouchBack(touchX, touchY)
  if touchX >= 2 and touchX <= 18 and touchY >= mH-1 and touchY <= mH-1 then
    mainScreen()
    return true
  else
    return false
  end
end

function drawBox(x, y, width, height, color)
  paintutils.drawFilledBox(x, y, x + width, y + height, color)
end

function printDevTools()
  -- For Development
  -- Color first line every pixel in different color
  if dev then
    for i = 1, mW do
      monitor.setCursorPos(i, 1)
      monitor.setBackgroundColor(i)
      monitor.write(" ")
    end

    -- Color first column every pixel in different color
    for i = 1, mH do
      monitor.setCursorPos(1, i)
      monitor.setBackgroundColor(i)
      monitor.write(" ")
    end
  end
end

-- Main Screen
function mainScreen()
  setBackgroundColor(colors.gray)
  local headline = "Base Dashboard " .. version .. " by " .. author
  printCentered(monitor, 2, headline, colors.white, colors.green)
  printDevTools()
  
  -- Print menu Box
  drawBox(2, 4, 16, 3, colors.black)

  -- Print menu Text
  printText(monitor, 3, 5, "Ideas", colors.red, colors.black)
  printText(monitor, 3, 6, "Settings", colors.red, colors.black)

  -- TODO: Print Shutdown button

  -- Main screen loop
  while true do
    local event, side, x, y = os.pullEvent("monitor_touch")
    -- Check if click is on "Ideas"
    if x >= 3 and x <= 8 and y >= 5 and y <= 5 then
      ideasScreen()
      break
    end
    -- Check if click is on "Settings"
    if x >= 3 and x <= 11 and y >= 6 and y <= 6 then
      settingsScreen()
      break
    end
  end
end

-- Ideas Screen
function ideasScreen(x, y)
  setBackgroundColor(colors.gray)
  printDevTools()

  printCentered(monitor, 2, "Ideas", colors.white, colors.green)
  drawBox(2, 4, mW-3, mH-7, colors.black)
  -- TODO: Print ideas from file
  -- TODO: Print checkboxes for ideas to mark as done
  -- TODO: Print button to delete idea
  -- TODO: Print button to add idea
  printBack(monitor)

  -- Ideas screen loop
  while true do
    local event, side, x, y = os.pullEvent("monitor_touch")

    -- Check if back button is pressed
    local back = checkTouchBack(x, y)
    if back then
      break
    end
  end
end

-- Settings Screen
function settingsScreen(touchX, touchY)
  setBackgroundColor(colors.gray)
  printDevTools()
  monitor.setCursorPos(2,2)
  monitor.write("Settings")
  printBack(monitor)

  -- Settings screen loop
  while true do
    local event, side, x, y = os.pullEvent("monitor_touch")

    -- Check if back button is pressed
    local back = checkTouchBack(x, y)
    if back then
      break
    end
  end
end

mainScreen()