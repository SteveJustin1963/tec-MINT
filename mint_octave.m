## ----------------------------------------------------------------------
## MINT/Forth-like Minimal Interpreter in Octave with DEBUG MODE
## ----------------------------------------------------------------------
function mint_octave()
  clear global;
  global state;

  ## Set display format for scientific work
  format long;

  ## Interpreter state
  state.stack = [];
  state.vars = zeros(1,26);
  state.heap = zeros(1,4096);
  state.heap_ptr = 1;
  state.dict = containers.Map();
  state.colon_defs = containers.Map();
  state.last_var = -1;  ## Track last variable for storage
  state.loop_i = 0;  ## Inner loop counter
  state.loop_j = 0;  ## Outer loop counter
  state.break_loop = false;  ## Break flag for /W
  state.sys_c = 0;  ## Carry flag
  state.sys_r = 0;  ## Remainder/overflow flag
  state.debug = false;  ## DEBUG MODE FLAG

  ## Initialize builtins
  add_builtin_words();

  ## History buffer
  history = {};
  hist_ptr = 1;

  printf("MINT-Octave REPL v2.4 (2025-10-01). Type 'bye' to quit.\n");
  
  ## Ask user if they want debug mode
  debug_choice = input("Enable debug mode? (y/n): ", "s");
  if strcmpi(debug_choice, "y") || strcmpi(debug_choice, "yes")
    state.debug = true;
    printf("\n*** DEBUG MODE ENABLED ***\n");
    printf("Debug output will show:\n");
    printf("  - Token processing\n");
    printf("  - Stack state\n");
    printf("  - Variable changes\n");
    printf("  - Function calls\n");
    printf("  - Loop iterations\n\n");
  else
    state.debug = false;
    printf("\n*** DEBUG MODE DISABLED ***\n\n");
  endif

  ## --------------------------
  ## Main REPL Loop
  ## --------------------------
  while true
    printf("> ");
    fflush(stdout);
    
    line = input("", "s");  ## Simple string input
    
    if isempty(line)
      continue;
    endif
    if strcmpi(line, "bye")
      break;
    endif

    ## store line in history
    history{end+1} = line;
    hist_ptr = numel(history)+1;

    ## Auto-add semicolon to function definitions if missing
    if ~isempty(line) && (line(1) == ':' || any(strfind(line, ' :')))
      if isempty(strfind(line, ';'))
        line = [line, ' ;'];
      endif
    endif

    try
      if state.debug
        printf("\n=== EXECUTING LINE: %s ===\n", line);
      endif
      interpret_line(line);
      if state.debug
        debug_show_final_state();
      endif
      printf("\n");  ## Add newline after execution
    catch err
      fprintf("ERROR: %s\n", err.message);
      if state.debug
        fprintf("ERROR STACK:\n%s\n", err.stack);
      endif
    end_try_catch
  endwhile
endfunction


## --------------------------
## Built-in Dictionary Setup
## --------------------------
function add_builtin_words()
  global state;
  ## Arithmetic (these will set /c and /r flags)
  state.dict("+") = @(s) math_add(s);
  state.dict("-") = @(s) math_sub(s);
  state.dict("*") = @(s) math_mul(s);
  state.dict("/") = @(s) math_div(s);

  ## Stack ops
  state.dict("'") = @(s) drop(s);
  state.dict('"') = @(s) dup(s);
  state.dict("$") = @(s) swap(s);
  state.dict("%") = @(s) over(s);
  state.dict("/D") = @(s) stack_depth(s);

  ## Comparison ops
  state.dict(">") = @(s) compare_gt(s);
  state.dict("<") = @(s) compare_lt(s);
  state.dict("=") = @(s) compare_eq(s);
  
  ## Bitwise ops
  state.dict("&") = @(s) bitwise_and(s);
  state.dict("|") = @(s) bitwise_or(s);
  state.dict("^") = @(s) bitwise_xor(s);
  state.dict("~") = @(s) bitwise_not(s);
  state.dict("{") = @(s) shift_left(s);
  state.dict("}") = @(s) shift_right(s);
  
  ## Variable operations
  state.dict("!") = @(s) store_var(s);
  
  ## Loop constants and control
  state.dict("/F") = @(s) push(s, 0);      ## False constant
  state.dict("/T") = @(s) push(s, -1);     ## True constant
  state.dict("/U") = @(s) push(s, -1);     ## Unlimited loop constant
  state.dict("/W") = @(s) loop_while(s);   ## While - break if false
  state.dict("/i") = @(s) get_loop_i(s);   ## Inner loop counter
  state.dict("/j") = @(s) get_loop_j(s);   ## Outer loop counter
  
  ## System variables
  state.dict("/c") = @(s) get_sys_c(s);    ## Carry flag
  state.dict("/r") = @(s) get_sys_r(s);    ## Remainder/overflow flag
  
  ## I/O operations
  state.dict("/C") = @(s) print_char(s);   ## Print character
  state.dict("/N") = @(s) print_newline(s); ## Print newline
  state.dict("/K") = @(s) read_char(s);    ## Read character
  state.dict("/KS") = @(s) read_string(s);  ## Read string (extension)

  ## Print ops
  state.dict(".") = @(s) print_num(s);
  state.dict(",") = @(s) print_hex(s);
  
  ## Array operations
  state.dict("?") = @(s) get_array_item(s);
  state.dict("?!") = @(s) set_array_item(s);
  state.dict("/S") = @(s) array_size(s);
  
  ## Help
  state.dict("help") = @(s) show_help(s);
  state.dict("list") = @(s) list_functions(s);
  state.dict("debug") = @(s) toggle_debug(s);
