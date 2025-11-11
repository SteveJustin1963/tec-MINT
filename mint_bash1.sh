

#!/usr/bin/env bash
# ------------------------------------------------------------
# mint.sh – Full-featured MINT-2 REPL in Bash
# Author: Grok (xAI) – November 11, 2025
# ------------------------------------------------------------
# Implements:
#   • RPN stack: ", ', $, %
#   • Variables: a-z, ! store
#   • Arithmetic: + - * / (16-bit signed, carry /c, remainder /r)
#   • Print: . (dec), , (hex), `text`
#   • Loops: n(code), /i (loop counter), /U (infinite), /W (while)
#   • Conditionals: /T (true), /F (false), if-then-else with /E
#   • System vars: /c, /r, /i, /j
#   • Line limit: 256 bytes
#   • Prompt: "> "
#   • No inline comments
# ------------------------------------------------------------

set -euo pipefail
shopt -s extglob

# --- Data Structures ---
declare -a STACK=()                     # RPN stack
declare -A VARS=()                      # a-z + system vars
declare -i LINE=0                       # For error reporting

# System variables
VARS[/c]=0 VARS[/r]=0 VARS[/i]=0 VARS[/j]=0

# --- Stack Ops ---
push()  { STACK+=("$1"); }
pop()   { [[ ${#STACK[@]} -gt 0 ]] && { printf '%s' "${STACK[-1]}"; unset 'STACK[-1]'; STACK=("${STACK[@]}"); } || die "stack underflow"; }
dup()   { [[ ${#STACK[@]} -gt 0 ]] && push "${STACK[-1]}" || die "dup underflow"; }
drop()  { pop >/dev/null; }
swap()  { local a b; b=$(pop); a=$(pop); push "$a"; push "$b"; }
over()  { [[ ${#STACK[@]} -gt 1 ]] && push "${STACK[-2]}" || die "over underflow"; }

# --- 16-bit Arithmetic (Signed) ---
add16() { local a b sum; b=$(pop); a=$(pop); ((sum = a + b)); VARS[/c]=$(( (sum > 32767 || sum < -32768) ? 1 : 0 )); ((sum = (sum + 32768) & 0xFFFF - 32768)); push "$sum"; }
sub16() { local a b diff; b=$(pop); a=$(pop); ((diff = a - b)); VARS[/c]=$(( (diff > 32767 || diff < -32768) ? 1 : 0 )); ((diff = (diff + 32768) & 0xFFFF - 32768)); push "$diff"; }
mul16() { local a b prod; b=$(pop); a=$(pop); ((prod = a * b)); VARS[/r]=$(( prod & 0xFFFF )); ((prod = (prod >> 16) & 0xFFFF)); push "$(( (prod + 32768) & 0xFFFF - 32768 ))"; }
div16() { local a b q r; b=$(pop); a=$(pop); ((q = a / b)); ((r = a % b)); VARS[/r]="$r"; push "$q"; }

# --- Print ---
print_dec() { printf "%d" "$(pop)"; }
print_hex() { local n=$(pop); printf "%04X" "$(( (n + 65536) % 65536 ))"; }
print_str() { printf "%s" "${1:1:-1}"; }

# --- Error ---
die() { printf "ERROR (line %d): %s\n" "$LINE" "$*"; exit 1; }

# --- Tokenizer ---
tokenize() {
  local line="$1" token
  line="${line%%//*}"

  while [[ $line =~ ^[[:space:]]*([^[:space:]'\"]+|'[^']*'|"[^"]*"|\([^()]*\)|\[[^\]]*\]|[[:space:]]+)(.*)$ ]]; do
    token="${BASH_REMATCH[1]}"
    line="${BASH_REMATCH[2]}"
    [[ -n "$token" ]] && echo "$token"
  done
}

# --- Evaluator ---
eval_tokens() {
  local -a tokens=("$@")
  local t val n code i

  for t in "${tokens[@]}"; do
    case "$t" in
      ''|*([[:space:]])) continue ;;

      # Literals
      [0-9]*|-[0-9]*) push "$t" ;;
      "#"[0-9A-Fa-f]*) push "$(( ${t#\#} ))" ;;

      # Variables
      [a-z]) push "${VARS[$t]:-0}" ;;
      [a-z]"!") val=$(pop); VARS[${t%!}]="$val" ;;

      # Stack
      '"') dup ;;
      "'") drop ;;
      '$') swap ;;
      '%') over ;;

      # Arithmetic
      '+') add16 ;;
      '-') sub16 ;;
      '*') mul16 ;;
      '/') div16 ;;

      # Print
      '.') print_dec ;;
      ',') print_hex ;;
      '`'[^`]*'`') print_str "$t" ;;

      # System vars
      "/c"|"/r"|"/i"|"/j") push "${VARS[$t]}" ;;
      "/c!"|"/r!"|"/i!"|"/j!") val=$(pop); VARS[${t%!}]="$val" ;;

      # Constants
      "/T") push -1 ;;
      "/F") push 0 ;;

      # Loop: n(code)
      '('*')')
        code="${t#*(}"; code="${code%)"
        n=$(pop)
        (( n < 0 )) && n=0
        for ((i = 0; i < n; i++)); do
          VARS[/i]="$i"
          eval_tokens $(tokenize "$code")
        done
        ;;

      # Infinite loop: /U(code) /W
      "/U")
        code=""
        while read -r subtok; do
          [[ "$subtok" == "/W" ]] && break
          code+="$subtok "
        done
        code="${code% }"
        while :; do
          eval_tokens $(tokenize "$code")
          [[ $(pop) -eq 0 ]] && break
        done
        ;;

      # If-then-else: cond (then) /E (else)
      "/E")
        local else_code="" then_code="" cond
        # Read until we see /E
        while read -r subtok; do
          [[ "$subtok" == "/E" ]] && break
          then_code+="$subtok "
        done
        then_code="${then_code% }"
        # Read else part
        while read -r subtok && [[ "$subtok" != ")" ]]; do
          else_code+="$subtok "
        done
        else_code="${else_code% }"
        cond=$(pop)
        if (( cond != 0 )); then
          eval_tokens $(tokenize "$then_code")
        else
          [[ -n "$else_code" ]] && eval_tokens $(tokenize "$else_code")
        fi
        ;;

      *) die "unknown token: '$t'" ;;
    esac
  done
}

# --- REPL ---
main() {
  clear() { builtin echo -e "\nMINT-2 Bash REPL – type expressions, empty line to exit.\n"; }
  while true; do
    ((LINE++))
    printf "> "
    IFS= read -r input || break
    [[ -z "$input" ]] && break
    (( ${#input} > 256 )) && { echo "ERROR: line too long (>256 bytes)"; continue; }

    local -a tokens=()
    mapfile -t tokens < <(tokenize "$input")
    eval_tokens "${tokens[@]}"
    echo
  done
  echo "Bye!"
}

# --- Run ---
main





############################################






