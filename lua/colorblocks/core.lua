-- Plugin module table
local M = {}

-- Namespace and autocommand group for virtual text
local ns = vim.api.nvim_create_namespace("color_blocks")
local group = vim.api.nvim_create_augroup("ColorBlocks", { clear = true })

-- Whether the plugin is currently active
local enabled = true

-- Default configuration options
local opts = {
  symbol = "■", -- Unicode block character used as color indicator
  virt_text_pos = "eol", -- Position of virtual text: "eol", "overlay", etc.
  mode = "fg", -- Whether to apply the hex color to the foreground or background
  show_hex = true, -- Show the hex value next to the block
  section = { "S", " ", "H" }, -- Ordered segments: S = symbol, H = hex, strings = literals
  filetypes = nil, -- Optional whitelist of filetypes
}

-- Pattern to match 6-digit hex codes (e.g. #AABBCC)
local patterns = {
  "()#(%x%x%x%x%x%x)",
}

-- Clear all extmarks in our namespace for the given buffer
local function clear(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
end

-- Build a list of virtual text segments based on the current section config
local function build_virt_text(hex)
  local virt = {}
  for _, part in ipairs(opts.section) do
    if part == "S" then
      table.insert(virt, { opts.symbol, "ColorBlock_" .. hex })
    elseif part == "H" then
      table.insert(virt, { "#" .. hex, "Comment" })
    else
      table.insert(virt, { part, "Comment" })
    end
  end
  return virt
end

-- Main function: apply color virtual text to matching lines
local function colorize()
  if not enabled then
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()

  -- If filetype filtering is enabled, skip unsupported files
  if opts.filetypes and not vim.tbl_contains(opts.filetypes, vim.bo.filetype) then
    return
  end

  clear(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  for linenr, line in ipairs(lines) do
    for _, pat in ipairs(patterns) do
      for s, hex in line:gmatch(pat) do
        local hl_group = "ColorBlock_" .. hex

        -- Ensure highlight group is created and scheduled before extmark is set
        -- vim.schedule(function()
        if vim.fn.hlID(hl_group) == 0 then
          local style = opts.mode == "bg" and { bg = "#" .. hex } or { fg = "#" .. hex }
          vim.api.nvim_set_hl(0, hl_group, style)
        end
        -- end)

        -- Attempt to place the virtual text extmark
        local ok, err = pcall(function()
          vim.api.nvim_buf_set_extmark(bufnr, ns, linenr - 1, tonumber(s), {
            virt_text = build_virt_text(hex),
            virt_text_pos = opts.virt_text_pos,
          })
        end)
        print("🔍 Creating hl_group:", hl_group, "→", "#" .. hex)
        -- Notify on error if extmark fails
        if not ok then
          vim.notify("ColorBlock extmark failed: " .. err, vim.log.levels.WARN)
        end
      end
    end
  end
end

-- Toggle color blocks on/off
function M.toggle()
  enabled = not enabled
  colorize()
end

-- Enable color blocks
function M.enable()
  enabled = true
  colorize()
end

-- Disable and clear color blocks
function M.disable()
  enabled = false
  local bufnr = vim.api.nvim_get_current_buf()
  clear(bufnr)
end

-- Initialize the plugin with optional user config
function M.setup(user_opts)
  opts = vim.tbl_deep_extend("force", opts, user_opts or {})

  -- Register the autocmds to trigger color rendering
  vim.api.nvim_create_autocmd({ "BufEnter", "BufRead", "TextChanged", "InsertLeave" }, {
    group = group,
    desc = "ColorBlocks: Render color hex markers",
    pattern = "*",
    callback = function()
      colorize()
    end,
  })

  -- Expose commands to toggle, enable, or disable manually
  vim.api.nvim_create_user_command("ColorBlocksToggle", M.toggle, {})
  vim.api.nvim_create_user_command("ColorBlocksEnable", M.enable, {})
  vim.api.nvim_create_user_command("ColorBlocksDisable", M.disable, {})
end

return M