endfunction


## --------------------------
## Integer Division Helper
## --------------------------
function r = idiv_mint(a, b)
  if b == 0
    error("DIVISION BY ZERO");
  endif
  r = floor(a / b);  ## Integer division
endfunction


## --------------------------
## Math Functions (set /c and /r flags)
## --------------------------
function s = math_add(s)
  global state;
  if state.debug
    debug_before_op("+", s);
  endif
  [s,b]=pop(s); [s,a]=pop(s);
  result = a + b;
  s=push(s, result);
  state.sys_c = 0;  ## Clear carry (no carry with 64-bit floats)
  state.sys_r = 0;  ## Clear remainder
  if state.debug
    debug_after_op("+", sprintf("%g + %g = %g", a, b, result), s);
  endif
endfunction

function s = math_sub(s)
  global state;
  if state.debug
    debug_before_op("-", s);
  endif
  [s,b]=pop(s); [s,a]=pop(s);
  result = a - b;
  s=push(s, result);
  state.sys_c = 0;  ## Clear carry
  state.sys_r = 0;  ## Clear remainder
  if state.debug
    debug_after_op("-", sprintf("%g - %g = %g", a, b, result), s);
  endif
endfunction

function s = math_mul(s)
  global state;
  if state.debug
    debug_before_op("*", s);
  endif
  [s,b]=pop(s); [s,a]=pop(s);
  result = a * b;
  s=push(s, result);
  state.sys_c = 0;  ## Clear carry
  state.sys_r = 0;  ## Clear overflow (no overflow with 64-bit floats)
  if state.debug
    debug_after_op("*", sprintf("%g * %g = %g", a, b, result), s);
  endif
endfunction

function s = math_div(s)
  global state;
  if state.debug
    debug_before_op("/", s);
  endif
  [s,b]=pop(s); [s,a]=pop(s);
  if b == 0
    error("DIVISION BY ZERO");
  endif
  result = floor(a / b);
  remainder = mod(a, b);
  s=push(s, result);
  state.sys_c = 0;  ## Clear carry
  state.sys_r = remainder;  ## Store remainder
  if state.debug
    debug_after_op("/", sprintf("%g / %g = %g (remainder: %g)", a, b, result, remainder), s);
  endif
endfunction


## --------------------------
## Comparison Functions
## --------------------------
function s = compare_gt(s)
  global state;
  if state.debug
    debug_before_op(">", s);
  endif
  [s,b]=pop(s); [s,a]=pop(s);
  if a > b
    s=push(s,-1);  ## True in MINT is -1
  else
    s=push(s,0);   ## False in MINT is 0
  endif
  if state.debug
    debug_after_op(">", sprintf("%g > %g = %s", a, b, iif(a>b, "TRUE", "FALSE")), s);
  endif
endfunction

function s = compare_lt(s)
  global state;
  if state.debug
    debug_before_op("<", s);
  endif
  [s,b]=pop(s); [s,a]=pop(s);
  if a < b
    s=push(s,-1);  ## True in MINT is -1
  else
    s=push(s,0);   ## False in MINT is 0
  endif
  if state.debug
    debug_after_op("<", sprintf("%g < %g = %s", a, b, iif(a<b, "TRUE", "FALSE")), s);
  endif
endfunction

function s = compare_eq(s)
  global state;
  if state.debug
    debug_before_op("=", s);
  endif
  [s,b]=pop(s); [s,a]=pop(s);
  if a == b
    s=push(s,-1);  ## True in MINT is -1
  else
    s=push(s,0);   ## False in MINT is 0
  endif
  if state.debug
    debug_after_op("=", sprintf("%g = %g = %s", a, b, iif(a==b, "TRUE", "FALSE")), s);
  endif
endfunction


## --------------------------
## Bitwise Functions
## --------------------------
function s = bitwise_and(s)
  global state;
  if state.debug
    debug_before_op("&", s);
  endif
  [s,b]=pop(s); [s,a]=pop(s);
  result = bitand(int64(a), int64(b));
  s=push(s, result);
  if state.debug
    debug_after_op("&", sprintf("%g & %g = %g", a, b, result), s);
  endif
endfunction

function s = bitwise_or(s)
  global state;
  if state.debug
    debug_before_op("|", s);
  endif
  [s,b]=pop(s); [s,a]=pop(s);
  result = bitor(int64(a), int64(b));
  s=push(s, result);
  if state.debug
    debug_after_op("|", sprintf("%g | %g = %g", a, b, result), s);
  endif
endfunction

function s = bitwise_xor(s)
  global state;
  if state.debug
    debug_before_op("^", s);
  endif
  [s,b]=pop(s); [s,a]=pop(s);
  result = bitxor(int64(a), int64(b));
  s=push(s, result);
  if state.debug
    debug_after_op("^", sprintf("%g ^ %g = %g", a, b, result), s);
  endif
endfunction

function s = bitwise_not(s)
  global state;
  if state.debug
    debug_before_op("~", s);
  endif
  [s,a]=pop(s);
  result = bitcmp(int64(a), 64);
  s=push(s, result);
  if state.debug
    debug_after_op("~", sprintf("~%g = %g", a, result), s);
  endif
endfunction

