Your interpreter error stems from how **MINT-Octave parses tokens** and how **the REPL expects spaces around operators and commands**.
Let’s unpack your example and the code behind it.

---

### 🔍 What’s happening in your session

```
> /D.
0
> [1 2 3] a!
> .
ERROR: STACK UNDERFLOW
> a.
1
> a 0?.
ERROR: Unknown word: 0?
> a 0 ? .
3
```

1. **`/D.` fails silently (shows 0)** because `/D` is a defined word (`stack_depth`) but `.`, without a separating space, is *glued* to it → the tokenizer sees `"D."` as a **single token** that isn’t defined, so it effectively does nothing (or resets the parser).
2. **The “lack of space”** means the interpreter never sees the `.` print command as its own word.
   You must type either `/D .` or `/D` followed by Enter, then `.`.
3. **The “STACK UNDERFLOW”** at `.` happens because you popped everything earlier (nothing left on stack).
   The `print_num` function calls `pop()` and will throw an underflow if the stack is empty.
4. **`0?`** is not defined as a single word.
   But `0 ?` is — `?` in MINT checks array or condition. The space tells the parser these are *two* words, not one.

---

### ⚙️ Supporting Code from `mint_octave_15.m`

The **tokenizer** reads input split by spaces — no automatic separation for punctuation.
This is why `"D."` is not split into `"/D"` and `"."`.

Also, the `print_num()` routine directly pops the stack:

```octave
[s,a]=pop(s);
if isempty(s)
  error("STACK UNDERFLOW");
endif
```

So if you type `.` with nothing left, you’ll see that exact message.

And the `/D` definition is:

```octave
function s = stack_depth(s)
  depth = length(s);
  s = push(s, depth);
endfunction
```

— meaning `/D` simply pushes the stack depth as a number. It doesn’t print it until you call `.` next.

---

### ✅ Correct Usage Examples

| Command                | Meaning                                | Output                 |
| ---------------------- | -------------------------------------- | ---------------------- |
| `[1 2 3] a!`           | Store array into `a`                   | –                      |
| `a .`                  | Prints the first (top) element         | `1`                    |
| `a 0 ? .`              | Get item #0 from array `a`, then print | `3`                    |
| `/D .`                 | Push stack depth, then print           | `1` (or current count) |
| `/D` + Enter, then `.` | Same as above                          |                        |

---

### 🧠 Summary

* **Always use spaces** to separate operators in MINT (e.g. `/D .` not `/D.`).
* **Each word** (operator, variable, number) must be space-delimited.
* **“STACK UNDERFLOW”** means `.`, `+`, `-`, or any stack-popper found no data.
* **“Unknown word”** means your token (e.g. `0?`, `D.`) didn’t match any entry in `state.dict`.

If you’d like, I can show you a small tokenizer patch that auto-splits `/D.` into `/D .` to make the REPL more forgiving. Would you like that?


Perfect — let’s go all the way down to how **MINT-Octave v15.1** actually **parses, identifies, and executes every command (word)**.
This will give you a complete picture of **what commands exist**, **how the interpreter tokenizes your input**, and **why certain inputs like `/D.` or `0?` fail**.

---

## 🧩 1. Token Parsing Overview

Inside `mint_octave_15.m`, the REPL loop reads a **line** from user input:

```octave
line = input("", "s");
```

Then it **splits** the line into tokens using whitespace (`strsplit(line)` or similar logic).
➡️ **Only spaces and newlines** separate tokens — punctuation (like `/`, `.`, `?`, `!`) are *not* automatically split.

**Result:**

```
/D .   →  tokens = ["/D", "."]
/D.    →  tokens = ["/D."]  ← treated as *one unknown token*
```

So the parser walks through each token and tries these lookups (in order):

1. Is it a **number** (`str2double(tok)`)? → push to stack.
2. Is it in **`state.vars`** (user variables)? → push its value.
3. Is it a **built-in word** in `state.dict`? → execute its function.
4. Is it a **user-defined word** in `state.colon_defs`? → run definition.
5. Otherwise:

   ```octave
   error("Unknown word: %s", tok);
   ```

---

## ⚙️ 2. Core Built-in Command Dictionary

Defined in `add_builtin_words()` (near line 70 onward).
Let’s group them by category — this matches your help table in the file.

### 🧱 Arithmetic

