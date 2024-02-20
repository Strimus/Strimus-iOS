//
//  File.swift
//  
//
//  Created by Sukru Kahraman on 7.02.2024.
//

import SocketIO
import Foundation

protocol SBSSocketManagerDelegate: AnyObject {
    func handleSocket(model: SBSSocketResponse)
}

public enum SocketIOEventType: String {
    case createRoom
    case join
    case message
    case leave
    case roomInfo
}

public class SBSSocketManager {
    
    private var manager: SocketManager!
    static let shared = SBSSocketManager()
    lazy var socket = manager.defaultSocket
    
    weak var delegate: SBSSocketManagerDelegate?
    
    let socketQeue = DispatchQueue.init(label: "socket-io-qeue-strimus", qos: .utility)
    
    var lastRoomID: String?
    var roomId: String?
    private init() {
        let serviceURL = "wss://straas-api.themachinarium.xyz/"
        manager = SocketManager(socketURL: URL(string: serviceURL)!, config: [.log(true), .compress])
        setConfigs()

        manager.handleQueue = socketQeue
        
        socket.on(clientEvent: .error, callback: { data, ack in
            guard let response = data as? [[String: Any]], let element = response.first else { return }
            guard let errorMessage = element["msg"] as? String else { return }
            print(errorMessage)
        })
        
        socket.on(clientEvent: .connect) { [weak self] data, ack in
            print("socket connected")
        }
        
        socket.on(clientEvent: .reconnectAttempt) { [weak self] data, ack in
            self?.setConfigs()
        }
        
        
        socket.on(clientEvent: .statusChange) { [weak self] data, ack in
            
        }
        
        socket.onAny { [weak self] event in
            self?.handleMessage(event: event)
        }
    }
    
    private func setConfigs() {
        self.manager.engine?.extraHeaders = ["partnerKey" : "1"]
        self.manager.setConfigs([.log(false), .forceWebsockets(true)])
    }
    
    func reconnect() {
        socket.manager?.reconnect()
    }
    
    func connect() {
        guard socket.status != .connected, socket.status != .connecting else { return }
        socket.connect()
    }
    
    func createRoom(roomId: String, roomName: String, userID: String, roomType: String) {
        guard socket.status == .connected else { return }
        socket.emit("createRoom", ["roomId": roomId, "roomName": roomName, "userID": userID, "roomType": roomType])
    }
    
    func joinRoom(streamId: String, roomId: String? = nil) {
        guard socket.status == .connected else { return }
        var joinParams = [String : String]()
        if let id = roomId {
            joinParams["roomId"] = id
        } else if let id = lastRoomID {
            joinParams["roomId"] = id
        }
        socket.emit("join", joinParams)
    }
    
    func leaveRoom(roomId: String) {
        socket.emit("leave", ["roomId": roomId]) { [weak self]  in
        }
    }
    
    func handleMessage(event: SocketAnyEvent) {
        guard let eventType = SocketIOEventType(rawValue: event.event) else { return }
        guard let items = event.items else { return }
        guard let data = try? JSONSerialization.data(withJSONObject: items, options: .prettyPrinted) else { return }
        
        if let response: SBSSocketResponse = decodeItems(data: data) {
            delegate?.handleSocket(model: response)
        }
    }
    
    func decodeItems<T: Codable>(data: Data) -> T?{
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .custom({ keys in
            let lastKey = keys.last!
            let firstLetter = lastKey.stringValue.prefix(1).lowercased()
            let modifiedKey = firstLetter + lastKey.stringValue.dropFirst()
            return CustomCodingKey(stringValue: modifiedKey)!
        })
        
        do {
            let decodedObject = try decoder.decode(T.self, from: data)
            return decodedObject
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
}

struct CustomCodingKey: CodingKey {
  var stringValue: String

  init?(stringValue: String) {
    self.stringValue = stringValue
  }

  var intValue: Int? {
    return nil
  }

  init?(intValue: Int) {
    return nil
  }

}

public struct SBSSocketResponse: Codable {
    let userCount: Int?
}
