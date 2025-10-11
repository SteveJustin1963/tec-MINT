## ----------------------------------------------------------------------
## MINT/Forth-like Minimal Interpreter in Octave with DEBUG MODE
## Version 2.6 - Multi-char variables FULLY FIXED
## ----------------------------------------------------------------------
function mint_octave_12()
  clear global;
  global state;

  ## Set display format for scientific work
  format long;

## Interpreter state
  state.stack = [];
  state.vars = containers.Map();  ## FIXED: Changed from array to Map for multi-char support
  state.heap = zeros(1,4096);
  state.heap_ptr = 1;
  state.start_time = time();  ## Track program start time for timestamps
  state.dict = containers.Map();
  state.colon_defs = containers.Map();
  state.last_var = "";  ## FIXED: Changed from -1 to empty string
  state.loop_i = 0;
  state.loop_j = 0;
  state.break_loop = false;
  state.sys_c = 0;
  state.sys_r = 0;
  state.debug = false;
  state.debug_file = -1;

  ## Capture mode for multi-line function definitions
  state.capture_mode = false;
  state.capture_buffer = "";
  state.capture_name = "";

  ## I/O Port simulation state
  state.port_dir = "mint_ports";
  state.port_buffers = containers.Map('KeyType', 'double', 'ValueType', 'any');

  

  ## Initialize builtins
  add_builtin_words();

  ## History buffer
  history = {};
  hist_ptr = 1;

  printf("MINT-Octave REPL v2.6 (2025-10-08). Type 'bye' to quit.\n");

  ## Ask user if they want debug mode
  debug_choice = input("Enable debug mode? (y/n): ", "s");
  if strcmpi(debug_choice, "y") || strcmpi(debug_choice, "yes")
    state.debug = true;

    ## Open debug log file
    debug_filename = sprintf("mint_debug_%s.log", datestr(now, "yyyymmdd_HHMMSS"));
    state.debug_file = fopen(debug_filename, "w");

    if state.debug_file == -1
      printf("WARNING: Could not open debug file '%s'\n", debug_filename);
    else
      printf("\n*** DEBUG MODE ENABLED ***\n");
      printf("Debug output will be written to: %s\n", debug_filename);
    endif

    printf("Debug output will show:\n");
    printf("  - Token processing\n");
    printf("  - Stack state\n");
    printf("  - Variable changes\n");
    printf("  - Function calls\n");
    printf("  - Loop iterations\n");
    printf("  - Capture mode status\n\n");
  else
    state.debug = false;
    printf("\n*** DEBUG MODE DISABLED ***\n\n");
  endif

  ## Main REPL Loop with Capture Mode Support
  while true
    if state.capture_mode
      printf("... ");
    else
      printf("> ");
    endif
    fflush(stdout);

    line = input("", "s");

    if isempty(line)
      continue;
    endif

    if strcmpi(line, "bye") && !state.capture_mode
      if state.debug && state.debug_file != -1
        fclose(state.debug_file);
        printf("Debug log saved.\n");
      endif
      break;
    endif

    history{end+1} = line;
    hist_ptr = numel(history)+1;

    ## Check if entering capture mode - ENHANCED VERSION
    if !state.capture_mode
      trimmed = strtrim(line);
      ## Allow : followed by any uppercase letter OR underscore for temp blocks
      if length(trimmed) >= 1 && trimmed(1) == ':'
        if length(trimmed) == 1
          ## Just ":" alone - prompt for function name
          printf("Function name required (A-Z or _ for temporary)\n");
          continue;
        endif
        
        func_char = trimmed(2);
        if (func_char >= 'A' && func_char <= 'Z') || func_char == '_'
          state.capture_mode = true;
          state.capture_name = func_char;
          state.capture_buffer = line;

          if state.debug
            if func_char == '_'
              debug_print("[DEBUG] >>> ENTERING CAPTURE MODE for TEMPORARY block\n");
            else
              debug_print(sprintf("[DEBUG] >>> ENTERING CAPTURE MODE for function '%s'\n", state.capture_name));
            endif
          endif

          ## Check if single-line definition
          if any(strfind(line, ';'))
            state.capture_mode = false;
            try
              if state.debug
                debug_print(sprintf("[DEBUG] SINGLE-LINE FUNCTION: %s\n", state.capture_buffer));
              endif
              interpret_line(state.capture_buffer);
              if state.debug
                debug_print(sprintf("[DEBUG] <<< FUNCTION '%s' SAVED\n", state.capture_name));
              endif
              
              ## Execute and delete if temporary
              if state.capture_name == '_'
                execute_temp_function();
              endif
            catch err
              fprintf("ERROR: %s\n", err.message);
              if state.debug
                try
                  if isfield(err, 'stack')
                    fprintf("ERROR STACK:\n");
                    disp(err.stack);
                  endif
                catch
                  fprintf("(Stack trace not available)\n");
                end_try_catch
              endif
            end_try_catch
            state.capture_buffer = "";
            state.capture_name = "";
          endif
          continue;
        else
          printf("Invalid function name. Use A-Z or _ for temporary blocks.\n");
          continue;
        endif
      endif
    endif

    ## If in capture mode, accumulate lines
    if state.capture_mode
      state.capture_buffer = [state.capture_buffer, " ", line];

      if state.debug
        debug_print("[DEBUG] CAPTURE: accumulating line into buffer\n");
      endif

      ## Check for semicolon to end capture
      if any(strfind(line, ';'))
        state.capture_mode = false;

        if state.debug
          debug_print("[DEBUG] <<< EXITING CAPTURE MODE\n");
          debug_print(sprintf("[DEBUG] COMPLETE BUFFER: %s\n", state.capture_buffer));
        endif

        try
          interpret_line(state.capture_buffer);
          if state.debug
            if state.capture_name == '_'
              debug_print("[DEBUG] TEMPORARY BLOCK SAVED\n");
            else
              debug_print(sprintf("[DEBUG] FUNCTION '%s' SAVED SUCCESSFULLY\n", state.capture_name));
            endif
          endif
          
          ## Execute and delete if temporary
          if state.capture_name == '_'
            execute_temp_function();
          endif
          
          if state.debug
            debug_show_final_state();
          endif
          printf("\n");
        catch err
          fprintf("ERROR: %s\n", err.message);
          if state.debug
            try
              if isfield(err, 'stack')
                fprintf("ERROR STACK:\n");
                disp(err.stack);
              endif
            catch
              fprintf("(Stack trace not available)\n");
            end_try_catch
          endif
        end_try_catch

        state.capture_buffer = "";
        state.capture_name = "";
      endif
      continue;
    endif

    ## Normal immediate mode execution
    try
      if state.debug
        debug_print(sprintf("\n=== EXECUTING LINE: %s ===\n", line));
      endif
      interpret_line(line);
      if state.debug
        debug_show_final_state();
      endif
      printf("\n");
    catch err
      fprintf("ERROR: %s\n", err.message);
      if state.debug
        try
          if isfield(err, 'stack')
            fprintf("ERROR STACK:\n");
            disp(err.stack);
          endif
        catch
          fprintf("(Stack trace not available)\n");
        end_try_catch
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
  state.dict("**") = @(s) math_power(s);

  ## Trigonometric functions
  state.dict("/sin") = @(s) trig_sin(s);
  state.dict("/cos") = @(s) trig_cos(s);
  state.dict("/tan") = @(s) trig_tan(s);
  state.dict("/asin") = @(s) trig_asin(s);
  state.dict("/acos") = @(s) trig_acos(s);
  state.dict("/atan") = @(s) trig_atan(s);
  state.dict("/atan2") = @(s) trig_atan2(s);
  state.dict("/sinh") = @(s) trig_sinh(s);
  state.dict("/cosh") = @(s) trig_cosh(s);
  state.dict("/tanh") = @(s) trig_tanh(s);
  state.dict("/asinh") = @(s) trig_asinh(s);
  state.dict("/acosh") = @(s) trig_acosh(s);
  state.dict("/atanh") = @(s) trig_atanh(s);

  ## Trig constants and conversions
  state.dict("/pi") = @(s) push(s, pi);
  state.dict("/e") = @(s) push(s, exp(1));
  state.dict("/deg") = @(s) rad_to_deg(s);
  state.dict("/rad") = @(s) deg_to_rad(s);

  ## Additional math functions
  state.dict("/sqrt") = @(s) math_sqrt(s);
  state.dict("/abs") = @(s) math_abs(s);
  state.dict("/ln") = @(s) math_ln(s);
  state.dict("/log") = @(s) math_log10(s);
  state.dict("/exp") = @(s) math_exp(s);

  ## Rounding and modulo functions
  state.dict("/floor") = @(s) math_floor(s);
  state.dict("/ceil") = @(s) math_ceil(s);
  state.dict("/round") = @(s) math_round(s);
  state.dict("/mod") = @(s) math_mod(s);

  ## Min/max functions
  state.dict("/min") = @(s) math_min(s);
  state.dict("/max") = @(s) math_max(s);
  ## Sign and truncate functions
  state.dict("/sign") = @(s) math_sign(s);
  state.dict("/trunc") = @(s) math_trunc(s);

  ## Stack ops
  state.dict("'") = @(s) drop(s);
  state.dict('"') = @(s) dup(s);
  state.dict("$") = @(s) swap(s);
  state.dict("%") = @(s) over(s);
  state.dict("/D") = @(s) stack_depth(s);
  state.dict("/CS") = @(s) clear_stack(s);

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
  state.dict("/F") = @(s) push(s, 0);
  state.dict("/T") = @(s) push(s, -1);
  state.dict("/U") = @(s) push(s, -1);
  state.dict("/W") = @(s) loop_while(s);
  state.dict("/i") = @(s) get_loop_i(s);
  state.dict("/j") = @(s) get_loop_j(s);

  ## System variables
  state.dict("/c") = @(s) get_sys_c(s);
  state.dict("/r") = @(s) get_sys_r(s);

  ## I/O operations
  state.dict("/C") = @(s) print_char(s);
  state.dict("/N") = @(s) print_newline(s);
  state.dict("/K") = @(s) read_char(s);
  state.dict("/KS") = @(s) read_string(s);
  state.dict("/O") = @(s) port_output(s);
  state.dict("/I") = @(s) port_input(s);

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
  state.sys_c = 0;
  state.sys_r = 0;
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
  state.sys_c = 0;
  state.sys_r = 0;
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
  state.sys_c = 0;
  state.sys_r = 0;
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
  result = a / b;
  s=push(s, result);
  state.sys_c = 0;
  state.sys_r = 0;
  if state.debug
    debug_after_op("/", sprintf("%g / %g = %g", a, b, result), s);
  endif
