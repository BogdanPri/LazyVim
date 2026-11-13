local M = {}

local state = {
  buf = nil,
  win = nil,
  job = nil,
}

local function is_valid_buf()
  return state.buf and vim.api.nvim_buf_is_valid(state.buf)
end

local function is_valid_win()
  return state.win and vim.api.nvim_win_is_valid(state.win)
end

local function close()
  if is_valid_win() then
    vim.api.nvim_win_close(state.win, true)
  end

  state.win = nil
end

function M.toggle()
  -- Close if already open
  if is_valid_win() then
    close()
    return
  end

  if vim.fn.executable("qalc") ~= 1 then
    vim.notify("qalc is not installed", vim.log.levels.ERROR)
    return
  end

  -- Create terminal buffer if needed
  if not is_valid_buf() then
    state.buf = vim.api.nvim_create_buf(false, true)

    vim.bo[state.buf].bufhidden = "hide"

    state.job = nil
  end

  local width = math.floor(vim.o.columns * 0.65)
  local height = math.floor(vim.o.lines * 0.45)

  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- Open floating window
  state.win = vim.api.nvim_open_win(state.buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " Qalculate! ",
    title_pos = "center",
  })

  -- Start Qalculate! only once
  if not state.job then
    state.job = vim.fn.termopen("qalc", {
      on_exit = function()
        state.job = nil
      end,
    })

    -- Terminal-local keymaps
    vim.keymap.set("t", "<Esc><Esc>", function()
      close()
    end, {
      buffer = state.buf,
      desc = "Close Qalculate scratchpad",
    })

    vim.keymap.set("t", "<C-q>", function()
      close()
    end, {
      buffer = state.buf,
      desc = "Close Qalculate scratchpad",
    })
  end

  -- Enter terminal mode automatically
  vim.cmd("startinsert")
end

return M
