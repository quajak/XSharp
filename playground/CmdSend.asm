; namespace DebugStub

; function SendRegisters {
DebugStub_SendRegisters:
    ; Send the actual started signal
    ; AL = #Ds2Vs_Registers
    Mov AL, DebugStub_Const_Ds2Vs_Registers
    ; ComWriteAL()
    Call DebugStub_ComWriteAL

    ; ESI = .PushAllPtr
    Mov ESI, DWORD [DebugStub_PushAllPtr]
    ; ECX = 32
    Mov ECX, 0x20
    ; ComWriteX()
    Call DebugStub_ComWriteX

    ; ESI = @.CallerESP
    Mov ESI, DebugStub_CallerESP
    ; ComWrite32()
    Call DebugStub_ComWrite32

    ; ESI = @.CallerEIP
    Mov ESI, DebugStub_CallerEIP
    ; ComWrite32()
    Call DebugStub_ComWrite32
; }
DebugStub_SendRegisters_Exit:
Mov DWORD [INTS_LastKnownAddress], DebugStub_SendRegisters_Exit
Ret 

; function SendFrame {
DebugStub_SendFrame:
    ; AL = #Ds2Vs_Frame
    Mov AL, DebugStub_Const_Ds2Vs_Frame
    ; ComWriteAL()
    Call DebugStub_ComWriteAL

    ; EAX = 32
    Mov EAX, 0x20
    ; ComWriteAX()
    Call DebugStub_ComWriteAX

    ; ESI = .CallerEBP
    Mov ESI, DWORD [DebugStub_CallerEBP]
    ; Dont transmit EIP or old EBP
    ; ESI += 8
    Add ESI, 0x8
    ; ECX = 32
    Mov ECX, 0x20
    ; ComWriteX()
    Call DebugStub_ComWriteX
; }
DebugStub_SendFrame_Exit:
Mov DWORD [INTS_LastKnownAddress], DebugStub_SendFrame_Exit
Ret 

; AL contains channel
; BL contains command
; ESI contains data start pointer
; ECX contains number of bytes to send as command data
; function SendCommandOnChannel{
DebugStub_SendCommandOnChannel:
  ; +All
  PushAD 
    ; ComWriteAL()
    Call DebugStub_ComWriteAL
  ; -All
  PopAD 

  ; AL = BL
  Mov AL, BL

  ; +All
  PushAD 
    ; ComWriteAL()
    Call DebugStub_ComWriteAL
  ; -All
  PopAD 

  ; +All
  PushAD 
    ; EAX = ECX
    Mov EAX, ECX
    ; ComWriteEAX()
    Call DebugStub_ComWriteEAX
  ; -All
  PopAD 

  ; now ECX contains size of data (count)
    ; ESI contains address
    ; while ECX != 0 {
        ; ComWrite8()
        Call DebugStub_ComWrite8
        ; ECX--
        Dec ECX
    ; }
    DebugStub_SendCommandOnChannel_Block1_End:
; }
DebugStub_SendCommandOnChannel_Exit:
Mov DWORD [INTS_LastKnownAddress], DebugStub_SendCommandOnChannel_Exit
Ret 

; function SendStack {
DebugStub_SendStack:
    ; AL = #Ds2Vs_Stack
    Mov AL, DebugStub_Const_Ds2Vs_Stack
    ; ComWriteAL()
    Call DebugStub_ComWriteAL

    ; Send size of bytes
    ; ESI = .CallerESP
    Mov ESI, DWORD [DebugStub_CallerESP]
    ; EAX = .CallerEBP
    Mov EAX, DWORD [DebugStub_CallerEBP]
    ; EAX -= ESI
    Sub EAX, ESI
    ; ComWriteAX()
    Call DebugStub_ComWriteAX

    ; Send actual bytes
    ; Need to reload ESI, WriteAXToCompPort modifies it
    ; ESI = .CallerESP
    Mov ESI, DWORD [DebugStub_CallerESP]
    ; while ESI != .CallerEBP {
        ; ComWrite8()
        Call DebugStub_ComWrite8
    ; }
    DebugStub_SendStack_Block1_End:
; }
DebugStub_SendStack_Exit:
Mov DWORD [INTS_LastKnownAddress], DebugStub_SendStack_Exit
Ret 