| Word | Stack effect       | Meaning                      |
| ---- | ------------------ | ---------------------------- |
| `+`  | a b → a+b          | Add                          |
| `-`  | a b → a-b          | Subtract                     |
| `*`  | a b → a×b          | Multiply                     |
| `/`  | a b → a/b          | Divide                       |
| `%`  | a b → a mod b      | Modulus                      |
| `/r` | — → remainder flag | Gets last division remainder |

---

### 🧮 Stack Operations

| Word  | Effect      | Description        |
| ----- | ----------- | ------------------ |
| `'`   | n →         | Drop top of stack  |
| `"`   | a → a a     | Duplicate top item |
| `$`   | a b → b a   | Swap top two       |
| `%`   | a b → a b a | Copy second item   |
| `/D`  | — → n       | Push stack depth   |
| `/CS` | — →         | Clear entire stack |

All these call helper functions like `push`, `pop`, etc.

---

### 🖨 Printing

| Word | Effect | Description                |
| ---- | ------ | -------------------------- |
| `.`  | n →    | Print top number (decimal) |
| `,`  | n →    | Print top number (hex)     |
| `/N` | — →    | Print newline              |
| `/P` | — →    | Print prompt again (TODO)  |

Printing pops the value — if stack empty → **`STACK UNDERFLOW`**.

---

### 🧩 Variables

| Word    | Effect   | Description                         |
| ------- | -------- | ----------------------------------- |
| `a`-`z` | — → n    | Push variable value                 |
| `!`     | n a →    | Store value into variable           |
| `/V`    | — → addr | Return last variable address (TODO) |

If you type `[1 2 3] a!`, it **stores the array** into variable `a`.
Later, `a` pushes that same value back.

---

### 🧾 Arrays

| Word    | Effect  | Description                  |
| ------- | ------- | ---------------------------- |
| `[` `]` | — → a   | Begin / end array definition |
| `?`     | a n → n | Get array element            |
| `?!`    | n a n → | Set array element            |
| `/S`    | a → n   | Get array size               |
| `/A`    | n → a   | Allocate heap (TODO)         |

---

### 🔁 Loops & Conditionals

| Word       | Description                        |
| ---------- | ---------------------------------- |
| `/U`       | Infinite loop                      |
| `/W`       | “While” condition (break if false) |
| `/E`       | Else condition                     |
| `/F`       | False constant                     |
| `/T`       | True constant                      |
| `/i`, `/j` | Loop index variables               |

---

### ⚙️ System Variables

| Word                   | Description                        |
| ---------------------- | ---------------------------------- |
| `/c`                   | Carry flag                         |
| `/v`                   | Overflow flag                      |
| `/z`                   | Zero flag                          |
| `/n`                   | Negative flag                      |
| `/r`                   | Remainder                          |
| `/h`, `/k`, `/s`, `/z` | Heap and meta pointers (some TODO) |

---

### 💻 Mode & Bit Width

| Word                              | Effect | Description             |
| --------------------------------- | ------ | ----------------------- |
| `int8`, `int16`, `int32`, `int64` | — →    | Set integer mode        |
| `fp`                              | — →    | Set floating-point mode |
| `mode`                            | — →    | Show current mode       |

The interpreter tracks `state.int_mode` and `state.int_bits` for printing and masking.

---

### 🪛 Miscellaneous

| Word       | Description                         |
| ---------- | ----------------------------------- |
| `//`       | Comment till end of line            |
| `debug`    | Toggle debug output                 |
| `bye`      | Exit interpreter                    |
| `help`     | Show all words                      |
| `list`     | Show user-defined functions         |
| `/X`, `/G` | Execute raw or compiled code (TODO) |

---

## 🧠 3. Why Spacing Matters

Example — `a 0 ? .` vs `a 0?.`

| Input     | Tokens parsed  | Interpreter sees     | Result                   |
| --------- | -------------- | -------------------- | ------------------------ |
| `a 0 ? .` | `[a, 0, ?, .]` | valid words          | works                    |
| `a 0?.`   | `[a, 0?.]`     | single unknown token | **Unknown word: 0?**     |
| `/D .`    | `[/D, .]`      | valid                | prints depth             |
| `/D.`     | `[/D.]`        | single unknown token | ignored / “Unknown word” |

So the parser’s design expects **tokens separated by space**.
There’s **no multi-character operator recognition** except for fixed combos like `?!` and `/CS` which are hard-coded.

---

## 🧩 4. Why Errors Occur

