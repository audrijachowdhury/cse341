; =================================================================
; PROJECT: Smart Parking Management & Vehicle Tracking System
; MEMBERS: 3
;
; FEATURES:
;   1. Parking Slot Management
;   2. Vehicle Registration & Parking Allocation
;   3. Vehicle Tracking & Information Search
;   4. Parking Fee Calculation
;   5. Parking Violation & Fine Management
;   6. Parking Payment & Settlement Management
;
; TECHNICAL: ARRAYS + PROCEDURES
; =================================================================

.MODEL SMALL
.STACK 100H

.DATA

; ======================= MENU & MESSAGES ==========================

MENU DB 0Dh,0Ah,"===== SMART PARKING SYSTEM =====",0Dh,0Ah
     DB "1. Parking Slot Management",0Dh,0Ah
     DB "2. Vehicle Registration & Parking Allocation",0Dh,0Ah
     DB "3. Vehicle Tracking & Information Search",0Dh,0Ah
     DB "4. Parking Fee Calculation",0Dh,0Ah
     DB "5. Parking Violation & Fine Management",0Dh,0Ah
     DB "6. Parking Payment & Settlement Management",0Dh,0Ah
     DB "7. Exit",0Dh,0Ah
     DB "Enter Choice: $"

MSG_SLOT DB 0Dh,0Ah,"===== SLOT STATUS =====",0Dh,0Ah,"$"
MSG_SLOT_NO DB "Slot $"
MSG_FREE DB ": FREE",0Dh,0Ah,"$"
MSG_OCCUPIED DB ": OCCUPIED",0Dh,0Ah,"$"

MSG_RELEASE DB 0Dh,0Ah,"Enter Slot Number to Release (1-5): $"
MSG_RELEASED DB 0Dh,0Ah,"Slot released successfully.",0Dh,0Ah,"$"
MSG_SLOT_EMPTY DB 0Dh,0Ah,"That slot is already free.",0Dh,0Ah,"$"
MSG_BAD_SLOT DB 0Dh,0Ah,"Invalid slot number.",0Dh,0Ah,"$"

MSG_VEHICLE DB 0Dh,0Ah,"Enter Vehicle ID (A-E): $"
MSG_PARKED DB 0Dh,0Ah,"Vehicle parked at Slot: $"
MSG_FULL DB 0Dh,0Ah,"ERROR: Parking is full!",0Dh,0Ah,"$"
MSG_DUP DB 0Dh,0Ah,"ERROR: Vehicle is already parked!",0Dh,0Ah,"$"

MSG_TRACKING DB 0Dh,0Ah,"===== VEHICLE TRACKING =====",0Dh,0Ah,"$"
MSG_TRACK_ID DB "Enter Vehicle ID to search: $"
MSG_TRACKED DB "Vehicle is currently parked.",0Dh,0Ah,"$"
MSG_ASSIGNED_SLOT DB "Assigned Slot: $"
MSG_NOTFOUND DB 0Dh,0Ah,"ERROR: Vehicle not found!",0Dh,0Ah,"$"

MSG_FEE_ID DB 0Dh,0Ah,"Enter Vehicle ID: $"
MSG_HOURS DB 0Dh,0Ah,"Enter Parking Hours (1-9): $"
MSG_FEE DB 0Dh,0Ah,"Parking Fee: $"
MSG_RATE DB 0Dh,0Ah,"Rate: 50 per hour.",0Dh,0Ah,"$"
MSG_VIOLATION DB 0Dh,0Ah,"===== VIOLATION & FINE MANAGEMENT =====",0Dh,0Ah,"$"
MSG_FINE_ID DB "Enter Vehicle ID: $"
MSG_FINE_MENU DB 0Dh,0Ah,"1. No Violation",0Dh,0Ah
              DB "2. Overstaying",0Dh,0Ah
              DB "3. Unauthorized Parking",0Dh,0Ah
              DB "4. Wrong-Slot Parking",0Dh,0Ah
              DB "Enter Choice: $"
