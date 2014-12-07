//
//  GACommunicationProtocol.swift
//  GameApplicationLayer
//
//  Created by Carina Macia on 04/12/14.
//  Copyright (c) 2014 Our company. All rights reserved.
//

import Foundation

//Packet structure 1035 bytes
// - Header: 11 bytes
// - Payload: maximun of 1024 bytes


struct Vector3D {
    var dx: Int16 = 0
    var dy: Int16 = 0
    var dz: Int16 = 0
}

struct ScenePoint {
    var x: Int16 = 0
    var y: Int16 = 0
    var z: Int16 = 0
}

//Bit masks used to get information stored in a lower level than the byte.
struct GAPHeaderMasks{
    let VERSION     : UInt8 = 0b11000000
    let PADDING     : UInt8 = 0b00100000
    let EXTENSION   : UInt8 = 0b00010000
    let CSRCCOUNT   : UInt8 = 0b00001111
    let MARKER      : UInt8 = 0b10000000
    let PAYLOAD     : UInt8 = 0b01111111
}

struct GAPHeader {
    var V_P_X_CC    : UInt8 = 0
    var M_PT        : UInt8 = 0
    var seqNumber   : UInt8 = 0
    var timeStamp   : UInt32 = 0
    var SSRC        : UInt32 = 0
    var text        = Array<Character>(count: 4, repeatedValue: "*")
}

struct GAPpayloadTypes {
    let SCENE       : UInt8 = 1
    let NODE        : UInt8 = 2
    let NODEACTION  : UInt8 = 3
    let PAUSE       : UInt8 = 4
}

struct GAPScenePayload {
    var sceneIdentifier : UInt8 = 0
}

struct GAPNodePayload {
    var nodeIdentifier  : UInt8 = 0
}

struct GAPNodeactionPayload {
    var nodeIdentifier  : UInt8 = 0
    var startPoint      = ScenePoint()
    var speed           : Float32 = 0.0
    var direction       = Vector3D()
}

struct GAPNodePacket {
    var header  = GAPHeader()
    var payload = GAPNodePayload()
}

struct GAPScenePacket {
    var header  = GAPHeader()
    var payload = GAPScenePayload()
}

//It has to be decided if it would be an instance of the protocol for each session(network) the peer is connected or for each connection client-server
class GACommunicationProtocol {
    var protocolVersion : UInt8 = 1
    let hdrMasks        = GAPHeaderMasks ()
    let payloadTypes    = GAPpayloadTypes ()
    var SSRC            : UInt32
//    var hdrBuffer       : UnsafeMutablePointer<UInt8> {
//        didSet{
//            println("GACommunicationProtocol> hdrBuffer has been set")
//        }
//    }

    var hdrBuffer       : UnsafeMutablePointer<GAPHeader>
    var hdr             = GAPHeader()
    var buffer          = UnsafeMutablePointer<UInt8>()
    
    var msgNode         : GAPNodePacket?
    var msgScene        : GAPScenePacket?
    
    init(){
        SSRC = UInt32(random())
//        hdrBuffer = UnsafeMutablePointer<UInt8>.alloc(1)
        
        
        hdrBuffer = UnsafeMutablePointer<GAPHeader>.alloc(1)
        hdrBuffer.initialize(GAPHeader())
        
        var aux = hdrBuffer.memory
        
        println("GACommunicationProtocol> hdrBuffer address: \(hdrBuffer.hashValue)")
    }
    
    //This metod creates the message regarding with the protocolo primitive SENDNODE
    func sendNode(node: GAPNode) -> (UnsafePointer<UInt8>,Int) {
//        var msg = GAPHeader()
        msgNode = GAPNodePacket()
        var buffer = UnsafePointer<UInt8>()
        
        self.buildHeader(&msgNode!.header, payloadType: payloadTypes.NODE)
        
        //Building payload
        msgNode!.payload.nodeIdentifier = node.nodeIdentifier
        
        var aux = NSData(bytes: &msgNode!, length: sizeof(GAPNodePacket))
        
        return (UnsafePointer<UInt8>(aux.bytes), aux.length)
    }
    
    func buildHeader (inout header: GAPHeader, payloadType: UInt8){
        var version = self.protocolVersion
        
        self.setVersionBits(version, toByte: &header.V_P_X_CC)
        self.setPaddingBits(0, toByte: &header.V_P_X_CC)          //For the moment, the padding bit will be set to '0' always
        self.setExtensionBits(0, toByte: &header.V_P_X_CC)        //For the moment, the extension bit will be set to '0' always
        self.setCSRCCountBits(0, toByte: &header.V_P_X_CC)
        
        self.setMarkerBits(1, toByte: &header.M_PT)
        self.setPayLoadTypeBits(payloadType, toByte: &header.M_PT)
        
        self.setTimeStamp(toByte: &header.timeStamp)
        self.setSSRC(toByte: &header.SSRC)
        
        header.text = ["H","o","l","a"]
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
    
    func getPayloadTypeBits(header: GAPHeader)->UInt8{
        var payloadBits: UInt8
        
        return header.M_PT & hdrMasks.PAYLOAD
    }
    
    func parseMessage(){
        var aux = UnsafeMutablePointer<GAPHeader> (bitPattern: hdrBuffer.hashValue)
        
        var h = GAPHeader()
        var aux2 = UnsafeMutablePointer<GAPHeader>.alloc(1)
        
        aux2.initialize(GAPHeader())
        var aux3 = aux2.memory

//        aux2.memory = h
        
        var aux4 = self.hdrBuffer.memory
        

        
        var payloadType = self.getPayloadTypeBits(hdrBuffer.memory)
        
        //var payloadType = self.getPayloadTypeBits(hdrBuffer.memory)

        
        
        switch (payloadType){
        case GAPpayloadTypes().NODE:
            println("GACommunicationProtocol> Payload type NODE")
            
        case GAPpayloadTypes().SCENE:
            println("GACommunicationProtocol> Payload type SCENE")

        case GAPpayloadTypes().NODEACTION:
            println("GACommunicationProtocol> Payload type NODEACTION")

        case GAPpayloadTypes().PAUSE:
            println("GACommunicationProtocol> Payload type PAUSE")
        
        default:
            println("GACommunicationProtocol> Payload type unkown")

        }
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
    
    func setSSRC(inout toByte byte: UInt32){
        byte = SSRC
    }
    
    func readData(bytesRead: Int){
        println("GACommunicationProtocol> number of bytes read: \(bytesRead)")
        
        /* Following the next steps
         *   1. Checking the verion (V) of the protocol. It should comfort of the current implementation
         *   2. Checking the payload type (PT) for determinig the primitive of the protocol sent
         *   3. Reading the payload according with the PT sent
         */
        self.parseMessage()
    }

    
    //Method called when bytes are available in the input stream
//    func receiveData()->(UnsafeMutablePointer<UInt8>,Int, (UnsafeMutablePointer<UInt8>,Int)){
    func receiveData()->(UnsafeMutablePointer<UInt8>,Int, (Int)->Void){
        //hdrBuffer = UnsafeMutablePointer<UInt8>.alloc(sizeof(GAPHeader))
        buffer = UnsafeMutablePointer<UInt8>(hdrBuffer)
        
        return (buffer, sizeof(GAPHeader)-1,readData)
    }
}