; sends a stack value
; Serial Params:
; 1: x32 - offset relative to EBP
; 2: x32 - size of data to send
; function SendMethodContext {
DebugStub_SendMethodContext:
    ; +All
    PushAD 

    ; AL = #Ds2Vs_MethodContext
    Mov AL, DebugStub_Const_Ds2Vs_MethodContext
    ; ComWriteAL()
    Call DebugStub_ComWriteAL

    ; ESI = .CallerEBP
    Mov ESI, DWORD [DebugStub_CallerEBP]

    ; offset relative to ebp
    ; size of data to send
    ; ComReadEAX()
    Call DebugStub_ComReadEAX
    ; ESI += EAX
    Add ESI, EAX
    ; ComReadEAX()
    Call DebugStub_ComReadEAX
    ; ECX = EAX
    Mov ECX, EAX

    ; now ECX contains size of data (count)
    ; ESI contains relative to EBP

    ; while ECX != 0 {
        ; ComWrite8()
        Call DebugStub_ComWrite8
        ; ECX--
        Dec ECX
    ; }
    DebugStub_SendMethodContext_Block1_End:

; Exit:
DebugStub_SendMethodContext_Exit:
    ; -All
    PopAD 
; }
Mov DWORD [INTS_LastKnownAddress], DebugStub_SendMethodContext_Exit
Ret 

; none
; saveregs
; frame
; sends a stack value
; Serial Params:
; 1: x32 - address
; 2: x32 - size of data to send
; function SendMemory {
DebugStub_SendMemory:
    ; +All
    PushAD 

    ; AL = #Ds2Vs_MemoryData
    Mov AL, DebugStub_Const_Ds2Vs_MemoryData
    ; ComWriteAL()
    Call DebugStub_ComWriteAL

    ; ComReadEAX()
    Call DebugStub_ComReadEAX
    ; ESI = EAX
    Mov ESI, EAX
    ; ComReadEAX()
    Call DebugStub_ComReadEAX
    ; ECX = EAX
    Mov ECX, EAX

    ; now ECX contains size of data (count)
    ; ESI contains address
    ; while ECX != 0 {
        ; ComWrite8()
        Call DebugStub_ComWrite8
        ; ECX--
        Dec ECX
    ; }
    DebugStub_SendMemory_Block1_End:

; Exit:
DebugStub_SendMemory_Exit:
    ; -All
    PopAD 
; }
Mov DWORD [INTS_LastKnownAddress], DebugStub_SendMemory_Exit
Ret 

; Modifies: EAX, ESI
; function SendTrace {
DebugStub_SendTrace:
    ; AL = #Ds2Vs_BreakPoint
    Mov AL, DebugStub_Const_Ds2Vs_BreakPoint
    ; If we are running, its a tracepoint, not a breakpoint.
    ; In future, maybe separate these into 2 methods
    ; if dword .DebugStatus = #Status_Run {
    Cmp DWORD [DebugStub_DebugStatus], DebugStub_Const_Status_Run
    Jne DebugStub_SendTrace_Block1_End
        ; AL = #Ds2Vs_TracePoint
        Mov AL, DebugStub_Const_Ds2Vs_TracePoint
    ; }
    DebugStub_SendTrace_Block1_End:
    ; ComWriteAL()
    Call DebugStub_ComWriteAL

    ; Send Calling EIP.
    ; ESI = @.CallerEIP
    Mov ESI, DebugStub_CallerEIP
    ; ComWrite32()
    Call DebugStub_ComWrite32
; }
DebugStub_SendTrace_Exit:
Mov DWORD [INTS_LastKnownAddress], DebugStub_SendTrace_Exit
Ret 

; Input: Stack
; Output: None
; Modifies: EAX, ECX, EDX, ESI
; function SendText {
DebugStub_SendText:
; +EBP
Push EBP
; EBP = ESP
Mov EBP, ESP
    ; +All
    PushAD 
    ; Write the type
    ; AL = #Ds2Vs_Message
    Mov AL, DebugStub_Const_Ds2Vs_Message
    ; ComWriteAL()
    Call DebugStub_ComWriteAL

    ; Write Length
    ; ESI = EBP
    Mov ESI, EBP
    ; ESI += 12
    Add ESI, 0xC
    ; ECX = [ESI]
    Mov ECX, DWORD [ESI]
    ; ComWrite16()
    Call DebugStub_ComWrite16

    ; Address of string
    ; ESI = [EBP + 8]
    Mov ESI, DWORD [EBP + 8]
; WriteChar:
DebugStub_SendText_WriteChar:
    ; if ECX = 0 goto Finalize
    Cmp ECX, 0x0
    Je DebugStub_SendText_Finalize
    ; ComWrite8()
    Call DebugStub_ComWrite8
    ; ECX--
    Dec ECX
    ; We are storing as 16 bits, but for now I will transmit 8 bits
    ; So we inc again to skip the 0
    ; ESI++
    Inc ESI
    ; goto WriteChar
    Jmp DebugStub_SendText_WriteChar

    ; Write Length
    ; ESI = EBP
    ; ESI + 12
    ; ECX = [ESI]
    ; // Address of string
    ; ESI = [EBP + 8]
; Finalize:
DebugStub_SendText_Finalize:
    ; -All
    PopAD 
  ; -EBP
  Pop EBP
; }
DebugStub_SendText_Exit:
Mov DWORD [INTS_LastKnownAddress], DebugStub_SendText_Exit
Ret 

