﻿namespace XSharp.Assembler
{
    [XSharp.Assembler.OpCode("%endif")]
    public class EndIfDefined : Instruction, IEndIfDefined {
        public override void WriteText(XSharp.Assembler.Assembler aAssembler, System.IO.TextWriter aOutput)
        {
            aOutput.Write(this.GetAsText());
        }
    }
}