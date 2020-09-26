//
//  main.swift
//  KSMessageServer
//
//  Created by saeipi on 2020/9/26.
//  Copyright © 2020 saeipi. All rights reserved.
//

import Foundation

let server = try WebSocketServer()
server.start()
RunLoop.main.run()