MSG_PARKING_FEE DB 0Dh,0Ah,"Parking Fee: $"
MSG_FINE DB 0Dh,0Ah,"Violation Fine: $"
MSG_TOTAL_DUE DB 0Dh,0Ah,"Total Amount Due: $"
MSG_BAD_VIOLATION DB 0Dh,0Ah,"Invalid violation choice.",0Dh,0Ah,"$"

MSG_PAYMENT DB 0Dh,0Ah,"===== PAYMENT & SETTLEMENT =====",0Dh,0Ah,"$"
MSG_PAYMENT_ID DB "Enter Vehicle ID: $"
MSG_AMOUNT_DUE DB "Amount Due: $"
MSG_AMOUNT_PAID DB 0Dh,0Ah,"Enter Amount Paid: $"
MSG_PAYMENT_SUCCESS DB 0Dh,0Ah,"Payment Successful!",0Dh,0Ah,"$"
MSG_CHANGE DB "Change: $"
MSG_PAYMENT_PAID DB "Payment Status: PAID",0Dh,0Ah,"$"
MSG_INSUFFICIENT DB 0Dh,0Ah,"Payment Incomplete!",0Dh,0Ah,"$"
MSG_REMAINING DB "Remaining Amount: $"
MSG_PAYMENT_DUE DB 0Dh,0Ah,"Payment Status: DUE",0Dh,0Ah,"$"

GOODBYE DB 0Dh,0Ah,"Thank you for using Smart Parking System.",0Dh,0Ah,"$"
NEWLINE DB 0Dh,0Ah,"$"

; ======================= PARKING DATA =============================

; 0 = FREE, 1 = OCCUPIED
SLOT_STATUS DB 0,0,0,0,0

; Vehicle ID stored at corresponding slot.
; 0 means no vehicle.
VEHICLE_IDS DB 0,0,0,0,0

TOTAL_SLOTS EQU 5
PARKING_RATE DB 50

OCCUPIED_COUNT DB 0
CURRENT_FEE DW 0

; Per-vehicle billing information.
VEHICLE_FEES DW 5 DUP(0)
VEHICLE_FINES DW 5 DUP(0)
VEHICLE_TOTALS DW 5 DUP(0)
PAYMENT_STATUS DB 5 DUP(0)     ; 0 = DUE, 1 = PAID

AMOUNT_PAID DW 0

; Temporary variables
TEMP_NUM DW 0
TEMP_HOURS DB 0
TEMP_SLOT DB 0
TEMP_VEHICLE DB 0

.CODE

; =================================================================
; MAIN
; =================================================================

MAIN PROC

    MOV AX,@DATA
    MOV DS,AX

MAIN_MENU:

    LEA DX,MENU
    CALL PRINT_STR
    CALL GET_DIGIT

    CMP AL,1
    JE FEATURE_1

    CMP AL,2
    JE FEATURE_2

    CMP AL,3
    JE FEATURE_3

    CMP AL,4
    JE FEATURE_4

    CMP AL,5
    JE FEATURE_5

    CMP AL,6
    JE FEATURE_6

    CMP AL,7
    JE PROGRAM_EXIT

    JMP MAIN_MENU

FEATURE_1:
    CALL MANAGE_SLOTS
    JMP MAIN_MENU

FEATURE_2:
    CALL REGISTER_VEHICLE
    JMP MAIN_MENU

FEATURE_3:
    CALL TRACK_VEHICLE
    JMP MAIN_MENU

FEATURE_4:
    CALL CALCULATE_FEE
    JMP MAIN_MENU

FEATURE_5:
    CALL VIOLATION_MANAGEMENT
    JMP MAIN_MENU

FEATURE_6:
    CALL PAYMENT_SETTLEMENT
    JMP MAIN_MENU

PROGRAM_EXIT:

    LEA DX,GOODBYE
    CALL PRINT_STR

    MOV AX,4C00H
    INT 21H

MAIN ENDP


; =================================================================
; GENERAL INPUT/OUTPUT PROCEDURES
; =================================================================

PRINT_STR PROC

    MOV AH,09H
    INT 21H

    RET
