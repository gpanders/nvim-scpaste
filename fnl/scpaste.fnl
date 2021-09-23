(fn make-name [bufnr]
  (let [fname (vim.api.nvim_buf_get_name bufnr)
        default (vim.fn.fnamemodify fname ":t")
        input (vim.fn.input "Name: " default :file)]
    (vim.api.nvim_command :mode)
    input))

(fn make-footer []
  (let [date (os.date "%F")
        time (os.date "%T%z")]
    (: "<small><em>Created on %s at %s by <a href=\"https://github.com/gpanders/nvim-scpaste\">nvim-scpaste</a></em></small>"
       :format date time)))

(fn scp [src dest]
  (let [scp-command (or vim.g.scpaste_scp :scp)
        scp-dest (assert vim.g.scpaste_scp_destination)
        cmd [scp-command src (: "%s/%s" :format scp-dest dest)]]
    (fn on-exit [_ code]
      (if (> code 0)
          (vim.notify (: "scp command failed with exit code %d" :format code)
                      vim.log.levels.WARN)
          (match vim.g.scpaste_http_destination
            http-dest (vim.notify (: "Paste is available at %s/%s" :format http-dest dest))
            _ (vim.notify (: "Paste copied to %s/%s" :format scp-dest dest))))
      (vim.loop.fs_unlink src))
    (vim.fn.jobstart cmd {:on_exit on-exit})))

(fn callback [name data type]
  (match type
    :stdout (when (and data (or (> (length data) 1) (not= (. data 1) "")))
              (let [tmp (vim.fn.tempname)]
                (table.insert data (make-footer))
                (with-open [f (io.open tmp :w)]
                  (f:write (table.concat data "\n")))
                (scp tmp (.. name "." (or vim.g.scpaste_extension :html)))))
    :stderr (vim.notify (table.concat data "\n") vim.log.levels.ERROR)))

(fn scpaste [?start ?end]
  (let [bufnr (vim.api.nvim_get_current_buf)
        name (make-name bufnr)]
    (if (= name "")
        (vim.notify "Name must not be blank" vim.log.levels.ERROR)
        (let [start (or ?start 1)
              end (or ?end (vim.api.nvim_buf_line_count bufnr))
              lines (vim.api.nvim_buf_get_lines bufnr (- start 1) end true)
              ft (match vim.bo.filetype
                   "" :none
                   ft ft)
              highlight-cmd (or vim.g.scpaste_highlight "highlight -I")
              highlight-args (.. " -T " name " -S " ft)
              cb #(callback name $2 $3)
              opts {:stdout_buffered true
                    :stderr_buffered true
                    :on_stdout cb
                    :on_stderr cb}
              job (vim.fn.jobstart (.. highlight-cmd highlight-args) opts)]
          (vim.fn.chansend job lines)
          (vim.fn.chanclose job :stdin)))))
