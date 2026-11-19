local M = {}

local function flip(text)
  return (text:gsub("[01a-zA-Z]", function(char)
    if char == "0" then
      return "1"
    elseif char == "1" then
      return "0"
    elseif char:match("%l") then
      return char:upper()
    else
      return char:lower()
    end
  end))
end

local function toggle_range(mode, start_pos, end_pos)
  local buf = 0

  local sr, sc = start_pos[2] - 1, start_pos[3] - 1
  local er, ec = end_pos[2] - 1, end_pos[3] - 1

  -- Normalize selection direction
  if sr > er or (sr == er and sc > ec) then
    sr, er = er, sr
    sc, ec = ec, sc
  end

  -- Linewise selection
  if mode == "line" then
    local lines = vim.api.nvim_buf_get_lines(buf, sr, er + 1, false)

    for i, line in ipairs(lines) do
      lines[i] = flip(line)
    end

    vim.api.nvim_buf_set_lines(buf, sr, er + 1, false, lines)
    return
  end

  -- Blockwise selection
  if mode == "block" then
    local left = math.min(start_pos[3], end_pos[3]) - 1
    local right = math.max(start_pos[3], end_pos[3]) - 1

    local lines = vim.api.nvim_buf_get_lines(buf, sr, er + 1, false)

    for i, line in ipairs(lines) do
      local before = line:sub(1, left)
      local selected = line:sub(left + 1, right + 1)
      local after = line:sub(right + 2)

      lines[i] = before .. flip(selected) .. after
    end

    vim.api.nvim_buf_set_lines(buf, sr, er + 1, false, lines)
    return
  end

  -- Characterwise selection
  local lines = vim.api.nvim_buf_get_text(
    buf,
    sr,
    sc,
    er,
    ec + 1,
    {}
  )

  for i, line in ipairs(lines) do
    lines[i] = flip(line)
  end

  vim.api.nvim_buf_set_text(
    buf,
    sr,
    sc,
    er,
    ec + 1,
    lines
  )
end

-- Operator function, invoked by g@
function M.operator(type)
  local start_pos = vim.fn.getpos("'[")
  local end_pos = vim.fn.getpos("']")

  toggle_range(type, start_pos, end_pos)
end

-- Normal mode: toggle one bit
function M.normal()
  vim.go.operatorfunc = "v:lua.require'utils.toggle_bits'.operator"

  -- g@l operates on one character and supports dot-repeat
  return "g@l"
end

-- Visual mode: toggle selected bits
function M.visual()
  local mode = vim.fn.mode()

  local type_map = {
    v = "char",
    V = "line",
    ["\22"] = "block",
  }

  -- local start_pos = vim.fn.getpos("'<")
  -- local end_pos = vim.fn.getpos("'>")

  local start_pos = vim.fn.getpos("v")
  local end_pos = vim.fn.getpos(".")

  toggle_range(type_map[mode], start_pos, end_pos)
end

return M
