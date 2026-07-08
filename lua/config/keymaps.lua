-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Exit insert mode by pressing "jk"
vim.keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode", silent = true })
vim.keymap.set("i", "йк", "<ESC>", { desc = "Exit insert mode", silent = true })

-- Set `Ctrl+j` to accept Copilot suggestions
vim.keymap.set("i", "<C-j>", function()
  if not vim.lsp.inline_completion.get() then
    return "<C-j>"
  end
end, {
  expr = true,
  silent = true,
  desc = "Accept Copilot suggestion",
})

-- Set `Ctrl+k` to cycle through Copilot suggestions
vim.keymap.set("i", "<C-k>", "copilot#CycleCompletions(-1)", {
  expr = true,
  silent = true,
  desc = "Cycle through Copilot suggestions",
})

-- Set `Ctrl+l` to accept Copilot suggested word
vim.keymap.set("i", "<C-l>", "copilot#Accept('<Right>')", {
  expr = true,
  silent = true,
  desc = "Accept Copilot suggested word",
})

-- Add Russian langmap
vim.opt.langmap =
  "яq,вw,еe,рr,тt,ыy,уu,иi,оo,пp,ш[,щ]," ..
  "аa,сs,дd,фf,гg,хh,йj,кk,лl," ..
  "э#,зz,ьx,цc,жv,бb,нn,мm,ю`,ч=," ..
  "ЯQ,ВW,ЕE,РR,ТT,ЫY,УU,ИI,ОO,ПP,Ш{,Щ}," ..
  "АA,СS,ДD,ФF,ГG,ХH,ЙJ,КK,ЛL," ..
  "Э~,ЗZ,ЬX,ЦC,ЖV,БB,НN,МM,Ч+"
