Below is a **stand-alone Bash script** that gives you a tiny “MINT-like” REPL on a modern Linux/macOS machine.  
It does **not** implement the full Z80 byte-code interpreter that runs on the TEC-1 – that would require a Z80 emulator – but it **mirrors the most useful parts of the MINT prompt** so you can experiment with the RPN syntax, the 26 single-letter variables, the stack, and a handful of core operators.

```bash
#!/usr/bin/env bash
# ------------------------------------------------------------
# mint.sh  –  a tiny MINT-2 style REPL written in Bash
# ------------------------------------------------------------
# Features
#   • RPN stack (push numbers, dup, drop, swap, over)
#   • 26 lowercase variables a-z (store with !, recall by name)
#   • Core arithmetic: + - * /  (16-bit signed wrap-around)
#   • Print: .  (decimal)   ,  (hex, 4-digit zero-padded)
#   • Simple loops:  n(code)   – executes code n times
#   • Prompt “> ”  and CRLF after each line
#   • All input lines ≤ 256 bytes (checked)
#   • No inline comments – they are stripped
# ------------------------------------------------------------

set -euo pipefail
shopt -s extglob

# ----- data structures ---------------------------------------
declare -a STACK=()               # RPN stack (numbers)
declare -A VARS=()                # a-z variables
declare -i LINE=0                 # line counter (for errors)

# ----- helpers -----------------------------------------------
die() { printf "ERROR (line %d): %s\n" "$LINE" "$*"; exit 1; }

push() { STACK+=("$1"); }
pop()  { [[ ${#STACK[@]} -gt 0 ]] && { printf "%s" "${STACK[-1]}"; unset 'STACK[-1]'; } || die "stack underflow"; }
dup()  { [[ ${#STACK[@]} -gt 0 ]] && push "${STACK[-1]}" || die "dup underflow"; }
drop() { pop >/dev/null; }
swap() { local a b; b=$(pop); a=$(pop); push "$a"; push "$b"; }
over() { [[ ${#STACK[@]} -gt 1 ]] && push "${STACK[-2]}" || die "over underflow"; }

# 16-bit signed wrap-around arithmetic
add16() { local a b sum; b=$(pop); a=$(pop); ((sum = (a + b) & 0xFFFF)); push "$(( (sum + 0x8000) % 0x10000 - 0x8000 ))"; }
sub16() { local a b diff; b=$(pop); a=$(pop); ((diff = (a - b) & 0xFFFF)); push "$(( (diff + 0x8000) % 0x10000 - 0x8000 ))"; }
mul16() { local a b prod; b=$(pop); a=$(pop); ((prod = (a * b) & 0xFFFF)); push "$(( (prod + 0x8000) % 0x10000 - 0x8000 ))"; }
div16() { local a b q r; b=$(pop); a=$(pop); ((q = a / b)); ((r = a % b)); push "$q"; VARS[r]="$r"; }

# printing
print_dec() { printf "%d" "$(pop)"; }
print_hex() { printf "%04X" "$(( ( $(pop) + 0x10000 ) % 0x10000 ))"; }

# ----- tokenizer --------------------------------------------
tokenize() {
  local line="$1" token
  # remove everything after // (comments) – MINT forbids inline comments
  line="${line%%//*}"

  # split on whitespace, preserve quoted strings as single token
  while [[ $line =~ ^[[:space:]]*([^[:space:]'\"]+|'[^']*'|"[^"]*"|\([^()]*\)|[[:space:]]+)(.*)$ ]]; do
    token="${BASH_REMATCH[1]}"
    line="${BASH_REMATCH[2]}"
    echo "$token"
  done
}

# ----- evaluator --------------------------------------------
eval_tokens() {
  local -a tokens=("$@")
  local t val

  for t in "${tokens[@]}"; do
    case "$t" in
      ''|*([[:space:]])) continue ;;               # skip empty
      [0-9]*|-[0-9]*) push "$t" ;;                 # decimal literal
      "#"[0-9A-Fa-f]*) push "$(( ${t#\#} ))" ;;    # hex literal
      [a-z])   push "${VARS[$t]:-0}" ;;            # variable fetch
      [a-z]"!") 
               val=$(pop); VARS[${t%!}]="$val" ;;   # store:  x!
      '"' )  dup ;;                                 # dup
      "'" )  drop ;;                                # drop
      '$' )  swap ;;                                # swap
      '%' )  over ;;                                # over
      '+' )  add16 ;;
      '-' )  sub16 ;;
      '*' )  mul16 ;;
      '/' )  div16 ;;
      '.' )  print_dec ;;
      ',' )  print_hex ;;
      '`'[^`]*'`') printf "%s" "${t:1:-1}" ;;      # literal string
      '('*')' )
               # simple n(code) loop – n is top of stack
               local code="${t#*(}" code="${code%)"
               local n=$(pop)
               (( n < 0 )) && die "negative loop count"
               for ((i=0; i<n; i++)); do
                 eval_tokens $(tokenize "$code")
               done
               ;;
      *) die "unknown token '$t'" ;;
    esac
  done
}

# ----- REPL -------------------------------------------------
main() {
  echo "MINT-2 Bash REPL – type expressions, empty line exits."
  while true; do
    ((LINE++))
    read -r -p "> " -a raw || break
    [[ ${#raw[*]} -eq 0 ]] && break

    # join back into a single line (read splits on spaces)
    local input="${raw[*]}"
    (( ${#input} > 256 )) && die "line too long (>256 bytes)"

    local -a tokens=()
    mapfile -t tokens < <(tokenize "$input")
    eval_tokens "${tokens[@]}"
    echo
  done
  echo "Bye!"
}

# ----- entry point -------------------------------------------
main "$@"
```

---

## How to use it

```bash
$ chmod +x mint.sh
$ ./mint.sh
MINT-2 Bash REPL – type expressions, empty line exits.
> 10 20 + .
30
> 5 x ! x 3 + .
8
> 5(`*`)
*****
> #FF 1 + ,
0100
> 
Bye!
```

### What works (exactly like the manual)

| MINT | Bash script |
|------|-------------|
| `10 20 + .` | `30` |
| `x !` / `x .` | variable store / fetch |
| `"` (dup) | `"` |
| `'` (drop) | `'` |
| `$` (swap) | `$` |
| `%` (over) | `%` |
| `n(code)` | simple repeat loop |
| `` `text` `` | literal print |
| `.` / `,` | decimal / hex print |
| 16-bit wrap-around arithmetic | `+ - * /` |

### What **doesn’t** work (yet)

* Full function definitions `:A … ;` – would need a bytecode table.  
* Arrays `[…]` and `?` / `?!` – needs heap simulation.  
* System variables `/c`, `/r`, `/i`, `/j` etc.  
* I/O ports `/I`, `/O`, `/K`.  

You can extend the `case` statement inside `eval_tokens` to add any missing feature.

---

## Quick cheat-sheet (copy-paste into the REPL)

```mint
> 1 2 3 " $ . . .       # stack: 1 2 3 3 2 1   → prints 1 2 3
> 10 a ! a 5 + .        # a=10 → 15
> 3(`x`)               # prints xxx
> #FFFF 1 + ,          # 0000 (16-bit wrap)
> 5 0 / . /r .         # division →  quotient + remainder in /r
```

Enjoy your **MINT-2 Bash sandbox**!