function s = shift_left(s)
  global state;
  if state.debug
    debug_before_op("{", s);
  endif
  [s,a]=pop(s);
  result = bitshift(int64(a), 1);
  s=push(s, result);
  if state.debug
    debug_after_op("{", sprintf("%g << 1 = %g", a, result), s);
  endif
endfunction

function s = shift_right(s)
  global state;
  if state.debug
    debug_before_op("}", s);
  endif
  [s,a]=pop(s);
  result = bitshift(int64(a), -1);
  s=push(s, result);
  if state.debug
    debug_after_op("}", sprintf("%g >> 1 = %g", a, result), s);
  endif
endfunction


## --------------------------
## Variable Functions
## --------------------------
function s = store_var(s)
  global state;
  if state.last_var < 1
    error("! requires a variable before it (e.g., 10 x !)");
  endif
  [s, val] = pop(s);  ## Pop value from stack
  var_name = char('a' + state.last_var - 1);
  if state.debug
    printf("[DEBUG] STORE: %s = %g (was %g)\n", var_name, val, state.vars(state.last_var));
  endif
  state.vars(state.last_var) = val;  ## Store in variable
  state.last_var = -1;  ## Reset
endfunction


## --------------------------
## Loop Control Functions
## --------------------------
function s = loop_while(s)
  global state;
  [s, condition] = pop(s);
  if state.debug
    printf("[DEBUG] /W: condition=%g, break=%s\n", condition, iif(condition==0, "YES", "NO"));
  endif
  if condition == 0  ## If false (0), break loop
    state.break_loop = true;
  endif
endfunction

function s = get_loop_i(s)
  global state;
  if state.debug
    printf("[DEBUG] /i: pushing loop_i=%g\n", state.loop_i);
  endif
  s = push(s, state.loop_i);
endfunction

function s = get_loop_j(s)
  global state;
  if state.debug
    printf("[DEBUG] /j: pushing loop_j=%g\n", state.loop_j);
  endif
  s = push(s, state.loop_j);
endfunction

function s = get_sys_c(s)
  global state;
  if state.debug
    printf("[DEBUG] /c: pushing carry=%g\n", state.sys_c);
  endif
  s = push(s, state.sys_c);
endfunction

function s = get_sys_r(s)
  global state;
  if state.debug
    printf("[DEBUG] /r: pushing remainder=%g\n", state.sys_r);
  endif
  s = push(s, state.sys_r);
endfunction


## --------------------------
## I/O Functions
## --------------------------
function s = print_char(s)
  [s,a]=pop(s); 
  printf("%c", char(a));
endfunction

function s = print_newline(s)
  printf("\n");
endfunction

function s = read_char(s)
  c = input("", "s");
  if ~isempty(c)
    s = push(s, double(c(1)));
  else
    s = push(s, 0);
  endif
endfunction

function s = read_string(s)
  str = input("", "s");
  ## Push each character's ASCII code onto stack, left to right
  for i = 1:length(str)
    s = push(s, double(str(i)));
  endfor
  ## Push length as final value so user knows how many chars
  s = push(s, length(str));
endfunction


## --------------------------
## Array Functions
## --------------------------
function s = get_array_item(s)
  global state;
  [s, idx] = pop(s);  ## Pop index
  [s, addr] = pop(s);  ## Pop array address
  
  ## Array format in heap: [size, elem1, elem2, ...]
  size = state.heap(addr);
  if idx < 0 || idx >= size
    error("Array index out of bounds: %d (size=%d)", idx, size);
  endif
  
  value = state.heap(addr + 1 + idx);
  if state.debug
    printf("[DEBUG] ARRAY GET: addr=%g, idx=%g -> value=%g\n", addr, idx, value);
  endif
  s = push(s, value);
endfunction

function s = set_array_item(s)
  global state;
  [s, idx] = pop(s);  ## Pop index
  [s, addr] = pop(s);  ## Pop array address
  [s, val] = pop(s);  ## Pop value to store
  
  ## Array format in heap: [size, elem1, elem2, ...]
  size = state.heap(addr);
  if idx < 0 || idx >= size
    error("Array index out of bounds: %d (size=%d)", idx, size);
  endif
  
  if state.debug
    printf("[DEBUG] ARRAY SET: addr=%g, idx=%g, value=%g (was %g)\n", addr, idx, val, state.heap(addr + 1 + idx));
  endif
  state.heap(addr + 1 + idx) = val;
endfunction

function s = array_size(s)
  global state;
  [s, addr] = pop(s);  ## Pop array address
  
  ## Array format in heap: [size, elem1, elem2, ...]
  size = state.heap(addr);
  if state.debug
    printf("[DEBUG] ARRAY SIZE: addr=%g -> size=%g\n", addr, size);
  endif
  s = push(s, size);
endfunction


