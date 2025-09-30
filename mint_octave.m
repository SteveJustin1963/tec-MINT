## ----------------------------------------------------------------------
## MINT/Forth-like Minimal Interpreter in Octave
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

  ## Initialize builtins
  add_builtin_words();

  ## History buffer
  history = {};
  hist_ptr = 1;

  printf("MINT-Octave REPL v2.1 (2025-01-20). Type 'bye' to quit.\n");

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
      interpret_line(line);
      printf("\n");  ## Add newline after execution
    catch err
      fprintf("ERROR: %s\n", err.message);
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
  
  ## Help
  state.dict("help") = @(s) show_help(s);
  state.dict("list") = @(s) list_functions(s);
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
  [s,b]=pop(s); [s,a]=pop(s);
  result = a + b;
  s=push(s, result);
  state.sys_c = 0;  ## Clear carry (no carry with 64-bit floats)
  state.sys_r = 0;  ## Clear remainder
endfunction

function s = math_sub(s)
  global state;
  [s,b]=pop(s); [s,a]=pop(s);
  result = a - b;
  s=push(s, result);
  state.sys_c = 0;  ## Clear carry
  state.sys_r = 0;  ## Clear remainder
endfunction

function s = math_mul(s)
  global state;
  [s,b]=pop(s); [s,a]=pop(s);
  result = a * b;
  s=push(s, result);
  state.sys_c = 0;  ## Clear carry
  state.sys_r = 0;  ## Clear overflow (no overflow with 64-bit floats)
endfunction

function s = math_div(s)
  global state;
  [s,b]=pop(s); [s,a]=pop(s);
  if b == 0
    error("DIVISION BY ZERO");
  endif
  result = floor(a / b);
  remainder = mod(a, b);
  s=push(s, result);
  state.sys_c = 0;  ## Clear carry
  state.sys_r = remainder;  ## Store remainder
endfunction


## --------------------------
## Comparison Functions
## --------------------------
function s = compare_gt(s)
  [s,b]=pop(s); [s,a]=pop(s);
  if a > b
    s=push(s,-1);  ## True in MINT is -1
  else
    s=push(s,0);   ## False in MINT is 0
  endif
endfunction

function s = compare_lt(s)
  [s,b]=pop(s); [s,a]=pop(s);
  if a < b
    s=push(s,-1);  ## True in MINT is -1
  else
    s=push(s,0);   ## False in MINT is 0
  endif
endfunction

function s = compare_eq(s)
  [s,b]=pop(s); [s,a]=pop(s);
  if a == b
    s=push(s,-1);  ## True in MINT is -1
  else
    s=push(s,0);   ## False in MINT is 0
  endif
endfunction


## --------------------------
## Bitwise Functions
## --------------------------
function s = bitwise_and(s)
  [s,b]=pop(s); [s,a]=pop(s);
  s=push(s, bitand(int64(a), int64(b)));
endfunction

function s = bitwise_or(s)
  [s,b]=pop(s); [s,a]=pop(s);
  s=push(s, bitor(int64(a), int64(b)));
endfunction

function s = bitwise_xor(s)
  [s,b]=pop(s); [s,a]=pop(s);
  s=push(s, bitxor(int64(a), int64(b)));
endfunction

function s = bitwise_not(s)
  [s,a]=pop(s);
  s=push(s, bitcmp(int64(a), 64));  ## 64-bit NOT
endfunction

function s = shift_left(s)
  [s,a]=pop(s);
  s=push(s, bitshift(int64(a), 1));  ## Shift left by 1
endfunction

function s = shift_right(s)
  [s,a]=pop(s);
  s=push(s, bitshift(int64(a), -1));  ## Shift right by 1
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
  state.vars(state.last_var) = val;  ## Store in variable
  state.last_var = -1;  ## Reset
endfunction


## --------------------------
## Loop Control Functions
## --------------------------
function s = loop_while(s)
  global state;
  [s, condition] = pop(s);
  if condition == 0  ## If false (0), break loop
    state.break_loop = true;
  endif
endfunction

function s = get_loop_i(s)
  global state;
  s = push(s, state.loop_i);
endfunction

function s = get_loop_j(s)
  global state;
  s = push(s, state.loop_j);
endfunction

function s = get_sys_c(s)
  global state;
  s = push(s, state.sys_c);
endfunction

