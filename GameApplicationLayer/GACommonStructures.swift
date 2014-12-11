//
//  GACommonStructures.swift
//  GameApplicationLayer
//
//  Created by Carina Macia on 29/11/14.
//  Copyright (c) 2014 Our company. All rights reserved.
//

import Foundation
import MultipeerConnectivity

public enum GAPlayerConnectionState {
    case GAPlayerConnectionStateConnected
    case GAPlayerConnectionStateNotConnected
    
    // Helper method for human readable printing of MCSessionState.  This state is per peer.
    static public func stringForPeerConnectionState(state: GAPlayerConnectionState)->String{
        switch(state){
        case .GAPlayerConnectionStateConnected:
            return "Connected";
            
        case .GAPlayerConnectionStateNotConnected:
            return "Not Connected";
        }
    }
}

public struct GAPNode {
    public var nodeIdentifier :UInt8
    
    public init(){
        nodeIdentifier = 0
    }
    
    public init(identifier: UInt8){
        nodeIdentifier = identifier
    }
}

public struct GAPScene {
    public var sceneIdentifier :UInt8
    
    public init(){
        sceneIdentifier = 0
    }
    
    public init(identifier: UInt8){
        sceneIdentifier = identifier
    }
    
}

public struct GAPNodeAction {
    public var nodeIdentifier   : UInt8 = 0
    var startPoint              = ScenePoint()
    var speed                   : Float32 = 0.0
    var direction               = Vector3D()
    
    public init(){
    }
}

