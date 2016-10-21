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
    

    @IBAction func led1On(sender: UIButton) {
        nataliaClient.toggleLED(1, state: "on")
    }
    
    @IBAction func led2On(sender: UIButton) {
         nataliaClient.toggleLED(2, state: "on")
    }
    
    @IBAction func led3On(sender: UIButton) {
         nataliaClient.setPMWValue(3, value: 20)
    }
    
    @IBAction func led4On(sender: UIButton) {
         nataliaClient.toggleLED(4, state: "on")
    }
    
    @IBAction func led5On(sender: UIButton) {
         nataliaClient.toggleLED(5, state: "on")
    }
    
    @IBAction func led1Off(sender: UIButton) {
         nataliaClient.toggleLED(1, state: "off")
    }
    
    @IBAction func led2Off(sender: UIButton) {
        nataliaClient.toggleLED(2, state: "off")
    }
    
    @IBAction func led3Off(sender: UIButton) {
        nataliaClient.setPMWValue(3, value: 0)
    }

    
    @IBAction func led4Off(sender: UIButton) {
        nataliaClient.toggleLED(4, state: "off")
    }
    
    
    @IBAction func led5Off(sender: UIButton) {
        nataliaClient.toggleLED(5, state: "off")
    }
    
    let nataliaClient = NataliaClient(serviceUUID: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
    
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