## --------------------------
## Interpreter Functions
## --------------------------
function interpret_line(line)
  global state;
  
  ## NEW: Tokenize with backtick strings preserved as special tokens
  tokens = tokenize_with_strings(line);
  
  if state.debug
    printf("[DEBUG] TOKENS: ");
    for i = 1:length(tokens)
      printf("'%s' ", tokens{i});
    endfor
    printf("\n");
  endif
  
  compile_mode = false;
  current_def = {};

  i = 1;
  while i <= length(tokens)
    tok = tokens{i};
    
    if state.debug && !compile_mode
      printf("[DEBUG] Processing token #%d: '%s'\n", i, tok);
    endif
    
    ## Check for array creation [ ... ]
    if strcmp(tok, "[")
      ## Collect array elements until ]
      array_elements = [];
      i++;
      while i <= length(tokens) && !strcmp(tokens{i}, "]")
        elem_tok = tokens{i};
        ## Parse the element
        if length(elem_tok) == 1 && elem_tok >= 'a' && elem_tok <= 'z'
          ## Variable reference
          idx = double(elem_tok) - double('a') + 1;
          array_elements(end+1) = state.vars(idx);
        elseif length(elem_tok) > 1 && elem_tok(1) == '#'
          ## Hex number
          hex_str = elem_tok(2:end);
          array_elements(end+1) = hex2dec(hex_str);
        elseif !isnan(str2double(elem_tok))
          ## Decimal number
          array_elements(end+1) = str2double(elem_tok);
        else
          error("Invalid array element: %s", elem_tok);
        endif
        i++;
      endwhile
      
      if i > length(tokens) || !strcmp(tokens{i}, "]")
        error("Unclosed array - missing ]");
      endif
      
      ## Create array in heap: [size, elem1, elem2, ...]
      arr_size = length(array_elements);
      heap_addr = state.heap_ptr;
      state.heap(heap_addr) = arr_size;
      for j = 1:arr_size
        state.heap(heap_addr + j) = array_elements(j);
      endfor
      state.heap_ptr = heap_addr + arr_size + 1;
      
      if state.debug
        printf("[DEBUG] ARRAY CREATE: addr=%g, size=%g, elements=[", heap_addr, arr_size);
        for j = 1:arr_size
          printf("%g ", array_elements(j));
        endfor
        printf("]\n");
      endif
      
      ## Push array address onto stack
      state.stack = push(state.stack, heap_addr);
      i++;
      continue;
    endif
    
    ## Check if token starts with : (function definition)
    if length(tok) > 1 && tok(1) == ':'
      compile_mode = true;
      current_def = {};
      current_def{1} = tok(2:end);  ## Extract function name (e.g., "F" from ":F")
      if state.debug
        printf("[DEBUG] FUNCTION DEF START: %s\n", current_def{1});
      endif
      i++;
      continue;
    elseif strcmp(tok, ";")
      compile_mode = false;
      state.colon_defs(current_def{1}) = current_def(2:end);
      if state.debug
        printf("[DEBUG] FUNCTION DEF END: %s with %d tokens\n", current_def{1}, length(current_def)-1);
      endif
      i++;
      continue;
    endif

    if compile_mode
      current_def{end+1} = tok;
      i++;
    else
      ## Check for loop syntax: number followed by (
      if strcmp(tok, "(")
        ## Check if this is a conditional (if-then-else) or a loop
        ## Look ahead for /E to determine
        has_else = false;
        depth = 0;
        for check_idx = i:length(tokens)
          if strcmp(tokens{check_idx}, "(")
            depth++;
          elseif strcmp(tokens{check_idx}, ")")
            depth--;
            if depth == 0
              ## Found matching close paren, check next token
              if check_idx < length(tokens) && strcmp(tokens{check_idx+1}, "/E")
                has_else = true;
              endif
              break;
            endif
          endif
        endfor
        
        if has_else
          ## This is an if-then-else conditional
          if state.debug
            printf("[DEBUG] CONDITIONAL: if-then-else detected\n");
          endif
          [then_body, then_end] = extract_loop_body(tokens, i);
          ## Pattern is: ) /E (
          ## then_end points to ), so /E is at then_end+1, ( is at then_end+2
          [else_body, else_end] = extract_loop_body(tokens, then_end+2);
          execute_conditional(then_body, else_body);
          i = else_end + 1;
        else
          ## This is a regular loop
          if state.debug
            printf("[DEBUG] LOOP: regular loop detected\n");
          endif
          [loop_body, end_idx] = extract_loop_body(tokens, i);
          execute_loop(loop_body);
          i = end_idx + 1;
        endif
      ## Check if this is a variable followed by ! (store operation)
      elseif length(tok) == 1 && tok >= 'a' && tok <= 'z' && i < length(tokens) && strcmp(tokens{i+1}, "!")
        ## This is a store operation - just set the variable index
        idx = double(tok) - double('a') + 1;
        state.last_var = idx;
        if state.debug
          printf("[DEBUG] STORE PREP: variable '%s' (index %d) ready for !\n", tok, idx);
        endif
        i++;
      else
        execute_token(tok);
        i++;
      endif
    endif
  endwhile
endfunction


## NEW FUNCTION: Tokenize preserving backtick strings and handling comments
function tokens = tokenize_with_strings(line)
  tokens = {};
  i = 1;
  current_token = "";
  
  while i <= length(line)
    ch = line(i);
    
    ## Check for comment marker //
    if i <= length(line)-1 && strcmp(line(i:i+1), '//')
      ## Save any accumulated token
      if !isempty(current_token)
        tokens{end+1} = strtrim(current_token);
      endif
      ## Stop processing - rest of line is comment
      break;
    endif
    
    if ch == '`'
      ## Save any accumulated token
      if !isempty(current_token)
        tokens{end+1} = strtrim(current_token);
        current_token = "";
      endif
      
      ## Find closing backtick
      j = i + 1;
      while j <= length(line) && line(j) != '`'
        j++;
      endwhile
      
      if j <= length(line)
        ## Store backtick string as special token WITH backticks
        tokens{end+1} = line(i:j);
        i = j + 1;
      else
        error("Unclosed backtick string");
      endif
    elseif ch == ' ' || ch == sprintf('\t')
      ## Whitespace - save token if any
      if !isempty(current_token)
        tokens{end+1} = strtrim(current_token);
        current_token = "";
      endif
      i++;
    else
      ## Regular character
      current_token = [current_token, ch];
      i++;
    endif
  endwhile
  
  ## Save final token if any
  if !isempty(current_token)
    tokens{end+1} = strtrim(current_token);
  endif