PRINT_STR ENDP


GET_DIGIT PROC

    MOV AH,01H
    INT 21H

    SUB AL,30H
    MOV AH,0

    RET
GET_DIGIT ENDP

; =================================================================
; GET_NUMBER
; Reads a decimal number. Press ENTER when finished.
; Result is returned in AX.
; =================================================================

GET_NUMBER PROC

    MOV BX,0

READ_NUMBER:

    MOV AH,01H
    INT 21H

    CMP AL,0DH
    JE NUMBER_DONE

    SUB AL,30H
    MOV AH,0

    PUSH AX
    MOV AX,BX
    MOV CX,10
    MUL CX
    MOV BX,AX
    POP AX
    ADD BX,AX

    JMP READ_NUMBER

NUMBER_DONE:

    MOV AX,BX
    RET

GET_NUMBER ENDP




; =================================================================
; FEATURE 1
; PARKING SLOT MANAGEMENT
;
; Displays slot status and allows the operator to release a slot
; directly by slot number. This keeps slot maintenance as one
; complete slot-management feature rather than a separate exit
; feature.
; =================================================================

MANAGE_SLOTS PROC

    LEA DX,MSG_SLOT
    CALL PRINT_STR

    MOV SI,0

SHOW_SLOT:

    CMP SI,TOTAL_SLOTS
    JGE SLOT_RELEASE_OPTION

    LEA DX,MSG_SLOT_NO
    CALL PRINT_STR

    MOV AX,SI
    INC AX
    CALL PRINT_NUM

    CMP SLOT_STATUS[SI],0
    JE SHOW_FREE

    LEA DX,MSG_OCCUPIED
    CALL PRINT_STR
    JMP NEXT_SLOT

SHOW_FREE:

    LEA DX,MSG_FREE
    CALL PRINT_STR

NEXT_SLOT:

    INC SI
    JMP SHOW_SLOT


SLOT_RELEASE_OPTION:

    LEA DX,MSG_RELEASE
    CALL PRINT_STR
    CALL GET_DIGIT

    CMP AL,1
    JB BAD_SLOT

    CMP AL,TOTAL_SLOTS
    JA BAD_SLOT

    DEC AL
    MOV AH,0
    MOV SI,AX

    CMP SLOT_STATUS[SI],0
    JE SLOT_ALREADY_FREE

    MOV SLOT_STATUS[SI],0
    MOV VEHICLE_IDS[SI],0
    DEC OCCUPIED_COUNT

    LEA DX,MSG_RELEASED
    CALL PRINT_STR
    RET


SLOT_ALREADY_FREE:

    LEA DX,MSG_SLOT_EMPTY
    CALL PRINT_STR
    RET


BAD_SLOT:

    LEA DX,MSG_BAD_SLOT
    CALL PRINT_STR
    RET

MANAGE_SLOTS ENDP


; =================================================================
; FEATURE 2
; VEHICLE REGISTRATION & PARKING ALLOCATION
;
; Registers a vehicle, prevents duplicate registration, finds the
; first free slot, and associates the vehicle with that slot.
; =================================================================

REGISTER_VEHICLE PROC

    LEA DX,MSG_VEHICLE
    CALL PRINT_STR

    MOV AH,01H
    INT 21H
    MOV BL,AL

    ; ---------------- Check duplicate vehicle ----------------

    MOV SI,0

CHECK_DUP:

    CMP SI,TOTAL_SLOTS
    JGE FIND_SLOT

    CMP VEHICLE_IDS[SI],BL
    JE DUPLICATE

    INC SI
    JMP CHECK_DUP


DUPLICATE:

    LEA DX,MSG_DUP
    CALL PRINT_STR
    RET


    ; ---------------- Find free slot ----------------

FIND_SLOT:

    MOV SI,0

SEARCH_FREE:

    CMP SI,TOTAL_SLOTS
    JGE NO_SPACE

    CMP SLOT_STATUS[SI],0
    JE SLOT_AVAILABLE

    INC SI
    JMP SEARCH_FREE


