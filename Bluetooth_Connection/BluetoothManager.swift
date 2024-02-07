//
//  BluetoothManager.swift
//  Bluetooth Connection
//
//  Created by Harim Choe on 2/7/24.
//

import Foundation
import CoreBluetooth

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    @Published var isBluetoothEnabled = false
    @Published var isConnected = false
    var hm19Peripheral: CBPeripheral?

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
        print("BluetoothManager initialized, central manager created.")
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            case .poweredOn:
                isBluetoothEnabled = true
                print("Bluetooth is powered on. Starting scan for peripherals...")
                centralManager.scanForPeripherals(withServices: nil, options: nil)
            case .poweredOff:
                isBluetoothEnabled = false
                print("Bluetooth is powered off. Please turn on Bluetooth.")
            case .resetting:
                print("Bluetooth is resetting...")
            case .unauthorized:
                print("Bluetooth access is unauthorized.")
            case .unsupported:
                print("Bluetooth is not supported on this device.")
            case .unknown:
                print("Bluetooth state is unknown.")
            @unknown default:
                print("Unknown Bluetooth state encountered.")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let name = peripheral.name {
            print("Discovered peripheral: \(name) with RSSI: \(RSSI)")
        }
        if let name = peripheral.name, name.contains("HM-19") {
            print("HM-19 Bluetooth Module found. Attempting to connect...")
            hm19Peripheral = peripheral
            centralManager.stopScan()
            print("Stopped scanning for peripherals. Trying to connect to \(name)...")
            centralManager.connect(peripheral, options: nil)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        isConnected = true
        print("Successfully connected to peripheral: \(peripheral.name ?? "Unknown")")
        peripheral.delegate = self
        print("Discovering services for peripheral: \(peripheral.name ?? "Unknown")...")
        peripheral.discoverServices(nil) // Specify the UART service UUID here if known
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }
        guard let services = peripheral.services else { return }
        print("Discovered services for \(peripheral.name ?? "Unknown"): \(services)")
        for service in services {
            print("Discovering characteristics for service \(service.uuid)...")
            peripheral.discoverCharacteristics(nil, for: service) // Specify characteristics UUIDs here if known
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Error discovering characteristics: \(error.localizedDescription)")
            return
        }
        guard let characteristics = service.characteristics else { return }
        print("Discovered characteristics for service \(service.uuid): \(characteristics)")
        for characteristic in characteristics {
            print("Characteristic \(characteristic.uuid) properties: \(characteristic.properties)")
        }
    }

    func writeToPeripheral(_ value: String) {
        guard let peripheral = hm19Peripheral else {
            print("HM-19 peripheral is not set.")
            return
        }
        guard let services = peripheral.services, !services.isEmpty else {
            print("No services found on HM-19 peripheral.")
            return
        }
        print("Writing to peripheral \(peripheral.name ?? "Unknown")...")
        for service in services {
            guard let characteristics = service.characteristics else { continue }
            for characteristic in characteristics {
                if characteristic.properties.contains(.write) || characteristic.properties.contains(.writeWithoutResponse) {
                    if let data = value.data(using: .utf8) {
                        print("Writing data to characteristic \(characteristic.uuid)...")
                        peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
                    } else {
                        print("Unable to create data from string: \(value)")
                    }
                }
            }
        }
    }
}
