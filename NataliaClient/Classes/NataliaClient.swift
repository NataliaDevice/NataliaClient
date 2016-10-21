//
//  NataliaClient.swift
//  Pods
//
//  Created by Tyler Nappy on 4/24/16.
//
//

import Foundation
import CoreBluetooth

protocol NataliaClientDelegate {
    //    func requestCompletedWithContent(response:String)
    //    func requestCompletedWithJobID(response:String)
    //    func onErrorOccurred(errorMessage:String)
}

public class NataliaClient : NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var delegate: NataliaClientDelegate?
    
    var serviceUUID = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E") // Replace this
//    var peripheralIdOrAddress = CBUUID(string: "a6cc000bf19b4e95b1ffa0aeac2e71d8")
    var txCharacteristicUUID = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
    var rxCharacteristicUUID = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")
    
    private var centralManager:CBCentralManager!
    private var blueToothReady = false
    private var peripheralConnected = false
    private var currentPeripheral:CBPeripheral!
    private var connectedToBLEAndSetModeToOutPut = false
    
    private var uartService:CBService?
    private var rxCharacteristic:CBCharacteristic?
    private var txCharacteristic:CBCharacteristic?
    
    private var portMasks = [UInt8](count: 3, repeatedValue: 0)
    
    private enum PinState:Int{
        case Low = 0
        case High
    }
    
    public enum LedState:Int{
        case Off = 0
        case On
    }
    
    public enum PinMode: UInt8{
        case Unknown = 255
        case Input = 0          // Don't chage the values (these are the bytes defined by firmata spec)
        case Output = 1
        
        case Analog = 2
        case PWM = 3
        case Servo = 4
    }
    
    let ledPins: [UInt8] = [2, 3, 5, 6, 9] //17=A0 18=A1
    
    required public init(serviceUUID:String) {
        self.serviceUUID = CBUUID(string: serviceUUID)
        self.txCharacteristicUUID = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
        self.rxCharacteristicUUID = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")
//        self.peripheralIdOrAddress = CBUUID(string: "a6cc000bf19b4e95b1ffa0aeac2e71d8")
        //        self.txCharacteristic = null
        //        self.rxCharacteristic = null
    }
    
   public func setup() {
        print("Initializing central manager")
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    private func discoverDevices() {
        print("discovering devices")
        centralManager.scanForPeripheralsWithServices([self.serviceUUID], options: nil)
    }
    
    // Bluetooth central manager delegate functions
    public func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        print("Discovered \(peripheral.name)")
        currentPeripheral = peripheral
//        if peripheral.name == "BLE_Firmata" {
            currentPeripheral.delegate = self
            centralManager.stopScan()
            print(currentPeripheral.name)
            print("this worked!")
            centralManager.connectPeripheral(currentPeripheral, options: nil)
//        }
    }
    
    public func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("Connected to peripheral")
        //        peripheral.delegate = self
        peripheral.discoverServices(nil)
        //        peripheral.discoverServices([CBUUID(string: "00001530-1212-EFDE-1523-785FEABCD123"), CBUUID(string: "180A")]) //array of dfuServiceUUID and deviceInformationServiceUUID
        
    }
    
    public func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        let services = peripheral.services as [CBService]!
        for s in services {
            print(s)
            uartService = s
            //            peripheral.discoverCharacteristics([txCharacteristicUUID(), rxCharacteristicUUID()], forService: uartService!)
            peripheral.discoverCharacteristics([self.txCharacteristicUUID], forService: s) // for txCharacteristicUUID and rxCharacteristicUUID
            //            peripheral.discoverCharacteristics(nil, forService: s)
        }
    }
    
    public func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        for c in (service.characteristics as [CBCharacteristic]!) {
//            if (c.UUID == CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")) { // if txCharacteristicUUID
            
                txCharacteristic = c
                print("IF STATEMENT WORKED!")
                print(c)
                //set pin modes to OUTPUT
                for pin in (ledPins as [UInt8]) {
                    print("Setting pin to PWM: ")
                    print(pin)
                    writePinMode(PinMode.PWM, pin:pin, characteristic:c)
                }
                //                for pin in (ledPins as [UInt8]) {
                //                    print("Setting pin to OUTPUT: ")
                //                    print(pin)
                //                    writePinState(PinState.High, pin:pin, characteristic:c)
                //                }
                //                for pin in (ledPins as [UInt8]) {
                //                    print("Setting pin to OUTPUT: ")
                //                    print(pin)
                //                    writePinState(PinState.Low, pin:pin, characteristic:c)
                //                }
                connectedToBLEAndSetModeToOutPut = true
//            }
        }
    }
    
    public func writePinMode(newMode:PinMode, pin:UInt8, characteristic:CBCharacteristic) {
        
        //Set a pin's mode
        
        let data0:UInt8 = 0xf4        //Status byte == 244
        let data1:UInt8 = pin        //Pin#
        let data2:UInt8 = UInt8(newMode.rawValue)    //Mode
        
        let bytes:[UInt8] = [data0, data1, data2]
        let newData:NSData = NSData(bytes: bytes, length: 3)
        print("Setting pin to OUTPUT")
        print(newData)
        currentPeripheral.writeValue(newData, forCharacteristic: characteristic, type: CBCharacteristicWriteType.WithoutResponse)
        
    }
    
