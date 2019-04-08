//
//  VM.swift
//  StulinSAP
//
//  Created by Misha Lvovsky on 4/7/19.
//  Copyright © 2019 Daniel Lacayo. All rights reserved.
//

import Foundation

class VM {
    var isRunning = false
    var programCounter = 0
    var registers:[Int] = Array(repeating: 0, count: 10)
    var memory:[Int] = []
    var reachDist = 0
    var compReg = 0//0: less than; 1: greater than; 2: equals
    func runCommand(_ command:Int) {
        switch command {
        case 0: haltVM()
        case 8: movmr()
        case 55: outs()
        case 49: printi()
        case 45: outcr()
        case 34: cmprr()
        case 12: addir()
        case 57: jmpne()
        case 13: addrr()
        case 6: movrr()
        default: break
        }
    }
    func doNext() {
        runCommand(memory[programCounter])
        incrementCounter()
    }
    func movmr() {
        registers[getPointAfterNum(2)] = memory[getPointAfterNum(1)]
    }
    func outs() {
        print(getString(getPointAfterNum(1)), terminator: "")
    }
    func printi() {
        print(registers[getPointAfterNum(1)], terminator: "")
    }
    func outcr() {
        print(String(UnicodeScalar(registers[getPointAfterNum(1)])!), terminator: "")
    }
    func cmprr() {
        let reg0 = registers[getPointAfterNum(1)]
        let reg1 = registers[getPointAfterNum(2)]
        if  reg0 > reg1 {
            compReg = 1
        } else if reg0 == reg1 {
            compReg = 2
        } else {
            compReg = 0
        }
    }
    func addir() {
        registers[getPointAfterNum(2)] += getPointAfterNum(1)
    }
    func jmpne() {
        let dest = getPointAfterNum(1)
        if compReg != 2 {
            jump(dest-1)
        }
    }
    func jump(_ destination: Int) {
        programCounter = destination
        reachDist = 0
    }
    func addrr() {
        registers[getPointAfterNum(2)] += registers[getPointAfterNum(1)]
    }
    func getString(_ memLoc: Int) -> String {
        return memory[memLoc+1...memLoc+memory[memLoc]].reduce("", {$0 + String(UnicodeScalar($1)!)})
    }
    func movrr() {
        registers[getPointAfterNum(2)] = registers[getPointAfterNum(1)]
    }
    func incrementCounter() {
        incrementCounter(reachDist + 1)
    }
    func incrementCounter(_ num:Int) {
        programCounter += num
        reachDist = 0
    }
    func getPointAfterNum(_ num:Int) -> Int {
        if reachDist < num {reachDist = num}
        return memory[programCounter + num]
    }
    func haltVM() {
        setSleeping()
    }
    func runVM() {
        let iPC = memory[1]
        programCounter = iPC
        memory.remove(at: 1)
        let iL = memory[0]
        memory.remove(at: 0)
        while (isRunning) {
            doNext()
        }
        memory.insert(iPC, at: 0)
        memory.insert(iL, at: 0)
    }
    func setRunning() {
        isRunning = true
    }
    func setSleeping() {
        isRunning = false
    }
}
