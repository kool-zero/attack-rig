# windbg

Reference for crash triage + exploit dev. `<addr>` = address/expr, `L<n>` = length.

## symbols & setup

| Command | Does |
|---------|------|
| `.symfix c:\symbols` | point symbol path at the MS symbol server |
| `.sympath+ <dir>` | append a local symbol dir |
| `.reload /f` | force-reload all symbols now |
| `!sym noisy` | verbose symbol loading (debug "no symbols") |
| `.effmach x86` / `x64` | force the effective processor mode |

## execution control

| Command | Does |
|---------|------|
| `g` | go (run) · `Ctrl+Break` to break back in |
| `gu` | go up: run until the current function returns |
| `p` / `t` | step **over** / step **into** (one instruction) |
| `pa <addr>` / `ta <addr>` | step/trace until `<addr>` |
| `pt` | step to next `ret` |
| `wt` | watch-trace the current call (call graph + counts) |
| `.restart` / `q` | restart target / quit debugger |

## breakpoints

| Command | Does |
|---------|------|
| `bp <mod>!<func>` | breakpoint (e.g. `bp kernel32!WinExec`) |
| `bu <sym>` | **deferred** bp: arms when the module loads |
| `bm <mod>!pat*` | bp on every symbol matching the pattern |
| `ba <a> <size> <addr>` | **hardware** bp: `a` = `e`xec / `r`ead / `w`rite (e.g. `ba w 4 <addr>`) |
| `bp <addr> "<cmds>;g"` | scripted/conditional bp (runs cmds, keeps going) |
| `bl` / `bc *` | list / clear all · `bd <n>` disable · `be <n>` enable |

## stack & registers

| Command | Does |
|---------|------|
| `k` / `kb` / `kp` | call stack · `kb` with 3 args · `kp` full params |
| `kv` / `kn` | with frame/FPO info · with frame numbers |
| `~` / `~*k` | list threads / stack of **every** thread |
| `~<n>s` | switch to thread N |
| `.frame <n>` / `dv` | select stack frame N / dump its local variables |
| `r` | dump registers · `r eax=0` set one · `r $ip` show one |
| `!teb` / `!peb` | thread / process environment block |

## examine memory

| Command | Does |
|---------|------|
| `db` `dw` `dd` `dq` | dump bytes / words / dwords / qwords |
| `dp` / `dps` / `dds` | pointer-sized · **with symbol resolution** (great for stacks & vtables) |
| `da` / `du` | ASCII / Unicode string at `<addr>` |
| `dt <mod>!_TYPE <addr>` | display a struct (e.g. `dt nt!_PEB @$peb`) |
| `poi(<addr>)` | dereference a pointer inside an expression |
| `!address <addr>` | describe the memory region (base, size, protect, type) |

## edit / dump memory

| Command | Does |
|---------|------|
| `eb` `ew` `ed` `eq` | write bytes / words / dwords / qwords |
| `ea` / `eu` | write an ASCII / Unicode string |
| `.writemem <file> <addr> L<n>` | dump a range to disk |
| `.readmem <file> <addr>` | load a file into memory |

## search memory

| Command | Does |
|---------|------|
| `s -a <start> L?<len> "str"` | find an **ASCII** string (`s -u` for Unicode) |
| `s -b <start> L?<len> <b1> <b2>` | find a **byte** pattern |
| `s -d <start> L?<len> <dword>` | find a **dword** (e.g. an address) |

## exceptions & crash triage

| Command | Does |
|---------|------|
| `!analyze -v` | verbose automatic crash analysis: **start here** |
| `.exr -1` | display the last exception record |
| `.ecxr` | switch context to the exception that fired |
| `.lastevent` | what stopped the target |
| `sxe av` / `sxe ld:<mod>` | **break on** access violation / module load (`sxd` to disable) |

## exploit-dev helpers

| Command | Does |
|---------|------|
| `!exchain` | walk the SEH chain (32-bit): find the overwritten handler |
| `!teb` | TEB → stack base/limit, SEH head |
| `s -a <start> L?<len> "Aa0A"` | locate a cyclic (msf) pattern to get the offset |
| `!heap -p -a <addr>` | page-heap info for a block (`!gflags +hpa` to enable) |
| `? <expr>` / `?? <C++>` | evaluate an expression / a C++ expression |
| `.formats <val>` | show a value in hex/dec/bin/ascii/time |
| `bp <addr> ".printf \"hit %x\\n\", @eax; g"` | logging breakpoint (no stop) |

## kernel quickies

| Command | Does |
|---------|------|
| `!process 0 0` | list all processes · `!process <addr> 7` full detail |
| `!thread <addr>` | thread details |
| `.bugcheck` / `!analyze -v` | bugcheck code / full BSOD analysis |
| `!drvobj <driver> 7` | driver object + dispatch table |
| `!idt` / `!pcr` | interrupt descriptor table / processor control region |
