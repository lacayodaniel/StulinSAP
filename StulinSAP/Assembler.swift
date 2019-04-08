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
        "movrr":(6, argType.rr)]
    let directives = [
        ".Integer",
        ".String"]
    func assemble(_ assembly:String) throws -> (bin:[Int], lst:String, sym:String) {
        var start:Int? = nil
        var lst:[(lst:String, isLabel:Bool)] = []
        var result : [Int] = []
        let lines = assembly.components(separatedBy: "\n")
        symbolTable = [:]
        for lineNum in 0..<lines.count {
            lst.append(("\(result.count): ", false))
            var thisLine = lines[lineNum].components(separatedBy: ";").first!.components(separatedBy: " ").filter({$0 != ""})
            if thisLine.count > 0 {
                if !commands.keys.contains(thisLine[0]) && !directives.contains(thisLine[0]) {
                    let symbol = String(thisLine[0].dropLast())
                    guard !symbolTable.keys.contains(symbol) else {
                        throw CompilerError("Symbol \(symbol) already exists.", lineNum)
                    }
                    lst[lineNum].isLabel = true
                    addSymbol(symbol, result.count)
                    thisLine.remove(at: 0)
                }
                if !(thisLine.count > 0) {break}
                if let command = commands[thisLine[0]] {
                    if start == nil {start = result.count}
                    result.append(command.bin)
                    do {
                        switch command.argType {
                        case .lr:
                            let l0 = try checkLineForL(thisLine, 1, lineNum)
                            result.append(l0)
                            let r1 = try checkLineForR(thisLine, 2, lineNum)
                            result.append(r1)
                            break
                        case .l:
                            let l0 = try checkLineForL(thisLine, 1, lineNum)
                            result.append(l0)
                            lst[lineNum].lst += "\(l0) "
                            break
                        case .r:
                            let r0 = try checkLineForR(thisLine, 1, lineNum)
                            result.append(r0)
                            lst[lineNum].lst += "\(r0) "
                            break
                        case .rr:
                            let r0 = try checkLineForR(thisLine, 1, lineNum)
                            result.append(r0)
                            lst[lineNum].lst += "\(r0) "
                            let r1 = try checkLineForR(thisLine, 2, lineNum)
                            result.append(r1)
                            lst[lineNum].lst += "\(r1) "
                            break
                        case .none: break
                        }
                    } catch {
                        throw error
                    }
                } else {
                    switch thisLine[0] {
                    case directives[0]:
                        if let lInt = Int(thisLine[1].dropFirst()) {
                            lst[lineNum].lst += "\(lInt) "
                            result.append(lInt)
                        }
                        break
                    case directives[1]:
                        var string = assembly.components(separatedBy: "\n")[lineNum].components(separatedBy: """
"
""")[1]
                        result.append(string.count)
                        for char in string.unicodeScalars {
                            lst[lineNum].lst += "\(char.value ) "
                            result.append(Int(char.value))
                        }
                        break
                    default: break
                    }
                }
            }
            lst[lineNum].lst = fitToLeft(15, lst[lineNum].lst) + "     "
            lst[lineNum].lst += !lst[lineNum].isLabel ? "    " : ""
            lst[lineNum].lst += lines[lineNum].components(separatedBy: " ").filter({$0 != ""}).reduce("", {$0 + "\($1) "})
        }
        result.insert(result.count, at: 0)
        result.insert(start ?? 0, at: 1)
        return (result, lst.reduce("", {$0 + "\($1.lst)\n"}), symbolTable.reduce("", {"\($0) \($1.key): \($1.value)\n"}))
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
    func fitToLeft(_ length: Int, _ str: String) -> String{
        if str.count > length {
            return String(str.dropLast(str.count-length))
        } else if (str.count < length) {
            var result = str
            for _ in str.count..<length {
                result += " "
            }
            return result
        } else {
            return str
        }
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