; Input: Stack
; Output: None
; Modifies: EAX, ECX, EDX, ESI
; function SendSimpleNumber {
DebugStub_SendSimpleNumber:
; +EBP
Push EBP
; EBP = ESP
Mov EBP, ESP
    ; +All
    PushAD 
    ; Write the type
    ; AL = #Ds2Vs_SimpleNumber
    Mov AL, DebugStub_Const_Ds2Vs_SimpleNumber
    ; ComWriteAL()
    Call DebugStub_ComWriteAL

    ; Write value
    ; EAX = [EBP + 8]
    Mov EAX, DWORD [EBP + 8]
    ; ComWriteEAX()
    Call DebugStub_ComWriteEAX

    ; -All
    PopAD 
  ; -EBP
  Pop EBP
; }
DebugStub_SendSimpleNumber_Exit:
Mov DWORD [INTS_LastKnownAddress], DebugStub_SendSimpleNumber_Exit
Ret 

; Input: Stack
; Output: None
; Modifies: EAX, ECX, EDX, ESI
; function SendKernelPanic {
DebugStub_SendKernelPanic:
; +EBP
Push EBP
; EBP = ESP
Mov EBP, ESP
    ; +All
    PushAD 
    ; Write the type
    ; AL = #Ds2Vs_KernelPanic
    Mov AL, DebugStub_Const_Ds2Vs_KernelPanic
    ; ComWriteAL()
    Call DebugStub_ComWriteAL

    ; Write value
    ; EAX = [EBP + 8]
    Mov EAX, DWORD [EBP + 8]
    ; ComWriteEAX()
    Call DebugStub_ComWriteEAX

	; SendCoreDump()
	Call DebugStub_SendCoreDump
    ; -All
    PopAD 
  ; -EBP
  Pop EBP
; }
DebugStub_SendKernelPanic_Exit:
Mov DWORD [INTS_LastKnownAddress], DebugStub_SendKernelPanic_Exit
Ret 

; Input: Stack
; Output: None
; Modifies: EAX, ECX, EDX, ESI
; function SendSimpleLongNumber {
DebugStub_SendSimpleLongNumber:
  ; +EBP
  Push EBP
  ; EBP = ESP
  Mov EBP, ESP
  ; +All
  PushAD 

  ; Write the type
  ; AL = #Ds2Vs_SimpleLongNumber
  Mov AL, DebugStub_Const_Ds2Vs_SimpleLongNumber
  ; ComWriteAL()
  Call DebugStub_ComWriteAL

  ; Write value
  ; EAX = [EBP + 8]
  Mov EAX, DWORD [EBP + 8]
  ; ComWriteEAX()
  Call DebugStub_ComWriteEAX
  ; EAX = [EBP + 12]
  Mov EAX, DWORD [EBP + 12]
  ; ComWriteEAX()
  Call DebugStub_ComWriteEAX

  ; -All
  PopAD 
  ; -EBP
  Pop EBP
; }
DebugStub_SendSimpleLongNumber_Exit:
Mov DWORD [INTS_LastKnownAddress], DebugStub_SendSimpleLongNumber_Exit
Ret 

