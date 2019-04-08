//
//  Assembler.swift
//  StulinSAP
//
//  Created by Misha Lvovsky on 4/7/19.
//  Copyright © 2019 Daniel Lacayo. All rights reserved.
//

import Foundation

class Assembler {
    var symbolTable : [String:Int] = [:]
    let commands : [String:(bin: Int, argType: argType)] = [
        "halt":(0, argType.none),
        "movmr":(8, argType.lr),
        "outs":(55, argType.l),
        "printi":(49, argType.r),
        "outcr":(45, argType.r),
        "cmprr":(34, argType.rr),
        "addir":(12, argType.rr),
        "jmpne":(57, argType.l),
        "addrr":(13, argType.rr),
        "movrr":(6, argType.rr),]
    let directives = [
        ".Integer",
        ".String"]
    func assemble(_ assembly:String) throws -> [Int] {
        var result : [Int] = []
        let byLine = assembly.components(separatedBy: "\n").map({$0.components(separatedBy: " ")})
        for lineNum in 0..<byLine.count {
            var thisLine = byLine[lineNum]
            if !commands.keys.contains(thisLine[0]) && !directives.contains(thisLine[0]) {
                let symbol = String(thisLine[0].dropLast())
                guard !symbolTable.keys.contains(symbol) else {
                    throw CompilerError("Symbol \(symbol) already exists.", lineNum)
                }
                addSymbol(symbol, result.count)
                thisLine.remove(at: 0)
            }
            if let command = commands[thisLine[0]] {
                result.append(command.bin)
                do {
                    switch command.argType {
                    case .lr:
                        try result.append(checkLineForL(thisLine, 1, lineNum))
                        try result.append(checkLineForR(thisLine, 2, lineNum))
                        continue
                    case .l:
                        try result.append(checkLineForL(thisLine, 1, lineNum))
                        continue
                    case .r:
                        try result.append(checkLineForR(thisLine, 1, lineNum))
                        continue
                    case .rr:
                        try result.append(checkLineForR(thisLine, 1, lineNum))
                        try result.append(checkLineForR(thisLine, 2, lineNum))
                        continue
                    case .none: continue
                    }
                } catch {
                    throw error
                }
            } else {
                switch thisLine[0] {
                case directives[0]:
                    print("intDirective")
                    if let lInt = Int(thisLine[1].dropFirst()) {
                        print("yeet")
                        result.append(lInt)
                    }
                    continue
                case directives[1]:
                    var string = assembly.components(separatedBy: "\n")[lineNum].components(separatedBy: """
"
""")[1]
                    result.append(string.count)
                    print(string)
                    for char in string.unicodeScalars {
                            result.append(Int(char.value))
                    }
                    continue
                default: continue
                }
            }
        }
        return result
    }
    func checkLineForR(_ line:[String],_ argNum: Int, _ lineNum: Int) throws -> Int {
        guard line.indices.contains(argNum) else {
            throw CompilerError("Command \(line[0]) requires an arg which needs to be of Integer type.", lineNum)
        }
        guard let intArg = Int(String(line[argNum].last!)) else {
            throw CompilerError("Arg \(line[argNum]) is not a register index.", lineNum)
        }
        return intArg
    }
    func checkLineForL(_ line:[String],_ argNum: Int, _ lineNum: Int) throws -> Int {
        guard line.indices.contains(1) else {
            throw CompilerError("Command \(line[0]) requires an arg which needs to be a label.", lineNum)
        }
        guard let symLoc = symbolTable[line[1]] else {
            throw CompilerError("Symbol arg \(line[1]) isn't recognized in symbol table.", lineNum)
        }
        return symLoc
    }
    func addError(_ error: String, _ lineLocation: Int) {
        
    }
    func addSymbol(_ symbol: String, _ symLoc: Int) {
        symbolTable[symbol] = symLoc
    }
    enum argType {
        case lr
        case l
        case r
        case rr
        case none
    }
}

class CompilerError: Error {
    var line:Int
    var message:String
    init(_ message: String, _ line: Int) {
        self.line = line
        self.message = message
    }
    
}
