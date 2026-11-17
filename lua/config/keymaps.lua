-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Exit insert mode by pressing "jk"
vim.keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode", silent = true })
vim.keymap.set("i", "йк", "<ESC>", { desc = "Exit insert mode", silent = true })

require("which-key").add({
  { "<leader>Q", group = "Qalculate!", icon = "", mode = { "n", "v" } },
})

-- Set `Ctrl+j` to accept Copilot suggestions
-- vim.keymap.set("i", "<C-j>", function()
--   if not vim.lsp.inline_completion.get() then
--     return "<C-j>"
--   end
-- end, {
--   expr = true,
--   silent = true,
--   desc = "Accept Copilot suggestion",
-- })

-- Set `Ctrl+k` to cycle through Copilot suggestions
-- vim.keymap.set("i", "<C-k>", "copilot#CycleCompletions(-1)", {
--   expr = true,
--   silent = true,
--   desc = "Cycle through Copilot suggestions",
-- })

-- Set `Ctrl+l` to accept Copilot suggested word
-- vim.keymap.set("i", "<C-l>", "copilot#Accept('<Right>')", {
--   expr = true,
--   silent = true,
--   desc = "Accept Copilot suggested word",
-- })


-- Qalculate! keymaps
local qalc = require("utils.qalculate")
local qalc_insert = require("utils.qalc_insert")
local qalc_operate = require("utils.qalc_operate")
local qalc_scratchpad = require("utils.qalc_scratchpad")

vim.keymap.set("n", "<leader>Qs", qalc_scratchpad.toggle, {
  desc = "Qalculate: Toggle scratchpad",
})

vim.keymap.set("x", "<leader>Qe", function()
  qalc.eval("evaluate")
end, { desc = "Qalculate: Evaluate and notify" })

vim.keymap.set("x", "<leader>Qr", function()
  qalc.eval("replace")
end, { desc = "Qalculate: Replace expression" })

vim.keymap.set("x", "<leader>Qa", function()
  qalc.eval("append")
end, { desc = "Qalculate: Append result" })

vim.keymap.set("n", "<leader>Qi", qalc_insert.open, {
  desc = "Qalculate: Calculate and insert",
})

-- Editable expression
vim.keymap.set({ "n", "x" }, "<leader>Qo", function()
  qalc_operate.open(false)
end, {
  desc = "Qalculate: Operate on expression",
})

-- Operation-only input
vim.keymap.set({ "n", "x" }, "<leader>QO", function()
  qalc_operate.open(true)
end, {
  desc = "Qalculate: Apply operation",
})

local bits = require("utils.toggle_bits")

-- Normal mode: dot-repeatable toggle
vim.keymap.set("n", "~", bits.normal, {
  expr = true,
  desc = "Toggle bit (0 ↔ 1)",
})

-- Visual, Visual Line, and Visual Block modes
vim.keymap.set("x", "~", function()
  bits.visual()
end, {
  desc = "Toggle selected bits (0 ↔ 1)",
})

-- Add Russian langmap
vim.opt.langmap =
  "яq,вw,еe,рr,тt,ыy,уu,иi,оo,пp,ш[,щ]," ..
  "аa,сs,дd,фf,гg,хh,йj,кk,лl,э#," ..
  "|\\,зz,ьx,цc,жv,бb,нn,мm,ю`,ч=," ..
  "ЯQ,ВW,ЕE,РR,ТT,ЫY,УU,ИI,ОO,ПP,Ш{,Щ}," ..
  "АA,СS,ДD,ФF,ГG,ХH,ЙJ,КK,ЛL," ..
  "Э~,ЗZ,ЬX,ЦC,ЖV,БB,НN,МM,Ч+"
  -- ";q,ςw,εe,ρr,τt,υy,θu,ιi,οo,πp,~[,ͺ]," ..
  -- "αa,σs,δd,φf,γg,ηh,ξj,κk,λl,\\#," ..
  -- "«\\,ζz,χx,ψc,ωv,βb,νn,μm," ..
  -- ":Q,ΣW,ΕE,ΡR,ΤT,ΥY,ΘU,ΙI,ΟO,ΠP,¨{," ..
  -- "ΑA,ΣS,ΔD,ΦF,ΓG,ΗH,ΞJ,ΚK,ΛL,|#," ..
  -- "»|,ΖZ,ΧX,ΨC,ΩV,ΒB,ΝN,ΜM"
