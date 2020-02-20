//
//  ViewController.swift
//  SlideLockButton
//
//  Created by Bosco Domingo on 19/02/2020.
//  Copyright © 2020 Bosco Domingo. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SlideLockButtonDelegate {

    
    @IBOutlet weak var slideButton: SlideLockButton!
    
    @IBAction func resetPressed(_ sender: UIButton) {
        slideButton.reset()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        slideButton.delegate = self //setting the delegate
    }
    
    //Delegate method
    func statusUpdated(status: SlideLockButton.Status, sender: SlideLockButton) {
        print(status.rawValue)
    }
}

