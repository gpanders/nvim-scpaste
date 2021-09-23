local function create_nvim_instance()
  local job = vim.fn.jobstart({"nvim", "--headless", "--embed"}, {rpc = true})
  local function _1_(func, ...)
    return vim.rpcrequest(job, ("nvim_" .. func), ...)
  end
  return _1_, job
end
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
local function rpc(job, func, ...)
  return vim.rpcrequest(job, ("nvim_" .. func), ...)
end
local function to_html(bufnr, name, _3fstart, _3fend)
  local start = (_3fstart or 0)
  local _end = (_3fend or vim.api.nvim_buf_line_count(bufnr))
  local fname = vim.api.nvim_buf_get_name(bufnr)
  local nvim, job_id = create_nvim_instance()
  local settings = vim.call("tohtml#GetUserSettings")
  do
    local _2_ = vim.g.scpaste_colors
    if (nil ~= _2_) then
      local scheme = _2_
      nvim("command", ("colorscheme " .. scheme))
    end
  end
  nvim("set_option", "termguicolors", true)
  nvim("command", ("edit " .. fname))
  nvim("call_function", "tohtml#Convert2HTML", {start, _end})
  nvim("command", string.format("%%s/<title>\\zs.\\{-}\\ze<\\/title>/%s/", vim.fn.fnamemodify(fname, ":t")))
  do
    local num_lines = nvim("buf_line_count", 0)
    nvim("call_function", "append", {num_lines, {make_footer()}})
  end
  nvim("command", ("saveas " .. name))
  local html_fname = nvim("buf_get_name", 0)
  vim.fn.jobstop(job_id)
  return html_fname
end
local function on_exit(code, cmd, html_file, name)
  if (code > 0) then
    vim.notify(("Command '%s' failed with exit code %d"):format(cmd, code), vim.log.levels.WARN)
  else
    local _4_ = vim.g.scpaste_http_destination
    if (nil ~= _4_) then
      local http_dest = _4_
      vim.notify(("Paste is available at %s/%s"):format(http_dest, name))
    else
      local _ = _4_
      local scp_dest = vim.g.scpaste_scp_destination
      vim.notify(("Paste copied to %s/%s"):format(scp_dest, name))
    end
  end
  return vim.loop.fs_unlink(html_file)
end
local function scpaste(start, _end, _3fopts)
  local bufnr = vim.api.nvim_get_current_buf()
  local name
  local function _8_()
    local t_7_ = _3fopts
    if (nil ~= t_7_) then
      t_7_ = (t_7_).suffix
    end
    return t_7_
  end
  name = make_name(bufnr, _8_())
  local html_file = to_html(bufnr, name, start, _end)
  local scp_command = (vim.g.scpaste_scp or "scp")
  local scp_dest = assert(vim.g.scpaste_scp_destination)
  local cmd = {scp_command, html_file, ("%s/%s"):format(scp_dest, name)}
  local function _10_(_241, _242)
    return on_exit(_242, table.concat(cmd, " "), html_file, name)
  end
  return vim.fn.jobstart(cmd, {on_exit = _10_})
end
return scpaste
