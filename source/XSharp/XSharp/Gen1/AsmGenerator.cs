﻿using System;
using System.Globalization;
using System.IO;

namespace XSharp
{
    // This class performs the translation from X# source code into a target
    // assembly language. At current time the only supported assembler syntax is NASM.

    public class AsmGenerator {
    protected TokenPatterns mPatterns = new TokenPatterns();

    public enum FlagBool {
      On, Off, Inherit
    }
    /// <summary>Should we keep the user comments in the generated target assembly program ?</summary>
    public bool EmitUserComments = false;

    public bool EmitSourceCode = true;

    protected int mLineNo = 0;
    protected string mPathname = "";

    /// <summary>Invoke this method when end of source code file is reached to make sure the last
    /// function or interrupt handler has well balanced opening/closing curly braces.</summary>
    private void AssertLastFunctionComplete() {
      if (!mPatterns.InFunctionBody) {
        return;
      }
      throw new Exception("The last function or interrupt handler from source code file is missing a curly brace.");
    }

    /// <summary>Parse the input X# source code file and generate the matching target assembly
    /// language.</summary>
    /// <param name="aReader">X# source code reader.</param>
    /// <returns>The resulting target assembler content. The returned object contains
    /// a code and a data block.</returns>
    public Assembler.Assembler Generate(TextReader aReader) {
      if (aReader == null) {
        throw new ArgumentNullException(nameof(aReader));
      }
      mPatterns.EmitUserComments = EmitUserComments;
      mLineNo = 0;
      var xResult = new Assembler.Assembler();
      try {
        // Read one X# source code line at a time and process it.
        while (true) {
          mLineNo++;
          string xLine = aReader.ReadLine();
          if (xLine == null) {
            break;
          }

          ProcessLine(xLine, mLineNo);
        }
        AssertLastFunctionComplete();
        return xResult;
      } finally {
        Assembler.Assembler.ClearCurrentInstance();
      }
    }

    /// <summary>Parse the input X# source code file and generate the matching target assembly
    /// language.</summary>
    /// <param name="aSrcPathname">X# source code file.</param>
    /// <returns>The resulting target assembler content. The returned object contains
    /// a code and a data block.</returns>
    public Assembler.Assembler Generate(string aSrcPathname) {
      try {
        using (var xInput = new StreamReader(File.Open(aSrcPathname, FileMode.Open))) {
          return Generate(xInput);
        }
      } catch (Exception E) {
        throw new Exception("Error while generating output for file " + Path.GetFileName(aSrcPathname), E);
      }
    }

    /// <summary>Parse the input X# source code file and generate two new files with target
    /// assembly language. The two generated files contain target assembler source and target
    /// assembler data respectively.</summary>
    /// <param name="aSrcPathname">X# source code file.</param>
    public void GenerateToFiles(string aSrcPathname) {
      mPathname = Path.GetFileName(aSrcPathname);
      new Assembler.Assembler(false);
      try {
        using (var xIn = File.OpenText(aSrcPathname)) {
          using (var xOut = new StreamWriter(File.Open(Path.ChangeExtension(aSrcPathname, ".asm"), FileMode.OpenOrCreate))) {
            xOut.WriteLine("; Generated at {0}", DateTime.Now.ToString(new CultureInfo("en-US")));
            Generate(xIn, xOut);
          }
        }
      } finally {
        Assembler.Assembler.ClearCurrentInstance();
      }
    }

    public void GenerateToFile(string aFileName, TextReader aSourceReader, TextWriter aDestinationWriter)
    {
      new Assembler.Assembler(false);
      try
      {
        aDestinationWriter.WriteLine("; Start of " + aFileName);
        Generate(aSourceReader, aDestinationWriter);
        aDestinationWriter.WriteLine("; End of " + aFileName);
        aDestinationWriter.Flush();
      }
      finally
      {
        Assembler.Assembler.ClearCurrentInstance();
      }
    }

    /// <summary>Parse the input X# source code from the given reader and write both target
    /// assembler code and target assembler data in their respective writers.</summary>
    /// <param name="aIn">A reader to acquire X# source code from.</param>
    /// <param name="aOut">A writer that will receive target assembler data.</param>
    public void Generate(TextReader aIn, TextWriter aOut) {
      mPatterns.EmitUserComments = EmitUserComments;
      mLineNo = 1;
      // Read one X# source code line at a time and process it.
      string xLine = aIn.ReadLine();
      while (xLine != null) {
        ProcessLine(xLine, mLineNo);

        xLine = aIn.ReadLine();
        mLineNo++;
      }
      Assembler.Assembler.CurrentInstance.FlushText(aOut);
      AssertLastFunctionComplete();
    }

    /// <summary>Process a single X# source code line and translate it into the target assembler syntax.</summary>
    /// <param name="aLine">The processed X# source code line.</param>
    /// <param name="aLineNo">Line number for debugging and diagnostic messages.</param>
    /// <returns>The resulting target assembler content. The returned object contains a code and a data block.</returns>
    protected void ProcessLine(string aLine, int aLineNo) {
      try {
        aLine = aLine.Trim();
        if (String.IsNullOrEmpty(aLine) == false) {
          // Currently we use a new assembler for every line.
          // If we dont it could create a really large in memory object.
          mPatterns.Assemble(aLine);
          //mPathname, aLineNo
        }
      } catch (Exception e) {
        throw new Exception("Source error. Line " + aLineNo + ", File: " + mPathname, e);
      }
    }
  }
}
