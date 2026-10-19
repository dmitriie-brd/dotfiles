# Neovim cheatsheet

Built for this config (Neovim 0.12, `~/.config/nvim`). `<leader>` = `Space`, `<localleader>` = `\`.

- Open this file: `<leader>hc`. Open the learning plan: `<leader>hl`.
- In this file: `gO` shows the outline, and `]]` / `[[` jump to the next / previous section.
- Do not remember a key? Press `<leader>` and wait (which-key). Or press `<leader>fk` (search all keymaps).
- `<leader>hk` (`:Keymaps`) generates the full list of config keymaps, with the file:line of each one.
- `<leader>hd` (`:Drill`) creates / resets the practice sandbox `~/nvim-drill`. `<leader>ht` = `:Tutor`.
- `:h {topic}` or `<leader>fh` opens the built-in help. For example: `:h text-objects`, `:h motion.txt`.

Legend: **[B]** built into Neovim, **[C]** added by this config.

---

## 1. The grammar: `[count] operator [count] motion | text-object`

You do not learn single commands. You learn words and you combine them.

| Operator | Action | Doubled (= current line) |
|---|---|---|
| `d` | delete (cut) | `dd` |
| `c` | change (delete, then insert) | `cc` |
| `y` | yank (copy) | `yy` (`Y` = to end of line) |
| `>` / `<` | indent / outdent | `>>` / `<<` |
| `<leader>=` [C] | re-indent (`=` is used for window resize) | `<leader>==` |
| `gu` / `gU` / `g~` | lower / upper / toggle case | `guu` / `gUU` |
| `gq` | wrap text at 'textwidth' (79 in zon) | `gqq` |
| `gc` | comment / uncomment (JSX aware) | `gcc` |
| `!` | filter through a shell command | `!!sort` |
| `zf` | create a fold | |
| `ys` [C] | add a surrounding (see section 7) | `yss` |

Examples: `d2w` (delete 2 words), `c$` (change to end of line), `y}` (yank to paragraph end),
`gUiw` (upper-case word), `>ip` (indent paragraph), `gcap` (comment paragraph), `3dd`.

`.` repeats the last change. It is the most important key in Vim. Make changes that you can repeat.

---

## 2. Motions

### In the line
| Keys | Moves to |
|---|---|
| `h` `l` | left / right |
| `0` / `^` / `$` | column 0 / first non-blank / end of line |
| `g_` | last non-blank |
| `f{c}` / `F{c}` | next / previous character `{c}` in the line |
| `t{c}` / `T{c}` | before the next / previous `{c}` |
| `;` / `,` | repeat the last f/t/F/T forward / backward |

### Words
| Keys | Moves to |
|---|---|
| `w` / `b` / `e` / `ge` | next word start / previous word start / word end / previous word end |
| `W` `B` `E` `gE` | the same for WORDS (sequences of non-blank characters: `foo.bar(x)` is one WORD) |

### Lines and screen
| Keys | Moves to |
|---|---|
| `j` `k` | down / up. Use counts: `5j`, `12k` (relative numbers are on) |
| `gj` `gk` | down / up by screen lines (when wrap is on) |
| `gg` / `G` / `42G` / `:42` | first line / last line / line 42 |
| `{` / `}` | previous / next empty line (paragraph) |
| `%` | matching `()[]{}` |
| `M` | middle of the screen (`H` / `L` = previous / next buffer here, see section 9) |
| `<C-d>` / `<C-u>` | half page down / up |
| `<C-f>` / `<C-b>` | full page down / up |
| `zz` / `zt` / `zb` | scroll so the cursor line is in the center / top / bottom |
| `<C-e>` / `<C-y>` | scroll one line, cursor stays |

### Jump anywhere on the screen: leap [C]
| Keys | Action |
|---|---|
| `s{c1}{c2}` | jump to the 2-character pair. If labels appear, type the label. |
| `s{c}<CR>` | jump to the closest `{c}` (a multi-line `f`) |
| `s<CR>` | repeat the last leap. More `<CR>` = next match, `<BS>` = previous match. |
| `S{c1}{c2}` | jump into another window |
| `d z{c1}{c2}` | operator + leap: delete up to the target (also `y z..`, `c z..`). Use `z`, because `ds` / `cs` / `ys` are surround. |
| `gs{c1}{c2}` + select + operator | "visit": jump there in visual mode, select (`iw`, `ip`, ...), press an operator; the cursor comes back. Example: `gs` + target + `iwy` copies a far word without moving. |
| `{c}<Space>` | target the last character of a line. `<Space><Space>` = empty lines. |

### Code motions
| Keys | Moves to |
|---|---|
| `]f` / `[f` [C] | next / previous function start |
| `]F` / `[F` [C] | next / previous function end |
| `]C` / `[C` [C] | next / previous class |
| `]a` / `[a` [C] | next / previous function argument |
| `[x` [C] | start of the enclosing function (the sticky header at the top) |
| `]]` / `[[` [C] | next / previous use of the word under the cursor (LSP) |
| `]d` / `[d` [B] | next / previous diagnostic (a float opens). `]D` / `[D` = last / first. |
| `]e` / `[e` [C] | next / previous **error** only |
| `]h` / `[h` [C] | next / previous changed hunk (git or CVS). `]H` / `[H` = last / first. |
| `]t` / `[t` [C] | next / previous `TODO:` / `FIXME:` / `XXX login:` comment |
| `]c` / `[c` [B] | next / previous change in diff mode (also `<Tab>` / `<S-Tab>` [C]) |
| `]s` / `[s` [B] | next / previous spelling error |

### Jumps, marks, history
| Keys | Action |
|---|---|
| `<C-o>` / `<C-i>` | back / forward in the jump list (after `gd`, search, `G`, leap, ...). `<Tab>` = `<C-i>`. |
| `g;` / `g,` | back / forward in the change list (where you edited) |
| `` `. `` / `gi` | go to the last change / insert again where you last inserted |
| ` `` ` | back to the position before the last jump |
| `ma` / `` `a `` / `'a` | set mark a / go to its exact position / go to its line (buffer-local) |
| `mA` / `` `A `` | global mark (file mark): it jumps to the file too. Good for "home" files. |
| `<leader>fm` / `<leader>fj` [C] | list marks / list the jump list |

---

## 3. Text objects (use after an operator or in visual mode)

`i` = inner (contents only), `a` = around (with delimiters / spaces).

| Object | Meaning |
|---|---|
| `iw` / `aw`, `iW` / `aW` | word, WORD |
| `is` / `as`, `ip` / `ap` | sentence, paragraph |
| `i(` `a(` (also `ib`), `i{` `a{` (also `iB`), `i[` `a[`, `i<` `a<` | inside / around brackets |
| `i"` `a"`, `i'` `a'`, `` i` `` `` a` `` | inside / around quotes (works from anywhere in the line) |
| `it` / `at` | inside / around an HTML / JSX tag |
| `if` / `af` [C] | function body / whole function (treesitter) |
| `ic` / `ac` [C] | class |
| `ia` / `aa` [C] | argument / argument with its comma |
| `io` / `ao` [C] | conditional (`if`) |
| `il` / `al` [C] | loop |
| `gh` [C] | the changed hunk (after an operator: `dgh`, `ygh`) |
| visual `an` / `in` [B] | expand the selection to the parent syntax node / shrink it. Press again to grow. |
| visual `]n` / `[n` [B] | select the next / previous sibling node |

Examples: `ci'` (change the string), `da(` (delete a call's arguments with the parentheses),
`yaf` (copy a function), `vafan` (select the function, then its parent), `cia` (change one argument),
`dat` (delete a JSX element), `=if` → in this config use `<leader>=if`.

---

## 4. Insert, change, delete

| Keys | Action |
|---|---|
| `i` / `a` | insert before / after the cursor |
| `I` / `A` | insert at line start / at line end |
| `o` / `O` | new line below / above |
| `jj` [C] or `<Esc>` or `<C-[>` | back to normal mode |
| `C` / `D` | change / delete to end of line |
| `x` / `X` | delete character under / before the cursor |
| `r{c}` / `R` | replace one character / replace mode |
| `J` / `gJ` | join lines with / without a space |
| `~` | toggle case of a character |
| `<C-a>` / `<C-x>` | increment / decrement the number under or after the cursor (`5<C-a>`) |
| visual `g<C-a>` | make a sequence: 1 2 3 ... on the selected lines |
| `u` / `<C-r>` | undo / redo. `<leader>tu` [C] = undo tree. |
| `[<Space>` / `]<Space>` [B] | add an empty line above / below, stay in normal mode |
| `<A-j>` / `<A-k>` [C] | move the line (or selection) down / up |
| `s` / `S` | **not** the Vim defaults here (they are leap). Use `cl` and `cc`. |

### In insert mode
| Keys | Action |
|---|---|
| `<C-w>` / `<C-u>` | delete the word / the line before the cursor |
| `<C-r>{reg}` | paste a register (`<C-r>"` last yank/delete, `<C-r>+` clipboard, `<C-r>.` last insert) |
| `<C-o>{cmd}` | run one normal mode command, then continue inserting (`<C-o>zz`) |
| `<C-t>` / `<C-d>` | indent / outdent the current line |
| `<C-v>{key}` | insert the key literally (`<C-v><Tab>` = a real tab) |
| `<C-g>s{char}` [C] | add a surrounding pair around the cursor |

---

## 5. Visual mode

| Keys | Action |
|---|---|
| `v` / `V` / `<C-v>` | characterwise / linewise / block selection |
| `gv` | select the last selection again |
| `o` | go to the other end of the selection |
| `<` / `>` [C] | indent; the selection stays, so you can press it again |
| `p` [C] | paste over the selection and keep the register (you can paste again) |
| `<C-v>` + `I` / `A` + text + `<Esc>` | insert / append the same text on many lines |
| `<C-v>` + `$` + `A` | append at the end of lines with different lengths |
| `:` | run an Ex command on the selected lines (`:'<,'>`) |
| `V` + `@a` / `V` + `Q` [B] | run macro `a` / the last macro on each selected line |
| `S{c}` [C] | surround the selection (`S'`, `S)`, `S<div>`) |

Rule: before you press `v`, ask "is there a text object or motion for this?" Usually there is one.

---

## 6. Registers, copy and paste

| Keys | Action |
|---|---|
| `p` / `P` | paste after / before (the clipboard is the default register) |
| `]p` / `[p` | paste with the indent of the current line |
| `"ayiw` / `"ap` | yank into register `a` / paste from `a` |
| `"Ayy` | **append** the line to register `a` (upper case appends) |
| `"0p` | paste the last **yank** (deletes do not change register 0) |
| `"1p` ... `"9p` | older deletes. `"1pu.u.u.` cycles through them. |
| `"_d` | delete into the black hole (registers do not change) |
| `".` `":` `"/` `"%` | last inserted text, last command, last search, file name |
| `<leader>f"` [C] | list all registers |
| `:let @a = ''` | clear register `a` |

---

## 7. Surround (nvim-surround) [C]

| Keys | Result |
|---|---|
| `ysiw'` | `word` → `'word'` |
| `ysiw)` / `ysiw(` | `(word)` / `( word )` (an opening bracket adds spaces) |
| `ysa'f` + name | `'x'` → `name('x')` (wrap in a function call) |
| `yss}` | surround the whole line |
| `cs'"` | `'x'` → `"x"` |
| `csq'` | change **any** quote to `'` (`q` = the nearest quote) |
| `ds(` / `dsq` / `dsf` / `dst` | delete brackets / the nearest quote / a function call / a tag |
| `cst<span>` | change the tag |
| visual `S<div class="x">` | wrap the selection in a tag |

Aliases: `b` = `)`, `B` = `}`, `r` = `]`, `a` = `>`, `q` = any quote, `s` = any surrounding.

---

## 8. Search and replace

`/` and `?` start in **very magic** mode [C] (`\v` is added), so the regex is like in JS:
`/(foo|bar)_\d+` works. To match a literal `(` `|` `+` `?` `{`, escape it: `\(`.
In very magic mode, `<` and `>` are word boundaries: `/<id>` finds `id`, but not `user_id`.

| Keys | Action |
|---|---|
| `/text` / `?text` | search forward / backward. `n` / `N` = next / previous (centered) [C]. |
| `*` / `#` | search the word under the cursor forward / backward (whole word) |
| `g*` / `g#` | the same, also inside other words |
| `<Esc>` [C] | remove the search highlight |
| `gn` / `cgn` | select / change the next match. Then `.` repeats on the next match. **Best rename for a few places:** `*` `cgn` new text `<Esc>` `.` `.` (`n` skips one). |
| `:%s/old/new/g` [C: `\v` added] | replace in the whole file. Flags: `g` all in line, `c` confirm, `i` ignore case. A live preview opens in a split. |
| `:'<,'>s/a/b/g` | replace in the selection only |
| `:s//new/` | an empty pattern = the last search. Search first, then replace. |
| `&` / `g&` | repeat the last `:s` on this line / on all lines |
| `:%s/\v(\w+)_id/\1Id/g` | groups: `\1`, `\2`; `&` = the whole match |
| `<C-r><C-w>` in `:` | insert the word under the cursor into the command line |

### Project-wide
| Keys | Action |
|---|---|
| `<leader>/` or `<leader>sg` [C] | live grep in the project (zon root). `<C-g>` switches regex ↔ fuzzy. |
| `<leader>sG` [C] | grep in the current file's folder |
| `<leader>sw` [C] | grep the word under the cursor (visual: grep the selection) |
| `<leader>sr` [C] | search and replace (grug-far) with a preview; starts with the word and the current folder. Visual: the selection. |
| `<leader>sf` [C] | search and replace in the current file only (grug-far) |
| inside grug-far: `g?` | help (`<localleader>r` = replace all, `<localleader>s` = sync the edited result lines back to the files) |
| grep → `<C-q>` → `:cdo s/a/b/ \| update` | replace in all quickfix lines and save. Or edit the quickfix lines directly, see section 13. |

---

## 9. Files, buffers, windows, tabs

### Find and open (fzf-lua) [C]
| Keys | Action |
|---|---|
| `<leader><Space>` / `<leader>ff` | find files in the project (zon root or git root) |
| `<leader>fF` | files in the current file's folder |
| `<leader>fr` | recent files |
| `<leader>,` / `<leader>fb` | open buffers |
| `<leader>fw` | files whose name matches the word under the cursor |
| `<leader>fc` | config files |
| `<leader>fR` / `<leader>sR` | resume the last picker (same query and position) |
| `<leader>:` / `<leader>s/` | command history / search history |
| `gf` / `gF` | open the file path under the cursor / and go to `:line` (`pkg/util/etask.js:120`) |
| `<C-w>f` / `<C-w>F` | the same in a split |
| `:A` / `<leader>zA` [C] | switch between a source file and its test |
| `<leader>e` / `<leader>tt` [C] | show the current file in the tree / toggle the tree |

**Inside any picker:**

| Keys | Action |
|---|---|
| `<CR>` | open (with many items selected: send them to the quickfix list) |
| `<C-v>` / `<C-s>` / `<C-t>` | open in vsplit / split / tab |
| `<Tab>` / `<S-Tab>` | select many items. `<A-a>` = select all. |
| `<C-q>` | send the selected items to the quickfix list |
| `<C-d>` / `<C-u>` | scroll the preview |
| `<F1>` help, `<F2>` fullscreen, `<F4>` preview on/off | |
| `<A-h>` / `<A-i>` | show hidden / ignored files |
| `<Esc>` or `<C-c>` | close |

Fuzzy syntax: `foo bar` (both), `'exact`, `^start`, `end$`, `!not`.

### nvim-tree (inside the tree) [C]
`g?` help, `<CR>`/`o` open, `<C-v>` vsplit, `a` add (end with `/` for a folder), `d` delete,
`r` rename, `x`/`c`/`p` cut/copy/paste, `y` copy name, `Y` copy relative path, `H` dotfiles, `-` up, `q` close.

### Buffers (the line at the top) [C]
A **buffer** is an open file. Opening a file (`<leader><Space>`, `gf`, `gd`, `:e`) shows it in the current window
and adds it to the buffer line at the top. The old file stays open there. This is what LazyVim calls "tabs".

| Keys | Action |
|---|---|
| `<S-h>` / `<S-l>` | previous / next buffer in the line |
| `<C-^>` or `<leader>bb` | switch to the alternate (last used) buffer |
| `<leader>bj` | pick a buffer: each one gets a letter, type it |
| `<leader>,` | search the open buffers (fuzzy) |
| `<leader>bp` / `<leader>bP` | pin / unpin this buffer / close all buffers that are not pinned |
| `<leader>bl` / `<leader>br` | close the buffers to the left / right |
| `<leader>b[` / `<leader>b]` | move this buffer left / right in the line |
| `<leader>bd` / `<leader>bo` | close this buffer (window stays) / close all other buffers |
| `]b` / `[b` [B] | next / previous buffer (by number, not by line order) |
| `:w` `:wa` (`<leader>qw`) `:e!` | write / write all / reload from disk (drop changes) |
| `ZZ` / `ZQ` / `<leader>qq` | write and quit / quit without saving / quit all |

### Windows
| Keys | Action |
|---|---|
| `<C-h>` `<C-j>` `<C-k>` `<C-l>` [C] | go to the left / lower / upper / right window |
| `<C-w>v` / `<C-w>s` (`<leader>wv`) | vertical / horizontal split (`<leader>w` = `<C-w>`) |
| `<C-w>q` / `<C-w>o` | close this window / close all other windows |
| `<C-w>=` / `<C-w>x` / `<C-w>T` | equal sizes / swap with the next / move to a new tab |
| `<C-w>H` `J` `K` `L` | move the window to the far left / bottom / top / right |
| `-` `=` / `_` `+` [C] | height − / + , width − / + |

### Tab pages
A **tab page** is a layout of windows (like a virtual desktop), not one file. When there are 2 or more,
their numbers show at the right end of the top line.
`gt` / `gT` next / previous tab page, `3gt` tab page 3, `:tabnew`, `:tabclose`, `<C-w>T` window to a new tab page.
The cheatsheet, the generated keymaps and CVS diffs open in their own tab page: close them with `q` or `:tabclose`.

### Sessions [C]
`<leader>qs` restore the session for this folder, `<leader>ql` the last one, `<leader>qS` select one, `<leader>qd` do not save this session.

---

## 10. LSP (JS/TS: vtsls, Rust: rust-analyzer)

| Keys | Action |
|---|---|
| `gd` [C] / `gD` [C] | go to definition / declaration. Come back with `<C-o>`. |
| `grr` | references (picker) |
| `gri` | implementations |
| `grt` | type definition |
| `K` | documentation (hover). Press `K` again to enter the float. |
| `<C-s>` (insert mode) | signature help |
| `grn` or `<leader>cr` | rename the symbol (in all files) |
| `gra` or `<leader>ca` | code action (quick fix, refactor, extract) |
| `gO` or `<leader>ss` | symbols in the buffer (outline). `<leader>sS` = in the workspace. |
| `<leader>cp` / `<leader>ct` / `<leader>ci` [C] | peek definition / type / implementation in a float. `<leader>cP` closes all. |
| `<leader>cR` [C] | rename the file and update the imports |
| `<leader>co` / `<leader>cM` / `<leader>cu` [C] | TS/JS: organize imports / add missing imports / remove unused imports |
| `<leader>th` [C] | inlay hints on/off |
| `<leader>cl` / `<leader>cL` [C] | LSP status (`:checkhealth vim.lsp`) / restart the LSP |

### Diagnostics
| Keys | Action |
|---|---|
| `]d` / `[d` / `]e` / `[e` | next / previous diagnostic / error (a float opens) |
| `<leader>cd` or `<C-w>d` | the diagnostics for this line in a float |
| `<leader>sd` / `<leader>sD` [C] | list the diagnostics in the buffer / in the workspace |
| `<leader>tv` [C] | show them as virtual text or as virtual lines below the line |
| `<leader>td` [C] | diagnostics on/off |

Sources: `ts` (vtsls), `zlint` (zon lint), `rustc` / `clippy`.

---

## 11. Completion and snippets (blink.cmp) [C]

| Keys | Action |
|---|---|
| `<CR>` | accept the selected item |
| `<C-n>` / `<C-p>` or `<Down>` / `<Up>` | next / previous item |
| `<C-Space>` | open the menu / show the documentation |
| `<C-e>` | close the menu |
| `<C-b>` / `<C-f>` | scroll the documentation |
| `<Tab>` / `<S-Tab>` | next / previous snippet field |
| `<C-k>` | signature help on/off |
| `:` + `<Tab>` | command-line completion |

**zon snippets** (type the prefix, then `<CR>`):

| Prefix | Inserts |
|---|---|
| `zhdr` / `zhdrb` / `zhdrr` | node / browser / react file header |
| `etask` | `const name = ()=>etask(function*(){ ... });` |
| `etaskn` | `E.name = ()=>etask(function*name(){ ... });` (exported API) |
| `ry` | `return yield ` |
| `zreq` | `const name = require('../util/name.js');` |
| `zdesc` / `zdescribe` | `describe(...)` / `zdescribe('BASE')('name', ()=>{ ... })` |
| `zit` / `zite` | `it('', ()=>{})` / `it('', ()=>etask(function*(){}))` |
| `xxx` | `// XXX dmitriie: ` |
| `zet` | `E.t = {};` (test-only exports) |

`:ZonHeader` (`<leader>zn`) inserts the full header with the correct `require('.../util/config.js')` path.

---

## 12. zon: CVS, zlint, zmocha `<leader>z` [C]

### CVS
| Keys / command | Action |
|---|---|
| `<leader>zm` / `:CvsModified` | list your modified files (local, about 1 s). `<CR>` open, `<C-d>` diff, `<C-v>` vsplit, `<Tab>` select many, `<C-q>` to quickfix. |
| `<leader>zs` / `:CvsStatus [dir]` | `cvs -n update` for the current folder (network): also shows files changed on the server (`U` = needs update, `C` = conflict). Result → quickfix. |
| `<leader>zd` / `:CvsDiff` | diff with **BASE** (the revision you checked out) in a new tab |
| `<leader>zD` / `:CvsDiff HEAD` | diff with **HEAD** (the latest version on the server) |
| `:CvsDiff 1.42` / `:CvsRev 1.42` | diff with a revision / open the file at a revision |
| `<leader>za` / `:CvsAnnotate` | annotate split (full names, dates colored by age). Press again to close. |
| `<leader>zb` | who changed this line: author, date and commit message in a float |
| `<leader>zh` / `:CvsLog` | file history with the message and the diff in the preview. `<CR>` diff of that commit, `<C-o>` open the file at that revision, `<C-y>` copy the revision. |
| `]h` `[h` / `gHgh` / `gH{motion}` | go to a changed hunk / undo the hunk under the cursor / undo hunks in a motion (compared to BASE) |
| `<leader>go` | show the changes inline in the buffer (overlay) |

**In the annotate split:**

| Keys | Action |
|---|---|
| `<CR>` | annotate the file at the revision of this line (go back in time) |
| `^` | annotate at the revision **before** this line's revision ("who wrote it before?") |
| `<BS>` | go back one step |
| `<Tab>` / `<S-Tab>` | next / previous block from the same revision |
| `d` | diff of that commit |
| `K` | the full commit message |
| `q` | close |

**In a diff (CVS or `nvim -d`):** `]c` `[c` or `<Tab>` `<S-Tab>` next / previous change, `do` get the change
from the other side, `dp` put it to the other side, `:diffupdate` recompute, `<leader>ti` ignore whitespace on/off,
`q` close the tab (from the left buffer).

### zlint
| Keys / command | Action |
|---|---|
| (automatic) | `zlint -c` runs on open and on save; the results are diagnostics (source `zlint`) |
| `<leader>zL` | live zlint on/off |
| `<leader>zl` / `<leader>zc` | `zlint` / `zlint -c` on this file → quickfix |
| `<leader>zM` | `zlint -c` on **all** CVS-modified JS files → quickfix (run before a handoff) |
| `<leader>zf` or `<leader>cf` | autofix: `eslint --fix` with the zon rules (quotes, semicolons, spacing). Then `:w`. |
| `:make` / `:make -c` | the old way: zlint through the `zlint` compiler → quickfix |

### zmocha
| Keys / command | Action |
|---|---|
| `<leader>zt` | run the test file for this buffer (`foo.js` → `foo.test.js`, `tests/foo.test.js`, `test.js`) |
| `<leader>zT` | run only the `it(...)` / `describe(...)` above the cursor (`zmocha -f`) |
| `<leader>zr` | run the last test again |
| `<leader>zB` / `:ZonBuild [name]` | choose the BUILD (`debug`, `debug_fe`). The statusline shows `BUILD=...`. |

The test output opens in a terminal split at the bottom. Go there with `<C-j>`, close it with `q` (in normal mode).

---

## 13. Quickfix: the list of places (grep, zlint, references)

| Keys | Action |
|---|---|
| `<leader>tq` [C] | open / close the quickfix window |
| `]q` / `[q` [B] | next / previous item. `]Q` / `[Q` = last / first. |
| `:copen` / `:cclose` | open / close |
| `:colder` / `:cnewer` or `<leader>sQ` | older / newer quickfix lists |
| `<leader>sq` [C] | search inside the quickfix list (fuzzy) |
| `>` / `<` (in the qf window) [C] | show / hide context lines |
| edit lines in the qf window + `:w` [C] | **apply the edits to all files** (quicker.nvim) |
| `:cdo {cmd}` | run a command on each item: `:cdo s/old/new/ \| update` |
| `:cfdo {cmd}` | run a command once per file: `:cfdo %s/old/new/g \| update` |

Location list = a quickfix list for one window: `]l` `[l`, `<leader>tL`, `<leader>sl`.

---

## 14. Macros and Ex power

| Keys | Action |
|---|---|
| `qa` ... `q` | record macro `a` |
| `@a` / `@@` / `10@a` | run it / run the last one again / run it 10 times |
| `:'<,'>norm @a` | run the macro on each selected line |
| `"ap` → edit → `0"ay$` | edit a macro as text and save it back |
| `@:` | repeat the last `:` command |
| `:g/pat/d` / `:v/pat/d` | delete all lines with / without `pat` |
| `:g/pat/norm A;` | run normal-mode keys on each matching line |
| `:g/pat/t$` / `:g/pat/m0` | copy matching lines to the end / move them to the top |
| `:t.` / `:m+1` | duplicate the line / move it down |
| `:r !cmd` / `:.!cmd` / `:%!jq .` | insert command output / filter the line / filter the file |
| `q:` / `q/` | open the command / search history in an editable window (`<CR>` runs a line) |
| `:sort` / `:sort u` / `:'<,'>sort` | sort lines / sort and remove duplicates / sort the selection |

Macro rules: start with a motion that puts the cursor in the same place (`0`, `^`, `f(`), end on the next item (`j`, `n`), and use `w`/`f`/`t`, not `l` many times.

---

## 15. Folds, spelling, misc

| Keys | Action |
|---|---|
| `za` / `zc` / `zo` | toggle / close / open the fold (treesitter folds, all open at start) |
| `zM` / `zR` | close all / open all |
| `zj` / `zk` | next / previous fold |
| `z=` / `zg` / `zw` | spelling suggestions / add the word to the zon dictionary / mark it wrong |
| `gx` | open the URL or path under the cursor in the browser |
| `ga` / `g8` | show the character code under the cursor |
| `<C-/>` [C] | terminal at the project root (toggle). In the terminal: `<Esc><Esc>` = normal mode. |
| `<leader>gg` [C] | lazygit (git repos only) |
| `<leader>tu` | the undo tree (`:Undotree`): move in it to go back to any old state |
| `:checkhealth` | check the setup |

---

## 16. Git (Rust and other git repos) [C]

| Keys | Action |
|---|---|
| `]h` `[h` / `ghgh` / `gHgh` | go to a hunk / **stage** the hunk / reset the hunk (`gh` + motion: stage a range) |
| `<leader>go` | inline diff overlay |
| `<leader>gb` | blame this line |
| `<leader>gd` / `<leader>gq` | diffview: review all changes / close |
| `<leader>gh` / `<leader>gl` / `<leader>gH` | file history / line history (also visual) / repo history |
| `<leader>gs` / `<leader>gc` / `<leader>gC` / `<leader>gB` | git status / commits / commits of this file / branches (pickers) |
| `<leader>gg` | lazygit (commit, push, rebase, ...) |

---

## 17. Rust [C]

| Keys | Action |
|---|---|
| `<leader>rr` / `<leader>rR` | runnables (cargo run, ...) / run the last one again |
| `<leader>rt` / `<leader>rT` | tests (pick one) / run the last test again |
| `<leader>rm` | expand the macro under the cursor |
| `<leader>re` / `<leader>rd` | explain the error (rustc --explain) / show the diagnostic like cargo |
| `<leader>ro` / `<leader>rc` / `<leader>rp` | docs.rs for the symbol / open Cargo.toml / parent module |
| `<leader>rj` | smart line join |
| `<leader>ca` / `K` | grouped code actions / hover with actions |
| in `Cargo.toml`: `<leader>rv` `<leader>rf` `<leader>ru` `<leader>rU` `<leader>rD` | versions / features / upgrade crate / upgrade all / crate docs |

Clippy runs on save. The file is formatted with rustfmt on save (`<leader>tf` = on/off).

---

## 18. Toggles `<leader>t` [C]

`tw` wrap, `ts` spell, `tn` relative numbers, `tl` invisible chars, `th` inlay hints, `td` diagnostics,
`tv` diagnostic style, `ti` diff ignores whitespace, `tc` sticky context, `tb` dark/light, `tf` format on save,
`tq` quickfix, `tL` location list, `tt` file tree, `tu` undo tree.

---

## 19. Built-in keys that this config changes

| Key | Vim default | Here | Use instead |
|---|---|---|---|
| `s` | delete a char, then insert | leap | `cl` |
| `S` | change the line | leap to other windows | `cc` |
| `gs` | sleep | leap visit | — |
| `-` / `+` | line up / down to first non-blank | window height | `k^` / `j^` or `<CR>` |
| `_` | first non-blank | window width | `^` |
| `=` | re-indent operator | window height | `<leader>=` (in visual mode `=` still works) |
| `<C-l>` | redraw + clear search + diffupdate | window right | `<Esc>` clears the search, `:diffupdate` |
| `<C-h>` `<C-j>` `<C-k>` | left / down / (nothing) | window moves | `h` `j` |
| `H` / `L` | top / bottom line of the screen | previous / next buffer | `zt` / `zb` + `M`, `<C-u>` / `<C-d>`, leap |
| `]a` / `[a` | next / previous file in the arglist | next / previous argument | `:next` / `:prev` |
| `]t` / `[t` | tag stack | TODO comments | `:tnext` / `:tprev` |
| `]]` / `[[` | next / previous section | next / previous LSP reference (markdown: headings) | — |
| visual `p` | paste and yank the replaced text | paste, keep the register | visual `P` is the same |
| `/` `?` | normal magic | very magic (`\v` added) | delete `\v` with `<C-w>` if you want normal magic |
| `<Tab>` | jump forward (`<C-i>`) | the same, but next change in diff mode | — |

---

## 20. Commands of this config

`:Cheatsheet` (this file, `<leader>hc`), `:Keymaps` (generated list, `<leader>hk`), `:LearnPlan` (`<leader>hl`),
`:Drill` (practice sandbox, `<leader>hd`), `:Tutor` (`<leader>ht`),
`:CvsDiff [BASE|HEAD|rev]`, `:CvsAnnotate`, `:CvsLog`, `:CvsModified`, `:CvsStatus [dir]`, `:CvsRev rev`,
`:ZonBuild [name]`, `:ZonHeader [node|script|mocha|browser|react|jdoc]`, `:A`,
`:ToggleBackground`, `:Mason`, `:lsp restart`, `:TSUpdate`, `:lua vim.pack.update()` (review, then `:w`).

---

## My notes

Add your own tips here (this file is yours, `:w` saves it).

- 
