local M = {}

local function evaluate(expr)
  local output = vim.fn.system({
    "qalc",
    "-t",
    "--color=0",
    expr,
  })

  if vim.v.shell_error ~= 0 then
    vim.notify("Qalculate: " .. output, vim.log.levels.ERROR)
    return nil
  end

  output = vim.trim(output)

  if output == "" then
    vim.notify("Qalculate returned no result", vim.log.levels.WARN)
    return nil
  end

  return output
end

-- Get the number under the cursor.
-- Supports signs, decimals, and scientific notation.
local function number_under_cursor()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()

  -- Match numeric tokens, including scientific notation.
  local pattern = "[+-]?%d*%.?%d+[eE]?[+-]?%d*"

  local from = 1

  while true do
    local s, e = line:find(pattern, from)

    if not s then
      break
    end

    if col + 1 >= s and col + 1 <= e then
      return {
        text = line:sub(s, e),
        sr = row - 1,
        sc = s - 1,
        er = row - 1,
        ec = e,
      }
    end

    from = e + 1
  end

  return nil
end

-- Get the active Visual selection.
local function visual_selection()
  local mode = vim.fn.mode()
  local start_pos = vim.fn.getpos("v")
  local end_pos = vim.fn.getpos(".")

  local sr, sc = start_pos[2] - 1, start_pos[3] - 1
  local er, ec = end_pos[2] - 1, end_pos[3] - 1

  if sr > er or (sr == er and sc > ec) then
    sr, er = er, sr
    sc, ec = ec, sc
  end

  if mode == "V" then
    local lines = vim.api.nvim_buf_get_lines(0, sr, er + 1, false)

    return {
      text = table.concat(lines, "\n"),
      sr = sr,
      sc = 0,
      er = er,
      ec = #(lines[#lines] or ""),
    }
  end

  if mode == "\22" then
    vim.notify(
      "Qalculate Operate: Visual Block mode is not supported",
      vim.log.levels.WARN
    )
    return nil
  end

  local lines = vim.api.nvim_buf_get_text(
    0,
    sr,
    sc,
    er,
    ec + 1,
    {}
  )

  return {
    text = table.concat(lines, "\n"),
    sr = sr,
    sc = sc,
    er = er,
    ec = ec + 1,
  }
end

local function open_popup(selection, operation_only)
  local source_buf = vim.api.nvim_get_current_buf()
  local source_win = vim.api.nvim_get_current_win()

  local buf = vim.api.nvim_create_buf(false, true)

  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false

  local initial = operation_only and "" or selection.text

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { initial })

  local width = math.max(
    20,
    math.min(60, vim.o.columns - 4)
  )

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = 1,
    row = math.floor((vim.o.lines - 3) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = operation_only
        and " Qalculate! Operation "
      or " Qalculate! Operate ",
    title_pos = "center",
  })

  local function close()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  local function submit()
    local input = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1]

    if vim.trim(input) == "" then
      close()
      return
    end

    local expr

    if operation_only then
      expr = "(" .. selection.text .. ") " .. input
    else
      expr = input
    end

    local result = evaluate(expr)

    if not result then
      return
    end

    if not vim.api.nvim_buf_is_valid(source_buf) then
      close()
      return
    end

    -- Replace original selection with evaluated result
    vim.api.nvim_buf_set_text(
      source_buf,
      selection.sr,
      selection.sc,
      selection.er,
      selection.ec,
      vim.split(result, "\n", { plain = true })
    )

    close()

    if vim.api.nvim_win_is_valid(source_win) then
      vim.api.nvim_set_current_win(source_win)
    end
  end

  vim.keymap.set("i", "<CR>", function()
    vim.cmd("stopinsert")
    submit()
  end, {
    buffer = buf,
    desc = "Qalculate: Evaluate and replace",
  })

  vim.keymap.set("i", "<Esc>", function()
    vim.cmd("stopinsert")
    close()
  end, {
    buffer = buf,
    desc = "Qalculate: Cancel",
  })

  vim.keymap.set("n", "<Esc>", close, {
    buffer = buf,
    desc = "Qalculate: Cancel",
  })

  -- Position cursor at end of initial expression
  vim.api.nvim_win_set_cursor(win, { 1, #initial })

  vim.cmd("startinsert")
end

function M.open(operation_only)
  if vim.fn.executable("qalc") ~= 1 then
    vim.notify("qalc is not installed", vim.log.levels.ERROR)
    return
  end

  local mode = vim.fn.mode()

  local selection

  if mode == "n" then
    selection = number_under_cursor()
  else
    selection = visual_selection()
  end

  if not selection then
    vim.notify(
      "Qalculate: No number or expression selected",
      vim.log.levels.WARN
    )
    return
  end

  open_popup(selection, operation_only)
end

return M
