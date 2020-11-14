//
//  ViewController.swift
//  calc-sb
//
//  Created by frezcirno on 2020/11/11.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var resultLabel: UILabel!
    
    var clear = false
        
    @IBAction func handleButtonPress(_ sender: UIButton) {
        if let input = sender.titleLabel?.text {
            if input == "=" {
                clear = true
                do {
                    let result = try eval(resultLabel.text!)
                    resultLabel.text = String(result)
                } catch let CalcError.ArithmeticError(reason) {
                    resultLabel.text = "Error: "+reason
                } catch let CalcError.SyntaxError(reason) {
                    resultLabel.text = "Error: "+reason
                } catch let CalcError.InputError(reason) {
                    resultLabel.text = "Error: "+reason
                } catch _ {
                    resultLabel.text = "Error"
                }
            } else if input == "C" {
                resultLabel.text?.removeAll()
                resultLabel.text?.append("0")
            } else if input == "CE" {
                _ = resultLabel.text?.popLast()
                if resultLabel.text?.isEmpty == true {
                    resultLabel.text?.append("0")
                }
            } else {
                if clear {
                    clear = false
                    resultLabel.text = "0"
                }
                if resultLabel.text == "0" {
                    resultLabel.text?.removeAll()
                }
                resultLabel.text?.append(input)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