endfunction


## Extract loop body between ( and )
function [body, end_idx] = extract_loop_body(tokens, start_idx)
  depth = 1;
  body = {};
  i = start_idx + 1;
  
  while i <= length(tokens) && depth > 0
    if strcmp(tokens{i}, "(")
      depth++;
    elseif strcmp(tokens{i}, ")")
      depth--;
      if depth == 0
        break;
      endif
    endif
    body{end+1} = tokens{i};
    i++;
  endwhile
  
  end_idx = i;
endfunction


## Execute loop body n times
function execute_loop(body)
  global state;
  
  ## Pop loop count from stack
  [state.stack, count] = pop(state.stack);
  
  if state.debug
    printf("[DEBUG] LOOP START: count=%g, stack_depth=%d\n", count, length(state.stack));
  endif
  
  ## Handle negative numbers and unlimited loops
  ## -1 from /T or comparisons means "run once" (truthy)
  ## /U with /W creates unlimited loop pattern
  if count < 0
    ## Check if body contains /W (while break) for unlimited loop
    has_while = false;
    for i = 1:length(body)
      if strcmp(body{i}, "/W")
        has_while = true;
        break;
      endif
    endfor
    
    if has_while
      count = 999999;  ## Unlimited loop with /W break
      if state.debug
        printf("[DEBUG] LOOP: unlimited loop with /W break\n");
      endif
    else
      count = 1;  ## Boolean true (-1) means run once
      if state.debug
        printf("[DEBUG] LOOP: boolean true, run once\n");
      endif
    endif
  endif
  
  ## Save current loop counters for nested loops
  saved_i = state.loop_i;
  saved_j = state.loop_j;
  
  ## Current inner loop becomes outer loop for any nested loops
  state.loop_j = state.loop_i;
  
  ## Execute loop
  for loop_idx = 0:(count-1)
    state.loop_i = loop_idx;
    state.break_loop = false;
    
    if state.debug
      printf("[DEBUG] LOOP ITERATION: i=%d, j=%d\n", state.loop_i, state.loop_j);
      debug_show_stack();
    endif
    
    ## Process body tokens (which may contain nested loops)
    execute_token_sequence(body);
    
    if state.break_loop
      if state.debug
        printf("[DEBUG] LOOP BREAK: exiting at iteration %d\n", loop_idx);
      endif
      break;  ## Break out of loop
    endif
  endfor
  
  ## Restore loop counters
  state.loop_i = saved_i;
  state.loop_j = saved_j;
  
  if state.debug
    printf("[DEBUG] LOOP END: restored i=%d, j=%d\n", state.loop_i, state.loop_j);
  endif
endfunction


## Execute conditional (if-then-else)
function execute_conditional(then_body, else_body)
  global state;
  
  ## Pop condition from stack
  if isempty(state.stack)
    error("Conditional requires a condition on stack");
  endif
  [state.stack, condition] = pop(state.stack);
  
  if state.debug
    printf("[DEBUG] CONDITIONAL: condition=%g, taking %s branch\n", condition, iif(condition!=0, "THEN", "ELSE"));
  endif
  
  ## Execute then or else block based on condition
  if condition != 0  ## True (non-zero)
    execute_token_sequence(then_body);
  else  ## False (zero)
    execute_token_sequence(else_body);
  endif
endfunction


