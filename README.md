# nvim-scpaste

scpaste plugin for Neovim based on [scpaste.el][] by Phil Hagelberg.

[scpaste.el]: https://git.sr.ht/~technomancy/scpaste/

## Usage

Use `:Scpaste` in a buffer. The command also accepts a range, so you can select
a region in visual mode and use `:Scpaste` to only paste the selection.

## Configuration

**`g:scpaste_http_destination`**

Full URL of the HTTP server that serves the pastes. This is only used to print
the final URL when the `:Scpaste` command completes.

**`g:nvpaste_scp_destination`**

SSH-accessible directory to which HTML files will be copied to. Example:
`p.gpanders.com:scpaste/`.

**`g:nvpaste_scp`**

Command to use for copying HTML files to the server. Defaults to `scp`.

**`g:scpaste_colors`**

Colorscheme to use for pastes. If omitted, use the colorscheme defined in
`g:colors_name`.

All other configuration is done through the `tohtml` builtin plugin. See `:h
:TOhtml`.

## License

[GPLv3][]

[GPLv3]: https://www.gnu.org/licenses/gpl-3.0.html
