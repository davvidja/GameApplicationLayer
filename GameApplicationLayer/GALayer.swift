//
//  GALayer.swift
//  GameApplicationLayer
//
//  Created by Carina Macia on 14/12/14.
//  Copyright (c) 2014 Our company. All rights reserved.
//

import Foundation
import MultipeerConnectivity

public protocol GADataTxOffered {
    func sendScene (scene: GAPScene)
    func sendNode (node: GAPNode)
    func sendNodeAction (nodeaction: GAPNodeAction)
    func sendGamePause ()
}

public protocol GADataRxDelegate {
    func didReceiveScene(scene: GAPScene)
    func didReceiveNode(node: GAPNode)
    func didReceiveNodeAction(nodeaction: GAPNodeAction)
    func didReceiveGamePause()
}

public protocol GAServerOffered {
    func startGameServer ()
    func stopGameServer ()
}

public protocol GASessionConnectionDelegate {
    func player(#peerPlayer: String!, didChangeStateTo newState: GAPlayerConnectionState)
}


public class GALayer {
    var rxDelegate              : GADataRxDelegate?
    var sessionConnectionDelegate  : GASessionConnectionDelegate?
    
    var myPeerID                : MCPeerID?
    var session                 : GASession?
    
    var gameServer              : GAServer?
    var gameClient              : GAClient?
    
    var dataTx                  : GADataTx?
    var dataRx                  : GADataRx?
    var communicationProtocol   : GACommunicationProtocol?
    
    public init(rxDelegate: GADataRxDelegate, sessionConnectionDelegate: GASessionConnectionDelegate){
        self.rxDelegate                = rxDelegate
        self.sessionConnectionDelegate = sessionConnectionDelegate
    }
    
    public func initGameClient (myPlayerName: String!, serviceType: String = "FreeBall", withAssistant: Bool = true)->(GAClient?, GADataRx?, GADataTx?) {
        initMainComponents(myPlayerName)
        
        if (gameClient == nil){
            gameClient = GAClient()
            gameClient!.session = session!
        }
        
        gameClient!.initGameClient(myPlayerName, serviceType: serviceType, withAssistant: withAssistant)
        
        return (gameClient, dataRx, dataTx)
    }
    
    public func initGameServer (myPlayerName: String!, serviceType: String = "FreeBall", withAssistant: Bool = true)->(GAServer?, GADataRx?, GADataTx?) {
        initMainComponents(myPlayerName)
        
        if (gameServer == nil){
            gameServer = GAServer()
            gameServer!.session = session!
        }
        
        gameServer!.initGameServer(myPlayerName, serviceType: serviceType, withAssistant: withAssistant)
        
        return (gameServer, dataRx, dataTx)
    }
    
    func initMainComponents (myPlayerName: String!){

        if (dataRx == nil){
            dataRx = GADataRx()
            dataRx!.dataRxDelegate = rxDelegate!
//            dataRx!.communicationProtocol = communicationProtocol
        }
        
        if (dataTx == nil){
            dataTx = GADataTx()
//            dataTx!.session = session
//            dataTx!.communicationProtocol = communicationProtocol
        }
        
        
        if (communicationProtocol == nil){
            communicationProtocol = GACommunicationProtocol()
            communicationProtocol!.delegate = dataRx!
            
            dataRx!.communicationProtocol = communicationProtocol
            dataTx!.communicationProtocol = communicationProtocol
        }
        

        
        if (myPeerID == nil){
            myPeerID = MCPeerID(displayName: myPlayerName)
        }
        
        if (session == nil){
            session = GASession(peer: myPeerID!)
            session!.sessionConnectionDelegate = sessionConnectionDelegate!
            session!.dataRxDelegate = dataRx!
            
            dataTx!.session = session
        }
    }
}