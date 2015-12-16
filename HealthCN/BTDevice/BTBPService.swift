//
// 藍牙 BLE Service
//

import UIKit
import CoreBluetooth
import Foundation

/**
* 藍芽血壓計
*
* 藍牙4.0 BLE BluetoothLeService
* <P>
* 廠商: Yuwell, 型號:??<BR>
* GATT Main service : D618D000-6000-1000-8000-000000000000
* D_DEVNAME = "Yuwell BloodPressure"
*
* 藍芽電池官方 Service: 0x1810,  cahrt: 0x2A35
*/

class BTBPService: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private let IS_DEBUG = false
    
    // 固定參數設定, 主 Service chanel, Character,
    private let D_BTDEVNAME0 = "Yuwell BloodPressure"
    
    // UUID, 血壓數值主 Service, Char
    private let UID_SERV: CBUUID = CBUUID(string: "D618D000-6000-1000-8000-000000000000")
    private let UID_CHAR_W: CBUUID = CBUUID(string: "D618D001-6000-1000-8000-000000000000")
    private let UID_CHAR_I: CBUUID = CBUUID(string: "D618D002-6000-1000-8000-000000000000")
    
    // BLE 設備，Center service 設定
    private var activeTimer:NSTimer!
    private var centralManager:CBCentralManager!
    private var connectingPeripheral: CBPeripheral!
    
    // 藍芽設備狀態
    private var BT_POWERON = false
    private var BT_ISREADYFOTESTING = false
    
    // 主要的 Chanel 與 Characteristic
    private var mBTService: CBService!
    private var mBTCharact_W: CBCharacteristic!
    private var mBTCharact_I: CBCharacteristic!
    
    // parenrt class, BTScaleMain
    private var pubClass: PubClass!
    private var mBTBPMain: BTBPMain!
    
    /**
    * 設定 vcParent 為上層的 BTScaleMain
    */
    func setParentVC(parentClass: BTBPMain) {
        mBTBPMain = parentClass
        pubClass = PubClass(viewControl: mBTBPMain)
    }
    
    /**
     * BT CentralManager, Start
     */
    func startUpCentralManager() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    /**
     * BT CentralManager, discover BLE Service channel
     */
    func discoverDevices() {
        centralManager.scanForPeripheralsWithServices(nil, options: nil)
    }
    
    /**
     * Delegate, CBCentralManagerDelegate
     * 開始探索 BLE 周邊裝置
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
     * 指定的藍芽設備找到後，開始執行設備連結
     * 可以在此設定 Peripheral Delegate
     */
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        self.connectingPeripheral.delegate = self
        
        // 尋找指定的 Service UID
        //self.connectingPeripheral.discoverServices([UID_SERV])
        
        // 搜尋全部的 Service
        self.connectingPeripheral.discoverServices(nil)
        
        mBTBPMain.notifyBTStat("BT_MSG_foundandtestconn")
        
        if (IS_DEBUG) {
            print("BT: Device found!\n")
        }
    }
    
    /**
     * Delegate, CBCentralManagerDelegate
     * BLE 斷線
     */
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        BT_ISREADYFOTESTING = false
        mBTBPMain.notifyBTStat("BT_MSG_noconn")
        pubClass.popIsee(Msg: pubClass.getLang("BT_MSG_noconn"))
    }
    
    /**
     * Delegate, CBCentralManagerDelegate
     * 目前 BLE center manage statu
     */
    func centralManagerDidUpdateState(central: CBCentralManager) {
        var msg = ""
        switch (central.state) {
        case .PoweredOff:
            msg = "BT: powered Off"
            print(msg)
            BT_POWERON = false
            BT_ISREADYFOTESTING = false
            mBTBPMain.notifyBTStat("BT_MSG_noconn")
            
        case .PoweredOn:
            msg = "BT: powered On"
            BT_POWERON = true;
            
        case .Resetting:
            msg = "BT: Resetting"
            
        case .Unauthorized:
            msg = "BT: Unauthorized"
            
        case .Unknown:
            msg = "BT: Unknown stat"
            
        case .Unsupported:
            msg = "BT: BLE Unsupported"
            
        }
        
        if (IS_DEBUG) {
            print(msg)
        }
        
        if BT_POWERON {
            discoverDevices()
        }
    }
    
    /**
     * 查詢藍芽設備的 Service channel
     * Service 查詢到後，可以在查詢該 Service 下的 'Characteristics'
     */
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?)
    {
        // 指定的 Service channel 查詢 character code
        
        // loop Service UUID, 設定指定 UUID 的 channel
        for tmpCBService in peripheral.services! {
            if (IS_DEBUG) {
                print("Serv UID: \(tmpCBService.UUID)")  // 顯示 'Blood Pressure'
                print("Serv UID: \(tmpCBService.UUID.UUIDString)\n") // 顯示 '1810'
            }
            
            if (tmpCBService.UUID == UID_SERV) {
                self.mBTService = tmpCBService
                
                if (IS_DEBUG) {
                    print("Main Serv UID: \(self.mBTService.UUID)\n")
                }
            }
            
            // 指定的 Service, 查詢全部的 Chart
            peripheral.discoverCharacteristics(nil, forService: tmpCBService)
        }
        
        // 指定的 Service, 查詢指定的 Chart UUID 執行測試連接
        //peripheral.discoverCharacteristics([UID_CHAR_W], forService: self.mBTService)
    }
    
    /**
     * 查詢指定 Service channel 的 charccter code
     */
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        
        // 指定的 service channel,loop charact UUID 設定 Test/Write charact
        for mChart in service.characteristics! {
            if (IS_DEBUG) {
                print("Char UID: \(mChart.UUID)\n")
            }
            
            // 設定 'Indenify' Chart
            if (mChart.UUID == UID_CHAR_I) {
                self.mBTCharact_I = mChart
                
                // 直接執行關閉或打開通知(Notify)的UUID, 若狀態改變會執行
                // NotificationStateForCharacteristic statu 更新
                peripheral.setNotifyValue(true, forCharacteristic: mChart)
                
                /*
                if (IS_DEBUG) {
                    print("SetNotify_Chart_UID:\(self.mBTCharact_W.UUID)")
                    print("Chart_IsNotify: \(self.mBTCharact_W.isNotifying)\n")
                }
                */
            }
            
            // 設定 '寫入' Chart
            else if (mChart.UUID == UID_CHAR_W) {
                self.mBTCharact_W = mChart
            }
        }
        
        /*
        if (IS_DEBUG) {
            peripheral.discoverDescriptorsForCharacteristic(self.mBTCharact_W)
        }
        */
    }
    
    /**
     * NotificationStateForCharacteristic statu 更新
     */
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        if (IS_DEBUG) {
            print("Notfy Recv, UID: \(characteristic.UUID)")
            print("Val: \(characteristic.value)")
            print("Notify: \(characteristic.isNotifying)\n")
        }
        
        // 測量值主 service 的 notify chart
        if (characteristic.isNotifying == true && characteristic.UUID == UID_CHAR_I) {
            mBTBPMain.notifyBTStat("BT_MSG_readyfortesting")
            BT_ISREADYFOTESTING = true
            
            return
        }
    }
    
    /**
     * 目前未用，主要是各 service, chart 的'描述說明'
     * Discover characteristics 的 DiscoverDescriptors
     */
    func peripheral(peripheral: CBPeripheral, didDiscoverDescriptorsForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        if (IS_DEBUG) {
            print("Despt of Chart : \(characteristic.UUID)")
            
            if (characteristic.descriptors?.count > 0) {
                for tmpDispt in characteristic.descriptors! {
                    print("Despt: \(tmpDispt.UUID)")
                    print("Despt: \(tmpDispt.value)\n")
                }
            }
        }
        
        // TODO
        let mDisp: CBDescriptor = characteristic.descriptors![0]

        if (IS_DEBUG) {
            print("BTDEF_NOTIFY: \(mDisp)")
        }
    }
    
    /**
     * BT 有資料更新，傳送到本機 BT 顯示
     *
     * 主 Service 數值回傳：血壓計回傳如下：
     *  
     *  0  1   2   3   4   5   6   7   8   9   10  11   12  13  14  15  16 17 18 19
     * ----------------------------------------------------------------------------
     *            YY  MM  DD  HH  mm  ss      Val      Val  Ht
     * [0, 5, 12, 15, 08, 20, 21, 46, 18, 00, 125, 00, 077, 88, 255, 0, 0, 0, 0, 0]
     */
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        // 接收到血壓計 回傳數值
        if (characteristic.value?.length > 0 && characteristic.UUID == UID_CHAR_I) {
            if (IS_DEBUG) {
                print("Update MainSrv val : \(characteristic.value!)\n")
            }
            
            // 取得回傳資料，格式如: HEX: 01 00 23 A0 02 ..., [Byte] = [UInt8]
            let mNSData = characteristic.value!
            var mIntVal = [UInt8](count:mNSData.length, repeatedValue:0)
            mNSData.getBytes(&mIntVal, length:mNSData.length)
            
            if (IS_DEBUG) {
                print(mIntVal)
            }
         
            // 通知上層 class 'BTScaleMain' 執行頁面更新
            dispatch_async(dispatch_get_main_queue(), {
                self.mBTBPMain.reloadPage(self.getTestingResult(mIntVal))
            })
            
            return
        }
    }
    
    /**
    * 將血壓計傳回的 bit array 轉為可閱讀的 Dictionary<String, String>
    * 規格參考 'didUpdateValueForCharacteristic'
    */
    private func getTestingResult(aryRS: Array<UInt8>)-> Dictionary<String, String> {
        var dictRS: Dictionary<String, String> = [:]
        dictRS["val_H"] = String(aryRS[10])
        dictRS["val_L"] = String(aryRS[12])
        dictRS["beat"] = String(aryRS[13])
        
        return dictRS
    }
    
    /**
     * BT 執行連接程序
     */
    func BTConnStart() {
        if (BT_ISREADYFOTESTING != true) {
            startUpCentralManager()
        }
    }
    
    /**
     * BT 斷開連接
     */
    func BTDisconn() {
        if (BT_ISREADYFOTESTING != true) {
            activeTimer = nil
            connectingPeripheral = nil
            mBTCharact_W = nil
            mBTCharact_I = nil
            mBTService = nil
            
            return
        }
        
        if activeTimer != nil {
            activeTimer.invalidate()
            activeTimer = nil
        }
        
        centralManager.cancelPeripheralConnection(connectingPeripheral)
        connectingPeripheral = nil
        mBTCharact_W = nil
        mBTCharact_I = nil
        mBTService = nil
        
        if (IS_DEBUG) {
            print("BT disconnect...")
        }
    }
    
    /**
     * !! NO USE !!
     * 寫入(傳送)資料至 remote BT
     */
    func BTWriteData() {
        var aryData: Array<UInt8> = [0x14];
        let mNSData = NSData(bytes: &aryData, length: (aryData.count))
        print(mNSData)
        
        // 寫入資料傳送至 remote BT
        self.connectingPeripheral.writeValue(mNSData, forCharacteristic: self.mBTCharact_W, type: CBCharacteristicWriteType.WithoutResponse)
        
        return
    }
    
}