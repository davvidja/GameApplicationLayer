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

public class GAClient: NSObject, MCBrowserViewControllerDelegate, GASessionDelegate {
    
    var myPeerID, nearbyPeerID: MCPeerID?
    var session: GASession?
    var adverstiserAssistant: MCAdvertiserAssistant?
    var peersBrowser: MCBrowserViewController?
    public var delegate: GAServerDelegate?
    
    
    public func initGameClient (myPlayerName: String!, serviceType: String = "FreeBall", withAssistant: Bool = true) {
        if (myPeerID == nil){
            myPeerID = MCPeerID(displayName: myPlayerName)
        }
        
        if (session == nil){
            session = GASession(peer: myPeerID!)
            session!.delegate = self
        }
        
        if(peersBrowser == nil){
            peersBrowser = MCBrowserViewController(serviceType: serviceType, session: session!.session)
            peersBrowser!.delegate = self
        }
    }
    
    public func startGameClient (parentViewController: UIViewController) {
        parentViewController.presentViewController(peersBrowser!, animated: true, completion: nil)
    }
    
    public func stopGameClient () {
        session!.disconnect()
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
    
    
    //Methods of the GASessionDelegate protocol
    func player(#peerPlayer: String!, didChangeStateTo newState: GAPlayerConnectionState){
        println("ViewController> Player \(peerPlayer) change estate to \(newState)")
        
        delegate!.player(peerPlayer: peerPlayer, didChangeStateTo: GAPlayerConnectionState.GAPlayerConnectionStateConnected)
    }

}