local M = {}

-- Evaluate an expression using Qalculate!
local function evaluate(expr)
  if vim.trim(expr) == "" then
    return nil
  end

  local result = vim.fn.system({
    "qalc",
    "-t",
    "--color=0",
    expr,
  })

  if vim.v.shell_error ~= 0 then
    vim.notify("Qalculate: " .. result, vim.log.levels.ERROR)
    return nil
  end

  result = vim.trim(result)

  if result == "" then
    vim.notify("Qalculate returned no result", vim.log.levels.WARN)
    return nil
  end

  return result
end

-- Evaluate the current Visual selection
-- action: "evaluate", "replace", or "append"
function M.eval(action)
  if vim.fn.executable("qalc") ~= 1 then
    vim.notify("qalc is not installed", vim.log.levels.ERROR)
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local mode = vim.fn.mode()

  -- Get active Visual selection
  local start_pos = vim.fn.getpos("v")
  local end_pos = vim.fn.getpos(".")

  local sr, sc = start_pos[2] - 1, start_pos[3] - 1
  local er, ec = end_pos[2] - 1, end_pos[3] - 1

  -- Normalize selection direction
  if sr > er or (sr == er and sc > ec) then
    sr, er = er, sr
    sc, ec = ec, sc
  end

  -- Process an expression according to the requested action
  local function process(expr)
    local result = evaluate(expr)

    if not result then
      return nil
    end

    if action == "evaluate" then
      vim.notify(expr .. " = " .. result, vim.log.levels.INFO, {
        title = "Qalculate!",
      })
      return nil
    elseif action == "append" then
      return expr .. " = " .. result
    elseif action == "replace" then
      return result
    end
  end

  -- Visual Line mode (Shift+V)
  if mode == "V" then
    local lines = vim.api.nvim_buf_get_lines(bufnr, sr, er + 1, false)
    local expr = table.concat(lines, "\n")
    local replacement = process(expr)

    if replacement then
      vim.api.nvim_buf_set_lines(
        bufnr,
        sr,
        er + 1,
        false,
        vim.split(replacement, "\n", { plain = true })
      )
    end

    return
  end

  -- Visual Block mode (Ctrl+V)
  if mode == "\22" then
    local left = math.min(start_pos[3], end_pos[3]) - 1
    local right = math.max(start_pos[3], end_pos[3]) - 1

    local lines = vim.api.nvim_buf_get_lines(bufnr, sr, er + 1, false)

    for i, line in ipairs(lines) do
      local before = line:sub(1, left)
      local expr = line:sub(left + 1, right + 1)
      local after = line:sub(right + 2)

      local replacement = process(expr)

      if replacement then
        lines[i] = before .. replacement .. after
      end
    end

    if action ~= "evaluate" then
      vim.api.nvim_buf_set_lines(bufnr, sr, er + 1, false, lines)
    end

    return
  end

  -- Characterwise Visual mode (v)
  local lines = vim.api.nvim_buf_get_text(
    bufnr,
    sr,
    sc,
    er,
    ec + 1,
    {}
  )

  local expr = table.concat(lines, "\n")
  local replacement = process(expr)

  if replacement then
    vim.api.nvim_buf_set_text(
      bufnr,
      sr,
      sc,
      er,
      ec + 1,
      vim.split(replacement, "\n", { plain = true })
    )
  end
end

return M
