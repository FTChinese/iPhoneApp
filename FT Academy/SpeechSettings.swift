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
    let englishAccent = [
        "英国":"en-GB",
        "美国":"en-US",
        "澳大利亚":"en-AU",
        "南非":"en-ZA",
        "爱尔兰":"en-IE"
    ]
    var englishAccentData = [String]()
    let chineseAccent = [
        "中国大陆":"zh-CN",
        "香港":"zh-HK",
        "台湾":"zh-TW"
    ]
    var chineseAccentData = [String]()
    
    override func loadView() {
        super.loadView()
        if self.popoverPresentationController?.adaptivePresentationStyle == .popover {
            print ("this is popover")
        } else {
            print ("this is not a popover")
        }
        englishAccentData = Array(englishAccent.keys)
        myPicker.dataSource = self
        myPicker.delegate = self
        chineseAccentData = Array(chineseAccent.keys)
        chineseAccentPick.dataSource = self
        chineseAccentPick.delegate = self
        //self.popoverPresentationController?.delegate = self
    }
    
    @IBOutlet weak var myPicker: UIPickerView!

    
    @IBOutlet weak var chineseAccentPick: UIPickerView!
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {        
        if pickerView.restorationIdentifier == "English Accent Picker" {
        return englishAccentData.count
        } else {
            return chineseAccentData.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.restorationIdentifier == "English Accent Picker" {
        return englishAccentData[row]
        } else {
            return chineseAccentData[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var language = "en"
        var accent = "en-GB"
        if pickerView.restorationIdentifier == "English Accent Picker" {
            language = "en"
            accent = englishAccent[englishAccentData[row]] ?? "en-GB"
        } else {
            language = "ch"
            accent = chineseAccent[chineseAccentData[row]] ?? "zh-CN"
        }
        changeAccent(language, accent: accent)
    }
    
    func changeAccent (_ language: String, accent: String) {
        // TODO: - Update Parent View's Accent and Save
        print("change \(language) into \(accent)")
    }
    

}