function s = get_sys_r(s)
  global state;
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
## Interpreter Functions
## --------------------------
function interpret_line(line)
  global state;
  
  ## Handle backtick strings - extract them before tokenizing
  processed_line = "";
  i = 1;
  while i <= length(line)
    if line(i) == '`'
      ## Found start of string, find closing backtick
      j = i + 1;
      while j <= length(line) && line(j) != '`'
        j++;
      endwhile
      if j <= length(line)
        ## Extract string between backticks and print it
        str_content = line(i+1:j-1);
        printf("%s", str_content);
        i = j + 1;
      else
        error("Unclosed backtick string");
      endif
    else
      processed_line = [processed_line, line(i)];
      i++;
    endif
  endwhile
  
  ## Skip processing if line only contained strings
  processed_line = strtrim(processed_line);
  if isempty(processed_line)
    return;
  endif
  
  tokens = strsplit(processed_line);
  compile_mode = false;
  current_def = {};

  i = 1;
  while i <= length(tokens)
    tok = tokens{i};
    
    ## Check if token starts with : (function definition)
    if length(tok) > 1 && tok(1) == ':'
      compile_mode = true;
      current_def = {};
      current_def{1} = tok(2:end);  ## Extract function name (e.g., "F" from ":F")
      i++;
      continue;
    elseif strcmp(tok, ";")
      compile_mode = false;
      state.colon_defs(current_def{1}) = current_def(2:end);
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
      else
        execute_token(tok);
        i++;
      endif
    endif
  endwhile
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
    else
      count = 1;  ## Boolean true (-1) means run once
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
    
    ## Process body tokens (which may contain nested loops)
    execute_token_sequence(body);
    
    if state.break_loop
      break;  ## Break out of loop
    endif
  endfor
  
  ## Restore loop counters
  state.loop_i = saved_i;
  state.loop_j = saved_j;
endfunction


## Execute conditional (if-then-else)
function execute_conditional(then_body, else_body)
  global state;
  
  ## Pop condition from stack
  if isempty(state.stack)
    error("Conditional requires a condition on stack");
  endif
  [state.stack, condition] = pop(state.stack);
  
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

  if isKey(state.colon_defs, tok)
    for j = 1:length(state.colon_defs(tok))
      execute_token(state.colon_defs(tok){j});
    endfor
  elseif isKey(state.dict, tok)
    state.stack = state.dict(tok)(state.stack);
  elseif length(tok) == 1 && tok >= 'a' && tok <= 'z'
    ## Single lowercase letter variable (a-z)
    idx = double(tok) - double('a') + 1;  ## Convert 'a'->1, 'b'->2, etc.
    state.last_var = idx;  ## Remember which variable for potential storage
    state.stack = push(state.stack, state.vars(idx));
  elseif length(tok) > 1 && tok(1) == '#'
    ## Hexadecimal number (e.g., #FF, #1F3A)
    hex_str = tok(2:end);
    num = hex2dec(hex_str);
    state.stack = push(state.stack, num);
  elseif !isnan(str2double(tok))
    ## Support 64-bit floating point numbers
    state.stack = push(state.stack, str2double(tok));
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
  [s,~]=pop(s);
endfunction

function s = dup(s)
  [s,a]=pop(s); s=push(s,a); s=push(s,a);
endfunction

function s = swap(s)
  [s,a]=pop(s); [s,b]=pop(s);
  s=push(s,a); s=push(s,b);
endfunction

function s = over(s)
  if length(s)<2, error("STACK UNDERFLOW"); endif
  s=push(s,s(end-1));
endfunction

function s = stack_depth(s)
  s=push(s, length(s));
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
  printf("  Display:      format long (15-16 significant digits for scientific work)\n\n");
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
  printf("LOOP      |    (   | BEGIN loop repeat n times                 | n --         | TODO\n");
  printf("LOOP      |    )   | END loop code block                       | --           | TODO\n");
  printf("LOOP      |   /U   | unlimited loop constant                   | -- b         | TODO\n");
  printf("LOOP      |   /W   | if false break out of loop                | b --         | TODO\n");
  printf("LOOP      |   /E   | else condition                            | -- b         | TODO\n");
  printf("LOOP      |   /F   | false constant                            | -- b         | TODO\n");
  printf("LOOP      |   /T   | true constant                             | -- b         | TODO\n");
  printf("VARIABLE  | *  a-z | variable access                           | -- n         | DONE\n");
  printf("VARIABLE  | *  !   | STORE value to memory                     | n a --       | DONE\n");
  printf("VARIABLE  |   /V   | address of last access                    | -- a         | TODO\n");
  printf("ARRAY     |    [   | begin array definition                    | --           | TODO\n");
  printf("ARRAY     |    ]   | end array definition                      | -- a         | TODO\n");
  printf("ARRAY     |    ?   | get array item                            | a n -- n     | TODO\n");
  printf("ARRAY     |   /S   | array size                                | a -- n       | TODO\n");
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
  printf("MISC      |   //   | comment (skips to end of line)            | --           | TODO\n");
  printf("MISC      |   /N   | print CRLF                                | --           | TODO\n");
  printf("MISC      |   /P   | print prompt                              | --           | TODO\n");
  printf("===================================================================================================\n");
  printf("Type 'bye' to quit\n");
  printf("===================================================================================================\n\n");
endfunction
