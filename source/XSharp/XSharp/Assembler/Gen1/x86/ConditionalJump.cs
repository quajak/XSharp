﻿namespace XSharp.Assembler.x86
{
    [XSharp.Assembler.OpCode("jcc")]
    public class ConditionalJump: JumpBase, IInstructionWithCondition {
        public ConditionalTestEnum Condition {
            get;
            set;
        }

        public override void WriteText( XSharp.Assembler.Assembler aAssembler, System.IO.TextWriter aOutput )
        {
            // MtW: NEVER EVER remove "near" here! It causes Nasm to take about 100 times as muh time for assembling....
            mMnemonic = "J" + Condition.GetMnemonic().ToUpperInvariant() + " near";
            base.WriteText(aAssembler, aOutput);
        }
    }
}