; Input: Stack
; Output: None
; Modifies: EAX, ECX, EDX, ESI
; function SendComplexNumber {
DebugStub_SendComplexNumber:
  ; +EBP
  Push EBP
  ; EBP = ESP
  Mov EBP, ESP
  ; +All
  PushAD 

  ; Write the type
  ; AL = #Ds2Vs_ComplexNumber
  Mov AL, DebugStub_Const_Ds2Vs_ComplexNumber
  ; ComWriteAL()
  Call DebugStub_ComWriteAL

  ; Write value
  ; EAX = [EBP+8]
  Mov EAX, DWORD [EBP + 8]
  ; ComWriteEAX()
  Call DebugStub_ComWriteEAX

  ; -All
  PopAD 
  ; -EBP
  Pop EBP
; }
DebugStub_SendComplexNumber_Exit:
Mov DWORD [INTS_LastKnownAddress], DebugStub_SendComplexNumber_Exit
Ret 

; Input: Stack
; Output: None
; Modifies: EAX, ECX, EDX, ESI
; function SendComplexLongNumber {
DebugStub_SendComplexLongNumber:
  ; +EBP
  Push EBP
  ; EBP = ESP
  Mov EBP, ESP
  ; +All
  PushAD 

  ; Write the type
  ; AL = #Ds2Vs_ComplexLongNumber
  Mov AL, DebugStub_Const_Ds2Vs_ComplexLongNumber
  ; ComWriteAL()
  Call DebugStub_ComWriteAL

  ; Write value
  ; EAX = [EBP+8]
  Mov EAX, DWORD [EBP + 8]
  ; ComWriteEAX()
  Call DebugStub_ComWriteEAX
  ; EAX = [EBP+12]
  Mov EAX, DWORD [EBP + 12]
  ; ComWriteEAX()
  Call DebugStub_ComWriteEAX

  ; -All
  PopAD 
  ; -EBP
  Pop EBP
; }
DebugStub_SendComplexLongNumber_Exit:
Mov DWORD [INTS_LastKnownAddress], DebugStub_SendComplexLongNumber_Exit
Ret 

; Input: Stack
; Output: None
; Modifies: EAX, ECX, EDX, ESI
; function SendPtr {
DebugStub_SendPtr:
    ; Write the type
    ; AL = #Ds2Vs_Pointer
    Mov AL, DebugStub_Const_Ds2Vs_Pointer
    ; ComWriteAL()
    Call DebugStub_ComWriteAL

    ; pointer value
    ; ESI = [EBP+8]
    Mov ESI, DWORD [EBP + 8]
    ; ComWrite32()
    Call DebugStub_ComWrite32
; }
DebugStub_SendPtr_Exit:
Mov DWORD [INTS_LastKnownAddress], DebugStub_SendPtr_Exit
Ret 

; Input: Stack
; Output: None
; Modifies: EAX, ECX, EDX, ESI
; function SendStackCorruptionOccurred {
DebugStub_SendStackCorruptionOccurred:
    ; Write the type
    ; AL = #Ds2Vs_StackCorruptionOccurred
    Mov AL, DebugStub_Const_Ds2Vs_StackCorruptionOccurred
    ; ComWriteAL()
    Call DebugStub_ComWriteAL

    ; pointer value
    ; ESI = @.CallerEIP
    Mov ESI, DebugStub_CallerEIP
    ; ComWrite32()
    Call DebugStub_ComWrite32
; }
DebugStub_SendStackCorruptionOccurred_Exit:
Mov DWORD [INTS_LastKnownAddress], DebugStub_SendStackCorruptionOccurred_Exit
Ret 

; Input: Stack
; Output: None
; Modifies: EAX, ECX, EDX, ESI
; function SendStackOverflowOccurred {
DebugStub_SendStackOverflowOccurred:
    ; Write the type
    ; AL = #Ds2Vs_StackOverflowOccurred
    Mov AL, DebugStub_Const_Ds2Vs_StackOverflowOccurred
    ; ComWriteAL()
    Call DebugStub_ComWriteAL

    ; pointer value
    ; ESI = @.CallerEIP
    Mov ESI, DebugStub_CallerEIP
    ; ComWrite32()
    Call DebugStub_ComWrite32
; }
DebugStub_SendStackOverflowOccurred_Exit:
Mov DWORD [INTS_LastKnownAddress], DebugStub_SendStackOverflowOccurred_Exit
Ret 

; Input: None
; Output: None
; Modifies: EAX, ECX, EDX, ESI
; function SendInterruptOccurred {
DebugStub_SendInterruptOccurred:
    ; Write the type
	; +EAX
	Push EAX

		; AL = #Ds2Vs_InterruptOccurred
		Mov AL, DebugStub_Const_Ds2Vs_InterruptOccurred
		; ComWriteAL()
		Call DebugStub_ComWriteAL

    ; -EAX
    Pop EAX
	; ComWriteEAX()
	Call DebugStub_ComWriteEAX
; }
DebugStub_SendInterruptOccurred_Exit:
Mov DWORD [INTS_LastKnownAddress], DebugStub_SendInterruptOccurred_Exit
Ret 