//    public func writePinState(newState: PinState, pin:UInt8, characteristic:CBCharacteristic){
    public func toggleLED(led:Int, state: String){
        if connectedToBLEAndSetModeToOutPut {
            var pin = ledPins[led-1]
            var onOrOff = state.lowercaseString
            var newState:PinState
        
            switch onOrOff {
            case "on":
                newState = PinState.High
            case "off":
                newState = PinState.Low
            default:
                newState = PinState.Low
            }
            print(newState)
        
        
            print((self, funcName: (#function), logString: "writing to pin: \(pin)"))
        
            //Set an output pin's state
        
            var data0:UInt8  //Status
            var data1:UInt8  //LSB of bitmask
            var data2:UInt8  //MSB of bitmask
        
            //Status byte == 144 + port#
            let port:UInt8 = pin / 8
            data0 = 0x90 + port
            
            //Data1 == pin0State + 2*pin1State + 4*pin2State + 8*pin3State + 16*pin4State + 32*pin5State
            let pinIndex:UInt8 = pin - (port*8)
            var newMask = UInt8(newState.rawValue * Int(powf(2, Float(pinIndex))))
            
            portMasks[Int(port)] &= ~(1 << pinIndex) //prep the saved mask by zeroing this pin's corresponding bit
            newMask |= portMasks[Int(port)] //merge with saved port state
            portMasks[Int(port)] = newMask
            data1 = newMask<<1; data1 >>= 1  //remove MSB
            data2 = newMask >> 7 //use data1's MSB as data2's LSB
            
            let bytes:[UInt8] = [data0, data1, data2]
            let newData:NSData = NSData(bytes: bytes, length: 3)
            //        delegate!.sendData(newData)
            print("Setting pin")
            print(newData)
            currentPeripheral.writeValue(newData, forCharacteristic: txCharacteristic!, type: CBCharacteristicWriteType.WithResponse)
            
            //        print((self, funcName: "setting pin states -->", logString: "[\(binaryforByte(portMasks[0]))] [\(binaryforByte(portMasks[1]))] [\(binaryforByte(portMasks[2]))]"))
        } else {
            print("Not connected to device and setup pinmode")
        }
        
    }
    
    //
    private var lastSentAnalogValueTime : NSTimeInterval = 0
    public func setPMWValue(led: Int, value: Int) -> Bool {
        if connectedToBLEAndSetModeToOutPut {
            var pin = ledPins[led-1]
            // Limit the amount of messages sent over Uart
            let currentTime = CACurrentMediaTime()
            guard currentTime - lastSentAnalogValueTime >= 0.05 else {
    //            DLog("Won't send: Too many slider messages")
                print("Won't send: Too many slider messages")
                return false
            }
            lastSentAnalogValueTime = currentTime
            
            // Store
    //        pin.analogValue = value
            
            // Send
            let data0 = 0xe0 + UInt8(pin)
            let data1 = UInt8(value & 0x7f)         //only 7 bottom bits
            let data2 = UInt8(value >> 7)           //top bit in second byte
            
            let bytes:[UInt8] = [data0, data1, data2]
            let data = NSData(bytes: bytes, length: bytes.count)
            currentPeripheral.writeValue(data, forCharacteristic: txCharacteristic!, type: CBCharacteristicWriteType.WithResponse)
            
            return true
        } else {
            print("Not connected to device and setup pinmode")
            return false
        }
    }
    //
    
    public func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        print("----------")
        print(characteristic)
        print(error)
    }
    
    
    
    @objc public func centralManagerDidUpdateState(central: CBCentralManager) {
        print("checking state")
        switch (central.state) {
        case .PoweredOff:
            print("CoreBluetooth BLE hardware is powered off")
            
        case .PoweredOn:
            print("CoreBluetooth BLE hardware is powered on and ready")
            blueToothReady = true;
            
        case .Resetting:
            print("CoreBluetooth BLE hardware is resetting")
            
        case .Unauthorized:
            print("CoreBluetooth BLE state is unauthorized")
            
        case .Unknown:
            print("CoreBluetooth BLE state is unknown");
            
        case .Unsupported:
            print("CoreBluetooth BLE hardware is unsupported on this platform");
            
        }
        if blueToothReady {
            discoverDevices()
        }
    }
    
    
}