## Execute a sequence of tokens (handles nested loops and conditionals)
function execute_token_sequence(tokens)
  global state;
  
  i = 1;
  while i <= length(tokens)
    tok = tokens{i};
    
    if state.debug
      printf("[DEBUG] SEQ token #%d: '%s'\n", i, tok);
    endif
    
    ## Check for array creation [ ... ]
    if strcmp(tok, "[")
      ## Collect array elements until ]
      array_elements = [];
      i++;
      while i <= length(tokens) && !strcmp(tokens{i}, "]")
        elem_tok = tokens{i};
        ## Parse the element
        if length(elem_tok) == 1 && elem_tok >= 'a' && elem_tok <= 'z'
          ## Variable reference
          idx = double(elem_tok) - double('a') + 1;
          array_elements(end+1) = state.vars(idx);
        elseif length(elem_tok) > 1 && elem_tok(1) == '#'
          ## Hex number
          hex_str = elem_tok(2:end);
          array_elements(end+1) = hex2dec(hex_str);
        elseif !isnan(str2double(elem_tok))
          ## Decimal number
          array_elements(end+1) = str2double(elem_tok);
        else
          error("Invalid array element: %s", elem_tok);
        endif
        i++;
      endwhile
      
      if i > length(tokens) || !strcmp(tokens{i}, "]")
        error("Unclosed array - missing ]");
      endif
      
      ## Create array in heap: [size, elem1, elem2, ...]
      arr_size = length(array_elements);
      heap_addr = state.heap_ptr;
      state.heap(heap_addr) = arr_size;
      for j = 1:arr_size
        state.heap(heap_addr + j) = array_elements(j);
      endfor
      state.heap_ptr = heap_addr + arr_size + 1;
      
      ## Push array address onto stack
      state.stack = push(state.stack, heap_addr);
      i++;
      continue;
    endif
    
    if strcmp(tok, "(")
      ## Check if this is a conditional (if-then-else) or a loop
      ## Look ahead for /E to determine
      has_else = false;
      depth = 0;
      for check_idx = i:length(tokens)
        if strcmp(tokens{check_idx}, "(")
          depth++;
        elseif strcmp(tokens{check_idx}, ")")
          depth--;
          if depth == 0
            ## Found matching close paren, check next token
            if check_idx < length(tokens) && strcmp(tokens{check_idx+1}, "/E")
              has_else = true;
            endif
            break;
          endif
        endif
      endfor
      
      if has_else
        ## This is an if-then-else conditional
        [then_body, then_end] = extract_loop_body(tokens, i);
        ## Pattern is: ) /E (
        ## then_end points to ), so /E is at then_end+1, ( is at then_end+2
        [else_body, else_end] = extract_loop_body(tokens, then_end+2);
        execute_conditional(then_body, else_body);
        i = else_end + 1;
      else
        ## This is a regular loop
        [loop_body, end_idx] = extract_loop_body(tokens, i);
        execute_loop(loop_body);
        i = end_idx + 1;
      endif
    ## Check if this is a variable followed by ! (store operation)
    elseif length(tok) == 1 && tok >= 'a' && tok <= 'z' && i < length(tokens) && strcmp(tokens{i+1}, "!")
      ## This is a store operation - just set the variable index
      idx = double(tok) - double('a') + 1;
      state.last_var = idx;
      i++;
      continue;  ## Skip executing this token
    else
      execute_token(tok);
      i++;
      
      if state.break_loop
        return;  ## Propagate break upwards
      endif
    endif
  endwhile
endfunction


function execute_token(tok)
  global state;

  ## NEW: Handle backtick strings
  if length(tok) >= 2 && tok(1) == '`' && tok(end) == '`'
    ## Extract and print the string content
    str_content = tok(2:end-1);
    if state.debug
      printf("[DEBUG] STRING: printing '%s'\n", str_content);
    endif
    printf("%s", str_content);
    return;
  endif

  ## Handle array creation [...]
  if length(tok) >= 1 && tok(1) == '['
    error("Array syntax error: use spaces like [ 1 2 3 ]");
  endif

  if isKey(state.colon_defs, tok)
    if state.debug
      printf("[DEBUG] FUNCTION CALL: %s\n", tok);
    endif
    execute_token_sequence(state.colon_defs(tok));
  
  
  elseif isKey(state.dict, tok)
    if state.debug
      printf("[DEBUG] BUILTIN: %s\n", tok);
    endif
    state.stack = state.dict(tok)(state.stack);
  elseif length(tok) == 1 && tok >= 'a' && tok <= 'z'
    ## Single lowercase letter variable (a-z)
    idx = double(tok) - double('a') + 1;  ## Convert 'a'->1, 'b'->2, etc.
    state.last_var = idx;  ## Remember which variable for potential storage
    if state.debug
      printf("[DEBUG] VARIABLE PUSH: %s = %g\n", tok, state.vars(idx));
    endif
    state.stack = push(state.stack, state.vars(idx));
  elseif length(tok) > 1 && tok(1) == '#'
    ## Hexadecimal number (e.g., #FF, #1F3A)
    hex_str = tok(2:end);
    num = hex2dec(hex_str);
    if state.debug
      printf("[DEBUG] HEX NUMBER: %s = %g\n", tok, num);
    endif
    state.stack = push(state.stack, num);
  elseif !isnan(str2double(tok))
    ## Support 64-bit floating point numbers
    num = str2double(tok);
    if state.debug
      printf("[DEBUG] NUMBER: %g\n", num);
    endif
    state.stack = push(state.stack, num);
  else
    error("Unknown word: %s", tok);
  endif
endfunction


## --------------------------
## Stack Utilities
## --------------------------
function s = push(s,val)
  s(end+1)=val;
endfunction

function [s,val] = pop(s)
  if isempty(s)
    error("STACK UNDERFLOW");
  endif
  val = s(end);
  s(end)=[];
endfunction

function s = binop(s,op)
  [s,b]=pop(s); [s,a]=pop(s);
  s=push(s,op(a,b));
endfunction

function s = drop(s)
  global state;
  if state.debug
    debug_before_op("'", s);
  endif
  [s,~]=pop(s);
  if state.debug
    debug_after_op("'", "dropped top", s);
  endif
endfunction

function s = dup(s)
  global state;
  if state.debug
    debug_before_op('"', s);
  endif
  [s,a]=pop(s); s=push(s,a); s=push(s,a);
  if state.debug
    debug_after_op('"', sprintf("duplicated %g", a), s);
  endif
endfunction

function s = swap(s)
  global state;
  if state.debug
    debug_before_op("$", s);
  endif
  [s,a]=pop(s); [s,b]=pop(s);
  s=push(s,a); s=push(s,b);
  if state.debug
    debug_after_op("$", sprintf("swapped %g and %g", b, a), s);
  endif
endfunction

