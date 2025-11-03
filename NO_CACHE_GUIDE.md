# MINT-Octave No-Cache I/O - ALWAYS SEES YOUR EDITS

## The Fix

**NO MORE CACHING.** Every `/I` read is **fresh from disk**. Your manual edits are seen **immediately**.

## How It Works Now

1. Every `/I` opens the file and reads it fresh
2. Remembers your **position** (index 1, 2, 3...)
3. Reads the value at that position
4. Increments position for next read
5. Wraps around when reaching end

**KEY**: Data is never cached - only your read position is remembered.

## Example: Manual Edits Work Instantly

```mint
# Write initial data
> 42 2 /O
> 99 2 /O

> 2 /I .
42
> 2 /I .
99

# NOW: Go edit port2.txt and add: 777 888 999

> 2 /I .
777    ← Sees your edit IMMEDIATELY! No /RELOAD needed!
> 2 /I .
888    ← Your data!
> 2 /I .
999    ← Your data!
> 2 /I .
42     ← Wraps around
```

## Real Workflow

### 1. MINT writes some data
```mint
> 42 2 /O
> 99 2 /O
```

File contains:
```
0.123 42
0.456 99
```

### 2. Read it
```mint
> 2 /I . 2 /I .
42 99
```

### 3. You manually edit `mint_ports/port2.txt`
Add your lines:
```
0.123 42
0.456 99
1.000 777
2.000 888
3.000 999
```

### 4. Keep reading - NO RELOAD NEEDED
```mint
> 2 /I .
777    ← Automatically sees your edits!
> 2 /I .
888
> 2 /I .
999
> 2 /I .
42     ← Wraps to beginning
```

## Commands

| Command | Stack | Purpose |
|---------|-------|---------|
| `/I` | `( port -- value )` | Read next value (always fresh from disk) |
| `/O` | `( value port -- )` | Write value (resets position to start) |
| `/RELOAD` | `( port -- )` | Reset position to beginning |

## When to Use `/RELOAD`

You only need it to **reset your position** back to the start:

```mint
> 42 2 /O
> 99 2 /O
> 123 2 /O

> 2 /I . 2 /I .
42 99    ← Now at position 3

> 2 /RELOAD
Port 2 position reset - next read starts from beginning

> 2 /I .
42    ← Back to start
```

## Performance Note

Yes, reading from disk every time is slower than caching. But:
- ✓ Always sees your manual edits
- ✓ No confusing stale data
- ✓ Simple and predictable
- ✓ Perfect for debugging and testing
- ✓ File I/O is still fast enough for typical use

## Key Differences from Before

| Behavior | Old (Cached) | New (No Cache) |
|----------|--------------|----------------|
| First read | Load to cache | Read from disk |
| Later reads | Read from cache | Read from disk |
| Manual edit | NOT SEEN | SEEN IMMEDIATELY |
| Speed | Faster | Slightly slower |
| Predictability | Confusing | Simple |

## Example: Mix MINT and Manual Freely

```mint
> 10 2 /O
> 20 2 /O

> 2 /I .
10

# [Edit file, add: 30 40 50]

> 2 /I .
20
> 2 /I .
30    ← Your edit, seen immediately!
> 2 /I .
40    ← Works!
> 2 /I .
50

> 100 2 /O   # Write more with MINT

> 2 /I .
10    ← Position reset, reads from start
```

---

**No cache. Always fresh. Edit freely!** ✓
