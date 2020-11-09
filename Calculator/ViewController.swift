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
    
    var firstNumberText = ""
    var secondNumberText = ""
    var op = ""
    var isFirstNumber = true
    var hasOp = false
    var canClear = true
    
    enum Operation {
        case Unary(String, (Double)->Double)
        case Binary(String, (Double, Double)->Double)
    }
    
    private var knownOps = [
        "+":Operation.Binary("+", +),
        "-":Operation.Binary("−"){ $1 - $0 },
        "*":Operation.Binary("*", *),
        "/":Operation.Binary("/"){ $1 / $0 }
    ]
    
    @IBAction func handleButtonPress(_ sender: UIButton) {
        if canClear {
            resultLabel.text = ""
            canClear = false
        }
        let t = resultLabel.text!
        if let text = sender.titleLabel?.text {
            switch text {
            case "+", "*", "/", "-":
                if hasOp {
                    return
                }
                op = text
                isFirstNumber = false
                hasOp = true
                resultLabel.text = "\(t)\(op)"
                break
            case "=":
                isFirstNumber = true
                hasOp = false
                canClear = true
                let result = calculate()
                resultLabel.text = "\(result)"
                break
            case "CE":
                _ = resultLabel.text?.popLast()
            case "C":
                resultLabel.text = nil
            default:
                if isFirstNumber {
                    firstNumberText = "\(firstNumberText)\(text)"
                } else {
                    secondNumberText = "\(secondNumberText)\(text)"
                }
                resultLabel.text = "\(t)\(text)"
                break;
            }
        }
    }
    
    func calculate<T:NSNumber>(_ firstNumber:T, _ secondNumber:T, op: (T,T)->T) -> T {
        return op(firstNumber, secondNumber)
    }
    
    
    func add<T:NSNumber>(_ n1:T,_ n2:T) -> T { return n1+n2 }
    func sub<T:NSNumber>(_ n1:T,_ n2:T) -> T { return n1-n2 }
    func mul<T:NSNumber>(_ n1:T,_ n2:T) -> T { return n1*n2 }
    func div<T:NSNumber>(_ n1:T,_ n2:T) -> T { return n1/n2 }
    
    
    
}

