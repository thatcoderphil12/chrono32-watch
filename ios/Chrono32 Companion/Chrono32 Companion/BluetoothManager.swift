//
//  BluetoothManager.swift
//  Chrono32 Companion
//
//  Created by Phil Murphy on 11/8/26.
//

import AccessorySetupKit
import Combine
import CoreBluetooth
import Foundation
import UIKit

final class BluetoothManager: NSObject, ObservableObject {

    // MARK: - Configuration

    private let serviceUUID = CBUUID(
        string: "ccd187a1-f3be-464b-8a49-d989e9c104ce"
    )

    // MARK: - AccessorySetupKit

    private let accessorySession = ASAccessorySession()
    private var selectedAccessory: ASAccessory?

    // MARK: - CoreBluetooth

    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral?

    // MARK: - Published State

    @Published var status = "Initializing..."
    @Published var isConnected = false
    @Published var isBluetoothAvailable = false
    @Published var discoveredCharacteristics: [String] = []
    @Published var receivedData = ""
    @Published var hasAuthorizedAccessory = false

    // MARK: - Initialization

    override init() {
        super.init()

        centralManager = CBCentralManager(
            delegate: self,
            queue: .main
        )

        accessorySession.activate(on: .main) { [weak self] event in
            self?.handleAccessoryEvent(event)
        }
    }

    // MARK: - Accessory Events

    private func handleAccessoryEvent(_ event: ASAccessoryEvent) {
        switch event.eventType {
        case .activated:
            status = "Ready"

            if let accessory = accessorySession.accessories.first {
                selectedAccessory = accessory
                hasAuthorizedAccessory = true
                status = "Reconnecting to Chrono32..."
                connect()
            } else {
                hasAuthorizedAccessory = false
                status = "No authorized watch"
            }

        case .accessoryAdded:
            guard let accessory = event.accessory else { return }

            selectedAccessory = accessory
            hasAuthorizedAccessory = true
            status = "Chrono32 authorized"

        case .accessoryChanged:
            if let accessory = event.accessory {
                selectedAccessory = accessory
                status = "Accessory updated"
            }

        case .accessoryRemoved:
            selectedAccessory = nil
            hasAuthorizedAccessory = false
            disconnect()
            status = "Accessory removed"

        case .invalidated:
            status = "Accessory session invalidated"

        default:
            break
        }
    }

    // MARK: - Accessory Setup

    func addAccessory() {
        var descriptor = ASDiscoveryDescriptor()
        descriptor.bluetoothServiceUUID = serviceUUID
        descriptor.bluetoothNameSubstring = "Chrono32"

        guard let image = UIImage(named: "Watch Face") else {
            status = "Missing 'Watch Face' image asset"
            return
        }

        let item = ASPickerDisplayItem(
            name: "Chrono32",
            productImage: image,
            descriptor: descriptor
        )

        accessorySession.showPicker(for: [item]) { [weak self] error in
            if let error {
                self?.status = "Picker error: \(error.localizedDescription)"
            }
        }
    }

    func connectOrAddAccessory() {
        if hasAuthorizedAccessory {
            connect()
        } else {
            addAccessory()
        }
    }

    // MARK: - Connection Management

    func connect() {
        guard let identifier = selectedAccessory?.bluetoothIdentifier else {
            status = "Select an accessory first"
            return
        }

        guard centralManager.state == .poweredOn else {
            status = "Bluetooth is not available"
            return
        }

        status = "Connecting..."

        guard let peripheral = centralManager
            .retrievePeripherals(withIdentifiers: [identifier])
            .first else {
            status = "Accessory not currently available"
            return
        }

        self.peripheral = peripheral
        peripheral.delegate = self
        centralManager.connect(peripheral)
    }

    func disconnect() {
        guard let peripheral else { return }
        centralManager.cancelPeripheralConnection(peripheral)
    }

    // MARK: - Characteristic Lookup

