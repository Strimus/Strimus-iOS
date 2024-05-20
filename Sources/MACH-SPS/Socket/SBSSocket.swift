//
//  File.swift
//  
//
//  Created by Sukru Kahraman on 7.02.2024.
//

import SocketIO
import Foundation

public protocol SBSSocketDelegate: AnyObject {
    func handleSocket(userCount: Int?)
}

public enum SocketIOEventType: String {
    case createRoom
    case join
    case message
    case leave
    case roomInfo
}

public class SBSSocket {
    
    static let shared = SBSSocket()
    
    private var manager = SocketManager(socketURL: URL(string: "wss://straas-api.themachinarium.xyz/")!, config: [.log(true), .compress, .extraHeaders(["partnerkey" : "1"]), .forceWebsockets(true)])
    var socket: SocketIOClient
    
    public weak var delegate: SBSSocketDelegate?
    
    let socketQeue = DispatchQueue.init(label: "socket-io-qeue-strimus", qos: .utility)
    
    var lastRoomID: String?
    var roomId: String?
    init() {
        socket = manager.defaultSocket
//        setConfigs()

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
            self?.reconnect()
        }
        
        socket.on(clientEvent: .statusChange) { [weak self] data, ack in
            
        }
        
        socket.onAny { [weak self] event in
            self?.handleMessage(event: event)
        }
        
        socket.on("roomInfo") { data, ack in
            
        }
        
        socket.on("join") { data, ack in
            
        }
        
    }
    
    private func setConfigs() {
        self.manager.engine?.extraHeaders = ["partnerkey" : "1"]
        self.manager.setConfigs([.log(false), .forceWebsockets(true)])
    }
    
    func reconnect() {
        socket.manager?.reconnect()
    }
    
    public func connect() {
        guard socket.status != .connected, socket.status != .connecting else { return }
        socket.connect()
    }
    
    public func createRoom(roomId: String, roomName: String, userID: String, roomType: String, partnerKey: String) {
        guard socket.status == .connected else { return }
        socket.emit("createRoom", ["roomId": roomId, "roomName": roomName, "userID": userID, "roomType": roomType, "partnerKey": partnerKey])
    }
    
    public func joinRoom(roomId: String) {
        socket.emit("join", ["roomId": roomId])
    }
    
    func leaveRoom(roomId: String) {
        socket.emit("leave", ["roomId": roomId]) { [weak self]  in
        }
    }
    
    func handleMessage(event: SocketAnyEvent) {
        guard let eventType = SocketIOEventType(rawValue: event.event) else { return }
        guard let items = event.items else { return }
        guard let data = try? JSONSerialization.data(withJSONObject: items, options: .prettyPrinted) else { return }
        
        if let response: [SBSSocketResponse] = decodeItems(data: data) {
            delegate?.handleSocket(userCount: response.first?.userCount)
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
