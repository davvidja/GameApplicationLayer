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

let CSCENE       : UInt8 = 1
let CNODE        : UInt8 = 2
let CNODEACTION  : UInt8 = 3
let CPAUSE       : UInt8 = 4


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
    var seqNumber   : UInt16 = 0
    var timeStamp   : UInt32 = 0
    var SSRC        : UInt32 = 0
//    var text        = Array<Character>(count: 4, repeatedValue: "*")
}

struct GAPpayloadTypes {
    let SCENE       : UInt8 = CSCENE
    let NODE        : UInt8 = CNODE
    let NODEACTION  : UInt8 = CNODEACTION
    let PAUSE       : UInt8 = CPAUSE
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

    var hdrBuffer       : UnsafeMutablePointer<GAPHeader>?
    var hdr             = GAPHeader()
    
    var nodePayloadBuffer : UnsafeMutablePointer<GAPNodePayload>?
    
    
    var msgNode         : GAPNodePacket?
    var msgScene        : GAPScenePacket?
    
    
    //Instance properties used in the reception of the next chunck of data
    var rxBuffer        : UnsafeMutablePointer<UInt8>?
    var rxMaxLen        : Int = 0
    var rxParsingMethod : ((Int)->Void)?
    
    init(){
        SSRC = UInt32(random())
        
        prepareForGAPHeaderReception()
    }
    
    //This metod creates the message regarding with the protocolo primitive SENDNODE
    func sendNode(node: GAPNode) -> (UnsafePointer<UInt8>,Int) {
        msgNode = GAPNodePacket()
        var buffer = UnsafePointer<UInt8>()
        
        self.buildHeader(&msgNode!.header, payloadType: payloadTypes.NODE)
        
        //Building payload
        msgNode!.payload.nodeIdentifier = node.nodeIdentifier
        
        var aux = NSData(bytes: &msgNode!, length: sizeof(GAPNodePacket))
        
        return (UnsafePointer<UInt8>(aux.bytes), aux.length)
    }
    
    //This metod creates the message regarding with the protocolo primitive SENDNODE
    func sendScene(scene: GAPScene) -> (UnsafePointer<UInt8>,Int) {
        msgScene = GAPScenePacket()
        
        var msgScenePointer = UnsafeMutablePointer<GAPScenePacket>.alloc(1)
        msgScenePointer.initialize(GAPScenePacket())
        
        
        var buffer = UnsafePointer<UInt8>()
        
        self.buildHeader(&msgScenePointer.memory.header, payloadType: payloadTypes.SCENE)
        
        //Building payload
        msgScenePointer.memory.payload.sceneIdentifier = scene.sceneIdentifier
        
//        var aux = NSData(bytes: &msgScene!, length: sizeof(GAPScenePacket))
        
        return (UnsafePointer<UInt8>(msgScenePointer), sizeof(GAPScenePacket))
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
        
//        header.text = ["H","o","l","a"]
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

}





/*
 * Extension rx Data. It implementes all methods needed to receive the incoming data
 */

extension GACommunicationProtocol {
    
    //Method called when bytes are available in the input stream. This method
    func receiveData()->(UnsafeMutablePointer<UInt8>,Int, (Int)->Void){
        return (rxBuffer!, rxMaxLen,rxParsingMethod!)
    }
    
    
    //Preparing the communication protocol for receiving a new GAPHeader
    func prepareForGAPHeaderReception () {
        
        //Preparing the suitable reception buffer
        hdrBuffer = UnsafeMutablePointer<GAPHeader>.alloc(1)
        hdrBuffer!.initialize(GAPHeader())
        
        rxBuffer = UnsafeMutablePointer<UInt8>(hdrBuffer!)
        
        //Setting the maxlength that could be stored in the reception buffered allocated
        rxMaxLen = sizeof(GAPHeader)
        
        //Setting the parsing method for the chunck of bits that will be received
        rxParsingMethod = readGAPHeader
    }
    
