//
//  GACommunicationProtocol.swift
//  GameApplicationLayer
//
//  Created by Carina Macia on 04/12/14.
//  Copyright (c) 2014 Our company. All rights reserved.
//

import Foundation

//Bit masks used to get information stored in a lower level than the byte.
struct GAPHeaderMasks{
    let VERSION:     UInt8 = 0b11000000
    let PADDING:     UInt8 = 0b00100000
    let EXTENSION:   UInt8 = 0b00010000
    let CSRCCOUNT:   UInt8 = 0b00001111
    let MARKER:      UInt8 = 0b10000000
    let PAYLOAD:     UInt8 = 0b01111111
}

struct GAPHeader {
    var VPCC: UInt8 = 0
    var MPT: UInt8 = 0
    var seqNumber: UInt8 = 0
    var timeStamp: UInt32 = 0
    var SSRC: UInt32 = 0
}

class GACommunicationProtocol {
    var protocolVersion: UInt8 = 1
    
    //This metod creates the message regarding with the protocolo primitive SENDNODE
    func sendNode() -> UnsafePointer<UInt8> {
        var msg = GAPHeader()
        let hdrMasks = GAPHeaderMasks()
        
        var version = self.protocolVersion
        
        version << 6
        
        
        
        
        
        
        
        return nil
    }
}