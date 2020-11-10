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
    
    var firstNumberText: String?
    var secondNumberText: String?
    var op: String?
    var finish = true
    var wait = 1
    
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
        "-": Operation.Binary(){ $1 - $0 },
        "*": Operation.Binary(*),
        "/": Operation.Binary(){ $1 / $0 },
        "n": Operation.Unary(){ -$0 },
        "p": Operation.Unary(){ $0 }
    ]
    
    func reset() {
        op = nil
        firstNumberText = nil
        secondNumberText = nil
        finish = true
        wait = 1
    }
    
    class State {
        var display: String = "";
        
        func transform(_ next: String) -> State {
            display += next
            return self
        }
    }
    
    
    @IBAction func handleButtonPress(_ sender: UIButton) {
        if let token = sender.titleLabel?.text {
            var state = State()
            state.transform("H").transform("e")
            if finish {
                resultLabel.text?.removeAll()
                finish = false
            }
            switch token {
            case "CE":
                _ = resultLabel.text?.popLast()
            case "C":
                resultLabel.text?.removeAll()
                reset()
            case "+", "*", "/", "-":
                if op != nil {
                    _ = resultLabel.text?.popLast()
                    return
                } else {
                    op = token
                }
                resultLabel.text?.append(token)
                wait = 2
                break
            case "=":
                guard (op != nil), (firstNumberText != nil), (secondNumberText != nil) else {
                    return
                }
                let result = knownOps[op!]!.apply(Double(firstNumberText!)!, Double(secondNumberText!))
                resultLabel.text = "\(result)"
                reset()
                break
            default: // 0123456789.
                if wait == 1 {
                    if firstNumberText == nil {
                        firstNumberText = token
                    } else {
                        firstNumberText?.append(token)
                    }
                } else if wait == 2 {
                    if secondNumberText == nil {
                        secondNumberText = token
                    } else {
                        secondNumberText?.append(token)
                    }
                }
                resultLabel.text?.append(token)
                break;
            }
        }
    }
}

