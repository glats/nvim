return {
  {
    "akinsho/bufferline.nvim",
    keys = {
      {
        "[b",
        function()
          vim.cmd("bprev " .. vim.v.count1)
        end,
        desc = "Previous buffer",
      },
      {
        "]b",
        function()
          vim.cmd("bnext " .. vim.v.count1)
        end,
        desc = "Next buffer",
      },
    },
  },
  {
    "folke/snacks.nvim",
  },
}
