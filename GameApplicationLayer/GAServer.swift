//
//  GAServer.swift
//  GameApplicationLayer
//
//  Created by Carina Macia on 29/11/14.
//  Copyright (c) 2014 Our company. All rights reserved.
//

import Foundation
import MultipeerConnectivity


public protocol GAServerDelegate {
    func player(#peerPlayer: String!, didChangeStateTo newState: GAPlayerConnectionState)
}




public class GAServer: NSObject, GASessionDelegate {
    
    var myPeerID, nearbyPeerID: MCPeerID?
    var session: GASession?
    var adverstiserAssistant: MCAdvertiserAssistant?

    public var delegate: GAServerDelegate?
    
    public func initGameServer (myPlayerName: String!, serviceType: String = "FreeBall", withAssistant: Bool = true) {
        if (myPeerID == nil){
            myPeerID = MCPeerID(displayName: myPlayerName)
        }
        
        if (session == nil){
            session = GASession(peer: myPeerID!)
            session!.delegate = self
        }
        
        if (adverstiserAssistant == nil){
            adverstiserAssistant = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: session!.session)
        }
    }
    
    public func startGameServer () {
        adverstiserAssistant!.start()
    }
    
    public func stopGameServer () {
        session!.disconnect()
        adverstiserAssistant!.stop()
    }
    
    //Transmition methods
    public func sendData (buffer: UnsafePointer<UInt8>, maxlength: Int){
        session!.writeOutputStream(buffer, maxLength: maxlength)
    }
    
    
    public func sendScene () {
        
    }
    
    public func sendNode () {
        
    }
    
    public func sendNodeAction () {
        
    }
    
    public func sendGamePause () {
        
    }
    
    //Methods of the GASessionDelegate protocol
    func player(#peerPlayer: String!, didChangeStateTo newState: GAPlayerConnectionState){
        println("ViewController> Player \(peerPlayer) change estate to \(newState)")
        
        delegate!.player(peerPlayer: peerPlayer, didChangeStateTo: GAPlayerConnectionState.GAPlayerConnectionStateConnected)
    }
}
