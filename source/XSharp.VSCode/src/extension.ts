'use strict';

import * as vscode from 'vscode';
import { EOL, platform } from 'os'
import * as cp from 'child_process';
import * as fs from 'fs';
import * as path from 'path';
import { Platform, Operator, Operators, Register } from './language';

let currentPlatform: Platform = Platform.x86;
let functions: Map<vscode.Uri, XSharpFunction[]> = new Map<vscode.Uri, XSharpFunction[]>();
let compilerPath: string;

let storagePath: string;

// settings
let compileOnSave: boolean;
let compileOutputPath: string;

// Channel for output
let channel: vscode.OutputChannel;

export function activate(context: vscode.ExtensionContext) {

    channel = vscode.window.createOutputChannel("X# tools");
    channel.show();

    // compilerPath = context.asAbsolutePath("D:/Coding/OS/Cosmos/XSharp/source/XSharp.Compiler/bin/Debug/net471/xsc.exe");
    compilerPath ="D:\\Coding\\OS\\Cosmos\\XSharp\\source\\XSharp.Compiler\\bin\\Debug\\net471\\xsc.exe";

    storagePath = context.storagePath != undefined ? context.storagePath : context.extensionPath;

    compileOnSave = vscode.workspace.getConfiguration("xsharp").get<boolean>("compileOnSave");
    compileOutputPath = vscode.workspace.getConfiguration("xsharp").get<string>("compileOutputPath");

    channel.appendLine("Loading X# extension");
    channel.appendLine(`Compiler Path: ${compilerPath}`)
    channel.appendLine(`Storage path: ${storagePath}`)
    channel.appendLine(`Compile on Save: ${compileOnSave}`)
    channel.appendLine(`Compile output path: ${compileOutputPath}`)

    let languageCompileFile = vscode.commands.registerTextEditorCommand("xsharp.compileFile", function (textEditor) {
        if (vscode.languages.match("xsharp", textEditor.document)) {

            let unsaved: boolean = false;

            if (textEditor.document.isDirty) {
                unsaved = true;
            }

            compileDocument(textEditor.document, unsaved);
        }
    });

    let languageCompileAllFiles = vscode.commands.registerTextEditorCommand("xsharp.compileAllFiles", function (textEditor) {
        let visibleDocumentsUri: vscode.Uri[] = new Array<vscode.Uri>();

        vscode.window.visibleTextEditors.forEach(function (textEditor) {
            if (vscode.languages.match("xsharp", textEditor.document)) {
                visibleDocumentsUri.push(textEditor.document.uri);
                compileDocument(textEditor.document, textEditor.document.isDirty)
            }
        });

        vscode.workspace.findFiles("*.xs").then(function (uri) {
            uri.forEach(u => function () {
                if (visibleDocumentsUri.find(docUri => docUri == u) == undefined) {
                    let textDoc = vscode.workspace.textDocuments.find(doc => doc.uri == u);

                    if (textDoc != undefined) {
                        compileDocument(textDoc);
                    }
                    else {
                        vscode.workspace.openTextDocument(u).then(compileDocument);
                    }
                }
            });
        });
    });

    if (vscode.workspace.rootPath != undefined) {
        vscode.workspace.findFiles("*.xs").then(function (uri) {
            uri.forEach(u => vscode.workspace.openTextDocument(u).then(parseFunctions));
        })
    }
    else {
        vscode.window.visibleTextEditors.forEach(e => parseFunctions(e.document));
    }

    let languageOnActiveTextEditorChanged = vscode.window.onDidChangeActiveTextEditor(function (e) {
        if (vscode.languages.match("xsharp", e.document)) {
            //updateCurrentPlatform(e);
        }
    });

    let languageOnTextSelectionChanged = vscode.window.onDidChangeTextEditorSelection(function (e) {
        if (e.textEditor.document.languageId == "xsharp" &&
            (currentPlatform == undefined ||
                e.selections.find(s => s.intersection(e.textEditor.document.lineAt(0).range) != undefined) != undefined)) {
            //updateCurrentPlatform(e.textEditor);
        }
    });

    let languageOnDocumentOpened = vscode.workspace.onDidOpenTextDocument(function (e) {
        if (vscode.languages.match("xsharp", e)) {
            parseFunctions(e);
        }
    });

    let languageOnDocumentSaved = vscode.workspace.onDidSaveTextDocument(function (e) {
        if (vscode.languages.match("xsharp", e)) {
            parseFunctions(e);

            if (compileOnSave) {
                channel.appendLine("Compiling on save");
                compileDocument(e);
            }
        }
    });

    // Provide the tooktip when hovering.
    let languageHoverProvider = vscode.languages.registerHoverProvider("xsharp", {
        provideHover(document, position, token) {
            let text = document.getText(document.getWordRangeAtPosition(position, /\w+/g));
            let registers = currentPlatform.Registers;

            if (registers.some(r => r.Name == text)) {
                return new vscode.Hover(registers.find(r => r.Name == text).Description);
            } else {
                let regexp = new RegExp(Operators.map(o => escapeRegExp(o.Symbol)).join("|"));
                let operator = document.getText(document.getWordRangeAtPosition(position, regexp));

                if (Operators.some(o => o.Symbol == operator)) {
                    return new vscode.Hover(Operators.find(o => o.Symbol == operator).Description);
                }
            }
        }
    });

    // function to trigger code completion.
    let languageCompletionProvider = vscode.languages.registerCompletionItemProvider("xsharp", {
        provideCompletionItems(document, position, token) {
            let completionList = new vscode.CompletionList();

            currentPlatform.Registers.forEach(r =>
                completionList.items.push(new vscode.CompletionItem(r.Name, vscode.CompletionItemKind.Variable)));

            functions.forEach(u => u.forEach(f =>
                completionList.items.push(new vscode.CompletionItem(f.Name, vscode.CompletionItemKind.Function))))

            return completionList;
        }
    }, "");

    // Function to provide F12 Jump to definition functionality
    let languageSymbolDefinitions = vscode.languages.registerDefinitionProvider("xsharp", {
        provideDefinition(document, position, token) {
            let functionWordRange = document.getWordRangeAtPosition(position, /\w+(?=\(\))/g);

            if (functionWordRange != undefined) {
                let functionName = document.getText(functionWordRange);
                let xsharpFunction: XSharpFunction;

                for (let functionsArray of functions.values()) {
                    xsharpFunction = functionsArray.find(f => f.Name == functionName);

                    if (xsharpFunction != undefined) {
                        return xsharpFunction.Location;
                    }
                }
            }
        }
    });

    // let languageOnTypeFormattingEditProvider = vscode.languages.registerOnTypeFormattingEditProvider("xsharp", {
    //     provideOnTypeFormattingEdits(document, position, token) {
    //         let wordRange = document.getWordRangeAtPosition(position, /\/?\*/g);

    //         if (position.isEqual(wordRange.end)) {
    //             let insertSpaces = vscode.window.activeTextEditor.options.insertSpaces;
    //             let tabSize = <number>vscode.window.activeTextEditor.options.tabSize;
    //             let tab = insertSpaces ? " ".repeat(tabSize) : "\t";
    //             let newLine = EOL;

    //             if (wordRange.start.character > 0) {
    //                 if (insertSpaces) {
    //                     newLine += " ".repeat(wordRange.start.character + 1);
    //                 }
    //                 else {
    //                     // needs testing
    //                     newLine += "\t".repeat((wordRange.start.character + 1) / tabSize) +
    //                         " ".repeat((wordRange.start.character + 1) % tabSize);
    //                 }
    //             }

    //             return [new vscode.TextEdit(new vscode.Range(new vscode.Position(position.line + 1, (newLine + tab).length),
    //                 new vscode.Position(position.line + 1, (newLine + tab).length)), newLine + tab + newLine + "*/")];
    //         }
    //     }
    // }, "*", EOL);

    context.subscriptions.push(languageCompileFile);
    context.subscriptions.push(languageCompileAllFiles);

    context.subscriptions.push(channel);
    
    context.subscriptions.push(languageOnActiveTextEditorChanged);
    context.subscriptions.push(languageOnTextSelectionChanged);
    context.subscriptions.push(languageOnDocumentOpened);
    context.subscriptions.push(languageOnDocumentSaved);
    context.subscriptions.push(languageHoverProvider);
    context.subscriptions.push(languageCompletionProvider);
    context.subscriptions.push(languageSymbolDefinitions);
    //context.subscriptions.push(languageOnTypeFormattingEditProvider);

    channel.appendLine("X# extension load complete.");
}

