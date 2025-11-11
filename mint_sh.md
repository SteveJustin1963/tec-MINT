
```
#!/usr/bin/env bash
# mint.sh — Minimal MINT-like 16-bit RPN interpreter (fixed stack + vars a..z)

shopt -s extglob

# --- State ----------------------------------------------------------
declare -a ST                 # stack storage
SP=0                          # stack pointer
declare -A VAR                # variables and system flags
for c in {a..z}; do VAR["$c"]=0; done
VAR["/c"]=0
VAR["/r"]=0

# --- Helpers --------------------------------------------------------
mask16(){ echo $(( $1 & 0xFFFF )); }
tos16(){ local v=$(mask16 "$1"); (( v & 0x8000 )) && echo $(( v - 0x10000 )) || echo $v; }
print_dec(){ printf "%d" "$(tos16 "$1")"; }
print_hex(){ printf "%04X" "$(( $1 & 0xFFFF ))"; }
emit_char(){ local v=$(( $1 & 0xFF )); printf "\\$(printf '%03o' "$v")"; }

# --- Stack ops (SP-based, robust) ----------------------------------
push(){ ST[$SP]="$1"; ((SP++)); }

pop(){
  if (( SP == 0 )); then
    echo "STACK UNDERFLOW" >&2
    return 1
  fi
  ((SP--))
  local val="${ST[$SP]}"
  ST=("${ST[@]:0:$SP}")   # shrink array properly
  echo "$val"
}

peek(){
  if (( SP == 0 )); then echo 0; else echo "${ST[$((SP-1))]}"; fi
}

op_drop(){ pop >/dev/null || true; }
op_dup (){ local a=$(peek); push "$a"; }
op_swap(){ local b=$(pop) a=$(pop) || return; push "$b"; push "$a"; }
op_over(){
  if (( SP < 2 )); then echo "STACK UNDERFLOW" >&2; return; fi
  push "${ST[$((SP-2))]}"
}

# --- Arithmetic -----------------------------------------------------
op_add(){ local b=$(pop) a=$(pop) || return
  local res=$(( (a+b) & 0xFFFF ))
  VAR["/c"]=$(( ((a&0xFFFF)+(b&0xFFFF))>0xFFFF ? 1:0 ))
  VAR["/r"]=0
  push "$res"
}
op_sub(){ local b=$(pop) a=$(pop) || return
  VAR["/c"]=$(( (a&0xFFFF)<(b&0xFFFF)?1:0 ))
  VAR["/r"]=0
  push $(( (a-b) & 0xFFFF ))
}
op_mul(){ local b=$(pop) a=$(pop) || return
  local prod=$(( (a&0xFFFF)*(b&0xFFFF) ))
  VAR["/r"]=$(( (prod>>16)&0xFFFF ))
  push $(( prod & 0xFFFF ))
}
op_div(){ local b=$(tos16 "$(pop)") a=$(tos16 "$(pop)") || return
  if (( b == 0 )); then echo "DIV0" >&2; push 0; VAR["/r"]=0; return; fi
  local q=$(( a / b ))
  local r=$(( a % b ))
  VAR["/r"]=$(mask16 "$r")
  push "$(mask16 "$q")"
}

# --- Bitwise / Logical ----------------------------------------------
op_and(){ local b=$(pop) a=$(pop) || return; push $(( (a&b) & 0xFFFF )); }
op_or (){ local b=$(pop) a=$(pop) || return; push $(( (a|b) & 0xFFFF )); }
op_xor(){ local b=$(pop) a=$(pop) || return; push $(( (a^b) & 0xFFFF )); }
op_not(){ local a=$(pop) || return; push $(( (~a) & 0xFFFF )); }
op_shl(){ local a=$(pop) || return; push $(( (a<<1) & 0xFFFF )); }
op_shr(){ local a=$(pop) || return; push $(( (a&0xFFFF) >> 1 )); }

# --- Token Evaluator ------------------------------------------------
eval_token(){
  local t="$1"
  [[ -z "$t" ]] && return

  # String literal
  if [[ "$t" == \`*\` ]]; then printf "%s" "${t:1:${#t}-2}"; return; fi

  # Numbers
  if [[ "$t" == \#* ]]; then push $(( 16#${t:1} )); return; fi
  if [[ "$t" =~ ^-?[0-9]+$ ]]; then push "$(mask16 "$t")"; return; fi

  # Booleans / specials
  case "$t" in
    /F) push 0; return ;;
    /T) push $((0xFFFF)); return ;;
    /N) printf '\n'; return ;;
    /C) local v=$(pop)||return; emit_char "$v"; return ;;
  esac

  # Variables
  if [[ "$t" =~ ^[a-z]$ ]]; then push "${VAR[$t]}"; return; fi
  if [[ "$t" =~ ^[a-z]\!$ ]]; then
    local name="${t:0:1}"; local val=$(pop)||return
    VAR["$name"]=$(mask16 "$val"); return
  fi

  # System vars
  if [[ "$t" == "/c" || "$t" == "/r" ]]; then push "${VAR[$t]}"; return; fi
  if [[ "$t" == "/c!" || "$t" == "/r!" ]]; then
    local v=$(pop)||return; VAR["${t%!}"]=$(mask16 "$v"); return
  fi

  # Operators
  case "$t" in
    +) op_add; return ;;
    -) op_sub; return ;;
    \*) op_mul; return ;;
    /) op_div; return ;;
    =) local b=$(pop) a=$(pop)||return; push $(( (a==b) ? 0xFFFF : 0 )); return ;;
    '&') op_and; return ;;
    '|') op_or; return ;;
    '^') op_xor; return ;;
    '~') op_not; return ;;
    '{') op_shl; return ;;
    '}') op_shr; return ;;
    "'") op_drop; return ;;
    '"') op_dup; return ;;
    '$') op_swap; return ;;
    '%') op_over; return ;;
    .)  local v=$(pop)||return; print_dec "$v"; printf '\n'; return ;;
    ,)  local v=$(pop)||return; print_hex "$v"; printf '\n'; return ;;
  esac

  echo "UNKNOWN TOKEN: $t" >&2
}

# --- Tokenizer ------------------------------------------------------
read_tokens(){
  local line="$1"
  line="${line%%//*}"   # remove // comments
  local -a toks=()
  local i=0 len=${#line}
  while (( i < len )); do
    local c=${line:i:1}
    if [[ "$c" =~ [[:space:]] ]]; then ((i++)); continue; fi
    if [[ "$c" == "\`" ]]; then
      local j=$((i+1)); local buf=""
      while (( j < len )); do
        local d=${line:j:1}
        [[ "$d" == "\`" ]] && break
        buf+="$d"; ((j++))
      done
      toks+=("`$buf`"); i=$((j+1)); continue
    fi
    local j=$i
    while (( j < len )) && ! [[ "${line:j:1}" =~ [[:space:]] ]]; do ((j++)); done
    toks+=("${line:i:j-i}")
    i=$j
  done
  printf '%s\0' "${toks[@]}"
}

# --- REPL -----------------------------------------------------------
echo "MINT(bash) — 16-bit RPN (fixed stack), vars a..z.  Ctrl+C to exit."
while true; do
  printf "> "
  IFS= read -r LINE || exit 0
  (( ${#LINE} > 256 )) && { echo "LINE TOO LONG"; continue; }
  mapfile -d '' TOKS < <(read_tokens "$LINE")
  for t in "${TOKS[@]}"; do eval_token "$t"; done
done


```






