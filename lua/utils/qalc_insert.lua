local M = {}

function M.open()
  if vim.fn.executable("qalc") ~= 1 then
    vim.notify("qalc is not installed", vim.log.levels.ERROR)
    return
  end

  -- Remember the original window and cursor position
  local source_win = vim.api.nvim_get_current_win()
  local source_buf = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(source_win)

  -- Create a temporary input buffer
  local buf = vim.api.nvim_create_buf(false, true)

  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false

  -- Floating window dimensions
  local width = math.min(60, vim.o.columns - 4)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = 1,
    row = math.floor((vim.o.lines - 3) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = " Qalculate! Insert ",
    title_pos = "center",
  })

  local function close()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  -- Evaluate expression and insert result
  local function submit()
    local expr = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1]

    if vim.trim(expr) == "" then
      close()
      return
    end

    local result = vim.fn.system({
      "qalc",
      "-t",
      "--color=0",
      expr,
    })

    if vim.v.shell_error ~= 0 then
      vim.notify("Qalculate: " .. result, vim.log.levels.ERROR)
      return
    end

    result = vim.trim(result)

    if result == "" then
      vim.notify("Qalculate returned no result", vim.log.levels.WARN)
      return
    end

    -- Make sure the original buffer/window still exists
    if not vim.api.nvim_win_is_valid(source_win)
      or not vim.api.nvim_buf_is_valid(source_buf)
    then
      close()
      return
    end

    close()

    -- Restore original window and cursor
    vim.api.nvim_set_current_win(source_win)
    vim.api.nvim_win_set_cursor(source_win, cursor)

    -- Insert result at cursor position
    local row, col = cursor[1] - 1, cursor[2]

    vim.api.nvim_buf_set_text(
      source_buf,
      row,
      col,
      row,
      col,
      vim.split(result, "\n", { plain = true })
    )
  end

  -- Enter evaluates and inserts
  vim.keymap.set("i", "<CR>", function()
    vim.cmd("stopinsert")
    submit()
  end, {
    buffer = buf,
    desc = "Qalculate: Insert result",
  })

  -- Escape cancels
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

  -- Start typing immediately
  vim.cmd("startinsert")
end

return M