export function deactivate() {
}

function updateCurrentPlatform(e: vscode.TextEditor) {
    // currently X# only supports x86
    if (e.document.languageId == "xsharp") {
        let firstLine = e.document.lineAt(0).text;

        if (firstLine.startsWith("#define Platform ")) {
            let platform = Platform[firstLine.replace("#define Platform ", "").trim()];

            if (platform != undefined) {
                currentPlatform = platform;
            }
        }
    }
}

function parseFunctions(document: vscode.TextDocument) {
    if (functions.has(document.uri)) {
        functions.get(document.uri).length = 0;
    }
    else {
        functions.set(document.uri, []);
    }

    for (var i = 0; i < document.lineCount; i++) {
        let line = document.lineAt(i);
        let regexp = /function (\w+)/g;
        var result: RegExpExecArray;

        while ((result = regexp.exec(line.text)) !== null) {
            functions.get(document.uri).push(new XSharpFunction(result[1],
                new vscode.Location(document.uri, new vscode.Position(i, result.index + "function ".length))));
            regexp.lastIndex++;
        }
    }
}

function compileDocument(document: vscode.TextDocument, unsaved: boolean = false) {
    let inputPath: string;
    channel.appendLine(`Compiling file: ${document.fileName}`);

    // If the file in unsaved, we make a temporary copy.
    if (unsaved) {
        if (!fs.existsSync(storagePath)) {
            fs.mkdir(storagePath);
        }

        let i: number = 1;

        while (fs.existsSync(inputPath = path.join(storagePath, "temp_" + i + ".xs"))) {
            i++;
        }

        fs.writeFileSync(inputPath, document.getText());
    }
    else {
        inputPath = document.uri.fsPath;
    }

    try {
        var outputFileName = compileOutputPath == "" ? inputPath.replace(".xs", ".asm") : path.join(compileOutputPath, path.basename(inputPath).replace(".xs", ".asm"));
        let compileCommand = compilerPath + " " + inputPath + " -Out:" + outputFileName;
        console.log("Running command: " + compileCommand);

        cp.exec(compileCommand, (error: Error, stdout: string, stderr: string) => {

            if (error != null)
            {
                channel.appendLine(`Compiling file: ${document.fileName}. Error: ${error.message}`);
            }
            if (stdout != null && stdout != "")
            {
                channel.appendLine(`Compiling file: ${document.fileName}. StdOut: ${stdout}`);
            }
            if (stderr != null && stderr != "")
            {
                channel.appendLine(`Compiling file: ${document.fileName}. StdErr: ${stderr}`);
            }

            if (unsaved) {
                fs.unlinkSync(inputPath);
            }
        });
    }
    catch {
        if (unsaved) {
            fs.unlinkSync(inputPath);
        }
    }
}

class XSharpFunction {
    Name: string;
    Location: vscode.Location;

    constructor(name: string, location: vscode.Location) {
        this.Name = name;
        this.Location = location;
    }
}

function escapeRegExp(str: string) {
    return str.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&");
}