SLOT_AVAILABLE:

    MOV SLOT_STATUS[SI],1
    MOV VEHICLE_IDS[SI],BL

    INC OCCUPIED_COUNT

    LEA DX,MSG_PARKED
    CALL PRINT_STR

    MOV AX,SI
    INC AX
    CALL PRINT_NUM

    LEA DX,NEWLINE
    CALL PRINT_STR

    RET


NO_SPACE:

    LEA DX,MSG_FULL
    CALL PRINT_STR

    RET

REGISTER_VEHICLE ENDP


; =================================================================
; FEATURE 3
; VEHICLE TRACKING & INFORMATION SEARCH
;
; Searches for a vehicle ID and displays the parking slot currently
; assigned to that vehicle.
; =================================================================

TRACK_VEHICLE PROC

    LEA DX,MSG_TRACKING
    CALL PRINT_STR

    LEA DX,MSG_TRACK_ID
    CALL PRINT_STR

    MOV AH,01H
    INT 21H
    MOV BL,AL

    MOV SI,0

TRACK_SEARCH:

    CMP SI,TOTAL_SLOTS
    JGE TRACK_NOT_FOUND

    CMP VEHICLE_IDS[SI],BL
    JE VEHICLE_FOUND

    INC SI
    JMP TRACK_SEARCH


VEHICLE_FOUND:

    LEA DX,MSG_TRACKED
    CALL PRINT_STR

    LEA DX,MSG_ASSIGNED_SLOT
    CALL PRINT_STR

    MOV AX,SI
    INC AX
    CALL PRINT_NUM

    LEA DX,NEWLINE
    CALL PRINT_STR

    RET


TRACK_NOT_FOUND:

    LEA DX,MSG_NOTFOUND
    CALL PRINT_STR

    RET

TRACK_VEHICLE ENDP


; =================================================================
; FEATURE 4
; PARKING FEE CALCULATION
;
; Calculates a parking charge for a currently parked vehicle.
; Fee = Parking Hours * 50.
;
; After calculation, the billing information is stored as a
; transaction record for Feature 5.
; =================================================================

CALCULATE_FEE PROC

    ; ---------------- Find vehicle ----------------

    LEA DX,MSG_FEE_ID
    CALL PRINT_STR

    MOV AH,01H
    INT 21H
    MOV BL,AL
    MOV TEMP_VEHICLE,AL

    MOV SI,0

FEE_SEARCH:

    CMP SI,TOTAL_SLOTS
    JGE FEE_VEHICLE_NOT_FOUND

    CMP VEHICLE_IDS[SI],BL
    JE FEE_VEHICLE_FOUND

    INC SI
    JMP FEE_SEARCH


FEE_VEHICLE_NOT_FOUND:

    LEA DX,MSG_NOTFOUND
    CALL PRINT_STR
    RET


FEE_VEHICLE_FOUND:

    ; Save slot number
    MOV AX,SI
    INC AX
    MOV TEMP_SLOT,AL

    ; ---------------- Get hours ----------------

    LEA DX,MSG_HOURS
    CALL PRINT_STR

    CALL GET_DIGIT

    MOV TEMP_HOURS,AL

    ; ---------------- Calculate fee ----------------

    MOV BL,PARKING_RATE
    MUL BL

    MOV CURRENT_FEE,AX

    ; Store fee for the selected vehicle.
    MOV AL,TEMP_VEHICLE
    SUB AL,'A'
    MOV AH,0
    MOV SI,AX
    ADD SI,SI
    MOV AX,CURRENT_FEE
    MOV VEHICLE_FEES[SI],AX

    LEA DX,MSG_FEE
    CALL PRINT_STR

    MOV AX,CURRENT_FEE
    CALL PRINT_NUM

    LEA DX,NEWLINE
    CALL PRINT_STR

    LEA DX,MSG_RATE
    CALL PRINT_STR

    ; ---------------- Save transaction ----------------


    RET

CALCULATE_FEE ENDP


