//
// 藍牙 BLE 必填標準參數 (iOS不用處理)
// 關閉或打開通知(Notify)的UUID, 藍牙規格固定值
// NOTIFY = "00002902-0000-1000-8000-00805f9b34fb" (Descriptor)
//

import UIKit
import CoreBluetooth
import Foundation

/**
 * 藍牙4.0 BLE BluetoothLeService
 * <P>
 * 廠商: ACCUWAY, 型號:BT908<BR>
 * GATT service : f433bd80-75b8-11e2-97d9-0002a5d5c51b
 * D_DEVNAME = "VScale"
 * <P>
 * Characteristics定義<BR>
 * Name: Calculate Result, 輸入數值計算結果<BR>
 * 計算體脂肪, 水分, water, muscle, bone, etc. Assigned Number:
 * 29f11080-75b9-11e2-8bf6-0002a5d5c51b Properties: writeWithResponse
 *
 * Name: Test Result Description: Read or notify the test result Assigned
 * Number: 1a2ea400-75b9-11e2-be05-0002a5d5c51b Properties: Read/Nofity
 * <P>
 *
 * 傳入BT資料, 身高,年齡,性別(M=0, F=1),如下:<BR>
 * 10 01 00 1E AF => 數據類型(固定)10, 用户：01, 性别：00, 年龄：2D(45), 身高：AD(173)
 * <P>
 *
 * 傳回數據如下：(最後一碼為'操作类型',不使用),<BR>
 * 01H 0XH 模式 + 第幾個 user XXH(性别） XXH(年龄） XXH（身高） XXH XXH(重量值，两个字节）+
 * 脂肪（两个字节）+水分（两个字节）+骨骼（两个字节）+肌肉（两个字节）+ 内脏脂肪（一个字节）+卡路里（两个字节）+BMI（两个字节）。一共20个字节。
 * <P>
 * 未傳送資料，回傳如:<BR>
 * HEX: 00 00 00 00 02 AE FF FF FF FF FF FF FF FF FF FF FF FF FF 00<BR>
 * 傳入BT資料, 性別,年齡,身高，回傳如:<BR>
 * HEX: 01 00 23 A0 02 AE 00 E5 02 14 00 1F 01 29 0A 06 27 01 0B 00
 *
 * 判別何時傳給 BT 資料, 由接收的 BT 資料第一個 位元資料<BR>
 * '00' 表示需要傳給 BT 資料，'01'表示BT接收到傳入資料，經計算後再回傳全部的結果
 *
 * <p>
 * 本 class 回傳數值為 'Strings'
 */