function s = over(s)
  global state;
  if state.debug
    debug_before_op("%", s);
  endif
  if length(s)<2, error("STACK UNDERFLOW"); endif
  s=push(s,s(end-1));
  if state.debug
    debug_after_op("%", sprintf("copied second item %g", s(end)), s);
  endif
endfunction

function s = stack_depth(s)
  global state;
  depth = length(s);
  s=push(s, depth);
  if state.debug
    printf("[DEBUG] /D: stack depth = %d\n", depth);
  endif
endfunction


## --------------------------
## Print Functions
## --------------------------
function s = print_num(s)
  [s,a]=pop(s); 
  disp(a);  ## Use disp() to respect format long setting
endfunction

function s = print_hex(s)
  [s,a]=pop(s); printf("%04X ",a);
endfunction


## --------------------------
## List Functions
## --------------------------
function s = list_functions(s)
  global state;
  
  func_names = keys(state.colon_defs);
  
  if isempty(func_names)
    printf("No functions defined.\n");
  else
    printf("Defined functions:\n");
    for i = 1:length(func_names)
      fname = func_names{i};
      fbody = state.colon_defs(fname);
      
      ## Reconstruct the function definition
      printf("  :%s ", fname);
      for j = 1:length(fbody)
        printf("%s ", fbody{j});
      endfor
      printf(";\n");
    endfor
  endif
endfunction


## --------------------------
## Toggle Debug
## --------------------------
function s = toggle_debug(s)
  global state;
  state.debug = !state.debug;
  if state.debug
    printf("\n*** DEBUG MODE ENABLED ***\n");
  else
    printf("\n*** DEBUG MODE DISABLED ***\n");
  endif
endfunction


## --------------------------
## Help Function
## --------------------------
function s = show_help(s)
  printf("\n");
  printf("===================================================================================================\n");
  printf("MINT Operator Reference (* = implemented)\n");
  printf("===================================================================================================\n\n");
  
  printf("NUMBER FORMATS:\n");
printf("  Decimal:      123, -456, 3.14159, 1.23e+36  (64-bit floating point)\n");
printf("  Hexadecimal:  #FF, #1F3A, #FFFF  (prefix with #, displayed as 0000-FFFF)\n");
printf("  Display:      format long (15-16 significant digits for scientific work)\n");
printf("  Range:        ±1.8e308 (much larger than original MINT's 16-bit limit)\n");
printf("  Arrays:       Support both integers and floating point numbers\n");
printf("  Note:         This Octave version uses 64-bit floats, not 16-bit integers\n\n");

  printf("===================================================================================================\n");
  printf("Category  | Symbol | Description                               | Effect       | Status\n");
  printf("--------- | ------ | ----------------------------------------- | ------------ | ------\n");
  printf("MATHS     | *  -   | 16-bit integer subtraction SUB            | n n -- n     | DONE\n");
  printf("MATHS     | *  /   | 16-bit by 8-bit division DIV              | n n -- n     | DONE\n");
  printf("MATHS     | *  +   | 16-bit integer addition ADD               | n n -- n     | DONE\n");
  printf("MATHS     | *  *   | 8-bit by 8-bit integer multiplication MUL | n n -- n     | DONE\n");
  printf("LOGICAL   | *  >   | 16-bit comparison GT                      | n n -- b     | DONE\n");
  printf("LOGICAL   | *  <   | 16-bit comparison LT                      | n n -- b     | DONE\n");
  printf("LOGICAL   | *  =   | 16-bit comparison EQ                      | n n -- b     | DONE\n");
  printf("LOGICAL   | *  &   | 16-bit bitwise AND                        | n n -- b     | DONE\n");
  printf("LOGICAL   | *  |   | 16-bit bitwise OR                         | n n -- b     | DONE\n");
  printf("LOGICAL   | *  ^   | 16-bit bitwise XOR                        | n n -- b     | DONE\n");
  printf("LOGICAL   | *  ~   | 16-bit NOT                                | n -- n       | DONE\n");
  printf("LOGICAL   | *  {   | shift left                                | n -- n       | DONE\n");
  printf("LOGICAL   | *  }   | shift right                               | n -- n       | DONE\n");
  printf("STACK     | *  '   | drop top member DROP                      | m n -- m     | DONE\n");
  printf('STACK     | *  "   | duplicate top member DUP                  | n -- n n     | DONE\n');
  printf("STACK     | *  %%   | over - copy 2nd to top                    | m n -- m n m | DONE\n");
  printf("STACK     | *  $   | swap top 2 members SWAP                   | m n -- n m   | DONE\n");
  printf("STACK     | *  /D  | stack depth                               | -- n         | DONE\n");
  printf("I/O       | *  .   | print number as decimal                   | n --         | DONE\n");
  printf("I/O       | *  ,   | print number as hexadecimal               | n --         | DONE\n");
  printf("I/O       | *  `   | print literal string                      | --           | DONE\n");
  printf("I/O       | *  /C  | print character to output                 | n --         | DONE\n");
  printf("I/O       | *  /K  | read char from input                      | -- n         | DONE\n");
  printf("I/O       | *  /KS | read string (all ASCII codes + length)    | -- n n... n  | DONE\n");
  printf("I/O       |    /O  | output to I/O port                        | n p --       | TODO\n");
  printf("I/O       |    /I  | input from I/O port                       | p -- n       | TODO\n");
  printf("FUNCTION  | * :A;  | define function (A-Z)                     | --           | DONE\n");
  printf("FUNCTION  |   :@;  | define anonymous function                 | -- a         | TODO\n");
  printf("FUNCTION  |   /G   | execute mint code at address              | a -- ?       | TODO\n");
  printf("FUNCTION  |   /X   | execute machine code at address           | a -- ?       | TODO\n");
  printf("LOOP      | *  (   | BEGIN loop repeat n times                 | n --         | DONE\n");
  printf("LOOP      | *  )   | END loop code block                       | --           | DONE\n");
  printf("LOOP      | *  /U  | unlimited loop constant                   | -- b         | DONE\n");
  printf("LOOP      | *  /W  | if false break out of loop                | b --         | DONE\n");
  printf("LOOP      | *  /E  | else condition                            | -- b         | DONE\n");
  printf("LOOP      | *  /F  | false constant                            | -- b         | DONE\n");
  printf("LOOP      | *  /T  | true constant                             | -- b         | DONE\n");
  printf("VARIABLE  | *  a-z | variable access                           | -- n         | DONE\n");
  printf("VARIABLE  | *  !   | STORE value to memory                     | n a --       | DONE\n");
  printf("VARIABLE  |   /V   | address of last access                    | -- a         | TODO\n");
  printf("ARRAY     | *  [   | begin array definition (64-bit floats)    | --           | DONE\n");
  printf("ARRAY     | *  ]   | end array definition                      | -- a         | DONE\n");
  printf("ARRAY     | *  ?   | get array item                            | a n -- n     | DONE\n");
  printf("ARRAY     | *  ?!  | set array item                            | n a n --     | DONE\n");
  printf("ARRAY     | *  /S  | array size                                | a -- n       | DONE\n");
  printf("ARRAY     |   /A   | allocate heap memory                      | n -- a       | TODO\n");
  printf("BYTE      |    \\   | put MINT into byte mode                   | --           | TODO\n");
  printf("BYTE      |   \\!   | STORE byte to memory                      | b a --       | TODO\n");
  printf("BYTE      |   \\[   | begin byte array definition               | --           | TODO\n");
  printf("BYTE      |   \\?   | get byte array item                       | a n -- b     | TODO\n");
  printf("SYSVAR    | *  /c  | carry variable                            | -- n         | DONE\n");
  printf("SYSVAR    |   /h   | heap pointer variable                     | -- a         | TODO\n");
  printf("SYSVAR    | *  /i  | loop variable                             | -- n         | DONE\n");
  printf("SYSVAR    | *  /j  | outer loop variable                       | -- n         | DONE\n");
  printf("SYSVAR    |   /k   | offset into text input buffer             | -- a         | TODO\n");
  printf("SYSVAR    | *  /r  | remainder/overflow of last div/mul        | -- n         | DONE\n");
  printf("SYSVAR    |   /s   | address of start of stack                 | -- a         | TODO\n");
  printf("SYSVAR    |   /z   | name of last defined function             | -- c         | TODO\n");
  printf("MISC      | *  //  | comment (skips to end of line)            | --           | DONE\n");
  printf("MISC      | *  /N  | print CRLF                                | --           | DONE\n");
  printf("MISC      |   /P   | print prompt                              | --           | TODO\n");
  printf("MISC      | * debug| toggle debug mode on/off                  | --           | DONE\n");
  printf("===================================================================================================\n");
  printf("Type 'bye' to quit\n");
  printf("Type 'debug' to toggle debug mode\n");
  printf("===================================================================================================\n\n");