endfunction

function s = math_power(s)
  global state;
  if state.debug
    debug_before_op("**", s);
  endif
  [s,b]=pop(s); [s,a]=pop(s);

  ## Check if operation would produce complex result
  if a < 0 && floor(b) != b
    error("Cannot raise negative number (%g) to fractional power (%g) - would produce complex result", a, b);
  endif

  result = a ^ b;

  ## Safety check: ensure result is real
  if ~isreal(result)
    error("Power operation produced complex result: %g ** %g", a, b);
  endif

  s=push(s, result);
  state.sys_c = 0;
  state.sys_r = 0;
  if state.debug
    debug_after_op("**", sprintf("%g ** %g = %g", a, b, result), s);
  endif
endfunction

function s = math_exp(s)
  global state;
  if state.debug
    debug_before_op("/exp", s);
  endif
  [s, val] = pop(s);
  result = exp(val);
  s = push(s, result);
  if state.debug
    debug_after_op("/exp", sprintf("exp(%g) = %g", val, result), s);
  endif
endfunction

## Rounding Functions
function s = math_floor(s)
  global state;
  if state.debug
    debug_before_op("/floor", s);
  endif
  [s, val] = pop(s);
  result = floor(val);
  s = push(s, result);
  if state.debug
    debug_after_op("/floor", sprintf("floor(%g) = %g", val, result), s);
  endif
endfunction

function s = math_ceil(s)
  global state;
  if state.debug
    debug_before_op("/ceil", s);
  endif
  [s, val] = pop(s);
  result = ceil(val);
  s = push(s, result);
  if state.debug
    debug_after_op("/ceil", sprintf("ceil(%g) = %g", val, result), s);
  endif
endfunction

function s = math_round(s)
  global state;
  if state.debug
    debug_before_op("/round", s);
  endif
  [s, val] = pop(s);
  result = round(val);
  s = push(s, result);
  if state.debug
    debug_after_op("/round", sprintf("round(%g) = %g", val, result), s);
  endif
endfunction

function s = math_mod(s)
  global state;
  if state.debug
    debug_before_op("/mod", s);
  endif
  [s, b] = pop(s);
  [s, a] = pop(s);
  if b == 0
    error("mod: division by zero");
  endif
  result = mod(a, b);
  s = push(s, result);
  if state.debug
    debug_after_op("/mod", sprintf("mod(%g, %g) = %g", a, b, result), s);
  endif
endfunction

## Min/Max Functions
function s = math_min(s)
  global state;
  if state.debug
    debug_before_op("/min", s);
  endif
  [s, b] = pop(s);
  [s, a] = pop(s);
  result = min(a, b);
  s = push(s, result);
  if state.debug
    debug_after_op("/min", sprintf("min(%g, %g) = %g", a, b, result), s);
  endif
endfunction

function s = math_max(s)
  global state;
  if state.debug
    debug_before_op("/max", s);
  endif
  [s, b] = pop(s);
  [s, a] = pop(s);
  result = max(a, b);
  s = push(s, result);
  if state.debug
    debug_after_op("/max", sprintf("max(%g, %g) = %g", a, b, result), s);
  endif
endfunction

