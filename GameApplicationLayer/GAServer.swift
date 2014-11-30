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




public class GAServer: NSObject, NSStreamDelegate, MCSessionDelegate {
    
    var myPeerID, nearbyPeerID: MCPeerID?
    var session: MCSession?
    var adverstiserAssistant: MCAdvertiserAssistant?
    var inputStream: NSInputStream?
    var outputStream: NSOutputStream?
    var outputStreamStarted, inputStreamReceived: Bool
    var outputStreamOpenCompleted, inputStreamOpenCompleted: Bool
    public var delegate: GAServerDelegate?
    
    public override init(){
        outputStreamStarted = false
        inputStreamReceived = false
        outputStreamOpenCompleted = false
        inputStreamOpenCompleted = false
    }
    
    public func initGameServer (myPlayerName: String!, serviceType: String = "FreeBall", withAssistant: Bool = true) {
        if (myPeerID == nil){
            myPeerID = MCPeerID(displayName: myPlayerName)
        }
        
        if (session == nil){
            session = MCSession(peer: myPeerID)
            session!.delegate = self
        }
        
        if (adverstiserAssistant == nil){
            adverstiserAssistant = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: session)
        }
    }
    
    public func startGameServer () {
        adverstiserAssistant!.start()
    }
    
    public func stopGameServer () {
        adverstiserAssistant!.stop()
    }
    
    //Transmition methods
    public func sendScene () {
        
    }
    
    public func sendNode () {
        
    }
    
    public func sendNodeAction () {
        
    }
    
    public func sendGamePause () {
        
    }
    
    //** Methods of the MCSessionDelegate protocol **//
    
    // Remote peer changed state
    public func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        println("Peer /(peerID.displayName) has changed state to /(state)")
        
        switch state {
            
        case MCSessionState.Connected:
            //Once we are noticed that a peer has been connected to the session we proced with the start of the output stream

            var error: NSError?
            
            nearbyPeerID = peerID
            
            self.outputStream = session.startStreamWithName(peerID.displayName, toPeer: peerID, error: &error)
            
            if (error != nil){
                println("An Error Occurred while outputStream start: \(error!)")
                outputStreamStarted = false
            } else {
                outputStreamStarted = true
                self.openStreams()
            }
            break
            
        case MCSessionState.Connecting:
            break
            
        case MCSessionState.NotConnected:
            break
            
        default:
            println("undefined state")
        }
    }
    
    // Received data from remote peer
    public func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!){
        
    }
    
    // Received a byte stream from remote peer
    public func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!){
        
        inputStreamReceived = true
        self.openStreams()
    }
    
    // Start receiving a resource from remote peer
    public func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!){
        
    }
    
    // Finished receiving a resource from remote peer and saved the content in a temporary location - the app is responsible for moving the file to a permanent location within its sandbox
    public func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!){
        
    }
    
    

    
    
    //Delegate method of NSStreamDelegate protocol
    public func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        switch eventCode {
        case NSStreamEvent.OpenCompleted:
            println("Open completed event received")
            
            if (aStream == outputStream!){
                outputStreamOpenCompleted = true
            }
            
            if (aStream == inputStream!){
                inputStreamOpenCompleted = true
            }
            
            //Checking if both, input and output streams are already open. In that case, the upper layer of the network arquitecture will be notified.
            if (inputStreamOpenCompleted && outputStreamOpenCompleted){
                delegate!.player(peerPlayer: nearbyPeerID?.displayName, didChangeStateTo: GAPlayerConnectionState.GAPlayerConnectionStateConnected)
            }
            
        case NSStreamEvent.HasBytesAvailable:
            println("Bytes available event received")
            
        case NSStreamEvent.HasSpaceAvailable:
            println("Space available event received")

            
        case NSStreamEvent.EndEncountered:
            println("End encountered event received")
            
            delegate!.player(peerPlayer: nearbyPeerID?.displayName, didChangeStateTo: GAPlayerConnectionState.GAPlayerConnectionStateNotConnected)

            
            if (aStream == outputStream!){
                outputStreamOpenCompleted = false
            }

            if (aStream == inputStream!){
                inputStreamOpenCompleted = false
            }
           
        case NSStreamEvent.ErrorOccurred:
            println("Error ocurred event received")
            
            delegate!.player(peerPlayer: nearbyPeerID?.displayName, didChangeStateTo: GAPlayerConnectionState.GAPlayerConnectionStateNotConnected)

            
            if (aStream == outputStream!){
                outputStreamOpenCompleted = false
            }
            
            if (aStream == inputStream!){
                inputStreamOpenCompleted = false
            }

            
        default:
            println("Event received but not treated")
        }
    }
    
    
    //** Stream handling methods **//
    
    //Opening of both the input and output streams
    func openStreams (){
        if (outputStreamStarted && inputStreamReceived){
            outputStream!.delegate = self
            outputStream!.scheduleInRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
            outputStream!.open()
            
            inputStream!.delegate = self
            inputStream!.scheduleInRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
            inputStream!.open()
        }
    }
    
    //Closing of both the input and output streams
    func closeStreams (){
        
    }

}
