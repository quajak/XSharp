﻿namespace XSharp.x86
{
    // Do all 8086/88 ops first
    // https://en.wikipedia.org/wiki/X86_instruction_listings
    //
    // http://ref.x86asm.net/coder32-abc.html
    // http://ref.x86asm.net/coder32.html
    // http://www.sandpile.org/
    // https://www-user.tu-chemnitz.de/~heha/viewchm.php/hs/x86.chm/x86.htm
    // http://www.felixcloutier.com/x86/
    //
    // x86 Instruction Encoding Revealed: Bit Twiddling for Fun and Profit
    // https://www.codeproject.com/Articles/662301/x-Instruction-Encoding-Revealed-Bit-Twiddling-fo
    //
    // Mulitbyte NOPs
    // https://software.intel.com/en-us/forums/watercooler-catchall/topic/307174
    // https://reverseengineering.stackexchange.com/questions/11971/nop-with-argument-in-x86-64
    // http://www.felixcloutier.com/x86/NOP.html
    // https://stackoverflow.com/questions/4798356/amd64-nopw-assembly-instruction
    // http://john.freml.in/amd64-nopl - Jump targets aligned on 16 byte boundaries
    // https://sites.google.com/site/paulclaytonplace/andy-glew-s-comparch-wiki/hint-instructions - Generic, Intel doesnt appear to have hints

    // Please add ops in alphabetical order
    public enum OpCode
    {
        Add,    // Add
        And,    // And
        Cmp,    // Compare
        Dec,    // Decrement
        Div,    // Divide
        In,     // In Oprator
        Inc,    // Increment
        IRet,   // Interrupt return
        Je,     // Jump if equal
        Ja,     // Jump if above
        Jae,    // Jump if above or equal
        Jb,     // Jump if below
        Jbe,    // Jump if below or equal
        Jmp,    // Jump
        Jne,    // Jump if not equal
        Mov,    // Move
        Mul,    // Multiply
        NOP,    // No op
        Not,    // Not
        Or,     // Or
        Out,    // Out
        Pop,    // Pop
        PopAD,  // Pop all
        Push,   // Push
        PushAD, // Push all
        Rem,    // Remainder
        Ret,    // Return
        Rol,    // Rotate Left
        Ror,    // Rotate Right
        Shl,     // Logical Shift Left
        Shr,     // Logical Shift Right
        Sub,    // Subtract
        Test,   // Test - logical compare
    }
}
