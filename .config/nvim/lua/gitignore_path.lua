-- Custom path source for gitignore files.
-- Extends blink.cmp's built-in path source to also complete bare relative
-- paths (e.g. `src`) that don't contain a slash, by falling back to cwd.
local M = {}

function M.new(opts)
  local self = setmetatable({}, { __index = M })
  self.path_source = require('blink.cmp.sources.path').new(opts)
  self.opts = self.path_source.opts
  return self
end

-- Empty trigger chars so blink also activates us during normal keyword typing
function M:get_trigger_characters() return {} end

function M:get_completions(context, callback)
  callback = vim.schedule_wrap(callback)
  local lib = require('blink.cmp.sources.path.lib')

  -- Skip comment lines and empty lines
  local line_before = context.line:sub(1, context.cursor[2])
  if line_before:match '^%s*#' or line_before:match '^%s*$' then
    return callback { is_incomplete_forward = false, is_incomplete_backward = false, items = {} }
  end

  local dirname = lib.dirname(self.opts, context)
  -- No slash in the path — fall back to the gitignore file's directory
  if not dirname then dirname = self.opts.get_cwd(context) end

  local include_hidden = self.opts.show_hidden_files_by_default

  lib
    .candidates(context, dirname, include_hidden, self.opts)
    :map(function(candidates)
      callback { is_incomplete_forward = false, is_incomplete_backward = false, items = candidates }
    end)
    :catch(function() callback() end)
end

return M