## Sign and Truncate Functions
function s = math_sign(s)
  global state;
  if state.debug
    debug_before_op("/sign", s);
  endif
  [s, val] = pop(s);
  result = sign(val);
  s = push(s, result);
  if state.debug
    debug_after_op("/sign", sprintf("sign(%g) = %g", val, result), s);
  endif
endfunction

function s = math_trunc(s)
  global state;
  if state.debug
    debug_before_op("/trunc", s);
  endif
  [s, val] = pop(s);
  result = fix(val);
  s = push(s, result);
  if state.debug
    debug_after_op("/trunc", sprintf("trunc(%g) = %g", val, result), s);
  endif
endfunction

## --------------------------
## Trigonometric Functions
## --------------------------

## Basic Trigonometric Functions (angles in radians)
function s = trig_sin(s)
  global state;
  if state.debug
    debug_before_op("/sin", s);
  endif
  [s, angle] = pop(s);
  result = sin(angle);
  s = push(s, result);
  if state.debug
    debug_after_op("/sin", sprintf("sin(%g) = %g", angle, result), s);
  endif
endfunction

function s = trig_cos(s)
  global state;
  if state.debug
    debug_before_op("/cos", s);
  endif
  [s, angle] = pop(s);
  result = cos(angle);
  s = push(s, result);
  if state.debug
    debug_after_op("/cos", sprintf("cos(%g) = %g", angle, result), s);
  endif
endfunction

function s = trig_tan(s)
  global state;
  if state.debug
    debug_before_op("/tan", s);
  endif
  [s, angle] = pop(s);
  result = tan(angle);
  s = push(s, result);
  if state.debug
    debug_after_op("/tan", sprintf("tan(%g) = %g", angle, result), s);
  endif
endfunction

## Inverse Trigonometric Functions (return radians)
function s = trig_asin(s)
  global state;
  if state.debug
    debug_before_op("/asin", s);
  endif
  [s, val] = pop(s);
  if val < -1 || val > 1
    error("asin domain error: value %g must be in [-1, 1]", val);
  endif
  result = asin(val);
  s = push(s, result);
  if state.debug
    debug_after_op("/asin", sprintf("asin(%g) = %g", val, result), s);
  endif
endfunction

function s = trig_acos(s)
  global state;
  if state.debug
    debug_before_op("/acos", s);
  endif
  [s, val] = pop(s);
  if val < -1 || val > 1
    error("acos domain error: value %g must be in [-1, 1]", val);
  endif
  result = acos(val);
  s = push(s, result);
  if state.debug
    debug_after_op("/acos", sprintf("acos(%g) = %g", val, result), s);
  endif
endfunction

function s = trig_atan(s)
  global state;
  if state.debug
    debug_before_op("/atan", s);
  endif
  [s, val] = pop(s);
  result = atan(val);
  s = push(s, result);
  if state.debug
    debug_after_op("/atan", sprintf("atan(%g) = %g", val, result), s);
  endif
endfunction

function s = trig_atan2(s)
  global state;
  if state.debug
    debug_before_op("/atan2", s);
  endif
  [s, x] = pop(s);
  [s, y] = pop(s);
  result = atan2(y, x);
  s = push(s, result);
  if state.debug
    debug_after_op("/atan2", sprintf("atan2(%g, %g) = %g", y, x, result), s);
  endif
endfunction

## Hyperbolic Trigonometric Functions
function s = trig_sinh(s)
  global state;
  if state.debug
    debug_before_op("/sinh", s);
  endif
  [s, val] = pop(s);
  result = sinh(val);
  s = push(s, result);
  if state.debug
    debug_after_op("/sinh", sprintf("sinh(%g) = %g", val, result), s);
  endif
endfunction

function s = trig_cosh(s)
  global state;
  if state.debug
    debug_before_op("/cosh", s);
  endif
  [s, val] = pop(s);
  result = cosh(val);
  s = push(s, result);
  if state.debug
    debug_after_op("/cosh", sprintf("cosh(%g) = %g", val, result), s);
  endif
endfunction

function s = trig_tanh(s)
  global state;
  if state.debug
    debug_before_op("/tanh", s);
  endif
  [s, val] = pop(s);
  result = tanh(val);
  s = push(s, result);
  if state.debug
    debug_after_op("/tanh", sprintf("tanh(%g) = %g", val, result), s);
  endif
endfunction

## Inverse Hyperbolic Trigonometric Functions
function s = trig_asinh(s)
  global state;
  if state.debug
    debug_before_op("/asinh", s);
  endif
  [s, val] = pop(s);
  result = asinh(val);
  s = push(s, result);
  if state.debug
    debug_after_op("/asinh", sprintf("asinh(%g) = %g", val, result), s);
  endif
endfunction

function s = trig_acosh(s)
  global state;
  if state.debug
    debug_before_op("/acosh", s);
  endif
  [s, val] = pop(s);
  if val < 1
    error("acosh domain error: value %g must be >= 1", val);
  endif
  result = acosh(val);
  s = push(s, result);
  if state.debug
    debug_after_op("/acosh", sprintf("acosh(%g) = %g", val, result), s);
  endif
endfunction

function s = trig_atanh(s)
  global state;
  if state.debug
    debug_before_op("/atanh", s);
  endif
  [s, val] = pop(s);
  if val <= -1 || val >= 1
    error("atanh domain error: value %g must be in (-1, 1)", val);
  endif
  result = atanh(val);
  s = push(s, result);
  if state.debug
    debug_after_op("/atanh", sprintf("atanh(%g) = %g", val, result), s);
  endif
endfunction

## Angle Conversion Functions
function s = deg_to_rad(s)
  global state;
  if state.debug
    debug_before_op("/rad", s);
  endif
  [s, degrees] = pop(s);
  radians = degrees * pi / 180;
  s = push(s, radians);
  if state.debug
    debug_after_op("/rad", sprintf("%g degrees = %g radians", degrees, radians), s);
  endif
endfunction

function s = rad_to_deg(s)
  global state;
  if state.debug
    debug_before_op("/deg", s);
  endif
  [s, radians] = pop(s);
  degrees = radians * 180 / pi;
  s = push(s, degrees);
  if state.debug
    debug_after_op("/deg", sprintf("%g radians = %g degrees", radians, degrees), s);
  endif
endfunction

## Additional Math Functions
function s = math_sqrt(s)
  global state;
  if state.debug
    debug_before_op("/sqrt", s);
  endif
  [s, val] = pop(s);
  if val < 0
    error("sqrt domain error: cannot take square root of negative number %g", val);
  endif
  result = sqrt(val);
  s = push(s, result);
  if state.debug
    debug_after_op("/sqrt", sprintf("sqrt(%g) = %g", val, result), s);
  endif
endfunction

function s = math_abs(s)
  global state;
  if state.debug
    debug_before_op("/abs", s);
  endif
  [s, val] = pop(s);
  result = abs(val);
  s = push(s, result);
  if state.debug
    debug_after_op("/abs", sprintf("abs(%g) = %g", val, result), s);
  endif
endfunction

