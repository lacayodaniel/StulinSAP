//
//  SAP.swift
//  StulinSAP
//
//  Created by Misha Lvovsky on 4/7/19.
//  Copyright © 2019 Daniel Lacayo. All rights reserved.
//

import Foundation

class SAP {
    let vm = VM()
    let ass = Assembler()
    var running = true
    var input:[String] = [""]
    var filePath:URL? = nil
    let help = """
SAP Help:
    asm <program name> - assemble the specified program
    run <program name> - run the specified program
    path <path specification> - set the path for the SAP program directory inclide final / but not name of file. SAP file must habe an extension of .txt
    printlst <program name> - print listening file for the specified program
    printbin <program name> - print the binary file for the specfied program
    printsym <program name> - print symbol table for the specified program
    quit   - terminate SAP program
    help   - print help table
"""
    func runUI() {
        print("Welcome to SAP!\n\n\(help)")
        while(running == true) {
            print("Enter option...", terminator: "")
            input = readLine()?.components(separatedBy: " ") ?? [""]
            switch input[0] {
            case "asm": asm()
                continue
            case "run": run()
                continue
            case "path": path()
                continue
            case "printlst": printlst()
                continue
            case "printbin": printbin()
                continue
            case "printsym": printsym()
                continue
            case "quit": running = false
                continue
            case "help": print(help)
                continue
            default: print("Unidentified command.")
                continue
            }
        }
    }
    func asm() {
        guard input.count == 2 else {
            print("Asm takes 1 argument: asm <program name>")
            return
        }
        guard filePath != nil else {
            print("Need to set URL first")
            return
        }
        
    }
    func run() {
        guard input.count == 2 else {
            print("Run takes 1 argument: run <program name>")
            return
        }
        guard filePath != nil else {
            print("Need to set URL first")
            return
        }
        var fileContents = [""]
        do {
            print(URL(fileURLWithPath: input[1], isDirectory: false, relativeTo: filePath).absoluteString)
            try fileContents = FileManager.default.contentsOfDirectory(atPath: URL(fileURLWithPath: input[1], isDirectory: false, relativeTo: filePath).absoluteString ?? "")
        } catch {
            print("Invalid filename")
            return
        }
        print(fileContents)
    }
    func path() {
        guard input.count == 2 else {
            print("Path takes 1 argument: path <path specification>")
            return
        }
        let newFilePath = URL(fileURLWithPath: input[1])
        do {
            guard try newFilePath.checkPromisedItemIsReachable() else {
                print("Invalid paath \(input[1])")
                return
            }
        } catch {
            print("Invalid path \(input[1])")
            return
        }
        filePath = newFilePath
    }
    func printlst() {
        
    }
    func printbin() {
        
    }
    func printsym() {
        
    }
}
