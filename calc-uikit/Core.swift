

enum Optr {
    case EQU, LP, RP, POS, NEG, ADD, SUB, MUL, DIV, POW, MOD
}

let order = [  //优先级表
    /*tp\nw '=', '(', ')', 'p', 'n', '+', '-', '*', 'd', '^', '%' */
    /* = */ ['=', '<', 'x', '<', '<', '<', '<', '<', '<', '<', '<'],
    /* ( */ ['x', '<', '=', '<', '<', '<', '<', '<', '<', '<', '<'],
    /* ) */ ['>', '?', '>', 'x', 'x', '>', '>', '>', '>', '>', '>'],
    /* p */ ['>', '<', '>', '<', '<', '>', '>', '>', '>', '>', '>'],
    /* n */ ['>', '<', '>', '<', '<', '>', '>', '>', '>', '>', '>'],
    /* + */ ['>', '<', '>', '<', '<', '>', '>', '<', '<', '<', '<'],
    /* - */ ['>', '<', '>', '<', '<', '>', '>', '<', '<', '<', '<'],
    /* * */ ['>', '<', '>', '<', '<', '>', '>', '>', '>', '<', '>'],
    /*div*/ ['>', '<', '>', '<', '<', '>', '>', '>', '>', '<', '>'],
    /* ^ */ ['>', '<', '>', '<', '<', '>', '>', '>', '>', '>', '>'],
    /* % */[ '>', '<', '>', '<', '<', '>', '>', '>', '>', '<', '>']
]

func do_calc(_ op: Optr, _ op1: Double, _ op2: Double) -> double {
    switch op {
        case .POS: return op1
        case .NEG: return -op1
        case .ADD: return op1 + op2
        case .SUB: return op1 - op2
        case .MUL: return op1 * op2
        case .POW: return pow(op1, op2)
        case .DIV:
            if (op2 == 0) {
                cerr << "错误：除数为0" << endl
                exit(-1)
            }
            return op1 / op2
        case .MOD:
            if (op2 == 0) {
                cerr << "错误：除数为0" << endl
                exit(-1)
            }
            return fmod(op1, op2)
    }
    return 0
}


func dispatch(_ op: Character, _ lastObj: Optr) -> Optr
{
    switch op {
        case '+': return ((lastObj == -1 || lastObj == .RP) ? .ADD : .POS)
        case '-': return ((lastObj == -1 || lastObj == .RP) ? .SUB : .NEG)
        case '*': return .MUL
        case '/': return .DIV
        case '^': return .POW
        case '%': return .MOD
        case '=':
        case '\0': return .EQU
        case '(':
            if (lastObj == .RP) {
                cerr << "错误：两对括号间缺少运算符" << endl
                exit(-1)
            }
            return .LP
        case ')':
            if (lastObj == .LP) {
                cerr << "错误：括号内没有内容" << endl
                exit(-1)
            }
            return .RP
        default: cerr << "错误：未知的运算符" << endl exit(-1)
    }
}


func eval(_ s: String) -> Double
{
    let opnd = [Double]
    let optr = [Optr]
    var lastObj = Optr.EQU
    optr.append(.EQU)
    while !optr.empty() {
        while isblank(*s) { s++ }
        if isdigit(*s) {  //数字
            var x: Double
            var len: Int
            sscanf(s, "%lf%n", &x, &len)
            opnd.append(x)
            s += len
            lastObj = -1
        } else {  //操作符
            var newOp = dispatch(*s, lastObj)
            switch order[optr.top()][newOp] {
                case '<':
                    optr.append(newOp); s++
                    lastObj = newOp
                case '=': //退栈
                    optr.popLast(); s++
                    lastObj = newOp
                case '>': {
                    var op = optr.popLast()
                    if case let (op == .POS || op == .NEG) {
                        double opnd1 = opnd.popLast()
                        opnd.append(do_calc(op, opnd1, 0))
                    } else {
                        double opnd2 = opnd.popLast()
                        double opnd1 = opnd.popLast()
                        opnd.append(do_calc(op, opnd1, opnd2))
                    }
                }
                default: cerr << "请检查表达式是否有误" << endl; exit(-1)
            }
        }
    }
    return opnd.top()
}