```
#!/usr/bin/env bash
# mint.sh — Minimal MINT-like 16-bit RPN interpreter (fixed stack, a..z vars)

shopt -s extglob

# --- State ----------------------------------------------------------
declare -a ST                 # data stack storage
SP=0                          # stack pointer (number of items on stack)
declare -A VAR                # variables a..z and system flags
for c in {a..z}; do VAR["$c"]=0; done
VAR["/c"]=0                   # carry / borrow
VAR["/r"]=0                   # remainder / overflow

# --- Helpers --------------------------------------------------------
mask16(){ echo $(( $1 & 0xFFFF )); }
tos16(){ local v=$(mask16 "$1"); (( v & 0x8000 )) && echo $(( v - 0x10000 )) || echo $v; }
print_dec(){ printf "%d" "$(tos16 "$1")"; }
print_hex(){ printf "%04X" "$(( $1 & 0xFFFF ))"; }
emit_char(){ local v=$(( $1 & 0xFF )); printf "\\$(printf '%03o' "$v")"; }

# --- Stack ops (SP-based, robust) ----------------------------------
push(){ ST[$SP]="$1"; ((SP++)); }
pop(){
  if (( SP == 0 )); then echo "STACK UNDERFLOW" >&2; return 1; fi
  ((SP--))
  echo "${ST[$SP]}"
  unset 'ST[$SP]'
}
peek(){
  if (( SP == 0 )); then echo 0; else echo "${ST[$((SP-1))]}"; fi
}

op_drop(){ pop >/dev/null || true; }
op_dup (){ local a=$(peek); push "$a"; }
op_swap(){ local b=$(pop) a=$(pop) || return; push "$b"; push "$a"; }
op_over(){
  if (( SP < 2 )); then echo "STACK UNDERFLOW" >&2; return; fi
  push "${ST[$((SP-2))]}"
}

# --- Arithmetic -----------------------------------------------------
op_add(){ local b=$(pop) a=$(pop) || return
  local res=$(( (a+b) & 0xFFFF ))
  VAR["/c"]=$(( ((a&0xFFFF)+(b&0xFFFF))>0xFFFF ? 1:0 ))
  VAR["/r"]=0
  push "$res"
}
op_sub(){ local b=$(pop) a=$(pop) || return
  VAR["/c"]=$(( (a&0xFFFF)<(b&0xFFFF)?1:0 ))
  VAR["/r"]=0
  push $(( (a-b) & 0xFFFF ))
}
op_mul(){ local b=$(pop) a=$(pop) || return
  local prod=$(( (a&0xFFFF)*(b&0xFFFF) ))
  VAR["/r"]=$(( (prod>>16)&0xFFFF ))
  push $(( prod & 0xFFFF ))
}
op_div(){ local b=$(tos16 "$(pop)") a=$(tos16 "$(pop)") || return
  if (( b == 0 )); then echo "DIV0" >&2; push 0; VAR["/r"]=0; return; fi
  local q=$(( a / b ))
  local r=$(( a % b ))
  VAR["/r"]=$(mask16 "$r")
  push "$(mask16 "$q")"
}

# --- Bitwise / Logical ----------------------------------------------
op_and(){ local b=$(pop) a=$(pop) || return; push $(( (a&b) & 0xFFFF )); }
op_or (){ local b=$(pop) a=$(pop) || return; push $(( (a|b) & 0xFFFF )); }
op_xor(){ local b=$(pop) a=$(pop) || return; push $(( (a^b) & 0xFFFF )); }
op_not(){ local a=$(pop) || return; push $(( (~a) & 0xFFFF )); }
op_shl(){ local a=$(pop) || return; push $(( (a<<1) & 0xFFFF )); }
op_shr(){ local a=$(pop) || return; push $(( (a&0xFFFF) >> 1 )); }

# --- Evaluator ------------------------------------------------------
eval_token(){
  local t="$1"
  [[ -z "$t" ]] && return

  # String literal
  if [[ "$t" == \`*\` ]]; then printf "%s" "${t:1:${#t}-2}"; return; fi

  # Numbers
  if [[ "$t" == \#* ]]; then push $(( 16#${t:1} )); return; fi
  if [[ "$t" =~ ^-?[0-9]+$ ]]; then push "$(mask16 "$t")"; return; fi

  # Booleans / specials
  case "$t" in
    /F) push 0; return ;;
    /T) push $((0xFFFF)); return ;;
    /N) printf '\n'; return ;;
    /C) local v=$(pop)||return; emit_char "$v"; return ;;
  esac

  # Variables
  if [[ "$t" =~ ^[a-z]$ ]]; then push "${VAR[$t]}"; return; fi
  if [[ "$t" =~ ^[a-z]\!$ ]]; then
    local name="${t:0:1}"; local val=$(pop)||return
    VAR["$name"]=$(mask16 "$val"); return
  fi

  # System vars
  if [[ "$t" == "/c" || "$t" == "/r" ]]; then push "${VAR[$t]}"; return; fi
  if [[ "$t" == "/c!" || "$t" == "/r!" ]]; then
    local v=$(pop)||return; VAR["${t%!}"]=$(mask16 "$v"); return
  fi

  # Operators
  case "$t" in
    +) op_add; return ;;
    -) op_sub; return ;;
    \*) op_mul; return ;;
    /) op_div; return ;;
    =) local b=$(pop) a=$(pop)||return
       push $(( (a==b) ? 0xFFFF : 0 )); return ;;
    '&') op_and; return ;;
    '|') op_or; return ;;
    '^') op_xor; return ;;
    '~') op_not; return ;;
    '{') op_shl; return ;;
    '}') op_shr; return ;;
    "'") op_drop; return ;;
    '"') op_dup; return ;;
    '$') op_swap; return ;;
    '%') op_over; return ;;
    .)  local v=$(pop)||return; print_dec "$v"; printf '\n'; return ;;
    ,)  local v=$(pop)||return; print_hex "$v"; printf '\n'; return ;;
  esac

  echo "UNKNOWN TOKEN: $t" >&2
}

# --- Tokenizer ------------------------------------------------------
read_tokens(){
  local line="$1"
  line="${line%%//*}"   # strip // comments
  local -a toks=()
  local i=0 len=${#line}
  while (( i < len )); do
    local c=${line:i:1}
    if [[ "$c" =~ [[:space:]] ]]; then ((i++)); continue; fi
    if [[ "$c" == "\`" ]]; then
      local j=$((i+1)); local buf=""
      while (( j < len )); do
        local d=${line:j:1}
        [[ "$d" == "\`" ]] && break
        buf+="$d"; ((j++))
      done
      toks+=("`$buf`"); i=$((j+1)); continue
    fi
    local j=$i
    while (( j < len )) && ! [[ "${line:j:1}" =~ [[:space:]] ]]; do ((j++)); done
    toks+=("${line:i:j-i}")
    i=$j
  done
  printf '%s\0' "${toks[@]}"
}

# --- REPL -----------------------------------------------------------
echo "MINT(bash) — 16-bit RPN (fixed stack), vars a..z.  Ctrl+C to exit."
while true; do
  printf "> "
  IFS= read -r LINE || exit 0
  (( ${#LINE} > 256 )) && { echo "LINE TOO LONG"; continue; }
  mapfile -d '' TOKS < <(read_tokens "$LINE")
  for t in "${TOKS[@]}"; do eval_token "$t"; done
done

```





