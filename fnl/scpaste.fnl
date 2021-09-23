(fn create-nvim-instance []
  (let [job (vim.fn.jobstart ["nvim" "--headless" "--embed"] {:rpc true})]
    (values
      (fn [func ...]
        (vim.rpcrequest job (.. "nvim_" func) ...))
      job)))

(fn make-name [bufnr ?suffix]
  (let [fname (vim.api.nvim_buf_get_name bufnr)
        stem (vim.fn.fnamemodify fname ":t")
        default (.. stem (or ?suffix "") ".html")
        input (vim.fn.input "Name: " default :file)]
    input))

(fn make-footer []
  (let [date (os.date "%F")
        time (os.date "%T%z")]
    (: "<small><em>Created on %s at %s by <a href=\"https://github.com/gpanders/nvim-scpaste\">nvim-scpaste</a></em></small>"
       :format date time)))

(fn rpc [job func ...]
  (vim.rpcrequest job (.. "nvim_" func) ...))

(fn to-html [bufnr name ?start ?end]
  (let [start (or ?start 0)
        end (or ?end (vim.api.nvim_buf_line_count bufnr))
        fname (vim.api.nvim_buf_get_name bufnr)
        (nvim job-id) (create-nvim-instance)
        settings (vim.call "tohtml#GetUserSettings")]
    (match vim.g.scpaste_colors
      scheme (nvim :command (.. "colorscheme " scheme)))
    (nvim :set_option :termguicolors true)
    (nvim :command (.. "edit " fname))
    (nvim :call_function "tohtml#Convert2HTML" [start end])
    (nvim :command (string.format "%%s/<title>\\zs.\\{-}\\ze<\\/title>/%s/"
                                  (vim.fn.fnamemodify fname ":t")))
    (let [num-lines (nvim :buf_line_count 0)]
      (nvim :call_function :append [num-lines [(make-footer)]]))
    (nvim :command (.. "saveas " name))
    (let [html-fname (nvim :buf_get_name 0)]
      (vim.fn.jobstop job-id)
      html-fname)))

(fn on-exit [code cmd html-file name]
  (if (> code 0)
      (vim.notify (: "Command '%s' failed with exit code %d" :format cmd code)
                  vim.log.levels.WARN)
      (match vim.g.scpaste_http_destination
        http-dest (vim.notify (: "Paste is available at %s/%s" :format http-dest name))
        _ (let [scp-dest vim.g.scpaste_scp_destination]
            (vim.notify (: "Paste copied to %s/%s" :format scp-dest name)))))
  (vim.loop.fs_unlink html-file))

(fn scpaste [start end ?opts]
  (let [bufnr (vim.api.nvim_get_current_buf)
        name (make-name bufnr (?. ?opts :suffix))
        html-file (to-html bufnr name start end)
        scp-command (or vim.g.scpaste_scp :scp)
        scp-dest (assert vim.g.scpaste_scp_destination)
        cmd [scp-command html-file (: "%s/%s" :format scp-dest name)]]
    (vim.fn.jobstart cmd {:on_exit #(on-exit $2 (table.concat cmd " ") html-file name)})))