; Input: Stack
; Output: None
; Modifies: EAX, ECX, EDX, ESI
; function SendNullReferenceOccurred {
DebugStub_SendNullReferenceOccurred:
    ; Write the type
    ; AL = #Ds2Vs_NullReferenceOccurred
    Mov AL, DebugStub_Const_Ds2Vs_NullReferenceOccurred
    ; ComWriteAL()
    Call DebugStub_ComWriteAL

    ; pointer value
    ; ESI = @.CallerEIP
    Mov ESI, DebugStub_CallerEIP
    ; ComWrite32()
    Call DebugStub_ComWrite32
; }
DebugStub_SendNullReferenceOccurred_Exit:
Mov DWORD [INTS_LastKnownAddress], DebugStub_SendNullReferenceOccurred_Exit
Ret 

; Input: Stack
; Output: None
; Modifies: EAX, ECX, EDX, ESI
; function SendMessageBox {
DebugStub_SendMessageBox:
    ; Write the type
    ; AL = #Ds2Vs_MessageBox
    Mov AL, DebugStub_Const_Ds2Vs_MessageBox
    ; ComWriteAL()
    Call DebugStub_ComWriteAL

    ; Write Length
    ; ESI = EBP
    Mov ESI, EBP
    ; ESI += 12
    Add ESI, 0xC
    ; ECX = [ESI]
    Mov ECX, DWORD [ESI]
    ; ComWrite16()
    Call DebugStub_ComWrite16

    ; Address of string
    ; ESI = [EBP+8]
    Mov ESI, DWORD [EBP + 8]
; WriteChar:
DebugStub_SendMessageBox_WriteChar:
    ; if ECX = 0 return
    Cmp ECX, 0x0
    Je DebugStub_SendMessageBox_Exit
    ; ComWrite8()
    Call DebugStub_ComWrite8
    ; ECX--
    Dec ECX
    ; We are storing as 16 bits, but for now I will transmit 8 bits
    ; So we inc again to skip the 0
    ; ESI++
    Inc ESI
    ; goto WriteChar
    Jmp DebugStub_SendMessageBox_WriteChar
; }
DebugStub_SendMessageBox_Exit:
Mov DWORD [INTS_LastKnownAddress], DebugStub_SendMessageBox_Exit
Ret 

; function SendCoreDump {
DebugStub_SendCoreDump:
    ; +EAX
    Push EAX
    ; +EBX
    Push EBX
    ; +ECX
    Push ECX
    ; +EDX
    Push EDX
    ; +EDI
    Push EDI
    ; +ESI
    Push ESI
    ; EAX = @.CallerEBP
    Mov EAX, DebugStub_CallerEBP
    ; +EAX
    Push EAX
    ; EAX = @.CallerEIP
    Mov EAX, DebugStub_CallerEIP
    ; +EAX
    Push EAX
    ; EAX = @.CallerESP
    Mov EAX, DebugStub_CallerESP
    ; +EAX
    Push EAX
    ; ECX = 36
    Mov ECX, 0x24
    ; EAX = EBP
    Mov EAX, EBP
    ; while EAX != 0 {
        ; EAX -= 4
        Sub EAX, 0x4
        ; +EAX
        Push EAX
        ; ECX += 4
        Add ECX, 0x4
        ; EAX = [EAX]
        Mov EAX, DWORD [EAX]
    ; }
    DebugStub_SendCoreDump_Block1_End:

    ; Send command
	; AL = #Ds2Vs_CoreDump
	Mov AL, DebugStub_Const_Ds2Vs_CoreDump
	; ComWriteAL()
	Call DebugStub_ComWriteAL
    ; EAX = ECX
    Mov EAX, ECX
    ; ComWriteAX()
    Call DebugStub_ComWriteAX
    ; while ECX != 0 {
        ; -EAX
        Pop EAX
        ; ComWriteEAX()
        Call DebugStub_ComWriteEAX
        ; ECX--
        Dec ECX
    ; }
    DebugStub_SendCoreDump_Block2_End:
; }
DebugStub_SendCoreDump_Exit:
Mov DWORD [INTS_LastKnownAddress], DebugStub_SendCoreDump_Exit
Ret 
