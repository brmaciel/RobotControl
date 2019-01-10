//
//  ConnectViewController.swift
//  My Robot
//
//  Created by Bruno Maciel on 11/30/16.
//  Copyright © 2016 Bruno Maciel. All rights reserved.
//

import UIKit
import CoreBluetooth

var HM10_Module: CBPeripheral!

class ConnectViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    @IBOutlet weak var lbBluetoothStatus: UILabel!
    @IBOutlet weak var lbConnectionStatus: UILabel!
    
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var btnConnect: UIButton!
    @IBOutlet weak var btnDisconnect: UIButton!
    
    @IBOutlet weak var txtMessage: UILabel!
    @IBOutlet weak var lbDevicesFound: UILabel!
    @IBOutlet weak var lbDeviceConnected: UILabel!
    
    var centralManager: CBCentralManager!
    
    var bluetoothState = false
    var devicesFound = false
    var chosenDevice = false
    
    var characteristicDicovered = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        centralManager = CBCentralManager(delegate: self, queue: nil)       //initialize manager
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    /*          Functions related to Buttons         */
    @IBAction func searchDevices(_ sender: AnyObject) {       //to search devices, must click on search button
        if bluetoothState {
            centralManager.scanForPeripherals(withServices: nil, options: nil)    //scan for bluetooth devices
            
            txtMessage.isHidden = false        //show the message of "searching" devices
            txtMessage.text = "Searching..."
        }
    }
    @IBAction func connectToDevice(_ sender: AnyObject) {     //click on connect button to connect
        txtMessage.isHidden = false            //show the message of "connecting" while it is trying to connect
        txtMessage.text = "Connecting..."
        btnSearch.isEnabled = false
        
        chosenDevice = true
        centralManager.scanForPeripherals(withServices: nil, options: nil)    //scan for bluetooth devices
    }
    @IBAction func disconnectDevice(_ sender: AnyObject) {        //click on disconnect button to disconnect
        txtMessage.isHidden = false            //show the message of "disconnecting" while it is trying to disconnect
        txtMessage.text = "Disconnecting..."
        
        //chosenDevice = false
        centralManager.cancelPeripheralConnection(HM10_Module)  //disconnect from connected device
        
    }
    
    
    /*          BLUETOOTH FUNCTIONS         */
    func centralManagerDidUpdateState(_ central: CBCentralManager) {      // check if bluetooth is ON
        switch (central.state) {
        case .poweredOn:
            print("Bluetooth is ON")
            lbBluetoothStatus.text = "ON"
            lbBluetoothStatus.textColor = UIColor.green
            
            bluetoothState = true           //let to search for bluetooth devices, only if bluetooth is ON
            btnSearch.isEnabled = true
        case .poweredOff:
            print("Bluetooth is OFF")
            lbBluetoothStatus.text = "OFF"
            lbBluetoothStatus.textColor = UIColor.red
            lbConnectionStatus.text = "Not Connected"
            lbConnectionStatus.textColor = UIColor.red
            
            bluetoothState = false
            chosenDevice = false
            
            btnSearch.isEnabled = false
            btnConnect.isEnabled = false
            btnDisconnect.isEnabled = false
            lbDevicesFound.text = ""
            lbDeviceConnected.isHidden = true
            
            if HM10_Module != nil {             //if device is already connected and bluetooth is turned OFF, reset stored device
                HM10_Module.delegate = nil
                HM10_Module = nil
            }
        default:
            print("default case")
            bluetoothState = false
        }
    }
    //after finding a device, wait until "Connect" button is clicked, and connect to it
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        //if device was found
        if peripheral.name != nil {
            print("Name: \(peripheral.name!)")
            
            lbDevicesFound.text = peripheral.name
            btnConnect.isEnabled = true
            txtMessage.isHidden = true
            
            //its name is "HMSoft" and the button Connect is clicked -> try to connect to device
            if (peripheral.name! == "HMSoft" && chosenDevice) {
                HM10_Module = peripheral
                centralManager.connect(HM10_Module, options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey : true])
                sleep(1)
            }
        }
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {     //check if device was connected
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        print("Connected to \(peripheral)")
        centralManager.stopScan()
        
        txtMessage.isHidden = false
        txtMessage.text = "Bluetooth Connected Successfully"
        
        lbConnectionStatus.text = "Connected"
        lbConnectionStatus.textColor = UIColor.green
        
        lbDeviceConnected.text = peripheral.name
        lbDeviceConnected.isHidden = false
        
        btnConnect.isEnabled = false
        btnDisconnect.isEnabled = true
    }
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?){//check if failed to connect
        print("connection failed", error)
        
        txtMessage.isHidden = true
        lbConnectionStatus.text = "Fail to Connect"
        lbConnectionStatus.textColor = UIColor.red
        btnSearch.isEnabled = true
    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?){
        print(HM10_Module)
        sleep(1)
        if HM10_Module != nil {
            HM10_Module.delegate = nil
            HM10_Module = nil
        }
        print("Disconnected", error)
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        lbDevicesFound.text = ""
        lbConnectionStatus.text = "Disconnected"
        lbConnectionStatus.textColor = UIColor.red
        
        chosenDevice = false
        txtMessage.isHidden = true
        lbDeviceConnected.isHidden = true
        btnDisconnect.isEnabled = false
        btnSearch.isEnabled = true
    }
    
    /*          SEND AND RECEIVE DATA FUNCTIONS         */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?){
        peripheral.discoverCharacteristics(nil, for: peripheral.services![0])
        //print(peripheral.services!) // [<CBService: 0x13561ff30, isPrimary = YES, UUID = FFE0>]
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?){
        characteristicDicovered = true
        peripheral.setNotifyValue(true, for: service.characteristics![0])
        //print(peripheral.services![0].characteristics!) // [<CBCharacteristic: 0x13557a3b0, UUID = FFE1, properties = 0x16, value = (null), notifying = NO>]
    }
}
