-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Edit .docx files as Markdown via pandoc, converting back on save.
-- Defining BufReadCmd/BufWriteCmd for the pattern makes Neovim skip its own
-- (binary-unsafe) read/write for these files, same technique gzip.vim/tar.vim use.
local docx_group = vim.api.nvim_create_augroup("docx_edit", { clear = true })

vim.api.nvim_create_autocmd("BufReadCmd", {
  pattern = "*.docx",
  group = docx_group,
  callback = function(ev)
    if vim.fn.executable("pandoc") == 0 then
      vim.notify("docx: pandoc not found in PATH (brew install pandoc)", vim.log.levels.ERROR)
      return
    end
    vim.cmd(("silent %%!pandoc %s -f docx -t gfm"):format(vim.fn.shellescape(ev.file)))
    vim.bo[ev.buf].filetype = "markdown"
    vim.bo[ev.buf].modified = false
  end,
})

vim.api.nvim_create_autocmd("BufWriteCmd", {
  pattern = "*.docx",
  group = docx_group,
  callback = function(ev)
    if vim.fn.executable("pandoc") == 0 then
      vim.notify("docx: pandoc not found in PATH (brew install pandoc)", vim.log.levels.ERROR)
      return
    end
    local tmp = vim.fn.tempname() .. ".md"
    vim.fn.writefile(vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false), tmp)
    local out = vim.fn.system({ "pandoc", tmp, "-f", "gfm", "-t", "docx", "-o", ev.file })
    vim.fn.delete(tmp)
    if vim.v.shell_error ~= 0 then
      vim.notify("docx: failed to save " .. ev.file .. "\n" .. out, vim.log.levels.ERROR)
      return
    end
    vim.bo[ev.buf].modified = false
    vim.notify("docx: saved " .. ev.file)
  end,
})
