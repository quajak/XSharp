﻿namespace XSharp.Assembler
{
    [XSharp.Assembler.OpCode("%ifdef")]
    public class IfDefined: Instruction, IIfDefined {
        public string Symbol {
            get;
            set;
        }

        public IfDefined(string aSymbol) {
            Symbol = aSymbol;
        }

        public override void WriteText(XSharp.Assembler.Assembler aAssembler, System.IO.TextWriter aOutput)
        {
            aOutput.Write(this.GetAsText());
        }
    }
}