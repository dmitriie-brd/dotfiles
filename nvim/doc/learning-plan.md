# Neovim learning plan

Goal: work in Neovim faster than in any other editor, on zon (JS), TS and Rust.
Duration: about 8 weeks, 15–20 minutes of practice a day, plus normal work in Neovim.

Open this file: `<leader>hl`. Open the cheatsheet: `<leader>hc`.
Mark finished items: put the cursor on `[ ]` and type `rx` (it becomes `[x]`), then `:w`.
This file is in the config git repo, so you can commit your progress.

---

## Rules (read them every Monday)

1. **One habit a week.** Each week has one "habit". Use it all day in real work, even when it is slower at first.
2. **Three times = stop.** If you press the same key 3+ times (`jjjj`, `xxxx`, `llll`) or do the same edit 3+ times,
   stop and find the better way: counts, a motion, a text object, `.`, a macro, a search.
3. **Look it up at once.** Not sure? Press `<leader>` and wait (which-key), `<leader>fk` (search keymaps),
   `<leader>hc` (cheatsheet) or `:h topic`. Then use the new key 10 times on the same day.
4. **Arrows and mouse only in an emergency.** They stop you from learning the real motions.
5. **Practice editing in the sandbox, not in the real checkout.** `:Drill` (`<leader>hd`) creates `~/nvim-drill`:
   copies of zon files (`date.js`, `array.js`, `string.js`, `url.js`, `escape.js`, `tests/date.test.js`,
   `react/lang_select_react.js`) in a git repo. Break anything, then reset it with `:Drill`.
   Navigation drills (no edits) can use the real `~/zon1`. If you change a zon file by mistake: `u` or `:e!`,
   then check `<leader>zm`.
6. **Daily routine (15–20 min):** 3 min — read the week's cheatsheet sections; 12 min — the week's drills;
   2 min — write one note in the "Progress log" at the end of this file.

---

## Week 0 (days 1–2): Orientation

- [ ] `:Tutor` (lesson 1, ~30 min). Then `:Tutor vim-02-beginner` (lesson 2).
- [ ] Learn the help system: `:h usr_02`. In help, `<C-]>` follows a link, `<C-o>` goes back, `gO` shows the outline.
      `<leader>fh` searches all help pages.
- [ ] Press `<leader>` and wait. Read every group in the which-key popup. Do the same for `g`, `]`, `[`, `z`.
- [ ] Read cheatsheet sections 1 (grammar) and 19 (changed built-in keys).
- [ ] Check kitty: the icons look correct, `<A-j>` moves a line, `<C-/>` opens a terminal.
- [ ] Run `:Drill` once and look at the sandbox.

---

## Week 1: Move without thinking

**Habit: count, do not hold.** Never press `j`/`k`/`w`/`l` more than 3 times. Use the relative line number
(`7j`), `}`, `/search`, `f`, or leap (`s`).

Learn (cheatsheet section 2): `hjkl` with counts, `w b e W B E`, `0 ^ $`, `f t F T ; ,`, `gg G 42G`,
`{ }`, `%`, `H M L`, `<C-d> <C-u>`, `zz zt`, `/ ? n N * #`, leap `s` / `S`, `<C-o>` / `<C-i>`.
Read: `:h usr_03`.

Drills (in `~/nvim-drill/date.js`):
- [ ] Go to line 139 (`139G`), go back (`<C-o>`), go forward (`<C-i>`). Repeat with `gg`, `G`, `50%`.
- [ ] Reach `E.str_to_dur` 3 ways: `/str_to<CR>`, leap `s` + `st` (+ label), `]f` several times. Which is fastest?
- [ ] In `E.ms_to_dur` (line 37), go to the 3rd `(` of line 52 with `3f(`. Then `;` and `,`.
- [ ] On every `{` of `ms_to_dur`, press `%` to jump to the matching `}`.
- [ ] Use only relative numbers: reach 10 lines on the screen with `{count}j` / `{count}k`.
- [ ] Leap game: choose 10 random words on the screen. Reach each in at most 4 keys (`s` + 2 chars + label).
- [ ] `*` on `pad` → walk all uses with `n` / `N`. Then `]]` / `[[` (LSP references) do the same.
- [ ] `H`, `M`, `L`, `<C-d>`, `<C-u>`, `zz`, `zt`: read the whole file without `j`/`k`.

