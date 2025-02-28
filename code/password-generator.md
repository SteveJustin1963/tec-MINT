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

```
