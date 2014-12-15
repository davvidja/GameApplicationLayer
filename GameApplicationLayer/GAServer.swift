//
//  GAServer.swift
//  GameApplicationLayer
//
//  Created by Carina Macia on 29/11/14.
//  Copyright (c) 2014 Our company. All rights reserved.
//

import Foundation
import MultipeerConnectivity



public class GAServer: NSObject {
    
    var myPeerID, nearbyPeerID: MCPeerID?
    var session: GASession?
    var adverstiserAssistant: MCAdvertiserAssistant?
    
    public func initGameServer (myPlayerName: String!, serviceType: String = "FreeBall", withAssistant: Bool = true) {
        if (adverstiserAssistant == nil){
            adverstiserAssistant = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: session!.session)
        }
    }
}


/*
* Server control interface methods for management of the Server, provided to the upper layer in the network architecture
*/

extension GAServer: GAServerOffered {
    public func startGameServer () {
        adverstiserAssistant!.start()
    }
    
    public func stopGameServer () {
        session!.disconnect()
        adverstiserAssistant!.stop()
    }
}




