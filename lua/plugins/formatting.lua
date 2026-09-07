return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      matlab = { "matlab_formatter" },
    },
    formatters = {
      matlab_formatter = {
        command = "matlab_formatter",
        args = { "-" },
        stdin = true,
      },
    },
  },
}
