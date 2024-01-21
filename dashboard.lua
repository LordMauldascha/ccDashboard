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

function printBottom(m, text, x)
  m.setCursorPos(x, mH-1)
  m.setTextColor(colors.white)
  m.setBackgroundColor(colors.black)
  m.write(text)
end

function checkTouchBack(touchX, touchY, screen)
  if touchX >= 2 and touchX <= 18 and touchY >= mH-1 and touchY <= mH-1 then
    if screen == "main" then
      mainScreen()
    elseif screen == "ideas" then
      ideasScreen()
    else
      mainScreen()
    end
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

  printBottom(monitor, "- Shutdown -", 2)

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

    -- Check if click is on "Shutdown"
    if x >= 2 and x <= 11 and y >= mH-1 and y <= mH-1 then
      clear()
      printCentered(monitor, 2, "Shutdown", colors.white, colors.green)
      printCentered(monitor, 4, "Goodbye!", colors.white, colors.green)
      os.sleep(1)
      os.shutdown()
    end
  end
end

-- Ideas Screen
function ideasScreen(x, y)
  setBackgroundColor(colors.gray)
  printDevTools()

  printCentered(monitor, 2, "Ideas", colors.white, colors.green)
  drawBox(2, 4, mW-3, mH-7, colors.black)

  -- Get Contents of ideas file
  local ideasFile = fs.open("ideas.txt", "r")
  local ideas = ideasFile.readAll()
  ideasFile.close()

  -- Print ideas
  monitor.setCursorPos(3, 5)
  monitor.setTextColor(colors.white)
  monitor.setBackgroundColor(colors.black)

  -- Convert JSON to table
  local ideas = textutils.unserialiseJSON(ideas)

  for i = 1, #ideas.ideas do
    monitor.setBackgroundColor(colors.black)
    if ideas.ideas[i].done then
      monitor.setBackgroundColor(colors.green)
      monitor.write("[x] " .. ideas.ideas[i].text)
    else
      monitor.write("[ ] " .. ideas.ideas[i].text)
    end
    monitor.setCursorPos(mW-3, 4+i)
    monitor.setBackgroundColor(colors.red)
    monitor.write("x")
    monitor.setCursorPos(3, 5+i)
  end

  printBottom(monitor, "+ Add Idea", mW-11)
  printBottom(monitor, "<- Back to Main Screen", 2)

  -- Ideas screen loop
  while true do
    local event, side, x, y = os.pullEvent("monitor_touch")

    -- Loop thru ideas and check if row value equals y
    for i = 1, #ideas.ideas do
      if y == 4+i then
        -- Check if delete button is pressed
        if x == mW-3 then
          -- Delete idea
          table.remove(ideas.ideas, i)

          -- Update Row Value of Ideas
          for i = 1, #ideas.ideas do
            ideas.ideas[i].row = 4+i
          end

          -- Save ideas to file
          local ideasFile = fs.open("ideas.txt", "w")
          ideasFile.write(textutils.serialiseJSON(ideas))
          ideasFile.close()
          -- Reload ideas screen
          ideasScreen()
          break
        end
        -- Check if idea is done
        if x >= 3 and x <= 5 then
          -- Toggle done
          if ideas.ideas[i].done then
            ideas.ideas[i].done = false
          else
            ideas.ideas[i].done = true
          end

          -- Save ideas to file
          local ideasFile = fs.open("ideas.txt", "w")
          ideasFile.write(textutils.serialiseJSON(ideas))
          ideasFile.close()
          -- Reload ideas screen
          ideasScreen()
          break
        end
      end
    end

    -- Check if add button is pressed
    if x >= mW-11 and x <= mW-1 and y >= mH-1 and y <= mH-1 then
      addIdeaScreen()
      break
    end
    
    -- Check if back button is pressed
    local back = checkTouchBack(x, y, "main")
    if back then
      break
    end
  end
end