function s = math_ln(s)
  global state;
  if state.debug
    debug_before_op("/ln", s);
  endif
  [s, val] = pop(s);
  if val <= 0
    error("ln domain error: cannot take natural log of non-positive number %g", val);
  endif
  result = log(val);
  s = push(s, result);
  if state.debug
    debug_after_op("/ln", sprintf("ln(%g) = %g", val, result), s);
  endif
endfunction

function s = math_log10(s)
  global state;
  if state.debug
    debug_before_op("/log", s);
  endif
  [s, val] = pop(s);
  if val <= 0
    error("log domain error: cannot take log of non-positive number %g", val);
  endif
  result = log10(val);
  s = push(s, result);
  if state.debug
    debug_after_op("/log", sprintf("log10(%g) = %g", val, result), s);
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
    s=push(s,-1);
  else
    s=push(s,0);
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
    s=push(s,-1);
  else
    s=push(s,0);
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
    s=push(s,-1);
  else
    s=push(s,0);
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
  result = bitand(bitand(int64(a), 65535), bitand(int64(b), 65535));
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
  a_16 = bitand(int64(a), 65535);
  b_16 = bitand(int64(b), 65535);
  result = bitor(a_16, b_16);
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
  a_16 = bitand(int64(a), 65535);
  b_16 = bitand(int64(b), 65535);
  result = bitxor(a_16, b_16);
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
  a_16bit = bitand(int64(a), int64(65535));
  result = bitxor(a_16bit, int64(65535));
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
  a_16 = bitand(int64(a), 65535);
  result = bitand(bitshift(a_16, 1), 65535);
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
  a_16 = bitand(int64(a), 65535);
  result = bitshift(a_16, -1);
  s=push(s, result);
  if state.debug
    debug_after_op("}", sprintf("%g >> 1 = %g", a, result), s);
  endif
endfunction

## --------------------------
## Variable Functions - FIXED for multi-char support
## --------------------------
function s = store_var(s)
  global state;
  if isempty(state.last_var)
    error("! requires a variable before it (e.g., 10 x !)");
  endif
  [s, val] = pop(s);
  
  old_val = 0;
  if isKey(state.vars, state.last_var)
    old_val = state.vars(state.last_var);
  endif
  
  if state.debug
    debug_print(sprintf("[DEBUG] STORE: %s = %g (was %g)\n", state.last_var, val, old_val));
  endif
  
  state.vars(state.last_var) = val;
  state.last_var = "";
endfunction

## --------------------------
## Loop Control Functions
## --------------------------
function s = loop_while(s)
  global state;
  [s, condition] = pop(s);
  if state.debug
    debug_print(sprintf("[DEBUG] /W: condition=%g, break=%s\n", condition, iif(condition==0, "YES", "NO")));
  endif
  if condition == 0
    state.break_loop = true;
  endif
endfunction

function s = get_loop_i(s)
  global state;
  if state.debug
    debug_print(sprintf("[DEBUG] /i: pushing loop_i=%g\n", state.loop_i));
  endif
  s = push(s, state.loop_i);
endfunction

function s = get_loop_j(s)
  global state;
  if state.debug
    debug_print(sprintf("[DEBUG] /j: pushing loop_j=%g\n", state.loop_j));
  endif
  s = push(s, state.loop_j);
endfunction

function s = get_sys_c(s)
  global state;
  if state.debug
    debug_print(sprintf("[DEBUG] /c: pushing carry=%g\n", state.sys_c));
  endif
  s = push(s, state.sys_c);
endfunction

function s = get_sys_r(s)
  global state;
  if state.debug
    debug_print(sprintf("[DEBUG] /r: pushing remainder=%g\n", state.sys_r));
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
  for i = 1:length(str)
    s = push(s, double(str(i)));
  endfor
  s = push(s, length(str));
endfunction

## --------------------------
## Port I/O Functions (Simulated via Files)
## --------------------------
function s = port_output(s)
  global state;
  [s, port] = pop(s);
  [s, value] = pop(s);

  if port < 0 || port > 255
    error("Port number must be 0-255");
  endif

  if !exist(state.port_dir, "dir")
    mkdir(state.port_dir);
    if state.debug
      debug_print(sprintf("[DEBUG] PORT: created directory '%s'\n", state.port_dir));
    endif
  endif

  filename = sprintf("%s/port%d.txt", state.port_dir, port);

  ## Calculate timestamp (seconds since program start)
  timestamp = time() - state.start_time;

  if state.debug
    debug_print(sprintf("[DEBUG] PORT OUTPUT: writing [%g] %g to port %d (%s)\n", timestamp, value, port, filename));
  endif

  fid = fopen(filename, "a");
  if fid == -1
    error("Failed to open port file: %s", filename);
  endif

  ## Write as timestamp-value pair with newline
  fprintf(fid, "%g %g\n", timestamp, value);
  fclose(fid);

  ## Clear buffer so next read will reload the file
  if isKey(state.port_buffers, port)
    remove(state.port_buffers, port);
  endif
endfunction

