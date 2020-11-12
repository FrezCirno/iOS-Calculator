//
//  ViewController.swift
//  calc-sb
//
//  Created by frezcirno on 2020/11/11.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var resultLabel: UILabel!
    
    // 枚举原子类型, 表示状态
    enum State {
        case STA, ZER1, DGT1, FRA1, OPR, ZER2, DGT2, FRA2, RES
    }
    
    var state = State.STA
    var opnd1 = "", opnd2 = "", optr = ""

    enum Operation {
        case Unary((Double)->Double)
        case Binary((Double, Double)->Double)
        func apply(_ arg1: Double?, _ arg2: Double? = nil)->Double{
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
        "-": Operation.Binary() { $0 - $1 },
        "*": Operation.Binary(*),
        "/": Operation.Binary() { $0 / $1 },
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
                _ = resultLabel.text?.popLast()
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
            case "C":
                resultLabel.text?.removeAll()
                resultLabel.text?.append("0")
                state = .STA
            case "CE": break
            default:
                print("Error")
            }
        case .ZER1: // "0"
            switch next {
            case "0": break
            case "1", "2", "3", "4", "5", "6", "7", "8", "9":
                opnd1 = next
                _ = resultLabel.text?.popLast()
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
            case "C":
                resultLabel.text?.removeAll()
                resultLabel.text?.append("0")
                state = .STA
            case "CE": break
            default:
                print("Error")
            }
        case .DGT1: // "x+"
            switch next {
            case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
                opnd1.append(next)
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
            case "C":
                resultLabel.text?.removeAll()
                resultLabel.text?.append("0")
                state = .STA
            case "CE":
                if opnd1.count == 1 {
                    _ = opnd1.popLast()
                    _ = resultLabel.text?.popLast()
                    resultLabel.text?.append("0")
                    state = .STA
                } else {
                    _ = opnd1.popLast()
                    _ = resultLabel.text?.popLast()
                }
            default:
                print("Error")
            }
        case .FRA1: // "x."
            switch next {
            case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
                opnd1.append(next)
                resultLabel.text?.append(next)
            case ".": break
            case "+", "-", "*", "/":
                opnd1.append("0")
                optr = next
                resultLabel.text?.append(next)
                state = .OPR
            case "=":
                state = .RES
            case "C":
                resultLabel.text?.removeAll()
                resultLabel.text?.append("0")
                state = .STA
            case "CE":
                _ = resultLabel.text?.popLast()
                state = .DGT1
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
                _ = resultLabel.text?.popLast()
                resultLabel.text?.append(next) // x.x-
                state = .OPR
            case "C":
                resultLabel.text?.removeAll()
                resultLabel.text?.append("0")
                state = .STA
            case "CE":
                _ = resultLabel.text?.popLast()
                if opnd2.contains(".") {
                    state = .FRA1
                } else {
                    state = .DGT1
                }
            default:
                print("Error")
            }
        case .ZER2: // "x.x+0"
            switch next {
            case "0": break
            case "1", "2", "3", "4", "5", "6", "7", "8", "9":
                opnd2 = next
                _ = resultLabel.text?.popLast()
                resultLabel.text?.append(next)
                state = .DGT2
            case ".":
                opnd2.append(next)
                resultLabel.text?.append(next)
                state = .FRA2
            case "+", "-", "*", "/":
                optr = next
                _ = resultLabel.text?.popLast()
                _ = resultLabel.text?.popLast()
                resultLabel.text?.append(next)
                state = .OPR
            case "=":
                _ = resultLabel.text?.popLast()
                _ = resultLabel.text?.popLast()
                resultLabel.text?.append(next)
                state = .RES
            case "C":
                resultLabel.text?.removeAll()
                resultLabel.text?.append("0")
                state = .STA
            case "CE":
                _ = resultLabel.text?.popLast()
                state = .OPR
            default:
                print("Error")
            }
        case .DGT2: // "x.x+yy"
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
                let res = knownOps[optr]!.apply(Double(opnd1)!, Double(opnd2))
                optr = next
                opnd1 = "\(res)"
                resultLabel.text?.removeAll()
                resultLabel.text?.append(opnd1)
                state = .OPR
            case "=":
                let res = knownOps[optr]!.apply(Double(opnd1)!, Double(opnd2))
                resultLabel.text?.removeAll()
                resultLabel.text?.append("\(res)")
                state = .RES
            case "C":
                resultLabel.text?.removeAll()
                resultLabel.text?.append("0")
                state = .STA
            case "CE":
                if opnd2.count == 1 {
                    _ = opnd2.popLast()
                    _ = resultLabel.text?.popLast()
                    state = .OPR
                } else {
                    _ = opnd1.popLast()
                    _ = resultLabel.text?.popLast()
                }
            default:
                print("Error")
            }
        case .FRA2: // x.x+y.(y?)
            switch next {
            case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
                opnd2.append(next)
                resultLabel.text?.append(next)
            case ".": break // ignore it
            case "+", "-", "*", "/":
                opnd2.append("0")
                let res = knownOps[optr]!.apply(Double(opnd1)!, Double(opnd2))
                optr = next
                opnd1 = "\(res)"
                resultLabel.text?.removeAll()
                resultLabel.text?.append(opnd1)
                state = .OPR
            case "=":
                opnd2.append("0")
                let res = knownOps[optr]!.apply(Double(opnd1)!, Double(opnd2))
                resultLabel.text?.removeAll()
                resultLabel.text?.append("\(res)")
                state = .RES
            case "C":
                resultLabel.text?.removeAll()
                resultLabel.text?.append("0")
                state = .STA
            case "CE":
                _ = opnd2.popLast()
                _ = resultLabel.text?.popLast()
                if !opnd2.contains(".") {
                    state = .DGT2
                }
            default:
                print("Error")
            }
        case .RES:
            switch next {
            case "0":
                opnd1 = "0"
                resultLabel.text?.removeAll()
                resultLabel.text?.append(next)
                state = .ZER1
            case "1", "2", "3", "4", "5", "6", "7", "8", "9":
                opnd1 = next
                resultLabel.text?.removeAll()
                resultLabel.text?.append(next)
                state = .DGT1
            case ".":
                opnd1 = "0."
                resultLabel.text?.removeAll()
                resultLabel.text?.append(next) // 0.
                state = .FRA1
            case "+", "-", "*", "/":
                opnd1 = resultLabel.text!
                optr = next
                resultLabel.text?.append(next) // z.z+
                state = .OPR
            case "=": break
            case "C", "CE":
                resultLabel.text?.removeAll()
                resultLabel.text?.append("0")
                state = .STA
            default:
                print("Error")
            }
        }
    }
    
    @IBAction func handleButtonPress(_ sender: UIButton) {
        if let token = sender.titleLabel?.text {
            transform(token)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