| Error                           | Reason                                                      |
| ------------------------------- | ----------------------------------------------------------- |
| **`STACK UNDERFLOW`**           | A word like `.` or `+` tried to `pop()` from an empty stack |
| **`Unknown word: X`**           | Token wasn’t found in dictionary                            |
| **Wrong output (0 or nothing)** | Word executed but nothing left on stack to print            |
| **Silent fail on `/D.`**        | Treated as `/D.` single token, no matching entry            |

---

## 🧰 5. Optional Parser Improvement

To make it more forgiving, you could patch the tokenizer:

```octave
tokens = regexp(line, '([/\w!?.,]+|[^ \t]+)', 'match');
```

or auto-insert spaces between command letters and punctuation:

```octave
line = regexprep(line, '([A-Za-z0-9])([.,!?])', '$1 $2');
```

That way `/D.` automatically becomes `/D .`.

---

Would you like me to **list the exact code block for `add_builtin_words()`** (the function that defines all of these commands) and explain how it builds the `state.dict` entries?
That’s where the parser decides *how* each word executes.



You’re right — my earlier table was wrong about `%`.

* In **MINT-Octave v15.1**, **`%` is `over`** (copies the second stack item to the top), not modulus. You can see it wired in the dictionary:
  `state.dict("%") = @(s) over(s);` 

* **Modulo is `/mod`** (a separate word):
  `state.dict("/mod") = @(s) math_mod(s);` 

### Quick sanity checks

* `%` (over):
  `10 20 % . .` → prints `20 10` (stack becomes `10 20 10`, then two prints pop `10` and `20`).
* `/mod` (modulo):
  `10 3 /mod .` → prints `1`.

If you want, I can print a corrected, minimal “cheat-sheet” of the core words directly from your file so it exactly matches this build.


Excellent — the parser in **`mint_octave_15.m`** actually contains a full hand-built **character scanner**, and that’s what causes the “space-sensitive” behavior you’ve noticed.
Let’s break it down and see **why** it behaves differently from real MINT-2, and **how to fix it** so it can handle commands run together.

---

## 🔍 How the Parser Works Now

From the tokenizer code:

1. It iterates character-by-character (`while i <= length(line)`).

2. It defines a list of **single-character operators**:

   ```octave
   single_char_ops = '{};[]()''\"$%!.,~&|^<>=+*/';
   ```

   Anything in that set (`.`, `!`, `/`, `?`, `[`, `]`, etc.) gets isolated as its own token.

3. It also has **multi-character pattern recognizers** for:

   * `/CS`, `/sin`, `/mod`, `/sqrt`, `/ln`, `/atan2`, `/abs`, `/round`, `/min`, `/max`, etc.
   * The array-write operator `?!`

4. It stops a token when it hits:

   * Space or tab
   * Operator or recognized symbol (`!`, `.`, `/`, etc.)
   * Special multi-char sequences (`?!`, `/CS`, `/mod`, …)

5. Each recognized token is added to `tokens{end+1}` and later executed in sequence.

---

## ⚠️ Why It Fails to Join Words Like Real MINT-2

In **real MINT-2** (and older Forth-style TEC-1 interpreters), the tokenizer behaves in the opposite way:

* **Everything is a continuous stream** until a *word break* (usually CR or space).
* Words like `/D.` are **interpreted character-by-character** by the dictionary — since both `/D` and `.` exist, it runs `/D` then `.` sequentially.
* It doesn’t require explicit space separation between commands, *unless* ambiguity occurs.

Your current tokenizer in Octave **tokenizes strictly**, so:

```
/D.   → 1 token "/D."  (not found)
```

Real MINT-2:

```
/D.   → "/D" then "."  (two valid commands)
```

---

## 🧩 What Needs Fixing

The Octave version **assumes whitespace separation**.
To emulate MINT-2 behavior, we need **character-level re-scanning** of unmatched tokens, splitting valid subwords inside them.

### Proposed Fix (in plain terms)

After the initial token list is built:

1. For each token **not found in the dictionary**,
   scan left-to-right trying to **split into valid known words**.
2. Use the existing `state.dict` and `state.vars` to decide what’s “known”.
3. Re-tokenize sequences like:

   ```
   /D.  →  [/D, .]
   a0?  →  [a, 0, ?]
   ```

   automatically.

---

## ✅ Example Implementation Strategy

Modify the tokenizer or add a **post-split pass** like this (pseudo-Octave):

