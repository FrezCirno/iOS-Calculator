//
//  ViewController.swift
//  Calculator
//
//  Created by Marcus Gabilheri on 2/19/16.
//  Copyright © 2016 Marcus Gabilheri. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var resultLabel: UILabel!
    
    // 枚举原子类型, 表示状态
    enum State {
        case STA, ZER1, DGT1, FRA1, OPR, ZER2, DGT2, FRA2, RES
    }

    var firstNumberText: String?
    var secondNumberText: String?
    var op: String?
    var finish = true
    var wait = 1
    
    var state = State.START
    var opnd1 = "", opnd2 = ""
    var optr = ""

    enum Operation {
        case Unary((Double)->Double)
        case Binary((Double, Double)->Double)
        func apply(_ arg1: Double?, _ arg2: Double?)->Double{
            switch self {
            case let .Unary(op):
                return op(arg1!)
            case let .Binary(op):
                return op(arg1!, arg2!)
            }
        }
    }
    
    private var knownOps = [
        "+": Operation.Binary(+),
        "-": Operation.Binary() { $1 - $0 },
        "*": Operation.Binary(*),
        "/": Operation.Binary() { $1 / $0 },
        "n": Operation.Unary() { -$0 },
        "p": Operation.Unary() { $0 }
    ]

    private func transform(_ next: String) {
        switch state {
        case .STA: // start "0"
            switch next {
            case "0":
                opnd1 = "0"
                state = .ZER1
            case "1", "2", "3", "4", "5", "6", "7", "8", "9":
                opnd1 = next
                resultLabel.text?.popLast()
                resultLabel.text?.append(next)
                state = .DGT1
            case ".":
                opnd1 = "0."
                resultLabel.text?.append(next) // 0.
                state = .FRA1
            case "+", "-", "*", "/":
                opnd1 = "0"
                optr = next
                resultLabel.text?.append(next) // 0+
                state = .OPR
            default:
                print("Error")
            }
        case .ZER1: // "0"
            switch next {
            case "0":

            case "1", "2", "3", "4", "5", "6", "7", "8", "9":
                opnd1 = next
                resultLabel.text?.popLast()
                resultLabel.text?.append(next)
                state = .DGT1
            case ".":
                opnd1.append(next)
                resultLabel.text?.append(next)
                state = .FRA1
            case "+", "-", "*", "/":
                optr = next
                resultLabel.text?.append(next)
                state = .OPR
            case "=":
                state = .RES
            default:
                print("Error")
            }
        case .DGT1: // "x"
            switch next {
            case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
                resultLabel.text?.append(next)
                state = .DGT1
            case ".":
                opnd1.append(next)
                resultLabel.text?.append(next)
                state = .FRA1
            case "+", "-", "*", "/":
                optr = next
                resultLabel.text?.append(next)
                state = .OPR
            case "=":
                state = .RES
            default:
                print("Error")
            }
        case .FRA1: // xx.
            switch next {
            case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
                opnd1.append(next)
                resultLabel.text?.append(next)
            case ".":
            
            case "+", "-", "*", "/":
                opnd1.append("0")
                optr = next
                resultLabel.text?.append(next)
                state = .OPR
            case "=":
                state = .RES
            default:
                print("Error")
            }

        case .OPR: // "x.x+"
            switch next {
            case "0":
                opnd2 = "0"
                resultLabel.text?.append(next)
                state = .ZER2
            case "1", "2", "3", "4", "5", "6", "7", "8", "9":
                opnd2 = next
                resultLabel.text?.append(next)
                state = .DGT2
            case ".":
                opnd2 = "0."
                resultLabel.text?.append(next) // x.x+.
                state = .FRA2
            case "+", "-", "*", "/":
                optr = next
                resultLabel.text?.popLast()
                resultLabel.text?.append(next) // x.x-
                state = .OPR
            default:
                
            }
        case .ZER2: // "x.x+0"
            switch next {
            case "0":

            case "1", "2", "3", "4", "5", "6", "7", "8", "9":
                opnd2 = next
                resultLabel.text?.popLast()
                resultLabel.text?.append(next)
                state = .DGT2
            case ".":
                opnd2.append(next)
                resultLabel.text?.append(next)
                state = .FRA2
            case "+", "-", "*", "/":
                optr = next
                resultLabel.text?.popLast()
                resultLabel.text?.popLast()
                resultLabel.text?.append(next)
                state = .OPR
            case "=":
                resultLabel.text?.popLast()
                resultLabel.text?.popLast()
                resultLabel.text?.append(next)
                state = .RES
            default:
                print("Error")
            }
        case .DGT2: // "x.x+y"
            switch next {
            case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
                opnd2.append(next)
                resultLabel.text?.append(next)
                state = .DGT2
            case ".":
                opnd2.append(next)
                resultLabel.text?.append(next)
                state = .FRA2
            case "+", "-", "*", "/":
                let res = knownOps[optr]!.apply(Double(opnd1!)!, Double(opnd2!))
                optr = next
                opnd1 = "\(res)"
                resultLabel.text?.removeAll()
                resultLabel.text?.append(opnd1)
                state = .OPR
            case "=":
                let res = knownOps[optr]!.apply(Double(opnd1!)!, Double(opnd2!))
                resultLabel.text?.removeAll()
                resultLabel.text?.append(res)
                state = .RES
            default:
                print("Error")
            }
        case .FRA2: // x.x+y.
            switch next {
            case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
                opnd2.append(next)
                resultLabel.text?.append(next)
            case ".":
            
            case "+", "-", "*", "/":
                opnd2.append("0")
                let res = knownOps[optr]!.apply(Double(opnd1!)!, Double(opnd2!))
                optr = next
                opnd1 = "\(res)"
                resultLabel.text?.removeAll()
                resultLabel.text?.append(opnd1)
                state = .OPR
            case "=":
                opnd2.append("0")
                let res = knownOps[optr]!.apply(Double(opnd1!)!, Double(opnd2!))
                resultLabel.text?.removeAll()
                resultLabel.text?.append(res)
                state = .RES
            default:
                print("Error")
            }
        case .RES:
            switch next {
            case "0":
                opnd1 = "0"
                state = .ZER1
            case "1", "2", "3", "4", "5", "6", "7", "8", "9":
                opnd1 = next
                resultLabel.text?.popLast()
                resultLabel.text?.append(next)
                state = .DGT1
            case ".":
                opnd1 = "0."
                resultLabel.text?.append(next) // 0.
                state = .FRA1
            case "+", "-", "*", "/":
                opnd1 = "0"
                optr = next
                resultLabel.text?.append(next) // 0+
                state = .OPR
            default:
                print("Error")
            }
        default:
            print("Error")
        }
    }
    
    @IBAction func handleButtonPress(_ sender: UIButton) {
        if let token = sender.titleLabel?.text {
            transform(token)
        }
    }
}

