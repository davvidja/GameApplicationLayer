//
//  GASession.swift
//  GameApplicationLayer
//
//  Created by Carina Macia on 30/11/14.
//  Copyright (c) 2014 Our company. All rights reserved.
//

import Foundation
import MultipeerConnectivity




protocol GASessionDataRxDelegate{
    func receiveData ()->(UnsafeMutablePointer<UInt8>,Int, (Int)->Void)
}

class GASession: NSObject, NSStreamDelegate, MCSessionDelegate {
    
    var myPeerID, nearbyPeerID: MCPeerID?
    var session: MCSession?
    var inputStream: NSInputStream?
    var outputStream: NSOutputStream?
    var outputStreamStarted, inputStreamReceived: Bool
    var outputStreamOpenCompleted, inputStreamOpenCompleted: Bool
    var outputStreamHasSpaceAvailable: Bool
    
    var sessionConnectionDelegate: GASessionConnectionDelegate?
    var dataRxDelegate: GASessionDataRxDelegate?
    
    var buffer = UnsafeMutablePointer<UInt8>()
    
    var once: Bool
    
    
    init(peer: MCPeerID){
        outputStreamStarted = false
        inputStreamReceived = false
        outputStreamOpenCompleted = false
        inputStreamOpenCompleted = false
        outputStreamHasSpaceAvailable = false
        
        session = MCSession(peer: peer)
        
        once = true
                
        super.init()
        
        session!.delegate = self
    }
    
    func disconnect(){
        self.closeStreams()
        session!.disconnect()
    }
    
    
    //** Methods of the MCSessionDelegate protocol **//
    
    // Remote peer changed state
     func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        println("Peer \(peerID.displayName) has changed state to \(self.stringForPeerConnectionState(state))")
        
        switch state {
            
        case MCSessionState.Connected:
            //Once we are noticed that a peer has been connected to the session we proced with the start of the output stream
            
            var error: NSError?
            
            nearbyPeerID = peerID
            
            self.outputStream = session.startStreamWithName(peerID.displayName, toPeer: peerID, error: &error)
            
            if (error != nil){
                println("GASession>: An Error Occurred while outputStream start: \(error!)")
                outputStreamStarted = false
            } else {
                println("GASession>: outputStream started correctly")
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
     func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!){
        
    }
    
    // Received a byte stream from remote peer
     func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!){
        
        inputStreamReceived = true
        inputStream = stream
        
        self.openStreams()
    }
    
    // Start receiving a resource from remote peer
     func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!){
        
    }
    
    // Finished receiving a resource from remote peer and saved the content in a temporary location - the app is responsible for moving the file to a permanent location within its sandbox
     func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!){
        
    }
    
    
    //Delegate method of NSStreamDelegate protocol
     func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        switch eventCode {
        case NSStreamEvent.OpenCompleted:
            println("Open completed event received")
            
            if (aStream == outputStream){
                outputStreamOpenCompleted = true
            }
            
            if (aStream == inputStream){
                inputStreamOpenCompleted = true
            }
            
            //Checking if both, input and output streams are already open. In that case, the upper layer of the network arquitecture will be notified.
            if (inputStreamOpenCompleted && outputStreamOpenCompleted){
                sessionConnectionDelegate!.player(peerPlayer: nearbyPeerID!.displayName, didChangeStateTo: GAPlayerConnectionState.GAPlayerConnectionStateConnected)
            }
            
        case NSStreamEvent.HasBytesAvailable:
            println("Bytes available event received")

            var maxLen      : Int
            var callback    : (Int)->Void
            var buffer      : UnsafeMutablePointer<UInt8>
            
            if (once){
                (buffer, maxLen, callback) = dataRxDelegate!.receiveData()
                
                if (maxLen > 0){
            
                    var len = inputStream!.read(buffer, maxLength: maxLen)
            
                    callback(len)
                    
                    println("GASession> Bytes read: \(len)")
                
//                once = false
                } else {
                    println("GASession> bytes not readed because the maxLen was 0")
                }
            }
            
            
        case NSStreamEvent.HasSpaceAvailable:
            println("Space available event received")
            outputStreamHasSpaceAvailable = true
            
            
        case NSStreamEvent.EndEncountered:
            println("End encountered event received")
            
            sessionConnectionDelegate!.player(peerPlayer: nearbyPeerID?.displayName, didChangeStateTo: GAPlayerConnectionState.GAPlayerConnectionStateNotConnected)
            
            
            if (aStream == outputStream!){
                outputStreamOpenCompleted = false
            }
            
            if (aStream == inputStream!){
                inputStreamOpenCompleted = false
            }
            
        case NSStreamEvent.ErrorOccurred:
            println("Error ocurred event received")
            
            sessionConnectionDelegate!.player(peerPlayer: nearbyPeerID?.displayName, didChangeStateTo: GAPlayerConnectionState.GAPlayerConnectionStateNotConnected)
            
            
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
    
    func writeOutputStream(buffer: UnsafePointer<UInt8>, maxLength: Int)->Bool{
        var bytesWritten: Int
        
        if(outputStreamHasSpaceAvailable){
            bytesWritten = self.outputStream!.write(buffer, maxLength: maxLength)
            
            println("GASession>: writing into outputStream. Max length: \(maxLength). Bytes written: \(bytesWritten)")
            
            return true
        } else {
            println("GASession>: writing into outputStream. There is not space available")
            
            return false
        }
    }
    
    
    //** Stream handling methods **//
    
    //Opening of both the input and output streams
    func openStreams (){
        println("GASession>: opening Streams. OutputStream started? \(outputStreamStarted). InputStream received? \(inputStreamReceived)")

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
        println("GASession>: closing Streams. OutputStream started? \(outputStreamStarted). InputStream received? \(inputStreamReceived)")
        if (outputStreamStarted){
            outputStream!.removeFromRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
            outputStream!.close()
        }
        
        if (inputStreamReceived){
            inputStream!.removeFromRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
            inputStream!.close()
        }
        
        once = true

    }
    
    
    // Helper method for human readable printing of MCSessionState.  This state is per peer.
    func stringForPeerConnectionState(state: MCSessionState)->String{
        switch(state){
        case MCSessionState.Connected:
            return "Connected";
            
        case MCSessionState.Connecting:
            return "Connecting";
            
        case MCSessionState.NotConnected:
            return "Not Connected";
        }
    }
    
}
