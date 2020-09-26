//
//  WebSocketClient.swift
//  KSMessageServer
//
//  Created by saeipi on 2020/9/26.
//  Copyright © 2020 saeipi. All rights reserved.
//

import Foundation
import Network

final class WebSocketClient: Hashable, Equatable {//继承哈希协议, 才能放进去set集合
    
    let id: String
    let connection: NWConnection
    var user_id: Int = 0
    var user_name: String = ""
        
    init(connection: NWConnection) {
        self.connection = connection
        //获取随机UUID
        self.id = UUID().uuidString
    }
    
    // MARK:- 判断等价的条件 Equatable协议
    ///Returns a Boolean value indicating whether two values are equal.
    static func == (lhs: WebSocketClient, rhs: WebSocketClient) -> Bool {
        lhs.id == rhs.id
    }
    // MARK:- 提供一个哈希标识
    /// Hashes the essential components of this value by feeding them into the given hasher.
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