class BTScaleService: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    // UID, 固定參數設定
    private let IS_DEBUG = false
    private let D_BTDEVNAME0 = "VScale"
    let aryTestingField: Array<String> = ["weight", "bmi", "fat", "water", "calory", "bone", "muscle", "vfat"]
    
    private let UID_SERV: CBUUID = CBUUID(string: "f433bd80-75b8-11e2-97d9-0002a5d5c51b")
    private let UID_CHAR_T: CBUUID = CBUUID(string: "1a2ea400-75b9-11e2-be05-0002a5d5c51b")
    private let UID_CHAR_W: CBUUID = CBUUID(string: "29f11080-75b9-11e2-8bf6-0002a5d5c51b")
    private let UID_NOTIFY: CBUUID = CBUUID(string: "00002902-0000-1000-8000-00805f9b34fb")
    
    private var activeTimer:NSTimer!
    private var centralManager:CBCentralManager!
    private var blueToothReady = false
    private var connectingPeripheral: CBPeripheral!
    
    private var mBTService: CBService!
    private var mBTCharact_T: CBCharacteristic!
    private var mBTCharact_W: CBCharacteristic!
    
    
    // parenrt class, BTScaleMain
    private var pubClass: PubClass!
    private var mBTScaleMain: BTScaleMain!
    private var dictUserData: Dictionary<String, String> = [:] // 身高/年齡/性別
    
    /**
     * 設定 vcParent 為上層的 BTScaleMain
     */
    func setParentVC(parentClass: BTScaleMain) {
        mBTScaleMain = parentClass
        dictUserData = mBTScaleMain.dictUserData
        pubClass = PubClass(viewControl: mBTScaleMain)
    }
    
    /**
    * BT CentralManager, Start
    */
    func startUpCentralManager() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    /**
     * BT CentralManager, discover
     */
    func discoverDevices() {
        centralManager.scanForPeripheralsWithServices(nil, options: nil)
    }
    
    /**
     * start Discover BT peripheral(周邊裝置)
     * On detecting a device, will get a call back to "didDiscoverPeripheral"
     */
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
    
        if (IS_DEBUG) {
            print("Discovered: \(peripheral.name)")
        }
        
        // TODO 需要設定搜尋時間
        
        // 找到指定裝置 名稱 or addr
        if (peripheral.name == D_BTDEVNAME0) {
            self.connectingPeripheral = peripheral
            self.centralManager.stopScan()
            self.centralManager.connectPeripheral(peripheral, options: nil)
        }
        
        //NSTimer(timeInterval: 2.0, target: self, selector: selector(scanTimeout:), userInfo: nil, repeats: false)
    }
    
    /**
     * 找到指定的BT, 開始查詢與連接 BT Service channel
     */
    func centralManager(central: CBCentralManager,didConnectPeripheral peripheral: CBPeripheral) {
        
        peripheral.delegate = self
        peripheral.discoverServices([UID_SERV])
        
        if (IS_DEBUG) {
            print("Connected BT device")
        }
    }
    
    /**
     * 目前 BLE center manage statu
     */
    func centralManagerDidUpdateState(central: CBCentralManager) {
        var msg = ""
        switch (central.state) {
        case .PoweredOff:
            msg = "CoreBluetooth BLE hardware is powered off"
            
        case .PoweredOn:
            msg = "CoreBluetooth BLE hardware is powered on and ready"
            blueToothReady = true;
            
        case .Resetting:
            msg = "CoreBluetooth BLE hardware is resetting"
            
        case .Unauthorized:
            msg = "CoreBluetooth BLE state is unauthorized"
            
        case .Unknown:
            msg = "CoreBluetooth BLE state is unknown"
            
        case .Unsupported:
            msg = "CoreBluetooth BLE hardware is unsupported on this platform"
            
        }
        
        if (IS_DEBUG) {
            print(msg)
        }
        
        if blueToothReady {
            discoverDevices()
        }
    }
    
    /**
     * 查詢 BT Service channel 指定的 charccter code
     */
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?)
    {
        // 指定的 Service channel 查詢 character code
        self.mBTService = peripheral.services![0]    
        
        // Discover 指定的 charact 執行測試連接
        if (IS_DEBUG) {
            print("Service: \(self.mBTService.UUID)")
        }
        
        peripheral.discoverCharacteristics([UID_CHAR_T], forService: self.mBTService)
    }
    
    /**
     * 查詢指定 Service channel 的 charccter code
     */
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        
        if (IS_DEBUG) {
            for mChart in service.characteristics! {
                print(mChart.UUID)
            }
        }
        
        // 指定的 service channel,loop charact UUID 設定 Test/Write charact
        self.mBTCharact_T = service.characteristics![0]
        
        if (IS_DEBUG) {
            print("Characteristic: \(self.mBTCharact_T)")
        }
        
        // 直接執行關閉或打開通知(Notify)的UUID, 藍牙規格固定值
        peripheral.setNotifyValue(true, forCharacteristic: self.mBTCharact_T)
        
        //peripheral.readValueForCharacteristic(self.actBTCharact)
        //peripheral.discoverDescriptorsForCharacteristic(self.actBTCharact)
        
        if (IS_DEBUG) {
            print("SetNotify: \(self.mBTCharact_T)")
        }
    }
    
    /**
     * NotificationStateForCharacteristic 更新
     */
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        if (IS_DEBUG) {
            print("didUpdata Notify: \(characteristic)")
        }
        
        connectingPeripheral.writeValue( NSData(bytes: [0x01] as [UInt8], length: 1), forCharacteristic: self.mBTCharact_T, type: CBCharacteristicWriteType.WithResponse)
    }
    
    /**
     * Discover characteristics 的 DiscoverDescriptors
     * 主要執行 BT 的 關閉或打開通知(Notify)
     */
    func peripheral(peripheral: CBPeripheral, didDiscoverDescriptorsForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        if (IS_DEBUG) {
            print("Descriptor: \(characteristic.descriptors)")
        }
        
        let mDisp: CBDescriptor = characteristic.descriptors![0]
        mDisp.setValue(1, forKey: "value")
        mDisp.setValue(UID_NOTIFY, forKey: "UUID")
        
        if (IS_DEBUG) {
            print("disp0: \(mDisp)")
        }
        
        //let mNSData = NSData()
        let mNSData = NSData(bytes: [0x01] as [UInt8], length: 1)
        peripheral.writeValue(mNSData, forDescriptor: mDisp)
        
        peripheral.readValueForCharacteristic(self.mBTCharact_T)
        
        /*
        var parameter = NSInteger(1)
        let mNSData = NSData(bytes: &parameter, length: 1)
        peripheral.writeValue(mNSData, forDescriptor: mDisp)
        */
    }
    
    /**
     * BT 有資料更新，傳送到本機 BT 顯示
     * 若回傳第0個位元 = 0x00 (0), 表示 Scale 有測到體重資料，
     * 需要回傳 USER 資料(年齡/身高/性別)計算
     * 傳送格式如: 
     * 0x10 0x01 0x00 0x1E 0xAF =>
     *    數據類型(固定)10, 用户：01, 性别：00, 年龄：2D(45), 身高：AD(173)
     * byte[] byteVal = { 0x10, 0x01, gender, age, height };
     * byte[] byteVal = { 0x10, 0x01, 0x00, 0x2D, 0xAD };
     */
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        if (characteristic.value?.length > 0) {
            //print("from BT value: \(characteristic.value!)")
            
            // 取得回傳資料，格式如: HEX: 01 00 23 A0 02 ..., [Byte] = [UInt8]
            let mNSData = characteristic.value!
            var mIntVal = [UInt8](count:mNSData.length, repeatedValue:0)
            mNSData.getBytes(&mIntVal, length:mNSData.length)
            
            if (IS_DEBUG) {
                print(mIntVal)
            }
            
            // Scale 傳來的資料，第一個位元若為 0x00, 表示本機 BT 需要傳送 user 資料
            if (mIntVal[0] == 0) {
                //let mNSData = NSData(bytes: [UInt8]("A".utf8), length: 1)
                //let aryData: Array<UInt8> = [10, 1, 0, 45, 173]
                
                var aryData: Array<UInt8> = [10];
                let intGender = (dictUserData["gender"] == "M") ? 1 : 0
                aryData.append(UInt8(intGender))
                aryData.append(UInt8(dictUserData["age"]!)!)
                aryData.append(UInt8(dictUserData["height"]!)!)
                
                let mNSData = NSData(bytes: aryData, length: aryData.count * sizeof(UInt8))
                
                // 寫入資料傳送至 remote BT
                connectingPeripheral.writeValue(mNSData, forCharacteristic: self.mBTCharact_W, type: CBCharacteristicWriteType.WithoutResponse)
                
                return
            }
            
            // 傳送 user 資料給 體重計計算後，體重計回傳結果, 通知上層 class 'BTScaleMain' 執行頁面更新
            if (mIntVal[0] == 1) {
                mBTScaleMain.reloadPage(self.getScaleResult(mIntVal))
                
                return
            }
        }
    }
    
    /**
    * 解析體重計回傳數值, 欄位定義如下
    * ["weight", "bmi", "fat", "water", "calory", "bone", "muscle", "vfat"]
    * 傳入BT資料, 身高,年齡,性別，回傳如:<BR>
    * HEX: 01 00 23 A0 02 AE 00 E5 02 14 00 1F 01 29 0A 06 27 01 0B 00<BR>
    * -----00-01-02-03-04-05-06-07-08-09-10-11-12-13-14-15-16-17-18-19<BR>
    * --------ge-ag-hi-weigh--fat--water--bone-muscl-vf-calor--bmi--XX
    *
    * @return Dict data, ex. 'weight'='69.1', 'bmi'='23.0', ...
    */
    private func getScaleResult(aryRS: Array<UInt8>)-> Dictionary<String, String> {
        // 預設數值
        var dictRS: Dictionary<String, String> = [:]
        dictRS["weight"] = "0.0"
        dictRS["fat"] = "0.0"
        dictRS["water"] = "0.0"
        dictRS["bone"] = "0.0"
        dictRS["muscle"] = "0.0"
        dictRS["vfat"] = "0"
        dictRS["calory"] = "0"
        dictRS["bmi"] = "0.0"
        
        // 檢查回傳的資料是否太離譜, 以 'vfat'內臟脂肪判別 >= 100, <=1
        if aryRS[14] >= 255 {
            return dictRS
        }
        
        // 重新設定各健康數值
        dictRS["weight"] = tranHEX10(valHigh: aryRS[4], valLow: aryRS[5])
        dictRS["fat"] = tranHEX10(valHigh: aryRS[6], valLow: aryRS[7])
        dictRS["water"] = tranHEX10(valHigh: aryRS[8], valLow: aryRS[9])
        dictRS["bone"] = tranHEX10(valHigh: aryRS[10], valLow: aryRS[11])
        dictRS["muscle"] = tranHEX10(valHigh: aryRS[12], valLow: aryRS[13])
        dictRS["vfat"] = String(aryRS[14])
        dictRS["calory"] = String(aryRS[15] * 255) + String(aryRS[16])
        dictRS["bmi"] = tranHEX10(valHigh: aryRS[17], valLow: aryRS[18])
        
        return dictRS
    }
    
    /**
     * 放大10倍資料轉換, weigh, fat, water, bone, muscle, bmi
     * HEX 數值為 02 AE, 實際的 val :'02AE' = 686, 已放大10倍<BR>
     * 需要 /10, 取小數點，本method直接用字元方式處理
     * <P>
     *
     * @param data0 : 高位 HEX 已轉成 int
     * @param data1 : 低位 HEX 已轉成 int
     * @return string
     */
    private func tranHEX10(valHigh data0: UInt8, valLow data1: UInt8)-> String {
        let strVal = String(data0 * 255 + data1)
        let numChar = strVal.characters.count
        let strFloatVal = pubClass.subStr(strVal, strFrom: (numChar - 1), strEnd: numChar)
        
        // 字元數目 <= 1, 表示為小數點數值
        if (numChar <= 1) {
            return "0." + strFloatVal
        }
        
        // 取得整數位數值
        let strDigInt = pubClass.subStr(strVal, strFrom: 0, strEnd: (numChar - 1))
        return strDigInt + "." + strFloatVal
    }
    
    /**
    * BT 執行連接程序
    */
    func BTConnStart() {
        startUpCentralManager()
    }
    
    /**
     * BT 斷開連接
     */
    func BTDisconn() {
        if activeTimer != nil {
            activeTimer.invalidate()
            activeTimer = nil
        }
        
        centralManager.cancelPeripheralConnection(connectingPeripheral)
        connectingPeripheral = nil
        mBTCharact_T = nil
        mBTService = nil
     
        if (IS_DEBUG) {
            print("BT disconnect...")
        }
    }
    
    /**
    * 寫入(傳送)資料至 remote BT
    */
    func BTWriteData() {
        let mNSData = NSData(bytes: [UInt8]("A".utf8), length: 1)
        connectingPeripheral.writeValue(mNSData, forCharacteristic: self.mBTCharact_T, type: CBCharacteristicWriteType.WithoutResponse)
    }
    
}