Self-test (end of week):
- [ ] Any visible place in ≤ 4 keys.
- [ ] Any line on the screen with one `{count}j/k`.
- [ ] I did not use arrows or the mouse for movement for one full day.

---

## Week 2: The grammar — operators, text objects, dot

**Habit: before you press `v`, find a text object. Make every change repeatable with `.`.**

Learn (cheatsheet sections 1, 3, 4, 6): `d c y > < gu gU gc` + motions; text objects `iw aw i( a( i" i' it at ip`;
code objects `if af ia aa ic ac io ao`; visual `an` / `in`; `.`; `u` / `<C-r>`; `x r J ~`; `p P "0p "_d`.
Read: `:h usr_04`, `:h text-objects`.

Drills (in `~/nvim-drill`):
- [ ] `date.js` line 155: change `'January'` to `'Jan'` with `ci'`. Then `2f'` (next string) and `.`, again `2f'` `.`
      (they all become `'Jan'`: the point is motion + repeat). Undo with `u`.
- [ ] Line 32 `function pad(num, size)`: change `size` with `cia`; delete it with `daa`; undo; swap the args with `<leader>cx`.
- [ ] In `ms_to_dur`: `dif` (empty the body), `u`; `yaf` (copy the function), `]f`, `P`; `u`.
- [ ] `vif`, then `an` `an` `an`: watch the selection grow by syntax nodes. `in` shrinks it.
- [ ] `gcaf` comments the whole function, `gcaf` again uncomments it. `gcc` on one line, `gc3j`.
- [ ] `di(` / `da(` / `ci(` on `Math.floor(sec/(60*60*24))`. Try it from different cursor places.
- [ ] `>ip` then `.` `.` (indent a paragraph 3 times), `u` `u` `u`.
- [ ] `react/lang_select_react.js` line 143: `cit` on `Language`, `dit`, `dat`, `vat` then `at` `at` (grows to outer tags).
- [ ] `yiw` a word, `viwp` over another word, then `viwp` over a third: the same word is pasted (the register stays).
- [ ] `D`, `C`, `cc`, `dd`, `5dd`, `d}`, `ct,`, `dt)`, `yi{`. Say the command in words while you type it
      ("delete inside parentheses").

Self-test:
- [ ] Change any string / argument / call contents in ≤ 4 keys after reaching it.
- [ ] Copy or move a whole function in ≤ 4 keys.
- [ ] I used `.` at least 20 times today.

---

## Week 3: Navigate the project

**Habit: never open a file from the tree or by typing a path.** Use `<leader><Space>`, `gd`, `gf`, `<C-^>`, `<leader>fr`.
Use the tree (`<leader>e`) only to look at a folder.