    //Releasing resources allocated for receiving the GAPHeader
    func releseResourcesForGAPHeaderReception (){
        println("Releasing resources for GAPHeaderReception")
        
        //releasing memory of the pointer to the GAPHeader
        hdrBuffer!.destroy(1)
        hdrBuffer!.dealloc(1)
        
        //reception pointer to nil
        rxBuffer! = nil
        
        //setting the maxlength to 0, avoiding to read new data when the memory is not ready
        rxMaxLen = 0
    }
    
    //Preparing the communication protocol for receiving a payload of a NODE protocol primitive
    func prepareForGAPNodePayloadReception (){
        //Preparing the suitable reception buffer
        nodePayloadBuffer = UnsafeMutablePointer<GAPNodePayload>.alloc(1)
        nodePayloadBuffer!.initialize(GAPNodePayload())
        
        rxBuffer = UnsafeMutablePointer<UInt8>(nodePayloadBuffer!)
        
        //Setting the maxlength that could be stored in the reception buffered allocated
        rxMaxLen = sizeof(GAPNodePayload)
        
        //Setting the parsing method for the chunck of bits that will be received
        rxParsingMethod = readGAPNodePayload
    }
    
    //Releasing resources allocated for receiving the GAPHeader
    func releseResourcesForGAPNodePayloadReception (){
        println("Releasing resources for GAPNodePayloadReception")

        //releasing memory of the pointer to the GAPHeader
        nodePayloadBuffer!.destroy(1)
        nodePayloadBuffer!.dealloc(1)
        
        //reception pointer to nil
        rxBuffer! = nil
        
        //setting the maxlength to 0, avoiding to read new data when the memory is not ready
        rxMaxLen = 0
    }
    
    func readGAPHeader(bytesRead: Int){
        println("GACommunicationProtocol (read GAPHeader)> number of bytes read: \(bytesRead)")
        
        if (bytesRead == sizeof(GAPHeader)){
            parseGAPHeader()
            
            
        } else {
            println("GACommunicationProtocol (GAPHeader)> number of bytes read does not complain with the destination structure. Data will not be parsed")
        }
    }
    
    func readGAPNodePayload(bytesRead: Int){
        println("GACommunicationProtocol (read GAPNodePayload)> number of bytes read: \(bytesRead)")
        
        if (bytesRead == sizeof(GAPNodePayload)){
            parseGAPNodePayload()
        } else {
            println("GACommunicationProtocol (GAPNodePayload)> number of bytes read does not complain with the destination structure. Data will not be parsed")
        }
    }
}







/*
* Extension Parsing rx Data. It implementes all methods needed to parse the received incoming data
*/

extension GACommunicationProtocol {
    
    /* Parsing the GAP Header
    *  Following the next steps
    *   1. Checking the verion (V) of the protocol. It should comfort of the current implementation
    *   2. Checking the payload type (PT) for determinig the primitive of the protocol sent
    *   3. Reading the payload according with the PT sent
    */
    func parseGAPHeader(){
        var payloadType = self.getPayloadTypeBits(hdrBuffer!.memory)
        
        switch (payloadType){
        case CNODE:
            println("GACommunicationProtocol> Payload type NODE")
            println("GACommunicationProtocol> Preparing the protocol for the reception of the payload")
            
            releseResourcesForGAPHeaderReception()
            
            prepareForGAPNodePayloadReception()
           
        case CSCENE:
            println("GACommunicationProtocol> Payload type SCENE")
            
        case CNODEACTION:
            println("GACommunicationProtocol> Payload type NODEACTION")
            
        case CPAUSE:
            println("GACommunicationProtocol> Payload type PAUSE")
            
        default:
            println("GACommunicationProtocol> Payload type unkown")
        }
    }
    
    func parseGAPNodePayload(){
        println("GACommunicationProtocol> parsing GAPNodePayload")
        
        releseResourcesForGAPNodePayloadReception()
        
        prepareForGAPHeaderReception ()
    }
}
