//
//  GACommonStructures.swift
//  GameApplicationLayer
//
//  Created by Carina Macia on 29/11/14.
//  Copyright (c) 2014 Our company. All rights reserved.
//

import Foundation

public enum GAPlayerConnectionState {
    case GAPlayerConnectionStateConnected
    case GAPlayerConnectionStateNotConnected
}

public struct GAPNode {
    var nodeIdentifier :UInt8 = 0
}

public struct GAPScene {
    var sceneIdentifier :UInt8 = 0
}