```
#!/usr/bin/env bash
# mint.sh — Minimal MINT-like 16-bit RPN interpreter (now with a..z variables)

shopt -s extglob

# --- State ----------------------------------------------------------
declare -a ST=()                 # Data stack
declare -A VAR                   # a..z variables
for c in {a..z}; do VAR["$c"]=0; done
VAR["/c"]=0                      # Carry / borrow
VAR["/r"]=0                      # Remainder / overflow

mask16(){ echo $(( $1 & 0xFFFF )); }
tos16(){ local v=$(mask16 "$1"); ((v&0x8000)) && echo $((v-0x10000)) || echo $v; }

push(){ ST+=("$1"); }
pop(){ local n=${#ST[@]}; ((n==0)) && { echo "STACK UNDERFLOW" >&2; return 1; }
       echo "${ST[$((n-1))]}"; unset 'ST[$((n-1))]'; }
peek(){ local n=${#ST[@]}; ((n==0)) && echo 0 || echo "${ST[$((n-1))]}"; }

print_dec(){ printf "%d" "$(tos16 "$1")"; }
print_hex(){ printf "%04X" "$(( $1 & 0xFFFF ))"; }
emit_char(){ local v=$(( $1 & 0xFF )); printf "\\$(printf '%03o' "$v")"; }

# --- Arithmetic -----------------------------------------------------
op_add(){ local b=$(pop) a=$(pop) || return
           local res=$(( (a+b) & 0xFFFF ))
           VAR["/c"]=$(( ((a&0xFFFF)+(b&0xFFFF))>0xFFFF ? 1:0 ))
           VAR["/r"]=0; push "$res"; }
op_sub(){ local b=$(pop) a=$(pop) || return
           VAR["/c"]=$(( (a&0xFFFF)<(b&0xFFFF)?1:0 ))
           push $(( (a-b)&0xFFFF )); VAR["/r"]=0; }
op_mul(){ local b=$(pop) a=$(pop) || return
           local prod=$(( (a&0xFFFF)*(b&0xFFFF) ))
           VAR["/r"]=$(( (prod>>16)&0xFFFF )); push $((prod&0xFFFF)); }
op_div(){ local b=$(tos16 "$(pop)") a=$(tos16 "$(pop)") || return
           ((b==0)) && { echo "DIV0" >&2; push 0; VAR["/r"]=0; return; }
           local q=$((a/b)); local r=$((a%b))
           VAR["/r"]=$(mask16 "$r"); push "$(mask16 "$q")"; }

# --- Bitwise / Logical ----------------------------------------------
op_and(){ local b=$(pop) a=$(pop) || return; push $(( (a&b)&0xFFFF )); }
op_or (){ local b=$(pop) a=$(pop) || return; push $(( (a|b)&0xFFFF )); }
op_xor(){ local b=$(pop) a=$(pop) || return; push $(( (a^b)&0xFFFF )); }
op_not(){ local a=$(pop) || return; push $(( (~a)&0xFFFF )); }
op_shl(){ local a=$(pop) || return; push $(( (a<<1)&0xFFFF )); }
op_shr(){ local a=$(pop) || return; push $(( (a&0xFFFF)>>1 )); }

# --- Stack ops ------------------------------------------------------
op_drop(){ pop >/dev/null || true; }
op_dup (){ local a=$(peek); push "$a"; }
op_swap(){ local b=$(pop) a=$(pop) || return; push "$b"; push "$a"; }
op_over(){ local n=${#ST[@]}; ((n<2)) && { echo "UNDERFLOW" >&2; return; }
           push "${ST[$((n-2))]}"; }

# --- Token evaluator ------------------------------------------------
eval_token(){
  local t="$1"
  [[ -z "$t" ]] && return

  # String literal
  if [[ "$t" == \`*\` ]]; then printf "%s" "${t:1:${#t}-2}"; return; fi

  # Numbers (#HEX or decimal)
  if [[ "$t" == \#* ]]; then push $((16#${t:1})); return; fi
  if [[ "$t" =~ ^-?[0-9]+$ ]]; then push "$(mask16 "$t")"; return; fi

  # Booleans / specials
  case "$t" in
    /F) push 0; return ;;
    /T) push $((0xFFFF)); return ;;
    /N) printf '\n'; return ;;
    /C) local v=$(pop)||return; emit_char "$v"; return ;;
  esac

  # Variable fetch
  if [[ "$t" =~ ^[a-z]$ ]]; then push "${VAR[$t]}"; return; fi

  # Variable store (a!)
  if [[ "$t" =~ ^[a-z]\!$ ]]; then
    local name="${t:0:1}"; local val=$(pop)||return
    VAR["$name"]=$(mask16 "$val"); return
  fi

  # System vars /c /r fetch
  if [[ "$t" == "/c" || "$t" == "/r" ]]; then push "${VAR[$t]}"; return; fi
  # System vars store (/c! /r!)
  if [[ "$t" == "/c!" || "$t" == "/r!" ]]; then
    local v=$(pop)||return; VAR["${t%!}"]=$(mask16 "$v"); return
  fi

  # Core operators
  case "$t" in
    +) op_add; return ;;
    -) op_sub; return ;;
    \*) op_mul; return ;;
    /) op_div; return ;;
    =) local b=$(pop) a=$(pop)||return
       push $(( (a==b) ? 0xFFFF : 0 )); return ;;
    '&') op_and; return ;;
    '|') op_or; return ;;
    '^') op_xor; return ;;
    '~') op_not; return ;;
    '{') op_shl; return ;;
    '}') op_shr; return ;;
    "'") op_drop; return ;;
    '"') op_dup; return ;;
    '$') op_swap; return ;;
    '%') op_over; return ;;
    .)  local v=$(pop)||return; print_dec "$v"; printf '\n'; return ;;
    ,)  local v=$(pop)||return; print_hex "$v"; printf '\n'; return ;;
    //*) return ;; # ignore comment lines
  esac

  echo "UNKNOWN TOKEN: $t" >&2
}

# --- Tokenizer ------------------------------------------------------
read_tokens(){
  local line="$1"
  line="${line%%//*}"   # remove inline comment
  local -a toks=()
  local i=0 len=${#line}
  while ((i<len)); do
    local c=${line:i:1}
    if [[ "$c" =~ [[:space:]] ]]; then ((i++)); continue; fi
    if [[ "$c" == "\`" ]]; then
      local j=$((i+1)); local buf=""
      while ((j<len)); do
        local d=${line:j:1}
        [[ "$d" == "\`" ]] && break
        buf+="$d"; ((j++))
      done
      toks+=("`$buf`"); i=$((j+1)); continue
    fi
    local j=$i; while ((j<len)) && ! [[ "${line:j:1}" =~ [[:space:]] ]]; do ((j++)); done
    toks+=("${line:i:j-i}"); i=$j
  done
  printf '%s\0' "${toks[@]}"
}

# --- REPL -----------------------------------------------------------
echo "MINT(bash) — 16-bit RPN with variables a..z.  Ctrl+C to exit."
while true; do
  printf "> "
  IFS= read -r LINE || exit 0
  (( ${#LINE} > 256 )) && { echo "LINE TOO LONG"; continue; }
  mapfile -d '' TOKS < <(read_tokens "$LINE")
  for t in "${TOKS[@]}"; do eval_token "$t"; done
done

```