function s = port_input(s)
  global state;
  [s, port] = pop(s);

  if port < 0 || port > 255
    error("Port number must be 0-255");
  endif

  filename = sprintf("%s/port%d.txt", state.port_dir, port);

  if state.debug
    debug_print(sprintf("[DEBUG] PORT INPUT: reading from port %d (%s)\n", port, filename));
  endif

  if !isKey(state.port_buffers, port)
    if !exist(filename, "file")
      error("Port file does not exist: %s (port %d not ready)", filename, port);
    endif

    fid = fopen(filename, "r");
    if fid == -1
      error("Failed to open port file: %s", filename);
    endif

    content = fread(fid, Inf, "char=>char")';
    fclose(fid);

    values = str2num(content);
    if isempty(values)
      error("No data available in port %d", port);
    endif

    ## Flatten matrix to row vector (in case file has newlines)
    values = reshape(values', 1, []);

    ## Parse timestamp-value pairs: extract only values (every other number starting at index 2)
    value_only = [];
    for i = 2:2:length(values)
      value_only(end+1) = values(i);
    endfor

    state.port_buffers(port) = num2cell(value_only);

    if state.debug
      debug_print(sprintf("[DEBUG] PORT: loaded %d values from port %d\n", length(value_only), port));
    endif
  endif

  buffer = state.port_buffers(port);

  if isempty(buffer)
    error("No more data available in port %d", port);
  endif

  value = buffer{1};
  buffer(1) = [];
  state.port_buffers(port) = buffer;

  if state.debug
    debug_print(sprintf("[DEBUG] PORT INPUT: read %g from port %d (%d values remaining)\n", value, port, length(buffer)));
  endif

  s = push(s, value);
endfunction

## --------------------------
## Array Functions
## --------------------------
function s = get_array_item(s)
  global state;
  [s, idx] = pop(s);
  [s, addr] = pop(s);

  size = state.heap(addr);
  if idx < 0 || idx >= size
    error("Array index out of bounds: %d (size=%d)", idx, size);
  endif

  value = state.heap(addr + 1 + idx);
  if state.debug
    debug_print(sprintf("[DEBUG] ARRAY GET: addr=%g, idx=%g -> value=%g\n", addr, idx, value));
  endif
  s = push(s, value);
endfunction

function s = set_array_item(s)
  global state;
  [s, idx] = pop(s);
  [s, addr] = pop(s);
  [s, val] = pop(s);

  size = state.heap(addr);
  if idx < 0 || idx >= size
    error("Array index out of bounds: %d (size=%d)", idx, size);
  endif

  if state.debug
    debug_print(sprintf("[DEBUG] ARRAY SET: addr=%g, idx=%g, value=%g (was %g)\n", addr, idx, val, state.heap(addr + 1 + idx)));
  endif
  state.heap(addr + 1 + idx) = val;
endfunction

function s = array_size(s)
  global state;
  [s, addr] = pop(s);

  size = state.heap(addr);
  if state.debug
    debug_print(sprintf("[DEBUG] ARRAY SIZE: addr=%g -> size=%g\n", addr, size));
  endif
  s = push(s, size);
endfunction

## --------------------------
## Helper function - ADDED for multi-char variable support
## --------------------------
function result = is_var_name(tok)
  result = false;
  len = length(tok);
  if len >= 1 && len <= 3
    result = all(tok >= 'a' & tok <= 'z');
  endif
endfunction

## --------------------------
## Interpreter Functions
## --------------------------
function interpret_line(line)
  global state;

  tokens = tokenize_with_strings(line);

  if state.debug
    debug_print("[DEBUG] TOKENS: ");
    for i = 1:length(tokens)
      debug_print(sprintf("'%s' ", tokens{i}));
    endfor
    debug_print("\n");
  endif

  compile_mode = false;
  current_def = {};

  i = 1;
  while i <= length(tokens)
    tok = tokens{i};

    if state.debug && !compile_mode
      debug_print(sprintf("[DEBUG] Processing token #%d: '%s'\n", i, tok));
    endif

    if length(tok) > 1 && tok(1) == ':'
      compile_mode = true;
      current_def = {};
      current_def{1} = tok(2:end);
      if state.debug
        debug_print(sprintf("[DEBUG] FUNCTION DEF START: %s\n", current_def{1}));
      endif
      i++;
      continue;
    elseif strcmp(tok, ";")
      if !compile_mode
        if state.debug
          debug_print("[DEBUG] WARNING: Ignoring standalone ';' outside function definition\n");
        endif
        i++;
        continue;
      endif
      compile_mode = false;
      state.colon_defs(current_def{1}) = current_def(2:end);
      if state.debug
        debug_print(sprintf("[DEBUG] FUNCTION DEF END: %s with %d tokens\n", current_def{1}, length(current_def)-1));
      endif
      i++;
      continue;
    endif

    if compile_mode
      current_def{end+1} = tok;
      i++;
    else
      if strcmp(tok, "[")
        array_elements = [];
        i++;
        while i <= length(tokens) && !strcmp(tokens{i}, "]")
          elem_tok = tokens{i};
          ## FIXED: Check for multi-char variables
          if is_var_name(elem_tok)
            if isKey(state.vars, elem_tok)
              array_elements(end+1) = state.vars(elem_tok);
            else
              array_elements(end+1) = 0;
            endif
          elseif length(elem_tok) > 1 && elem_tok(1) == '#'
            hex_str = elem_tok(2:end);
            array_elements(end+1) = hex2dec(hex_str);
          elseif !isnan(str2double(elem_tok))
            array_elements(end+1) = str2double(elem_tok);
          else
            error("Invalid array element: %s", elem_tok);
          endif
          i++;
        endwhile

        if i > length(tokens) || !strcmp(tokens{i}, "]")
          error("Unclosed array - missing ]");
        endif

        arr_size = length(array_elements);
        heap_addr = state.heap_ptr;
        state.heap(heap_addr) = arr_size;
        for j = 1:arr_size
          state.heap(heap_addr + j) = array_elements(j);
        endfor
        state.heap_ptr = heap_addr + arr_size + 1;

        if state.debug
          debug_print(sprintf("[DEBUG] ARRAY CREATE: addr=%g, size=%g, elements=[", heap_addr, arr_size));
          for j = 1:arr_size
            debug_print(sprintf("%g ", array_elements(j)));
          endfor
          debug_print("]\n");
        endif

        state.stack = push(state.stack, heap_addr);
        i++;
      elseif strcmp(tok, "(")
        has_else = false;
        depth = 0;
        for check_idx = i:length(tokens)
          if strcmp(tokens{check_idx}, "(")
            depth++;
          elseif strcmp(tokens{check_idx}, ")")
            depth--;
            if depth == 0
              if check_idx < length(tokens) && strcmp(tokens{check_idx+1}, "/E")
                has_else = true;
              endif
              break;
            endif
          endif
        endfor

        if has_else
          if state.debug
            debug_print("[DEBUG] CONDITIONAL: if-then-else detected\n");
          endif
          [then_body, then_end] = extract_loop_body(tokens, i);
          [else_body, else_end] = extract_loop_body(tokens, then_end+2);
          execute_conditional(then_body, else_body);
          i = else_end + 1;
        else
          if state.debug
            debug_print("[DEBUG] LOOP: regular loop detected\n");
          endif
          [loop_body, end_idx] = extract_loop_body(tokens, i);
          execute_loop(loop_body);
          i = end_idx + 1;
        endif
      ## FIXED: Check for variable followed by !
      elseif is_var_name(tok) && i < length(tokens) && strcmp(tokens{i+1}, "!")
        state.last_var = tok;
        if state.debug
          debug_print(sprintf("[DEBUG] STORE PREP: variable '%s' ready for !\n", tok));
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

  single_char_ops = '{};[]()''\"$%!.,~&|^<>=+*/';

  while i <= length(line)
    ch = line(i);

    if i <= length(line)-1 && strcmp(line(i:i+1), '//')
      if !isempty(current_token)
        tokens{end+1} = strtrim(current_token);
      endif
      break;
    endif

    if ch == '-' && i < length(line) && isstrprop(line(i+1), 'digit')
      if !isempty(current_token)
        tokens{end+1} = strtrim(current_token);
        current_token = "";
      endif
      current_token = '-';
      i++;
      continue;
    endif

    if ch == '/' && i < length(line)
      next_ch = line(i+1);

      if i <= length(line)-5
        six_char = line(i:i+5);
        if any(strcmp(six_char, {'/atan2', '/asinh', '/acosh', '/atanh', '/floor', '/round', '/trunc'}))
          if !isempty(current_token)
            tokens{end+1} = strtrim(current_token);
            current_token = "";
          endif
          tokens{end+1} = six_char;
          i = i + 6;
          continue;
        endif
      endif

      if i <= length(line)-4
        five_char = line(i:i+4);
        if any(strcmp(five_char, {'/sinh', '/cosh', '/tanh', '/asin', '/acos', '/atan', '/sqrt', '/ceil', '/sign'}))
          if !isempty(current_token)
            tokens{end+1} = strtrim(current_token);
            current_token = "";
          endif
          tokens{end+1} = five_char;
          i = i + 5;
          continue;
        endif
      endif

      if i <= length(line)-3
        four_char = line(i:i+3);
        if any(strcmp(four_char, {'/sin', '/cos', '/tan', '/abs', '/exp', '/log', '/deg', '/rad', '/mod', '/min', '/max'}))
          if !isempty(current_token)
            tokens{end+1} = strtrim(current_token);
            current_token = "";
          endif
          tokens{end+1} = four_char;
          i = i + 4;
          continue;
        endif
      endif

      if i <= length(line)-2
        three_char = line(i:i+2);
        if any(strcmp(three_char, {'/CS', '/pi', '/ln'}))
          if !isempty(current_token)
            tokens{end+1} = strtrim(current_token);
            current_token = "";
          endif
          tokens{end+1} = three_char;
          i = i + 3;
          continue;
        endif
      endif

      if any(next_ch == 'NWEFTUijcrhszkVCKDSAIOPGXe')
        if !isempty(current_token)
          tokens{end+1} = strtrim(current_token);
          current_token = "";
        endif
        tokens{end+1} = line(i:i+1);
        i = i + 2;
        continue;
      endif
    endif

    if ch == '`'
      if !isempty(current_token)
        tokens{end+1} = strtrim(current_token);
        current_token = "";
      endif
      j = i + 1;
      while j <= length(line) && line(j) != '`'
        j++;
      endwhile
      if j <= length(line)
        tokens{end+1} = line(i:j);
        i = j + 1;
      else
        error("Unclosed backtick string");
      endif
    elseif ch == ' ' || ch == sprintf('\t')
      if !isempty(current_token)
        tokens{end+1} = strtrim(current_token);
        current_token = "";
      endif
      i++;
    elseif ch == '-'
      if !isempty(current_token)
        tokens{end+1} = strtrim(current_token);
        current_token = "";
      endif
      tokens{end+1} = ch;
      i++;
    elseif ch == '*' && i < length(line) && line(i+1) == '*'
      if !isempty(current_token)
        tokens{end+1} = strtrim(current_token);
        current_token = "";
      endif
      tokens{end+1} = '**';
      i = i + 2;
    elseif ch == '.' && i < length(line) && isstrprop(line(i+1), 'digit')
      current_token = [current_token, ch];
      i++;
    elseif any(ch == single_char_ops)
      if !isempty(current_token)
        tokens{end+1} = strtrim(current_token);
        current_token = "";
      endif
      tokens{end+1} = ch;
      i++;
    else
      current_token = [current_token, ch];
      i++;
    endif
  endwhile

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

  [state.stack, count] = pop(state.stack);

  if state.debug
    debug_print(sprintf("[DEBUG] LOOP START: count=%g, stack_depth=%d\n", count, length(state.stack)));
  endif

  if count < 0
    has_while = false;
    for i = 1:length(body)
      if strcmp(body{i}, "/W")
        has_while = true;
        break;
      endif
    endfor

    if has_while
      count = 999999;
    else
      count = 1;
      if state.debug
        debug_print("[DEBUG] LOOP: boolean true, run once\n");
      endif
    endif
  endif

  saved_i = state.loop_i;
  saved_j = state.loop_j;

  state.loop_j = state.loop_i;

  for loop_idx = 0:(count-1)
    state.loop_i = loop_idx;
    state.break_loop = false;

    if state.debug
      debug_print(sprintf("[DEBUG] LOOP ITERATION: i=%d, j=%d\n", state.loop_i, state.loop_j));
      debug_show_stack();
    endif

    execute_token_sequence(body);

    if state.break_loop
      if state.debug
        debug_print(sprintf("[DEBUG] LOOP BREAK: exiting at iteration %d\n", loop_idx));
      endif
      break;
    endif
  endfor

  state.loop_i = saved_i;
  state.loop_j = saved_j;

  if state.debug
    debug_print(sprintf("[DEBUG] LOOP END: restored i=%d, j=%d\n", state.loop_i, state.loop_j));
  endif
endfunction

## Execute conditional (if-then-else)
function execute_conditional(then_body, else_body)
  global state;

  if isempty(state.stack)
    error("Conditional requires a condition on stack");
  endif
  [state.stack, condition] = pop(state.stack);

  if state.debug
    debug_print(sprintf("[DEBUG] CONDITIONAL: condition=%g, taking %s branch\n", condition, iif(condition!=0, "THEN", "ELSE")));
  endif

  if condition != 0
    execute_token_sequence(then_body);
  else
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
      debug_print(sprintf("[DEBUG] SEQ token #%d: '%s'\n", i, tok));
    endif

    if strcmp(tok, "[")
      array_elements = [];
      i++;
      while i <= length(tokens) && !strcmp(tokens{i}, "]")
        elem_tok = tokens{i};
        ## FIXED: Check for multi-char variables
        if is_var_name(elem_tok)
          if isKey(state.vars, elem_tok)
            array_elements(end+1) = state.vars(elem_tok);
          else
            array_elements(end+1) = 0;
          endif
        elseif length(elem_tok) > 1 && elem_tok(1) == '#'
          hex_str = elem_tok(2:end);
          array_elements(end+1) = hex2dec(hex_str);
        elseif !isnan(str2double(elem_tok))
          array_elements(end+1) = str2double(elem_tok);
        else
          error("Invalid array element: %s", elem_tok);
        endif
        i++;
      endwhile

      if i > length(tokens) || !strcmp(tokens{i}, "]")
        error("Unclosed array - missing ]");
      endif

      arr_size = length(array_elements);
      heap_addr = state.heap_ptr;
      state.heap(heap_addr) = arr_size;
      for j = 1:arr_size
        state.heap(heap_addr + j) = array_elements(j);
      endfor
      state.heap_ptr = heap_addr + arr_size + 1;

      state.stack = push(state.stack, heap_addr);
      i++;
    elseif strcmp(tok, "(")
      has_else = false;
      depth = 0;
      for check_idx = i:length(tokens)
        if strcmp(tokens{check_idx}, "(")
          depth++;
        elseif strcmp(tokens{check_idx}, ")")
          depth--;
          if depth == 0
            if check_idx < length(tokens) && strcmp(tokens{check_idx+1}, "/E")
              has_else = true;
            endif
            break;
          endif
        endif
      endfor

      if has_else
        [then_body, then_end] = extract_loop_body(tokens, i);
        [else_body, else_end] = extract_loop_body(tokens, then_end+2);
        execute_conditional(then_body, else_body);
        i = else_end + 1;
      else
        [loop_body, end_idx] = extract_loop_body(tokens, i);
        execute_loop(loop_body);
        i = end_idx + 1;
      endif
    ## FIXED: Check for variable followed by !
    elseif is_var_name(tok) && i < length(tokens) && strcmp(tokens{i+1}, "!")
      state.last_var = tok;
      if state.debug
        debug_print(sprintf("[DEBUG] STORE PREP: variable '%s' ready for !\n", tok));
      endif
      i++;
      continue;
    else
      execute_token(tok);
      i++;

      if state.break_loop
        return;
      endif
    endif
  endwhile
endfunction

function execute_token(tok)
  global state;

  if length(tok) >= 2 && tok(1) == '`' && tok(end) == '`'
    str_content = tok(2:end-1);
    if state.debug
      debug_print(sprintf("[DEBUG] STRING: printing '%s'\n", str_content));
    endif
    printf("%s", str_content);
    return;
  endif

  if length(tok) >= 1 && tok(1) == '['
    error("Array syntax error: use spaces like [ 1 2 3 ]");
  endif

  if isKey(state.colon_defs, tok)
    if state.debug
      debug_print(sprintf("[DEBUG] FUNCTION CALL: %s\n", tok));
    endif
    execute_token_sequence(state.colon_defs(tok));

  elseif isKey(state.dict, tok)
    if state.debug
      debug_print(sprintf("[DEBUG] BUILTIN: %s\n", tok));
    endif
    state.stack = state.dict(tok)(state.stack);
  ## FIXED: Check for multi-char variable names
  ## NOTE: We do NOT set last_var here - that's only done when preparing to store
  elseif is_var_name(tok)
    if isKey(state.vars, tok)
      val = state.vars(tok);
    else
      val = 0;
    endif
    if state.debug
      debug_print(sprintf("[DEBUG] VARIABLE READ: %s = %g\n", tok, val));
    endif
    state.stack = push(state.stack, val);
  elseif length(tok) > 1 && tok(1) == '#'
    hex_str = tok(2:end);
    num = hex2dec(hex_str);
    if state.debug
      debug_print(sprintf("[DEBUG] HEX NUMBER: %s = %g\n", tok, num));
    endif
    state.stack = push(state.stack, num);
  elseif !isnan(str2double(tok))
    num = str2double(tok);
    if state.debug
      debug_print(sprintf("[DEBUG] NUMBER: %g\n", num));
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
    debug_print(sprintf("[DEBUG] /D: stack depth = %d\n", depth));
  endif
endfunction

function s = clear_stack(s)
  global state;
  if state.debug
    debug_print(sprintf("[DEBUG] /CS: clearing stack (had %d items)\n", length(s)));
  endif
  s = [];
endfunction

## --------------------------
## Print Functions
## --------------------------
function s = print_num(s)
  [s,a]=pop(s);
  printf("%g ", a);
  fflush(stdout);
endfunction

function s = print_hex(s)
  [s,a]=pop(s);
  if a < 0
    a_unsigned = bitand(int64(a), int64(65535));
  else
    a_unsigned = mod(int64(a), 65536);
  endif
  printf("%04X ", a_unsigned);
endfunction

## --------------------------
## List Functions - Enhanced (Filters Temporary Blocks)
## --------------------------
function s = list_functions(s)
  global state;

  func_names = keys(state.colon_defs);
  
  ## Remove temporary function from listing
  temp_idx = -1;
  for i = 1:length(func_names)
    if strcmp(func_names{i}, '_')
      temp_idx = i;
      break;
    endif
  endfor
  
  if temp_idx > 0
    func_names(temp_idx) = [];
  endif

  if isempty(func_names)
    printf("No functions defined.\n");
  else
    printf("Defined functions:\n");
    printf("==================\n");
    for i = 1:length(func_names)
      fname = func_names{i};
      fbody = state.colon_defs(fname);

      printf(":%s ", fname);
      for j = 1:length(fbody)
        printf("%s ", fbody{j});
      endfor
      printf(";\n");
    endfor
    printf("==================\n");
  endif
endfunction

## --------------------------
## Execute and Delete Temporary Function
## --------------------------
function execute_temp_function()
  global state;
  
  if state.debug
    debug_print("[DEBUG] EXECUTING TEMPORARY BLOCK '_'\n");
  endif
  
  if isKey(state.colon_defs, '_')
    try
      execute_token_sequence(state.colon_defs('_'));
      if state.debug
        debug_print("[DEBUG] TEMPORARY BLOCK COMPLETED\n");
      endif
    catch err
      fprintf("ERROR in temporary block: %s\n", err.message);
    end_try_catch
    
    ## Delete the temporary function
    remove(state.colon_defs, '_');
    if state.debug
      debug_print("[DEBUG] TEMPORARY BLOCK DELETED\n");
    endif
  endif
endfunction

## --------------------------
## Toggle Debug
## --------------------------
function s = toggle_debug(s)
  global state;
  state.debug = !state.debug;

  if state.debug
    debug_filename = sprintf("mint_debug_%s.log", datestr(now, "yyyymmdd_HHMMSS"));
    state.debug_file = fopen(debug_filename, "w");

    if state.debug_file == -1
      printf("WARNING: Could not open debug file '%s'\n", debug_filename);
    else
      printf("\n*** DEBUG MODE ENABLED ***\n");
      printf("Debug output will be written to: %s\n", debug_filename);
    endif
  else
    if state.debug_file != -1
      fclose(state.debug_file);
      printf("Debug log saved.\n");
    endif
    state.debug_file = -1;
    printf("\n*** DEBUG MODE DISABLED ***\n");
  endif
endfunction

## --------------------------
## Help Function - COMPLETE VERSION
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
  printf("  Range:        Â±1.8e308 (much larger than original MINT's 16-bit limit)\n");
  printf("  Arrays:       Support both integers and floating point numbers\n");
  printf("  Note:         This Octave version uses 64-bit floats, not 16-bit integers\n\n");

  printf("===================================================================================================\n");
  printf("Category  | Symbol | Description                               | Effect       | Status\n");
  printf("--------- | ------ | ----------------------------------------- | ------------ | ------\n");
  printf("MATHS     | *  -   | floating-point subtraction                | n n -- n     | DONE\n");
  printf("MATHS     | *  /   | floating-point division (floor)           | n n -- n     | DONE\n");
  printf("MATHS     | *  +   | floating-point addition                   | n n -- n     | DONE\n");
  printf("MATHS     | *  *   | floating-point multiplication             | n n -- n     | DONE\n");
  printf("MATHS     | *  **  | exponentiation (x to power y)             | n n -- n     | DONE\n");
  printf("MATHS     | * /sqrt| square root                               | n -- n       | DONE\n");
  printf("MATHS     | * /abs | absolute value                            | n -- n       | DONE\n");
  printf("MATHS     | * /ln  | natural logarithm (base e)                | n -- n       | DONE\n");
  printf("MATHS     | * /log | base-10 logarithm                         | n -- n       | DONE\n");
  printf("MATHS     | * /exp | e to the power x                          | n -- n       | DONE\n");
  printf("MATHS     | */floor| round down to nearest integer             | n -- n       | DONE\n");
  printf("MATHS     | * /ceil| round up to nearest integer               | n -- n       | DONE\n");
  printf("MATHS     | */round| round to nearest integer                  | n -- n       | DONE\n");
  printf("MATHS     | * /mod | modulo (remainder of a/b)                 | a b -- n     | DONE\n");
  printf("MATHS     | * /min | minimum of two numbers                    | a b -- n     | DONE\n");
  printf("MATHS     | * /max | maximum of two numbers                    | a b -- n     | DONE\n");
  printf("MATHS     | * /sign| sign of number (-1, 0, or 1)              | n -- n       | DONE\n");
  printf("MATHS     | */trunc| truncate toward zero                      | n -- n       | DONE\n");
  printf("TRIG      | * /sin | sine (radians)                            | n -- n       | DONE\n");
  printf("TRIG      | * /cos | cosine (radians)                          | n -- n       | DONE\n");
  printf("TRIG      | * /tan | tangent (radians)                         | n -- n       | DONE\n");
  printf("TRIG      | * /asin| arcsine (returns radians)                 | n -- n       | DONE\n");
  printf("TRIG      | * /acos| arccosine (returns radians)               | n -- n       | DONE\n");
  printf("TRIG      | * /atan| arctangent (returns radians)              | n -- n       | DONE\n");
  printf("TRIG      | */atan2| atan2(y,x) - 2-arg arctangent             | y x -- n     | DONE\n");
  printf("HYPER     | * /sinh| hyperbolic sine                           | n -- n       | DONE\n");
  printf("HYPER     | * /cosh| hyperbolic cosine                         | n -- n       | DONE\n");
  printf("HYPER     | * /tanh| hyperbolic tangent                        | n -- n       | DONE\n");
  printf("HYPER     | */asinh| inverse hyperbolic sine                   | n -- n       | DONE\n");
  printf("HYPER     | */acosh| inverse hyperbolic cosine (val >= 1)      | n -- n       | DONE\n");
  printf("HYPER     | */atanh| inverse hyperbolic tangent (-1 < val < 1) | n -- n       | DONE\n");
  printf("CONST     | * /pi  | push pi constant (3.14159...)             | -- n         | DONE\n");
  printf("CONST     | * /e   | push e constant (2.71828...)              | -- n         | DONE\n");
  printf("CONVERT   | * /deg | convert radians to degrees                | n -- n       | DONE\n");
  printf("CONVERT   | * /rad | convert degrees to radians                | n -- n       | DONE\n");
  printf("LOGICAL   | *  >   | floating-point comparison GT              | n n -- b     | DONE\n");
  printf("LOGICAL   | *  <   | floating-point comparison LT              | n n -- b     | DONE\n");
  printf("LOGICAL   | *  =   | floating-point comparison EQ              | n n -- b     | DONE\n");
  printf("LOGICAL   | *  &   | bitwise AND (masked to 16-bit)            | n n -- n     | DONE\n");
  printf("LOGICAL   | *  |   | bitwise OR (masked to 16-bit)             | n n -- n     | DONE\n");
  printf("LOGICAL   | *  ^   | bitwise XOR (masked to 16-bit)            | n n -- n     | DONE\n");
  printf("LOGICAL   | *  ~   | bitwise NOT (masked to 16-bit)            | n -- n       | DONE\n");
  printf("LOGICAL   | *  {   | shift left (masked to 16-bit)             | n -- n       | DONE\n");
  printf("LOGICAL   | *  }   | shift right (masked to 16-bit)            | n -- n       | DONE\n");
  printf("STACK     | *  '   | drop top member DROP                      | m n -- m     | DONE\n");
  printf('STACK     | *  "   | duplicate top member DUP                  | n -- n n     | DONE\n');
  printf("STACK     | *  %%  | over - copy 2nd to top                    | m n -- m n m | DONE\n");
  printf("STACK     | *  $   | swap top 2 members SWAP                   | m n -- n m   | DONE\n");
  printf("STACK     | *  /D  | stack depth                               | -- n         | DONE\n");
  printf("STACK     | *  /CS | clear stack                               | ... --       | DONE\n");
  printf("I/O       | *  .   | print number as decimal                   | n --         | DONE\n");
  printf("I/O       | *  ,   | print number as hexadecimal               | n --         | DONE\n");
  printf("I/O       | *  `   | print literal string                      | --           | DONE\n");
  printf("I/O       | *  /C  | print character to output                 | n --         | DONE\n");
  printf("I/O       | *  /K  | read char from input                      | -- n         | DONE\n");
  printf("I/O       | *  /KS | read string (all ASCII codes + length)    | -- n n... n  | DONE\n");
  printf("I/O       | *  /O  | output to I/O port (file-based)           | n p --       | DONE\n");
  printf("I/O       | *  /I  | input from I/O port (file-based)          | p -- n       | DONE\n");
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
  printf("MISC      | * debug| toggle on/off to screen and file          | --           | DONE\n");
  printf("===================================================================================================\n");
  printf("Type 'bye' to quit\n");
  printf("Type 'debug' to toggle debug mode\n");
  printf("Type 'list' to show all defined functions\n");
  printf("===================================================================================================\n\n");
endfunction

## ========================================================================
## DEBUG FUNCTIONS - Can be toggled on/off at startup or with 'debug'
## ========================================================================

function debug_print(msg)
  global state;
  printf("%s", msg);

  if state.debug && state.debug_file != -1
    fprintf(state.debug_file, "%s", msg);
    fflush(state.debug_file);
  endif
endfunction

function debug_before_op(op, stack)
  debug_print(sprintf("[DEBUG] BEFORE %s: stack=", op));
  debug_print_stack(stack);
endfunction

function debug_after_op(op, desc, stack)
  debug_print(sprintf("[DEBUG] AFTER %s: %s, stack=", op, desc));
  debug_print_stack(stack);
endfunction

function debug_print_stack(stack)
  if isempty(stack)
    debug_print("(empty)\n");
  else
    debug_print("[");
    for i = 1:length(stack)
      debug_print(sprintf("%g", stack(i)));
      if i < length(stack)
        debug_print(" ");
      endif
    endfor
    debug_print("]\n");
  endif
endfunction

function debug_show_stack()
  global state;
  debug_print("[DEBUG] STACK: ");
  debug_print_stack(state.stack);
endfunction

function debug_show_vars()
  global state;
  debug_print("[DEBUG] VARIABLES:\n");
  var_names = keys(state.vars);
  for i = 1:length(var_names)
    vname = var_names{i};
    debug_print(sprintf("  %s = %g\n", vname, state.vars(vname)));
  endfor
endfunction

function debug_show_final_state()
  global state;
  debug_print("\n[DEBUG] === FINAL STATE ===\n");
  debug_show_stack();
  debug_show_vars();
  debug_print(sprintf("[DEBUG] SYSTEM: /c=%g, /r=%g, /i=%g, /j=%g\n", state.sys_c, state.sys_r, state.loop_i, state.loop_j));
  debug_print("[DEBUG] ====================\n");
endfunction

function r = iif(condition, true_val, false_val)
  if condition
    r = true_val;
  else
    r = false_val;
  endif
endfunction
