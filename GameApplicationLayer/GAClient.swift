//
//  GAClient.swift
//  GameApplicationLayer
//
//  Created by Carina Macia on 29/11/14.
//  Copyright (c) 2014 Our company. All rights reserved.
//

import Foundation
import MultipeerConnectivity

public protocol GAClientDelegate {
    func player(#peerPlayer: String!, didChangeStateTo newState: GAPlayerConnectionState)
    func didReceiveScene()
    func didReceiveNode()
    func didReceiveNodeAction()
    func didReceiveGamePause()
}

public class GAClient: NSObject, NSStreamDelegate, MCSessionDelegate, MCBrowserViewControllerDelegate {
    
    var myPeerID, nearbyPeerID: MCPeerID?
    var session: MCSession?
    var adverstiserAssistant: MCAdvertiserAssistant?
    var peersBrowser: MCBrowserViewController?
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
    
    public func initGameClient (myPlayerName: String!, serviceType: String = "FreeBall", withAssistant: Bool = true) {
        if (myPeerID == nil){
            myPeerID = MCPeerID(displayName: myPlayerName)
        }
        
        if (session == nil){
            session = MCSession(peer: myPeerID)
            session!.delegate = self
        }
        
        if(peersBrowser == nil){
            peersBrowser = MCBrowserViewController(serviceType: serviceType, session: session)
            peersBrowser!.delegate = self
        }
    }
    
    public func startGameClient (parentViewController: UIViewController) {
        parentViewController.presentViewController(peersBrowser!, animated: true, completion: nil)
    }
    
    public func stopGameClient () {

    }
    

    
    //** Methods of the MCBrowserViewControllerDelegate protocol **//
    
    // Notifies the delegate, when the user taps the done button
    public func browserViewControllerDidFinish(browserViewController: MCBrowserViewController!){
        browserViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Notifies delegate that the user taps the cancel button.
    public func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController!){
        browserViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Notifies delegate that a peer was found; discoveryInfo can be used to determine whether the peer should be presented to the user, and the delegate should return a YES if the peer should be presented; this method is optional, if not implemented every nearby peer will be presented to the user.
    public func browserViewController(browserViewController: MCBrowserViewController!, shouldPresentNearbyPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) ->Bool{
        return true
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
        
    }
    
    // Start receiving a resource from remote peer
    public func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!){
        
    }
    
    // Finished receiving a resource from remote peer and saved the content in a temporary location - the app is responsible for moving the file to a permanent location within its sandbox
    public func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!){
        
    }
}