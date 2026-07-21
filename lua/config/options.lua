-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Set the shell based on the operating system and available shells
if vim.fn.has("win32") == 1 then
  -- On Windows
  if vim.fn.executable("pwsh") == 1 then
    vim.opt.shell = "pwsh"
  else
    vim.opt.shell = "powershell"
  end

  vim.opt.shellcmdflag = "-NoLogo -NoProfile -Command"
  vim.opt.shellquote = ""
  vim.opt.shellxquote = ""
else
  -- On Linux/macOS (or anything else)
  if vim.fn.executable("fish") == 1 then
    vim.opt.shell = "fish" -- or the output of `which fish`
  else
    vim.opt.shell = "bash"
  end
end

-- Custom comments for different file types
vim.cmd([[
  autocmd FileType lsl setlocal commentstring=//\ %s
  autocmd FileType kscript setlocal commentstring=//\ %s
]])

vim.filetype.add({
  extension = {
    gmf = "matlab",
  },
})

-- Set default tab width and indentation for specific file types
vim.cmd([[
  autocmd FileType lua setlocal tabstop=2 shiftwidth=2 softtabstop=2
  autocmd FileType cpp setlocal tabstop=2 shiftwidth=2 softtabstop=2
  autocmd FileType python setlocal tabstop=4 shiftwidth=4 softtabstop=4
  autocmd FileType matlab setlocal tabstop=4 shiftwidth=4 softtabstop=4
]])

-- Code formatting settings
vim.g.autoformat = false -- Disable automatic formatting on save
vim.opt.conceallevel = 0 -- Disable concealment for better visibility of code

-- VimTex settings for LaTeX
vim.g.vimtex_quickfix_open_on_warning = false -- Don't open quickfix on warnings

if vim.fn.executable("zathura") == 1 then
  vim.g.vimtex_view_method = "zathura" -- Use Zathura as the PDF viewer if available
else
  vim.g.vimtex_view_method = "okular" -- Use Okular as the PDF viewer if Zathura is not available
end

vim.g.vimtex_compiler_progname = "nvr" -- Use Neovim remote for compilation 
vim.g.tex_flavor = "latex" -- Set the TeX flavor to LaTeX
