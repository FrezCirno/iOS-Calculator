//
//  ViewController.swift
//  calc-sb
//
//  Created by frezcirno on 2020/11/11.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var resultLabel: UILabel!

    @IBAction func handleButtonPress(_ sender: UIButton) {
        if let input = sender.titleLabel?.text {
            if input == "=" {
                eval(resultLabel.text!)
            } else if input == "C" {
                resultLabel.text?.removeAll()
            } else if input == "CE" {
                _ = resultLabel.text?.popLast()
            } else {
                resultLabel.text?.append(input)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

