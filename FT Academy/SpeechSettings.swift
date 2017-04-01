//
//  SpeechSettings.swift
//  FT中文网
//
//  Created by Oliver Zhang on 2017/4/1.
//  Copyright © 2017年 Financial Times Ltd. All rights reserved.
//

import Foundation
import UIKit
class SpeechSettings: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBAction func closeSetting(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    let pickerData = ["英国","美国","澳大利亚","印度","新加坡","加拿大"]
    
    override func loadView() {
        super.loadView()
        if self.popoverPresentationController?.adaptivePresentationStyle == .popover {
            print ("this is popover")
        } else {
            print ("this is not a popover")
        }
        
        myPicker.dataSource = self
        myPicker.delegate = self
        //self.popoverPresentationController?.delegate = self
    }
    
    @IBOutlet weak var myPicker: UIPickerView!

    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print (pickerData[row])
    }
    

}