; =================================================================
;
; Utility procedure used by Feature 4 to store one billing
; transaction in the transaction arrays.
;
; Stored information:
;   Vehicle ID
;   Slot number
;   Parking hours
;   Fee
; =================================================================
; =================================================================
; =================================================================
; FEATURE 5
; PARKING VIOLATION & FINE MANAGEMENT
;
; Finds the stored parking fee for a vehicle, applies a violation
; fine, and stores the final amount due for that vehicle.
; =================================================================

VIOLATION_MANAGEMENT PROC

    LEA DX,MSG_VIOLATION
    CALL PRINT_STR

    LEA DX,MSG_FINE_ID
    CALL PRINT_STR

    MOV AH,01H
    INT 21H
    MOV BL,AL

    CMP BL,'A'
    JB FEE_NOT_FOUND
    CMP BL,'E'
    JA FEE_NOT_FOUND

    ; Vehicle A-E becomes array index 0-4.
    MOV AL,BL
    SUB AL,'A'
    MOV AH,0
    MOV SI,AX
    ADD SI,SI

    MOV AX,VEHICLE_FEES[SI]
    CMP AX,0
    JE FEE_NOT_FOUND

    MOV CURRENT_FEE,AX

    LEA DX,MSG_PARKING_FEE
    CALL PRINT_STR

    MOV AX,CURRENT_FEE
    CALL PRINT_NUM

    LEA DX,MSG_FINE_MENU
    CALL PRINT_STR

    CALL GET_DIGIT

    CMP AL,1
    JE NO_VIOLATION

    CMP AL,2
    JE OVERSTAYING

    CMP AL,3
    JE UNAUTHORIZED

    CMP AL,4
    JE WRONG_SLOT

    LEA DX,MSG_BAD_VIOLATION
    CALL PRINT_STR
    RET

NO_VIOLATION:

    MOV AX,0
    MOV VEHICLE_FINES[SI],AX
    JMP CALCULATE_TOTAL

OVERSTAYING:

    MOV AX,200
    MOV VEHICLE_FINES[SI],AX
    JMP CALCULATE_TOTAL

UNAUTHORIZED:

    MOV AX,300
    MOV VEHICLE_FINES[SI],AX
    JMP CALCULATE_TOTAL

WRONG_SLOT:

    MOV AX,150
    MOV VEHICLE_FINES[SI],AX

CALCULATE_TOTAL:

    MOV AX,VEHICLE_FEES[SI]
    ADD AX,VEHICLE_FINES[SI]
    MOV VEHICLE_TOTALS[SI],AX

    ; New total needs a new payment.
    MOV DI,SI
    SHR DI,1
    MOV PAYMENT_STATUS[DI],0

    LEA DX,MSG_FINE
    CALL PRINT_STR

    MOV AX,VEHICLE_FINES[SI]
    CALL PRINT_NUM

    LEA DX,MSG_TOTAL_DUE
    CALL PRINT_STR

    MOV AX,VEHICLE_TOTALS[SI]
    CALL PRINT_NUM

    LEA DX,NEWLINE
    CALL PRINT_STR

    RET

FEE_NOT_FOUND:

    LEA DX,MSG_NOTFOUND
    CALL PRINT_STR

    RET

VIOLATION_MANAGEMENT ENDP


; =================================================================
; FEATURE 6
; PARKING PAYMENT & SETTLEMENT MANAGEMENT
;
; Selects a vehicle, retrieves that vehicle's final amount due,
; and processes the amount paid.
; =================================================================

