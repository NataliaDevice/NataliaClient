//
//  ViewController.swift
//  NataliaClient
//
//  Created by Tyler Nappy on 04/24/2016.
//  Copyright (c) 2016 Tyler Nappy. All rights reserved.
//

import UIKit
import NataliaClient

class ViewController: UIViewController {
    
    let nataliaClient = NataliaClient(serviceUUID: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
//    let nataliaClient = NataliaClient(serviceUUID: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
    //    nataliaClient.delegate = self
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        nataliaClient.setup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