function addIdeaScreen()
  setBackgroundColor(colors.gray)
  printDevTools()
  printCentered(monitor, 2, "Add Idea", colors.white, colors.green)

  -- Print text box
  drawBox(2, 4, mW-3, 0, colors.black)

  local keyboardX = math.floor((mW - 16) / 2)
  local keyboardY = 8
  local shift = false
  local word = ""

  -- Print backspace
  printText(monitor, 31, keyboardY-2, "<--", colors.white, colors.black)
  -- Print Shift
  printText(monitor, 17, keyboardY-2, "Shift", colors.white, colors.black)

  -- Print whole Keyboard centered in Screen
  local keyboard = {
    "a", "b", "c", "d", "e", "f", "g", "h", "i", "j",
    "k", "l", "m", "n", "o", "p", "q", "r", "s",
    "t", "u", "v", "w", "x", "y", "z",
  }

  for i = 1, #keyboard do
    if i == 10 or i == 19 or i == 28 then
      keyboardX = math.floor((mW - 16) / 2)
      keyboardY = keyboardY + 2
    end
    printText(monitor, keyboardX, keyboardY, keyboard[i], colors.white, colors.black)
    keyboardX = keyboardX + 2
  end

  -- Print space
  printText(monitor, 17, keyboardY+2, "      space      ", colors.white, colors.black)

  -- Print add button
  printText(monitor, 17, keyboardY+4, "      + Add      ", colors.white, colors.green)

  printBottom(monitor, "<- Back to Ideas (Cancel)", 2)

  -- Add idea screen loop
  while true do
    local event, side, x, y = os.pullEvent("monitor_touch")

    -- Check if Shift if pressed
    if x >= 17 and x <= 22 and y >= 6 and y <= 6 then
      -- Print whole Keyboard centered in Screen
      local keyboard = {
        "A", "B", "C", "D", "E", "F", "G", "H", "I", "J",
        "K", "L", "M", "N", "O", "P", "Q", "R", "S",
        "T", "U", "V", "W", "X", "Y", "Z",
      }

      if shift then
        shift = false
        keyboard = {
          "a", "b", "c", "d", "e", "f", "g", "h", "i", "j",
          "k", "l", "m", "n", "o", "p", "q", "r", "s",
          "t", "u", "v", "w", "x", "y", "z",
        }
      else 
        shift = true
      end

      keyboardX = math.floor((mW - 16) / 2)
      keyboardY = 8

      for i = 1, #keyboard do
        if i == 10 or i == 19 or i == 28 then
          keyboardX = math.floor((mW - 16) / 2)
          keyboardY = keyboardY + 2
        end
        printText(monitor, keyboardX, keyboardY, keyboard[i], colors.white, colors.black)
        keyboardX = keyboardX + 2
      end

      -- Print space
      printText(monitor, 17, keyboardY+2, "      space      ", colors.white, colors.black)

      -- Print add button
      printText(monitor, 17, keyboardY+4, "      + Add      ", colors.white, colors.green)
    end

    -- Check if any letter is pressed
    if y >= 6 and y <= 16 then
      local letter = ""
      if y == 8 then
        if x == 17 then
          letter = "a"
        elseif x == 19 then
          letter = "b"
        elseif x == 21 then
          letter = "c"
        elseif x == 23 then
          letter = "d"
        elseif x == 25 then
          letter = "e"
        elseif x == 27 then
          letter = "f"
        elseif x == 29 then
          letter = "g"
        elseif x == 31 then
          letter = "h"
        elseif x == 33 then
          letter = "i"
        end
      elseif y == 10 then
        if x == 17 then
          letter = "j"
        elseif x == 19 then
          letter = "k"
        elseif x == 21 then
          letter = "l"
        elseif x == 23 then
          letter = "m"
        elseif x == 25 then
          letter = "n"
        elseif x == 27 then
          letter = "o"
        elseif x == 29 then
          letter = "p"
        elseif x == 31 then
          letter = "q"
        elseif x == 33 then
          letter = "r"
        end
      elseif y == 12 then
        if x == 17 then
          letter = "s"
        elseif x == 19 then
          letter = "t"
        elseif x == 21 then
          letter = "u"
        elseif x == 23 then
          letter = "v"
        elseif x == 25 then
          letter = "w"
        elseif x == 27 then
          letter = "x"
        elseif x == 29 then
          letter = "y"
        elseif x == 31 then
          letter = "z"
        end
      elseif y == 14 and x >= 17 then
        letter = " "
      end

      if shift then
        letter = string.upper(letter)
      end

      if string.len(word) < mW-4 then
        word = word .. letter
      end

      -- Clear word line and remove last letter if backspace is pressed
      printText(monitor, 3, 4, "                                               ", colors.white, colors.black)

      -- Remove last letter if backspace is pressed
      if x >= 31 and x <= 33 and y == 6 then
        word = string.sub(word, 1, -2)
      end

      -- Print letter in text box
      printText(monitor, 3, 4, word .. "_", colors.white, colors.black)
    end

    -- Check if add button is pressed
    if x >= 17 and x <= 31 and y >= keyboardY+4 and y <= keyboardY+4 then
      -- Get Contents of ideas file
      local ideasFile = fs.open("ideas.txt", "r")
      local ideas = ideasFile.readAll()
      ideasFile.close()

      -- Convert JSON to table
      local ideas = textutils.unserialiseJSON(ideas)

      -- Add new idea to table
      table.insert(ideas.ideas, {text = word, done = false, row = 0})

      -- Update Row Value of Ideas
      for i = 1, #ideas.ideas do
        ideas.ideas[i].row = 4+i
      end

      -- Save ideas to file
      local ideasFile = fs.open("ideas.txt", "w")
      ideasFile.write(textutils.serialiseJSON(ideas))
      ideasFile.close()

      -- Reload ideas screen
      ideasScreen()
      break
    end

    -- Check if back button is pressed
    local back = checkTouchBack(x, y, "ideas")
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
  printBottom(monitor, "<- Back to Main Screen")

  -- Settings screen loop
  while true do
    local event, side, x, y = os.pullEvent("monitor_touch")

    -- Check if back button is pressed
    local back = checkTouchBack(x, y, "main")
    if back then
      break
    end
  end
end

mainScreen()