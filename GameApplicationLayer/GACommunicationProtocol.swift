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
    var V_P_X_CC: UInt8 = 0
    var M_PT: UInt8 = 0
    var seqNumber: UInt8 = 0
    var timeStamp: UInt32 = 0
    var SSRC: UInt32 = 0
}

struct GAPpayloadTypes {
    let SCENE:          UInt8 = 1
    let NODE:           UInt8 = 2
    let NODEACTION:     UInt8 = 3
    let PAUSE:          UInt8 = 4
}

//It has to be decided if it would be an instance of the protocol for each session(network) the peer is connected or for each connection client-server
class GACommunicationProtocol {
    var protocolVersion: UInt8 = 1
    let hdrMasks = GAPHeaderMasks ()
    let payloadTypes = GAPpayloadTypes ()
    var SSRC: UInt32
    var hdrBuffer: UnsafeMutablePointer<UInt8>?
    
    init(){
        SSRC = UInt32(random())
    }
    
    //This metod creates the message regarding with the protocolo primitive SENDNODE
    func sendNode() -> (UnsafePointer<UInt8>,Int) {
        var msg = GAPHeader()
        var buffer = UnsafePointer<UInt8>()
        
        
        var version = self.protocolVersion
        
        msg.V_P_X_CC    = 0b10110101
        msg.M_PT        = 0b10100011
        
        self.setVersionBits(version, toByte: &msg.V_P_X_CC)
        self.setPaddingBits(0, toByte: &msg.V_P_X_CC)          //For the moment, the padding bit will be set to '0' always
        self.setExtensionBits(0, toByte: &msg.V_P_X_CC)        //For the moment, the extension bit will be set to '0' always
        self.setCSRCCountBits(0, toByte: &msg.V_P_X_CC)
        
        self.setMarkerBits(1, toByte: &msg.M_PT)
        self.setPayLoadTypeBits(payloadTypes.NODE, toByte: &msg.M_PT)
        
        self.setTimeStamp(toByte: &msg.timeStamp)
        self.setSSRC(toByte: &msg.SSRC)
        
        var aux = NSData(bytes: &msg, length: sizeof(GAPHeader))
        
        return (UnsafePointer<UInt8>(aux.bytes), aux.length)
    }
    
    func setVersionBits(versionBits: UInt8, inout toByte byte: UInt8){
        var noVersionBits: UInt8
        let noVersionBitsMask: UInt8 = ~hdrMasks.VERSION
        
        //As version is represented for first two bits of the byte V_P_X_CC, we need to move version from base band to the appropiate band in the byte: 6
        
        //We pass from 00000001 to 01000000
        var versionShiftedBits = versionBits << 6
        
        noVersionBits = byte & noVersionBitsMask
        
        byte = versionShiftedBits | noVersionBits
    }
    
    func setPaddingBits(padingBits: UInt8, inout toByte byte: UInt8){
        //For the moment, the padding bit will be set to '0' always
        var noPaddingBits: UInt8
        let noPaddingBitsMask: UInt8 = ~hdrMasks.PADDING
        
        var paddingShiftedBits = padingBits << 5
        
        noPaddingBits = byte & noPaddingBitsMask
        
        byte = paddingShiftedBits | noPaddingBits
    }
    
    func setExtensionBits(extensionBits: UInt8, inout toByte byte: UInt8){
        //For the moment, the extension bit will be set to '0' always
        var noExtensionBits: UInt8
        let noExtensionBitsMask: UInt8 = ~hdrMasks.EXTENSION
        
        var extensionShiftedBits = extensionBits << 4
        
        noExtensionBits = byte & noExtensionBitsMask
        
        byte = extensionShiftedBits | noExtensionBits
    }
    
    func setCSRCCountBits(CSRCCountBits: UInt8, inout toByte byte: UInt8){
        var noCSRCCountBits: UInt8
        let noCSRCCountBitsMask: UInt8 = ~hdrMasks.CSRCCOUNT
        
        noCSRCCountBits = byte & noCSRCCountBitsMask
        
        byte = CSRCCountBits | noCSRCCountBits
    }
    
    func setMarkerBits(markerBits: UInt8, inout toByte byte: UInt8){
        var noMarkerBits: UInt8
        let noMarkerBitsMask: UInt8 = ~hdrMasks.MARKER
        
        var markertShiftedBits = markerBits << 7
        
        noMarkerBits = byte & noMarkerBitsMask
        
        byte = markertShiftedBits | noMarkerBits
    }
    
    func setPayLoadTypeBits(payloadBits: UInt8, inout toByte byte: UInt8){
        var nopayloadBits: UInt8
        let nopayloadBitsMask: UInt8 = ~hdrMasks.PAYLOAD
        
        nopayloadBits = byte & nopayloadBitsMask
        
        byte = payloadBits | nopayloadBits
    }
    
    func setTimeStamp(inout toByte byte: UInt32){
        var gregorianCalendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
        var dateComponentes19000101 = NSDateComponents()
        var date19000101: NSDate?
        var intervalTimeStamp: NSTimeInterval?
        var now = NSDate()
        
        dateComponentes19000101.year = 1900
        dateComponentes19000101.month = 1
        dateComponentes19000101.day = 1
        dateComponentes19000101.hour = 0
        dateComponentes19000101.minute = 0

        
        date19000101 = gregorianCalendar!.dateFromComponents(dateComponentes19000101)
        
        intervalTimeStamp = now.timeIntervalSinceDate(date19000101!)
        
        byte = UInt32(intervalTimeStamp!)
    }
    
    //Method called when bytes are available in the input stream
    func receiveData()->(UnsafeMutablePointer<UInt8>,Int){
        hdrBuffer = UnsafeMutablePointer<UInt8>.alloc(sizeof(GAPHeader))
        
        return (hdrBuffer!, sizeof(GAPHeader))
    }
    
    func setSSRC(inout toByte byte: UInt32){
        byte = SSRC
    }


}