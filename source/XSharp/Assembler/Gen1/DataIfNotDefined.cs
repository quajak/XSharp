﻿using System;

namespace XSharp.Assembler
{
    public class DataIfNotDefined: DataMember, IIfNotDefined {
        public DataIfNotDefined(string aSymbol)
            : base("define", Array.Empty<byte>()) {
            Symbol = aSymbol;
        }

        public string Symbol {
            get;
            set;
        }

        public override void WriteText(XSharp.Assembler.Assembler aAssembler, System.IO.TextWriter aOutput)
        {
            aOutput.Write(this.GetAsText());
        }
    }
}
