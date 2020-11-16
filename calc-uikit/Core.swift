import os
import Foundation

enum Optr: Int, CustomStringConvertible {
    var description: String {
        switch self {
        case .ADD: return "Addition"
        case .SUB: return "Substraction"
        case .MUL: return "Multiplition"
        case .DIV: return "Division"
        case .POS: return "Positive"
        case .NEG: return "Negative"
        case .POW: return "Power"
        case .SQRT: return "Square root"
        case .EQU: return "Evaluation"
        case .LP: return "Open parenthese"
        case .RP: return "Close parenthese"
        case .MOD: return "Modulation"
        }
    }
    
    case EQU, LP, RP, POS, NEG, ADD, SUB, MUL, DIV, POW, MOD, SQRT
}

let order = [  //优先级表
 //    tp\nw "=", "(", ")", "p", "n", "+", "-", "*", "d", "^", "%", "q"
    /* = */ ["=", "<", "x", "<", "<", "<", "<", "<", "<", "<", "<", "<"],
    /* ( */ ["x", "<", "=", "<", "<", "<", "<", "<", "<", "<", "<", "<"],
    /* ) */ [">", "?", ">", "x", "x", ">", ">", ">", ">", ">", ">", "x"],
    /* p */ [">", "<", ">", "<", "<", ">", ">", ">", ">", "<", ">", "<"],
    /* n */ [">", "<", ">", "<", "<", ">", ">", ">", ">", "<", ">", "<"],
    /* + */ [">", "<", ">", "<", "<", ">", ">", "<", "<", "<", "<", "<"],
    /* - */ [">", "<", ">", "<", "<", ">", ">", "<", "<", "<", "<", "<"],
    /* * */ [">", "<", ">", "<", "<", ">", ">", ">", ">", "<", ">", "<"],
    /*div*/ [">", "<", ">", "<", "<", ">", ">", ">", ">", "<", ">", "<"],
    /* ^ */ [">", "<", ">", "<", "<", ">", ">", ">", ">", ">", ">", "<"],
    /* % */ [">", "<", ">", "<", "<", ">", ">", ">", ">", "<", ">", "<"],
    /*sqr*/ [">", "<", ">", "<", "<", ">", ">", ">", ">", ">", ">", "<"]
]

let logger = Logger()

func do_calc(_ op: Optr, _ op1: Double, _ op2: Double) throws -> Double {
    switch op {
    case .POS: return op1
    case .NEG: return -op1
    case .ADD: return op1 + op2
    case .SUB: return op1 - op2
    case .MUL: return op1 * op2
    case .POW: return pow(op1, op2)
    case .DIV:
        if op2 == 0 {
            throw CalcError.ArithmeticError(detail: "Divide by 0")
        }
        return op1 / op2
    case .MOD:
        if op2 == 0 {
            throw CalcError.ArithmeticError(detail: "Mod 0")
        }
        return op1.truncatingRemainder(dividingBy: op2)
    case .SQRT:
        if op1 < 0 {
            throw CalcError.ArithmeticError(detail: "Sqrt x < 0")
        }
        return sqrt(op1)
    default: throw CalcError.ArithmeticError(detail: "Unknown operation")
    }
}


func dispatch(_ op: Character, _ lastObj: Optr?) throws -> Optr
{
    switch op {
    case "+":
        switch lastObj {
        case .EQU, .LP, .POS, .NEG, .SQRT, .ADD, .SUB, .MUL, .DIV, .MOD, .POW: return .POS
        default: return .ADD
        }
    case "-":
        switch lastObj {
        case .EQU, .LP, .POS, .NEG, .SQRT, .ADD, .SUB, .MUL, .DIV, .MOD, .POW: return .NEG
        default: return .SUB
        }
    case "*":
        guard lastObj == nil else {
            throw CalcError.SyntaxError(detail: "Expect a number")
        }
        return .MUL
    case "÷":
        guard lastObj == nil else {
            throw CalcError.SyntaxError(detail: "Expect a number")
        }
        return .DIV
    case "^":
        guard lastObj == nil else {
            throw CalcError.SyntaxError(detail: "Expect a number")
        }
        return .POW
    case "%":
        guard lastObj == nil else {
            throw CalcError.SyntaxError(detail: "Expect a number")
        }
        return .MOD
    case "=":
        guard lastObj == nil else {
            throw CalcError.SyntaxError(detail: "Expect a number")
        }
        return .EQU
    case "(":
        if lastObj == .RP {
            throw CalcError.SyntaxError(detail: ") followed by (")
        }
        return .LP
    case ")":
        if lastObj == .LP {
            throw CalcError.SyntaxError(detail: "Empty ()")
        }
        return .RP
    case "√": return .SQRT
    default: throw CalcError.InputError(detail: "Unknown operator")
    }
}


func eval(_ expr: String) throws -> Double {
    var s = expr
    var opnd: [Double] = []
    var optr = [Optr.EQU]
    var lastObj: Optr? = Optr.EQU
    var ptr = s.startIndex
    
    if s.last != "=" {
        s.append("=")
    }

    while !optr.isEmpty {
        let ch = s[ptr]
        logger.log("\(ch)")
        while ch.isWhitespace { ptr = s.index(after: ptr) }
        if ch.isNumber {  //数字
            let subs = String(s[ptr...])
            let scanner = Scanner(string: subs)
            opnd.append(scanner.scanDouble()!)
            logger.log("- Got a number: \(opnd.last!)")
            ptr = s.index(ptr, offsetBy: subs.distance(from: subs.startIndex, to: scanner.currentIndex))
            lastObj = nil
        } else {  //操作符
            let newOp = try dispatch(ch, lastObj)
            logger.log("- Got an operator: \(newOp)")
            switch order[optr.last!.rawValue][newOp.rawValue] {
            case "<":
                logger.log("- - Push")
                optr.append(newOp)
                ptr = s.index(after: ptr)
                lastObj = newOp
            case "=": //退栈
                logger.log("- - Pop")
                _ = optr.popLast()
                ptr = s.index(after: ptr)
                lastObj = nil // 括号规约成数字
            case ">":
                let op = optr.popLast()!
                logger.log("- - Last is: \(op)")
                if op == .POS || op == .NEG || op == .SQRT {
                    let opnd1 = opnd.popLast()!
                    logger.log("- - - Pop number: \(opnd1)")
                    opnd.append(try do_calc(op, opnd1, 0))
                    logger.log("- - - Result is: \(opnd.last!)")
                } else {
                    let opnd2 = opnd.popLast()!
                    logger.log("- - - Pop number2: \(opnd2)")
                    let opnd1 = opnd.popLast()!
                    logger.log("- - - Pop number1: \(opnd1)")
                    opnd.append(try do_calc(op, opnd1, opnd2))
                    logger.log("- - - Result is: \(opnd.last!)")
                }
            default: throw CalcError.SyntaxError(detail: "invalid expression")
            }
        }
    }
    return opnd.last!
}

enum CalcError: Error {
    case ArithmeticError(detail: String)
    case SyntaxError(detail: String)
    case InputError(detail: String)
}
