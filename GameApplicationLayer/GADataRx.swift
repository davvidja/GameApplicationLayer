//
//  GADataRx.swift
//  GameApplicationLayer
//
//  Created by Carina Macia on 14/12/14.
//  Copyright (c) 2014 Our company. All rights reserved.
//

import Foundation

public class GADataRx {
    var dataRxDelegate  :GADataRxDelegate?
    var communicationProtocol: GACommunicationProtocol?

 
    init(){
        
    }
}

//Extension implementing the GAPCommunicationProtocolDelegate methods
extension GADataRx: GACommunicationProtocolDelegate {
    func didReceiveNode(nodeId: UInt8) {
        var node = GAPNode()
        node.nodeIdentifier = nodeId
        
        if (dataRxDelegate != nil){
            dataRxDelegate!.didReceiveNode(node)
            
        } else {
            println("GAClient> no GAClient´s delegate has been set.")
        }
    }
    
    func didReceiveScene(scene: GAPScene) {
        
        if (dataRxDelegate != nil){
            dataRxDelegate!.didReceiveScene(scene)
            
        } else {
            println("GAClient> no GAClient´s delegate has been set.")
        }
    }
    
    func didReceiveNodeaction(nodeaction: GAPNodeAction) {
        
        if (dataRxDelegate != nil){
            dataRxDelegate!.didReceiveNodeAction(nodeaction)
            
        } else {
            println("GAClient> no GAClient´s delegate has been set.")
        }
    }
    
    func didReceivePause() {
        if (dataRxDelegate != nil){
            dataRxDelegate!.didReceiveGamePause()
            
        } else {
            println("GAClient> no GAClient´s delegate has been set.")
        }
    }
}


extension GADataRx: GASessionDataRxDelegate{

    public func receiveData ()->(UnsafeMutablePointer<UInt8>,Int, (Int)->Void){
        return communicationProtocol!.receiveData()
    }
}