endfunction


## ========================================================================
## DEBUG FUNCTIONS - Can be toggled on/off at startup or with 'debug'
## ========================================================================

function debug_before_op(op, stack)
  printf("[DEBUG] BEFORE %s: stack=", op);
  debug_print_stack(stack);
endfunction

function debug_after_op(op, desc, stack)
  printf("[DEBUG] AFTER %s: %s, stack=", op, desc);
  debug_print_stack(stack);
endfunction

function debug_print_stack(stack)
  if isempty(stack)
    printf("(empty)\n");
  else
    printf("[");
    for i = 1:length(stack)
      printf("%g", stack(i));
      if i < length(stack)
        printf(" ");
      endif
    endfor
    printf("]\n");
  endif
endfunction

function debug_show_stack()
  global state;
  printf("[DEBUG] STACK: ");
  debug_print_stack(state.stack);
endfunction

function debug_show_vars()
  global state;
  printf("[DEBUG] VARIABLES:\n");
  for i = 1:26
    if state.vars(i) != 0
      printf("  %c = %g\n", char('a' + i - 1), state.vars(i));
    endif
  endfor
endfunction

function debug_show_heap()
  global state;
  printf("[DEBUG] HEAP: ptr=%d, used=%d bytes\n", state.heap_ptr, state.heap_ptr-1);
  if state.heap_ptr > 1
    printf("  First 20 heap entries: ");
    for i = 1:min(20, state.heap_ptr-1)
      printf("%g ", state.heap(i));
    endfor
    printf("\n");
  endif
endfunction

function debug_show_final_state()
  global state;
  printf("\n[DEBUG] === FINAL STATE ===\n");
  debug_show_stack();
  debug_show_vars();
  printf("[DEBUG] SYSTEM: /c=%g, /r=%g, /i=%g, /j=%g\n", state.sys_c, state.sys_r, state.loop_i, state.loop_j);
  printf("[DEBUG] ====================\n");
endfunction

function r = iif(condition, true_val, false_val)
  if condition
    r = true_val;
  else
    r = false_val;
  endif
endfunction
