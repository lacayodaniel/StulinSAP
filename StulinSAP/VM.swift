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
    var state:vmState = .program
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
        registers[getPointAfterNum(1)] = memory[getPointAfterNum(2)]
    }
    func outs() {
        print(getString(getPointAfterNum(1)))
    }
    func printi() {
        print(getPointAfterNum(1))
    }
    func outcr() {
        print(registers[getPointAfterNum(1)])
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
            jump(dest)
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
        let stringEnd = memLoc+memory[memLoc]
        if programCounter-stringEnd > 0 {reachDist = programCounter-stringEnd}
        return memory[memLoc+1...memLoc+memory[memLoc]].reduce("", {$0 + String(UnicodeScalar($1)!)})
    }
    func movrr() {
        registers[getPointAfterNum(2)] = registers[getPointAfterNum(1)]
    }
    func incrementCounter() {
        incrementCounter(reachDist)
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
        while (isRunning) {
            doNext()
        }
    }
    func setRunning() {
        isRunning = true
    }
    func setSleeping() {
        isRunning = false
    }
    enum vmState {
        case program
        case string
    }
}