Learn (cheatsheet sections 9, 10): `<leader><Space>`, `<leader>/`, `<leader>fr`, `<leader>,`, `<leader>fR`,
picker keys (`<Tab>`, `<C-q>`, `<C-v>`), `gd grr gri K gO <leader>ss`, `<leader>cp`, `<C-o>` / `<C-i>`, `<C-^>`,
`gf` / `gF`, `:A`, global marks `mA` / `` `A ``, `]q` / `[q`.
Read: `:h usr_07`, `:h usr_29`.

Drills (in the real `~/zon1`, read only):
- [ ] Open `pkg/util/etask.js` by typing `etask` in `<leader><Space>`. Target: < 3 s. Do the same for 5 other files you know.
- [ ] `<leader>/` `ms_to_dur`: select 3 results with `<Tab>`, `<C-q>` → quickfix. Walk them with `]q` / `[q`.
- [ ] In `pkg/util/date.js`: `grr` on `E.ms_to_dur`; `gd` on `pad` inside it; `<C-o>` back.
- [ ] Open a service file that uses `etask` (`<leader>/` `etask(function`). `gd` on `etask` → read → `<C-o>`.
      Then `<leader>cp` on `etask` (peek in a float, no jump).
- [ ] `gO` in `date.js`: jump to `to_sql` by typing its name. Same with `<leader>ss`.
- [ ] `:A` in `pkg/util/date.js` → `pkg/util/tests/date.test.js`, `:A` back, then `<C-^>` to switch fast.
- [ ] Set `mD` in `date.js` and `mE` in `etask.js`. Jump between them from any file with `` `D `` / `` `E ``.
- [ ] Type `pkg/util/date.js:139` in a scratch buffer (`<leader>bn`). Put the cursor on it and press `gF`.
- [ ] `<leader>fr` (recent files) and `<leader>,` (buffers): use them instead of the tree for one day.
- [ ] `<leader>fR`: run a grep, close it, open it again with the same results.

Self-test:
- [ ] Open a known file: < 3 s. Definition and back: < 2 s.
- [ ] Find all callers of a function and open the 3rd one: < 10 s.

---

## Week 4: Big edits — search and replace, cgn, macros, quickfix

**Habit: the third same change is automated** (`.`, `cgn`, a macro, `:s`, `:g`, quickfix).

Learn (cheatsheet sections 5, 7, 8, 13, 14): `*` + `cgn` + `.` + `n`; `:%s` with `\v` groups and the `c` flag;
`:s//new/`; `&` / `g&`; `:g` / `:v` / `:norm`; macros `qa … q`, `@a`, `@@`, `:'<,'>norm @a`; registers `"a` / `"A`;
`:cdo` / `:cfdo`; editing the quickfix window; grug-far; surround; block `<C-v>` + `I` / `A`; `g<C-a>`.
Read: `:h usr_10`, `:h usr_12`, `:h usr_26`, `:h usr_27`.

Drills (in `~/nvim-drill`; run `:Drill` first for a clean copy):
- [ ] `date.js` `ms_to_dur`: rename `_ms` to `ms_val` **only in this function**: `vaf` then `:s/_ms/ms_val/g`.
      Undo it, and do it again with `*` + `cgnms_val<Esc>` + `.`.
- [ ] In `ms_to_dur`, change each `var` to `let`: `/<var>` + `cgnlet<Esc>` + `.` … (use `n` to skip one).
- [ ] Surround: on `'January'`: `ysa'f`, type `t` + `<CR>` → `t('January')`; `cs'"`; `ds"`; `ysiw]`; `ds]`.
- [ ] Block edit: `<C-v>` on 5 lines, `I// <Esc>`; undo; `<C-v>` + `$` + `A;<Esc>`.
- [ ] Macro: list all exported functions in a new buffer:
      1. `:let @a = ''` (empty register `a`), then `:g/^E\.\w\+ = function/y A` (append each line to `a`;
         `:g` uses normal magic, not very magic).
      2. `:enew`, `"ap`, then `:v/\S/d` (delete the empty lines) and `gg`.
      3. On the first line: `qb0df.i- <Esc>f Djq` (makes `- ms_to_dur`).
      4. `100@b` (or `VG` + `:norm @b`). Result: a clean list.
- [ ] Multi-file rename: `<leader>/` `ms_to_dur` → `<A-a>` (select all) → `<C-q>` →
      `:cdo s/ms_to_dur/ms_to_duration/g | update`. Check it with `<leader>gd` (diffview), close with `<leader>gq`.
- [ ] Same rename again (after `:Drill`), but edit the lines directly in the quickfix window and `:w` (quicker).
- [ ] grug-far: `<leader>sr` on `var` → set the replace text to `let` → look at the preview → `<localleader>r` (`\r`) to apply.
- [ ] `:g/console.log/d`, `:v/\S/d` (delete empty lines), `:g/^E\./norm A // x`; undo each one.
- [ ] `:%s/(\w+)_(\w+)/\2_\1/gc` (`\v` is added for you after `%s/`): practice the confirm keys `y` `n` `a` `q`.

Self-test:
- [ ] Rename a variable in 5 places in one function: < 15 s.
- [ ] Make the same edit on 20 lines: < 30 s.

---

## Week 5: The zon workflow end to end

**Habit: review before every handoff:** `<leader>zM` (lint all modified files) + `<leader>zm` with `<C-d>` on each file.

Learn (cheatsheet sections 11, 12): `<leader>zm zd zD za zb zh zs`; `]h` / `[h`, `gHgh`, `<leader>go`;
live zlint, `<leader>zc zf zM`; `<leader>zt zT zr zB`; `<leader>zn`, snippets `zhdr etask zit ry`; `gq` at 79 columns.

Drills (real `~/zon1`):
- [ ] `<leader>za` in `pkg/util/date.js`: find who wrote `ms_to_dur`. Press `<CR>` to go to that revision,
      `^` to see the code before it, `<BS>` to come back, `K` for the message, `q` to close.
- [ ] `<leader>zh` in `pkg/util/etask.js`: read the diffs of the last 5 commits in the preview.
- [ ] `<leader>zb` on 5 lines in your modified files.
- [ ] `<leader>zm`: open each modified file's diff with `<C-d>`. In the diff tab: `]c` / `[c`, then `q`.
- [ ] In a modified file: walk the hunks with `]h` / `[h`; show them inline with `<leader>go`.
- [ ] `<leader>zs` in a folder you work in: are there server updates (`U`) or conflicts (`C`)?
- [ ] In `pkg/util/tests/date.test.js`: cursor in `it('ms_to_dur'` → `<leader>zT`; then `<leader>zr`; then `<leader>zt` (whole file).
- [ ] Lint practice: create `pkg/util/zz_drill.js`, `<leader>zn` (header), type code with errors (`"x"`,
      missing `;`, `var`). See the zlint diagnostics after `:w`, jump with `]d`, fix with `<leader>zf` + `:w`,
      check with `<leader>zc`. **Then delete it:** `:call delete(expand('%')) | bd!`.
- [ ] Snippets in the same temp file: `etask`, `ry`, `zit`, `zdescribe`, `xxx`; use `<Tab>` to move between fields.
- [ ] Do one real small task fully in Neovim with this loop:
      find (`<leader>/`, `gd`) → edit → `]h` review → `<leader>zT` test → `<leader>zM` lint →
      `<leader>zm` + `<C-d>` review → `<leader>zs` server check → handoff / commit in the terminal (`<C-/>`).

Self-test:
- [ ] Full review of all modified files + lint: < 2 min.
- [ ] "Who changed this line and why?": < 10 s.

---

## Week 6: LSP refactors, the fix loop, Rust, git

**Habit: the fix loop:** `]d` → read → `<leader>ca` or edit → `]d` … until the file is clean.

Learn (cheatsheet sections 10, 16, 17): `grn` / `<leader>cr`, `gra` / `<leader>ca`, `<leader>co cM cu`,
`<leader>cR`, `]d ]e <leader>cd <leader>sd <leader>sD`, `<leader>tv`, `<leader>th`; Rust `<leader>rr rt rT rm re rd ro`,
`K`, crates keys; git `]h ghgh gHgh <leader>gd gh gl gg`.

Drills:
- [ ] `~/nvim-drill/date.js`: rename `pad` to `zero_pad` with `grn`. Check every use changed (`grr`).
- [ ] `<leader>sD`: list the workspace diagnostics, open one, fix it, `]d` to the next one.
- [ ] `<leader>th` (inlay hints) and `<leader>tv` (diagnostic style): choose what you like.
- [ ] Rust: `cargo new /tmp/rdrill`, open `src/main.rs`. Write `let v = vec![1, 2, 3]; if v.len() == 0 {}`;
      after `:w` clippy shows a warning → `]d` → `<leader>ca` → apply the fix.
- [ ] Rust: write a `#[test]`, run it with `<leader>rt`, run again with `<leader>rT`; `<leader>rm` on `vec!`;
      `<leader>re` on an error; `K` on a std type, then `<leader>ro` (docs.rs).
- [ ] Rust: in `Cargo.toml` add `serde = "1"`; `<leader>rv` (versions), `<leader>rf` (features).
- [ ] Git (`~/nvim-drill` is a git repo): change 3 places, `]h`, stage one hunk with `ghgh`, reset another with `gHgh`,
      review with `<leader>gd`, commit with `<leader>gg` (lazygit: `c` commit, `q` quit).

Self-test:
- [ ] Rename a symbol across files: < 5 s.
- [ ] Fix all diagnostics in a file without the mouse.

---

## Week 7: Windows, tabs, sessions, terminal, folds, undo tree, command line

**Habit: one tab per task.** A task tab has its source, its test and a terminal. Close it when the task is done.

Learn (cheatsheet sections 9, 14, 15): `<C-w>v s o = x T H L`, `<C-h/j/k/l>`, `- = _ +`, `gt gT`,
`<leader>qs ql`, `<C-/>`, `za zM zR`, `<leader>tu`, `q:`, `@:`, `<C-r><C-w>`, `:r !cmd`, `:%!jq .`, `z= zg`.
Read: `:h usr_08`, `:h usr_20`, `:h usr_28`, `:h usr_32`.

Drills:
- [ ] Layout: `pkg/util/date.js`, `<C-w>v`, `:A` (test on the right), `<leader>zT` (test output at the bottom).
      Move with `<C-h/j/k/l>`, resize with `+` `_`, `<C-w>=` to equalize, `<C-w>o` to keep one window.
- [ ] Move a window to a new tab with `<C-w>T`, come back with `gT`.
- [ ] Undo tree: make 5 edits, undo 3, make a new edit. Use `<leader>tu` to go back to the "lost" edits.
- [ ] `q:`: edit an old command and run it. `@:` repeats the last command.
- [ ] `:r !date`, `:.!tr a-z A-Z`, a minified JSON + `:%!jq .`.
- [ ] Folds: `zM` in `date.js` (all closed), `za` to open one function, `zR` (all open).
- [ ] Session: open a layout, `:qa`, start `nvim` in the same folder, `<leader>qs`.

---

## Week 8 and later: Mastery

- [ ] Read one section a day: `:h usr_24`, `:h usr_25`, `:h usr_30`, then `:h motion.txt`, `:h change.txt`,
      `:h pattern.txt`, `:h quickfix.txt`.
- [ ] Book (optional): "Practical Vim" by Drew Neil — short tips that match weeks 2–4.
- [ ] Every week: add one keymap or setting for a pain you felt. Open the config with `<leader>fc`. Keymaps use
      `require('helpers.map').nmap(lhs, rhs, 'description')`, so they appear in which-key and `:Keymaps`. Commit it.
- [ ] Every month: `:Keymaps` — find keys you never use and delete them. Add your own tips to "My notes" at the end
      of `doc/cheatsheet.md`.
- [ ] Every month: update the plugins with `:lua vim.pack.update()` (read the list, `:w` to apply). If something
      breaks: `git checkout nvim-pack-lock.json` in `~/.config/nvim`, restart, then
      `:lua vim.pack.update(nil, { target = 'lockfile' })`.
- [ ] Learn to read the config: open one `plugin/*.lua` file a week and change one option.

---

## Things to unlearn

| Old habit | Do this instead |
|---|---|
| Arrow keys, mouse, holding `j`/`k` | counts (`7j`), `}`, `/`, leap `s`, `<C-d>` |
| `v` + many `l` + `d` | a text object: `diw`, `di(`, `dif` |
| `xxxxx` | `dw`, `dt,`, `D`, `ciw` |
| Retyping the same change | `.`, `cgn`, a macro |
| Opening the tree to find a file | `<leader><Space>`, `gd`, `<leader>fr` |
| Scrolling to find a function | `gO`, `<leader>ss`, `]f`, `/name` |
| Find-and-replace by hand in many files | `grn` (code symbols), quickfix + `:cdo`, grug-far |
| `:w` after every line | write when a step is done; `<leader>qw` writes all |
| Many open buffers / tabs you never close | `<leader>bo`, one tab per task, `<leader>qs` sessions |

---

## Weekly self-test scores

Time yourself. Write the time or "ok".

| Task | Target | W1 | W2 | W3 | W4 | W5 | W6 | W8 |
|---|---|---|---|---|---|---|---|---|
| Reach a visible place | ≤ 4 keys | | | | | | | |
| Change a string / argument at a visible place | ≤ 8 keys | | | | | | | |
| Open a known file | < 3 s | | | | | | | |
| Definition and back | < 2 s | | | | | | | |
| All callers, open the 3rd | < 10 s | | | | | | | |
| Rename a variable in one function (5 uses) | < 15 s | | | | | | | |
| Same edit on 20 lines | < 30 s | | | | | | | |
| Who changed this line and why (CVS) | < 10 s | | | | | | | |
| Review + lint all modified files | < 2 min | | | | | | | |

---

## Progress log

| Week | Started | Habit kept (1–5) | Hardest thing | Note |
|---|---|---|---|---|
| 0 | | | | |
| 1 | | | | |
| 2 | | | | |
| 3 | | | | |
| 4 | | | | |
| 5 | | | | |
| 6 | | | | |
| 7 | | | | |
| 8 | | | | |
