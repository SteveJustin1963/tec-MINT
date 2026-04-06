# sudo
```
BEGIN
    PRINT "Password Generator for FX-730P - Press <EXE> to start"
    CLEAR SCREEN

    // Define and initialize character array with possible password characters
    DATA "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()"
    LOAD DATA into character array P$()
    SET N = size of character array
    IF N > 32767 THEN
        PRINT "Error: Character set too large for 16-bit integer."
        EXIT
    END IF

    // Main loop
    WHILE TRUE
        PRINT "Enter password length or exit (0 to exit)"
        INPUT L

        // Validate input as 16-bit signed integer
        IF L < -32768 OR L > 32767 THEN
            PRINT "Error: Input out of 16-bit signed integer range (-32768 to 32767)."
            CONTINUE
        END IF

        // Check if user wants to exit
        IF L = 0 THEN
            EXIT
        END IF

        // Validate length (positive and within reasonable bounds)
        IF L < 1 OR L > 32767 THEN
            PRINT "Invalid length. Enter a positive number between 1 and 32767."
            CONTINUE
        END IF

        // Initialize password string
        SET password = ""

        // Generate password by randomly selecting characters
        FOR I = 1 TO L
            IF I > 32767 THEN
                PRINT "Error: Loop exceeded 16-bit integer limit."
                BREAK
            END IF
            SET R = random integer between 1 and N
            IF R < 1 OR R > 32767 THEN
                PRINT "Error: Random index out of 16-bit range."
                BREAK
            END IF
            APPEND P$(R) to password
        END FOR

        // Print the generated password
        PRINT "Generated password: ", password
    END WHILE

END
```

# mint
```
:P 
  `Password Generator` /N 
  `Press any key to start` /K /N 
  12345 s!           // Initialize seed for random number generator with 12345
;

:C 
  // Define character set for passwords - all printable ASCII characters
  [ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+-={}[]|:;<>,.?/] c! 
;

:R 
  c /S n!            // Get size of character array into n
  // Linear Congruential Generator (LCG) formula: seed = (seed * A + C) % M
  s @ s 75 * 74 + 65537 % s!  // Update seed value using LCG formula
  s n % 1 +          // Convert to range 1-n (valid array index)
;

:G 
  `Enter password length (0 to exit): ` 
  /K 48 - l!         // Read keyboard input, convert ASCII to number
  
  // Handle exit condition
  l 0 = (/F /W)      // If length is 0, exit function
  
  // Validate input
  l 0 < (
    `Invalid length. Try again.` /N 
    /F /W            // If negative, show error and exit function
  )
  
  // Generate password
  l 0 > (
    `Generating password of length ` l . `...` /N
    
    // Initialize counter and password array
    0 i!              // Reset index counter
    [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] p!  // Create password array (max 20 chars)
    
    // Loop to generate each character
    l(
      R r!            // Get random index
      r c r? \? p i?! // Get char at random index and store in password array
      i 1+ i!         // Increment counter
    )
    
    // Display generated password
    `Password: `
    0 i!              // Reset counter
    l(
      p i? \? /C      // Print each character in password
      i 1+ i!         // Increment counter
    )
    /N                // Print newline
  )
;

:M 
  P                   // Display welcome message and init seed
  C                   // Initialize character array
  /U(                 // Start unlimited loop
    G                 // Generate password based on user input
  )                   // Loop continues until user enters 0
;
```

without comments
```
:P `Password Generator` /N `Press any key to start` /K /N 
  12345 s!
;

:C [ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+-={}[]|:;<>,.?/] c! ;

:R c /S n!
  s @ s 75 * 74 + 65537 % s!
  s n % 1 +
;

:G `Enter password length (0 to exit): ` /K 48 - l!
  l 0 = (/F /W)
  l 0 < (`Invalid length. Try again.` /N /F /W)
  l 0 > (
    `Generating password of length ` l . `...` /N
    0 i!
    [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] p!
    l(
      R r!
      r c r? \? p i?!
      i 1+ i!
    )
    `Password: `
    0 i!
    l(
      p i? \? /C
      i 1+ i!
    )
    /N
  )
;

:M P 
  C 
  /U(
    G
  )
;
```


