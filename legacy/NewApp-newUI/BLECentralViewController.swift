//
//  BLEViewController.swift
//  NewApp-newUI
//
//  Created by Hua Chen on 2015-03-12.
//  Copyright (c) 2015 Hua Chen. All rights reserved.
//

import UIKit
import CoreBluetooth

class BLECentralViewController: UIViewController, CBCentralManagerDelegate,
CBPeripheralDelegate, ENSideMenuDelegate {
    
    // MARK: BLE Setups

    let service_UUID = CBUUID(string: "E20A39F4-73F5-4BC4-A12F-17D1AD07A961")
    let characteristic_UUID = CBUUID(string: "08590F7E-DB05-467E-8757-72F6FAEB13D4")
    var centralManager: CBCentralManager!
    var discoveredPeripheral: CBPeripheral!
    var data: NSMutableData!
    var imageData: NSData!
    var base64String: String!
    
    // MARK: IBOutlets
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    // Gestures
    var screenEdgeRecognizer: UIScreenEdgePanGestureRecognizer!
    
    // MARK: ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sideMenuController()?.sideMenu?.delegate = self
        
        screenEdgeRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: "slideout:")
        screenEdgeRecognizer.edges = .Left
        view.addGestureRecognizer(screenEdgeRecognizer)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        centralManager = CBCentralManager(delegate: self, queue: nil)
        data = NSMutableData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.centralManager.stopScan()
        print("Scanning stopped")
        super.viewWillDisappear(animated)
    }
    
    // MARK: Toggle Side Menu
    func slideout(sender: UIScreenEdgePanGestureRecognizer) {
        if sender.state == .Ended {
            toggleSideMenuView()
        }
    }
    
    // MARK: Central Methods
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch central.state {
        case .Unsupported:
            print("BLE is unsupported")
        case .Unauthorized:
            print("BLE is unauthorized")
        case .Unknown:
            print("BLE is unknown")
        case .Resetting:
            print("BLE is resetting")
        case .PoweredOff:
            print("BLE is powered off")
        case .PoweredOn:
            print("BLE is powered on")
            print("BLE is scanning")
            self.scan()
        default:
            print("BLE default")
        }
    }
    
    func scan() {
        self.centralManager.scanForPeripheralsWithServices([service_UUID],
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        print("Scanning started @ \(service_UUID)")
    }
    
    func centralManager(central: CBCentralManager,
        didDiscoverPeripheral peripheral: CBPeripheral,
        advertisementData: [String : AnyObject], RSSI: NSNumber) {
            
            if RSSI.integerValue > -15 {
                return
            }
            
            if RSSI.integerValue < -35 {
                return
            }
            print("Discovered \(peripheral.name) at \(RSSI)")
            
            if self.discoveredPeripheral !=  peripheral {
                self.discoveredPeripheral = peripheral
                
                print("Connecting to peripheral \(peripheral)")
                self.centralManager.connectPeripheral(peripheral, options: nil)
            }
    }
    
    func centralManager(central: CBCentralManager,
        didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
            print("Fiailed to connect to \(peripheral). \(error)")
            cleanup()
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("Peripheral Connected")
        
        centralManager.stopScan()
        print("Scanning stopped")
        
        self.data.length = 0
        
        peripheral.delegate = self
        
        peripheral.discoverServices([service_UUID])
    }
    
    func centralManager(central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
            print("Peripheral disconnected")
            self.discoveredPeripheral = nil
            
            self.scan()
    }
    // MARK: Peripheral Methods
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if error != nil {
            print("Error discovering services: \(error)")
            cleanup()
        }
        
        for service in peripheral.services! {
            peripheral.discoverCharacteristics([characteristic_UUID], forService: service as CBService)
            print("Service found \(service)")
        }
    }
    
    func peripheral(peripheral: CBPeripheral,
        didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
            if error != nil {
                print("Error discovering characteristics: \(error)")
                cleanup()
            }
            
            for characteristic in service.characteristics! {
                if characteristic.UUID == characteristic_UUID {
                    peripheral.setNotifyValue(true,
                        forCharacteristic: characteristic as CBCharacteristic)
                }
            }
            // Once this is complete, we just need to wait for the data to come in
    }
    
    func peripheral(peripheral: CBPeripheral,
        didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
            if error != nil {
                print("Error discovering characteristics: \(error)")
            }
            let stringFromData = NSString(data: characteristic.value!, encoding: NSUTF8StringEncoding)
            
            if stringFromData == "EOM" as NSString {
                //textView.text = String(self.data)
                textView.text = NSString(data: self.data, encoding: NSUTF8StringEncoding) as! String

                peripheral.setNotifyValue(false, forCharacteristic: characteristic)
                
                centralManager.cancelPeripheralConnection(peripheral)
            }
            print("Char Value: \(characteristic.value)")
            self.data.appendData(characteristic.value!)
    }
    
    func peripheral(peripheral: CBPeripheral,
        didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
            if error != nil {
                print("Error changing notification state: \(error)")
            }
            
            if characteristic.UUID != characteristic_UUID {
                return
            }
            
            if characteristic.isNotifying {
                print("Notification began on \(characteristic)")
            } else {
                print("Notification stopped on \(characteristic). Disconnecting")
                centralManager.cancelPeripheralConnection(peripheral)
            }
    }
    
    // MARK: Helper Methods
    func cleanup() {
        if self.discoveredPeripheral.state != .Connected {
            return
        }
        
        if self.discoveredPeripheral.services != nil {
            for service in self.discoveredPeripheral.services! {
                if service.characteristics != nil {
                    for characteristic in service.characteristics! {
                        if characteristic.UUID == service_UUID {
                            if characteristic.isNotifying {
                                self.discoveredPeripheral.setNotifyValue(false, forCharacteristic: characteristic as CBCharacteristic)
                                print("--------Cleanup Done!")
                                return
                            }
                        }
                    }
                }
            }
        }
        self.centralManager.cancelPeripheralConnection(self.discoveredPeripheral)
    }
}
