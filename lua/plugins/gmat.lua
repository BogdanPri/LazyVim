local function register_gmat_parser()
  require("nvim-treesitter.parsers").gmat = {
    install_info = {
      url = "https://github.com/astro-tools/gmat-script",
      files = {
        "src/parser.c",
        "src/scanner.c",
      },
      branch = "main",
      location = "tree-sitter-gmat",
      queries = "tree-sitter-gmat/queries",
    },
    filetype = "gmat",
  }
  vim.treesitter.language.register("gmat", "gmat")
end

vim.filetype.add({
  extension = {
    gmf = "gmat",
    script = "gmat",
  },
})

local gmat_group = vim.api.nvim_create_augroup("GmatScript", { clear = true })

vim.api.nvim_create_autocmd("User", {
  group = gmat_group,
  pattern = "TSUpdate",
  callback = register_gmat_parser,
})

vim.api.nvim_create_autocmd("FileType", {
  group = gmat_group,
  pattern = "gmat",
  callback = function()
    local ok, err = pcall(vim.treesitter.start)
    if not ok then
      vim.notify("GMAT Tree-sitter highlighting failed: " .. err, vim.log.levels.WARN)
    end
  end,
})

return {
  {
    "nvim-treesitter/nvim-treesitter",
    init = function()
      register_gmat_parser()
    end,
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      if not vim.tbl_contains(opts.ensure_installed, "gmat") then
        vim.list_extend(opts.ensure_installed, { "gmat" })
      end
    end,
  },

  {
    "neovim/nvim-lspconfig",
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "gmat",
        callback = function(args)
          if vim.fn.executable("gmat-script-lsp") ~= 1 then
            vim.notify(
              'gmat-script-lsp not found. Install it with: pip install "gmat-script[lsp]"',
              vim.log.levels.WARN
            )
            return
          end

          vim.lsp.start({
            name = "gmat-script-lsp",
            cmd = { "gmat-script-lsp" },
            root_dir = vim.fs.dirname(args.file),
          })
        end,
      })
    end,
  },
}
