# nvim-scpaste

scpaste plugin for Neovim based on [scpaste.el][] by Phil Hagelberg.

[scpaste.el]: https://git.sr.ht/~technomancy/scpaste/

## Usage

Use `:Scpaste` in a buffer. The command also accepts a range, so you can select
a region in visual mode and use `:Scpaste` to only paste the selection.

You can also create a mapping to `<Plug>(scpaste)`.

## Configuration

**`g:scpaste_http_destination`**

Full URL of the HTTP server that serves the pastes. This is only used to print
the final URL when the `:Scpaste` command completes.

**`g:nvpaste_scp_destination`**

SSH-accessible directory to which HTML files will be copied to. Example:
`p.gpanders.com:scpaste/`.

**`g:nvpaste_scp`**

Command to use for copying HTML files to the server. Defaults to `scp`.

**`g:scpaste_highlight`**

Command to use to create HTML from source file. Default is `highlight
--inline-css -O html`. The command should accept the source file on stdin and
emit the output on stdout.

**`g:scpaste_extension`**

Extension to use for output files. Defaults to `html`.

## License

[GPLv3][]

[GPLv3]: https://www.gnu.org/licenses/gpl-3.0.html