```
#!/usr/bin/env bash
# mint.sh — minimal MINT-like interpreter in Bash (16-bit, RPN)
# Features: numbers (dec, #HEX), + - * /, & | ^ { } ~, . ,  `text`  /N /C /F /T
# Stack ops: ' (drop), " (dup), $ (swap), % (over)
# Vars: a..z get; "n a !" stores n into var a. System vars: /c, /r
# Comments: // to end of line. Prompt: "> "

shopt -s extglob

# --- state ---
declare -a ST=()           # data stack (bash integers)
declare -A VAR=()          # variables a..z and /c /r
VAR["/c"]=0
VAR["/r"]=0

mask16(){ echo $(( $1 & 0xFFFF )); }
tos16(){ local v; v=$(mask16 "$1"); # sign-extend 16->64 for display math
  if (( v & 0x8000 )); then echo $(( v - 0x10000 )); else echo $v; fi
}

push(){ ST+=("$1"); }
pop(){ local n=${#ST[@]}; (( n==0 )) && echo "STACK UNDERFLOW" >&2 && return 1
       echo "${ST[$((n-1))]}"; unset 'ST[$((n-1))]'; }
peek(){ local n=${#ST[@]}; (( n==0 )) && echo 0 || echo "${ST[$((n-1))]}"; }

print_dec(){ printf "%d" "$(tos16 "$1")"; }
print_hex(){ printf "%04X" "$(( $1 & 0xFFFF ))"; }

is_var(){ [[ "$1" =~ ^[a-z]$ ]]; }
is_sys(){ [[ "$1" == "/c" || "$1" == "/r" ]]; }

# --- arithmetic helpers (set /c and /r like the manual where sensible) ---
op_add(){ # a b -> a+b ; set /c if unsigned carry
  local b=$(pop) a=$(pop) || return
  local res=$(( (a + b) & 0xFFFF ))
  local carry=$(( (a & 0xFFFF) + (b & 0xFFFF) > 0xFFFF ? 1 : 0 ))
  VAR["/c"]=$carry
  VAR["/r"]=0
  push "$res"
}
op_sub(){
  local b=$(pop) a=$(pop) || return
  local ua=$((a & 0xFFFF)); local ub=$((b & 0xFFFF))
  local borrow=$(( ua < ub ? 1 : 0 ))
  local res=$(( (ua - ub) & 0xFFFF ))
  VAR["/c"]=$borrow  # treat as "carry/borrow" indicator
  VAR["/r"]=0
  push "$res"
}
op_mul(){ # 8x8 per spec would be tight; we do 16x16 but only keep low, /r = overflow count (rollovers)
  local b=$(pop) a=$(pop) || return
  local prod=$(( (a & 0xFFFF) * (b & 0xFFFF) ))
  local lo=$(( prod & 0xFFFF ))
  local hi=$(( (prod >> 16) & 0xFFFF ))
  VAR["/r"]=$hi
  VAR["/c"]=0
  push "$lo"
}
op_div(){ # a b -> a/b ; /r = remainder (Euclidean on signed a,b coerced to 16-bit signed)
  local b=$(tos16 "$(pop)") a=$(tos16 "$(pop)") || return
  if (( b == 0 )); then echo "DIV BY ZERO" >&2; push 0; VAR["/r"]=0; return; fi
  local q=$(( a / b ))
  local r=$(( a % b ))
  VAR["/r"]=$(mask16 "$r")
  VAR["/c"]=0
  push "$(mask16 "$q")"
}

# --- bitwise ---
op_and(){ local b=$(pop) a=$(pop) || return; push $(( (a & b) & 0xFFFF )); }
op_or (){ local b=$(pop) a=$(pop) || return; push $(( (a | b) & 0xFFFF )); }
op_xor(){ local b=$(pop) a=$(pop) || return; push $(( (a ^ b) & 0xFFFF )); }
op_not(){ local a=$(pop) || return; push $(( (~a) & 0xFFFF )); }
op_shl(){ local a=$(pop) || return; push $(( ( (a<<1) & 0xFFFF ) )); }
op_shr(){ local a=$(pop) || return; push $(( (a & 0xFFFF) >> 1 )); }

# --- stack ops ---
op_drop(){ pop >/dev/null || true; }
op_dup (){ local a=$(peek); push "$a"; }
op_swap(){ local b=$(pop) a=$(pop) || return; push "$b"; push "$a"; }
op_over(){ local n=${#ST[@]}; (( n<2 )) && { echo "STACK UNDERFLOW" >&2; return; }
           push "${ST[$((n-2))]}"; }

# --- printing, io ---
emit_char(){ local v=$(( $1 & 0xFF )); printf "\\$(printf '%03o' "$v")"; }

# --- tokenization with backtick literals ---
read_tokens(){
  local line="$1"
  # strip // comments
  line="${line%%//*}"
  local -a toks=()
  local i=0 len=${#line}
  while (( i < len )); do
    local c=${line:i:1}
    if [[ "$c" =~ [[:space:]] ]]; then ((i++)); continue; fi
    if [[ "$c" == "\`" ]]; then
      # collect until next backtick
      local j=$((i+1)) ; local buf=""
      while (( j < len )); do
        local d=${line:j:1}
        if [[ "$d" == "\`" ]]; then break; fi
        buf+="$d"; ((j++))
      done
      toks+=("`$buf`"); i=$((j+1)); continue
    fi
    # regular token
    local j=$i
    while (( j < len )) && ! [[ "${line:j:1}" =~ [[:space:]] ]]; do ((j++)); done
    toks+=("${line:i:j-i}")
    i=$j
  done
  printf '%s\0' "${toks[@]}"
}

# --- evaluator ---
eval_token(){
  local t="$1"

  # string literal
  if [[ "$t" == \`*\` ]]; then
    printf '%s' "${t:1:${#t}-2}"
    return
  fi

  # booleans & specials
  case "$t" in
    /N) printf '\n'; return ;;
    /F) push 0; return ;;
    /T) push $((0xFFFF)); return ;;
    /C) local v=$(pop) || return; emit_char "$v"; return ;;
  esac

  # numbers: #HEX or DEC (with optional leading -)
  if [[ "$t" == \#* ]]; then
    local hex=${t:1}
    [[ "$hex" =~ ^[0-9A-Fa-f]+$ ]] || { echo "BAD HEX: $t" >&2; push 0; return; }
    push $(( 16#$hex ))
    return
  elif [[ "$t" =~ ^-?[0-9]+$ ]]; then
    push "$(mask16 "$t")"; return
  fi

  # variables a..z fetch; /c /r fetch
  if is_var "$t"; then
    local k="$t"
    local v=${VAR[$k]:-0}
    push "$v"; return
  fi
  if is_sys "$t"; then
    push "${VAR[$t]:-0}"; return
  fi

  # store: value var !
  if [[ "$t" == "!" ]]; then
    local var=$(pop) val=$(pop) || { echo "STORE ERR" >&2; return; }
    # Expect 'var' came from pushing a var token; allow numbers mapping to letters via ASCII?
    # Simpler: last non-number token stored in global LASTVAR; but we keep: previous token must be a..z or /c /r
    echo "Use: <value> <varletter> !" >&2
    return
  fi

  # We implement a friendlier form: detect pattern "<value> x !" during the pass.
  # That requires the parser to know neighbors; instead offer explicit pseudo-op: a! means store TOS into 'a'
  if [[ "$t" =~ ^[a-z]\!$ ]]; then
    local name="${t:0:1}"
    local val=$(pop) || return
    VAR["$name"]=$(mask16 "$val"); return
  fi
  if [[ "$t" == "/c!" ]]; then local v=$(pop)||return; VAR["/c"]=$(mask16 "$v"); return; fi
  if [[ "$t" == "/r!" ]]; then local v=$(pop)||return; VAR["/r"]=$(mask16 "$v"); return; fi

  # ops
  case "$t" in
    +) op_add; return ;;
    -) op_sub; return ;;
    \*) op_mul; return ;;
    /) op_div; return ;;
    '&') op_and; return ;;
    '|') op_or; return ;;
    '^') op_xor; return ;;
    '~') op_not; return ;;
    '{') op_shl; return ;;
    '}') op_shr; return ;;
    "'") op_drop; return ;;
    '"') op_dup; return ;;
    '$') op_swap; return ;;
    '%') op_over; return ;;
    .)  local v=$(pop)||return; print_dec "$v"; printf '\n'; return ;;
    ,)  local v=$(pop)||return; print_hex "$v"; printf '\n'; return ;;
  esac

  # fallback: pushing unknown var name as zero or error
  echo "UNKNOWN TOKEN: $t" >&2
}

# --- REPL ---
echo "MINT(bash) — 16-bit RPN toy. Type Ctrl+C to exit."
while true; do
  printf "> "
  IFS= read -r LINE || exit 0
  # token limit guard (approx 256 chars)
  if (( ${#LINE} > 256 )); then echo "LINE TOO LONG (256 max)"; continue; fi
  mapfile -d '' TOKS < <(read_tokens "$LINE")
  # quick three-token pattern: <num> <var> !  -> store
  # We'll do a first pass to collapse "X y !" into "y!" with X on stack as expected.
  # Build a transformed token list:
  TRANS=()
  for ((i=0;i<${#TOKS[@]};)); do
    if (( i+2<${#TOKS[@]} )) && [[ "${TOKS[i]}" != "" ]] && [[ "${TOKS[i+1]}" =~ ^[a-z]$ ]] && [[ "${TOKS[i+2]}" == "!" ]]; then
      # push first token later, replace var/! with var!
      TRANS+=("${TOKS[i]}")           # value stays
      TRANS+=("${TOKS[i+1]}!")        # store op
      ((i+=3))
    else
      TRANS+=("${TOKS[i]}")
      ((i++))
    fi
  done

  for t in "${TRANS[@]}"; do
    [[ -z "$t" ]] && continue
    eval_token "$t"
  done
done
```

