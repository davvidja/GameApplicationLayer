//
//  GADataTx.swift
//  GameApplicationLayer
//
//  Created by Carina Macia on 14/12/14.
//  Copyright (c) 2014 Our company. All rights reserved.
//

import Foundation

public class GADataTx {
    var communicationProtocol: GACommunicationProtocol?
    var session: GASession?
    
    init(){
        
    }
    
}

/*
* Downlink interface methods for the transmition of information provided to the upper layer in the network architecture
*/

extension GADataTx: GADataTxOffered {
    public func sendScene (scene: GAPScene) {
        var buffer: UnsafePointer<UInt8>
        var bufferSize: Int
        (buffer, bufferSize) = communicationProtocol!.sendScene(scene)
        session!.writeOutputStream(buffer, maxLength: bufferSize)
    }
    
    public func sendNode (node: GAPNode) {
        var buffer: UnsafePointer<UInt8>
        var bufferSize: Int
        (buffer, bufferSize) = communicationProtocol!.sendNode(node)
        session!.writeOutputStream(buffer, maxLength: bufferSize)
    }
    
    public func sendNodeAction (nodeaction: GAPNodeAction) {
        var buffer: UnsafePointer<UInt8>
        var bufferSize: Int
        (buffer, bufferSize) = communicationProtocol!.sendNodeAction(nodeaction)
        session!.writeOutputStream(buffer, maxLength: bufferSize)
    }
    
    public func sendGamePause () {
        var buffer: UnsafePointer<UInt8>
        var bufferSize: Int
        (buffer, bufferSize) = communicationProtocol!.sendPause()
        session!.writeOutputStream(buffer, maxLength: bufferSize)
    }
}