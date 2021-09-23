local function make_name(bufnr, _3fsuffix)
  local fname = vim.api.nvim_buf_get_name(bufnr)
  local stem = vim.fn.fnamemodify(fname, ":t")
  local default = (stem .. (_3fsuffix or "") .. ".html")
  local input = vim.fn.input("Name: ", default, "file")
  return input
end
local function make_footer()
  local date = os.date("%F")
  local time = os.date("%T%z")
  return ("<small><em>Created on %s at %s by <a href=\"https://github.com/gpanders/nvim-scpaste\">nvim-scpaste</a></em></small>"):format(date, time)
end
local function scp(src, dest)
  local scp_command = (vim.g.scpaste_scp or "scp")
  local scp_dest = assert(vim.g.scpaste_scp_destination)
  local cmd = {scp_command, src, ("%s/%s"):format(scp_dest, dest)}
  local function on_exit(_, code)
    if (code > 0) then
      vim.notify(("scp command failed with exit code %d"):format(code), vim.log.levels.WARN)
    else
      local _1_ = vim.g.scpaste_http_destination
      if (nil ~= _1_) then
        local http_dest = _1_
        vim.notify(("Paste is available at %s/%s"):format(http_dest, dest))
      else
        local _0 = _1_
        vim.notify(("Paste copied to %s/%s"):format(scp_dest, dest))
      end
    end
    return vim.loop.fs_unlink(src)
  end
  return vim.fn.jobstart(cmd, {on_exit = on_exit})
end
local function callback(name, data, type)
  local _4_ = type
  if (_4_ == "stdout") then
    if (data and ((#data > 1) or (data[1] ~= ""))) then
      local tmp = vim.fn.tempname()
      table.insert(data, make_footer())
      do
        local f = io.open(tmp, "w")
        local function close_handlers_7_auto(ok_8_auto, ...)
          f:close()
          if ok_8_auto then
            return ...
          else
            return error(..., 0)
          end
        end
        local function _6_()
          return f:write(table.concat(data, "\n"))
        end
        close_handlers_7_auto(xpcall(_6_, (package.loaded.fennel or debug).traceback))
      end
      return scp(tmp, name)
    end
  elseif (_4_ == "stderr") then
    return vim.notify(table.concat(data, "\n"), vim.log.levels.ERROR)
  end
end
local function scpaste(_3fstart, _3fend, _3fopts)
  local bufnr = vim.api.nvim_get_current_buf()
  local name
  local function _10_()
    local t_9_ = _3fopts
    if (nil ~= t_9_) then
      t_9_ = (t_9_).suffix
    end
    return t_9_
  end
  name = make_name(bufnr, _10_())
  local start = (_3fstart or 1)
  local _end = (_3fend or vim.api.nvim_buf_line_count(bufnr))
  local lines = vim.api.nvim_buf_get_lines(bufnr, (start - 1), _end, true)
  local ft = vim.bo.filetype
  local highlight_cmd = (vim.g.scpaste_highlight or "highlight --inline-css")
  local highlight_args = (" -T " .. name .. " -S " .. ft)
  local cb
  local function _12_(_241, _242, _243)
    return callback(name, _242, _243)
  end
  cb = _12_
  local opts = {on_stderr = cb, on_stdout = cb, stderr_buffered = true, stdout_buffered = true}
  local job = vim.fn.jobstart((highlight_cmd .. highlight_args), opts)
  vim.fn.chansend(job, lines)
  return vim.fn.chanclose(job, "stdin")
end
return scpaste