    private func characteristic(withUUID uuid: String) -> CBCharacteristic? {
        let targetUUID = CBUUID(string: uuid)

        return peripheral?.services?
            .flatMap { $0.characteristics ?? [] }
            .first { $0.uuid == targetUUID }
    }

    // MARK: - Write Data

    func write(_ data: Data, to characteristicUUID: String) {
        guard let peripheral else {
            status = "Not connected"
            return
        }

        guard let characteristic = characteristic(withUUID: characteristicUUID) else {
            status = "Characteristic not found"
            return
        }

        let properties = characteristic.properties
        let writeType: CBCharacteristicWriteType

        if properties.contains(.write) {
            writeType = .withResponse
        } else if properties.contains(.writeWithoutResponse) {
            writeType = .withoutResponse
        } else {
            status = "Characteristic is not writable"
            return
        }

        peripheral.writeValue(
            data,
            for: characteristic,
            type: writeType
        )
    }

    // MARK: - Read Data

    func read(characteristicUUID: String) {
        guard let peripheral else {
            status = "Characteristic not found"
            return
        }

        guard let characteristic = characteristic(withUUID: characteristicUUID) else {
            status = "Characteristic not found"
            return
        }

        peripheral.readValue(for: characteristic)
    }
}

// MARK: - CBCentralManagerDelegate

extension BluetoothManager: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            isBluetoothAvailable = true
            status = "Bluetooth ready"

        case .poweredOff:
            isBluetoothAvailable = false
            status = "Bluetooth is turned off"

        case .unauthorized:
            isBluetoothAvailable = false
            status = "Bluetooth access unavailable"

        case .unsupported:
            isBluetoothAvailable = false
            status = "Bluetooth unsupported"

        case .resetting:
            status = "Bluetooth resetting"

        case .unknown:
            status = "Bluetooth state unknown"

        @unknown default:
            status = "Unknown Bluetooth state"
        }
    }

    func centralManager(
        _ central: CBCentralManager,
        didConnect peripheral: CBPeripheral
    ) {
        isConnected = true
        status = "Connected"
        peripheral.discoverServices(nil)
    }

    func centralManager(
        _ central: CBCentralManager,
        didFailToConnect peripheral: CBPeripheral,
        error: Error?
    ) {
        isConnected = false
        status = "Connection failed: " +
            (error?.localizedDescription ?? "Unknown error")
    }

    func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: Error?
    ) {
        isConnected = false
        discoveredCharacteristics = []
        status = error?.localizedDescription ?? "Disconnected"
    }
}

// MARK: - CBPeripheralDelegate

extension BluetoothManager: CBPeripheralDelegate {

    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverServices error: Error?
    ) {
        if let error {
            status = "Service discovery failed: \(error.localizedDescription)"
            return
        }

        guard let services = peripheral.services else { return }

        for service in services {
            print("Service:", service.uuid)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: Error?
    ) {
        if let error {
            status = "Characteristic discovery failed: \(error.localizedDescription)"
            return
        }

        guard let characteristics = service.characteristics else { return }

        for characteristic in characteristics {
            let uuid = characteristic.uuid.uuidString

            if !discoveredCharacteristics.contains(uuid) {
                discoveredCharacteristics.append(uuid)
            }

            print("Characteristic:", uuid)

            let supportsNotifications = characteristic.properties.contains(.notify)
                || characteristic.properties.contains(.indicate)

            if supportsNotifications {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        if let error {
            status = "Read failed: \(error.localizedDescription)"
            return
        }

        guard let data = characteristic.value else { return }

        receivedData = data
            .map { String(format: "%02X", $0) }
            .joined(separator: " ")

        print("Received from \(characteristic.uuid):", receivedData)
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didWriteValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        if let error {
            status = "Write failed: \(error.localizedDescription)"
        } else {
            status = "Data written successfully"
        }
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateNotificationStateFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        if let error {
            print("Notification error:", error.localizedDescription)
        } else {
            print("Notifications enabled:", characteristic.isNotifying)
        }
    }
}