PAYMENT_SETTLEMENT PROC

    LEA DX,MSG_PAYMENT
    CALL PRINT_STR

    LEA DX,MSG_PAYMENT_ID
    CALL PRINT_STR

    MOV AH,01H
    INT 21H
    MOV BL,AL

    CMP BL,'A'
    JB NO_AMOUNT_DUE
    CMP BL,'E'
    JA NO_AMOUNT_DUE

    ; Vehicle A-E becomes array index 0-4.
    MOV AL,BL
    SUB AL,'A'
    MOV AH,0
    MOV SI,AX
    ADD SI,SI

    ; Convert word-array index to byte-array index.
    MOV DI,SI
    SHR DI,1

    MOV AX,VEHICLE_TOTALS[SI]
    CMP AX,0
    JE NO_AMOUNT_DUE

    CMP PAYMENT_STATUS[DI],1
    JE ALREADY_PAID

    LEA DX,MSG_AMOUNT_DUE
    CALL PRINT_STR

    MOV AX,VEHICLE_TOTALS[SI]
    CALL PRINT_NUM

    LEA DX,MSG_AMOUNT_PAID
    CALL PRINT_STR

    CALL GET_NUMBER
    MOV AMOUNT_PAID,AX

    MOV AX,AMOUNT_PAID
    CMP AX,VEHICLE_TOTALS[SI]
    JE EXACT_PAYMENT
    JA EXTRA_PAYMENT

INSUFFICIENT_PAYMENT:

    LEA DX,MSG_INSUFFICIENT
    CALL PRINT_STR

    LEA DX,MSG_REMAINING
    CALL PRINT_STR

    MOV AX,VEHICLE_TOTALS[SI]
    SUB AX,AMOUNT_PAID

    CALL PRINT_NUM

    LEA DX,MSG_PAYMENT_DUE
    CALL PRINT_STR

    RET

EXACT_PAYMENT:

    MOV PAYMENT_STATUS[DI],1

    LEA DX,MSG_PAYMENT_SUCCESS
    CALL PRINT_STR

    LEA DX,MSG_PAYMENT_PAID
    CALL PRINT_STR

    RET

EXTRA_PAYMENT:

    MOV PAYMENT_STATUS[DI],1

    LEA DX,MSG_PAYMENT_SUCCESS
    CALL PRINT_STR

    LEA DX,MSG_CHANGE
    CALL PRINT_STR

    MOV AX,AMOUNT_PAID
    SUB AX,VEHICLE_TOTALS[SI]

    CALL PRINT_NUM

    LEA DX,MSG_PAYMENT_PAID
    CALL PRINT_STR

    RET

ALREADY_PAID:

    LEA DX,MSG_PAYMENT_PAID
    CALL PRINT_STR

    RET

NO_AMOUNT_DUE:

    LEA DX,MSG_NOTFOUND
    CALL PRINT_STR

    RET

PAYMENT_SETTLEMENT ENDP


; PRINT_NUM
;
; Prints an unsigned decimal number from 0 to 999.
; =================================================================

PRINT_NUM PROC

    CMP AX,100
    JB BELOW_100

    ; ---------------- 100 to 999 ----------------

    MOV BX,100
    MOV DX,0
    DIV BX

    ; Save last two digits before using DX for output
    MOV TEMP_NUM,DX

    ; Print hundreds digit
    ADD AL,30H
    MOV DL,AL
    MOV AH,02H
    INT 21H

    ; Restore last two digits
    MOV AX,TEMP_NUM

    MOV BX,10
    MOV DX,0
    DIV BX

    ; Save ones digit before using DL for output
    MOV TEMP_NUM,DX

    ; Print tens digit
    ADD AL,30H
    MOV DL,AL
    MOV AH,02H
    INT 21H

    ; Print ones digit
    MOV AX,TEMP_NUM
    ADD AL,30H
    MOV DL,AL
    MOV AH,02H
    INT 21H

    RET


BELOW_100:

    ; ---------------- 0 to 99 ----------------

    MOV BX,10
    MOV DX,0
    DIV BX

    ; Save ones digit
    MOV TEMP_NUM,DX

    CMP AX,0
    JE PRINT_SINGLE_DIGIT

    ; Print tens digit
    ADD AL,30H
    MOV DL,AL
    MOV AH,02H
    INT 21H

    ; Print ones digit
    MOV AX,TEMP_NUM
    ADD AL,30H
    MOV DL,AL
    MOV AH,02H
    INT 21H

    RET


PRINT_SINGLE_DIGIT:

    MOV AX,TEMP_NUM
    ADD AL,30H
    MOV DL,AL
    MOV AH,02H
    INT 21H

    RET

PRINT_NUM ENDP


END MAIN