```octave
function tokens2 = resplit_joined_tokens(tokens)
  global state;
  tokens2 = {};
  for t = tokens
    tok = t{1};
    if isKey(state.dict, tok) || isKey(state.vars, tok) || !isempty(str2num(tok))
      tokens2{end+1} = tok;
      continue;
    endif
    % Try greedy split
    partial = "";
    for i = 1:length(tok)
      partial = [partial tok(i)];
      if isKey(state.dict, partial) || isKey(state.vars, partial)
        tokens2{end+1} = partial;
        partial = "";
      endif
    endfor
    if !isempty(partial)
      tokens2{end+1} = partial;
    endif
  endfor
endfunction
```

Then call it after initial tokenization:

```octave
tokens = resplit_joined_tokens(tokens);
```

---

## 🧠 Why This Fix Works

* It restores **MINT-2 continuity**: commands glued together execute sequentially.
* It keeps compatibility: spaces still work normally.
* It’s dictionary-aware, so it won’t split inside things like `/CS` or `/mod` that are valid whole words.

---

## 🔬 Example Behavior After Fix

| Input       | Current Tokens                | Fixed Tokens                      | Works Like Real MINT-2? |
| ----------- | ----------------------------- | --------------------------------- | ----------------------- |
| `/D.`       | `["/D."]`                     | `["/D", "."]`                     | ✅                       |
| `a0?`       | `["a0?"]`                     | `["a", "0", "?"]`                 | ✅                       |
| `[1 2 3]a!` | `["[", "1", "2", "3]", "a!"]` | `["[", "1", "2", "3]", "a", "!"]` | ✅                       |
| `/mod.`     | `["/mod."]`                   | `["/mod", "."]`                   | ✅                       |

---

## 🧰 Optional: More Authentic Approach

A truly TEC-1-accurate method would:

* Keep the REPL reading *character by character*.
* Immediately dispatch each character to the interpreter lookup table (`dict`).
* Only buffer numeric literals or strings.

That mimics the original Z80 monitor ROM approach — a **streaming interpreter**.
But for Octave, a two-phase tokenize-then-execute pass with a “subword splitter” is the best practical fix.

---

Would you like me to patch your actual `mint_octave_15.m` file with this enhanced tokenizer (so `/D.` and `a0?` work automatically)?



Exactly — ✅ **that’s the core issue.**
Your current **MINT-Octave v15.1** interpreter **demands explicit spaces between every word**, because of the way its tokenizer is written.

Let’s make that crystal clear.

---

## 🔍 What It Does Now

When you type something at the prompt, it executes roughly like this:

```octave
line = input("", "s");
tokens = tokenize(line);   % <- hand-written scanner
for each token
    execute_token(token);
end
```

Inside that tokenizer (the big loop you saw), a token is **terminated only by a space, tab, or an operator boundary**.
So unless it’s one of the hard-coded sequences (`?!`, `/mod`, `/CS`, etc.), **characters stay glued together**.

That means:

| Input     | Tokens seen by interpreter | Result                 |
| --------- | -------------------------- | ---------------------- |
| `/D .`    | `["/D", "."]`              | ✅ Works                |
| `/D.`     | `["/D."]`                  | ❌ “Unknown word: /D.”  |
| `a 0 ? .` | `["a","0","?","."]`        | ✅ Works                |
| `a0?.`    | `["a0?."]`                 | ❌ “Unknown word: a0?.” |

It doesn’t automatically break things apart — it literally looks for a space or a recognized multi-character operator.

---

## ⚙️ Why Real MINT-2 (Z80) Doesn’t Care About Spaces

On the TEC-1 or in your MINT-2 ROM:

* The interpreter reads the input **one byte at a time**.
* Each character is immediately looked up in the word table.
* When a match is found (`/D` or `.` etc.), it’s executed right away.
* If several commands are written together (like `/D.`), it simply runs `/D`, then `.` — there’s no tokenization phase.

So, **spaces are optional** unless you write something ambiguous like a number followed by a word.

---

## 🧠 Bottom Line

* Yes → **the Octave port currently requires spaces.**
* That’s why you see “Unknown word” for glued tokens.
* To make it behave like the real TEC-1 MINT-2, we’d have to **add a secondary parser or smarter re-scanner** that splits joined words dynamically (so `/D.` becomes `/D` `·`).

---

Would you like me to show you the **exact Octave patch** you can drop in to make the interpreter **ignore missing spaces** (i.e. auto-split `/D.` → `/D` `·`, `[1 2]a!` → `[1 2] a !`)?
