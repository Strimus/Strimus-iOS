//
//  File.swift
//  
//
//  Created by Sukru Kahraman on 20.02.2024.
//

import Foundation

public struct SBSSocketResponse: Codable {
    let userId: String?
    let roomId: String?
    let roomOwner: String?
    let partnerKey: String?
    let userCount: Int?
    let socketId: String?
    let nickName: String?
}

/*
 {
     "userId": "03e3610d97d515d6ffd3a1522aff470a5da2901f117a5302c629c30bddd55253",
     "socketId": "il7S09q-Er4kbp1SAAAH",
     "nickName": "guest0.6162310350692104",
     "roomId": "9987276162-1223901AJSDX",
     "roomOwner": "oDtOFgPE6JQS5GCcAAAF",
     "partnerKey": "1234",
     "userExtraInfo": {
         "partnerKey": "1"
     },
     "roomUsers": [
         {
             "userId": "acc683508b24d8dce8e6157c656b0d829cc73a2f914791586fc9f7887a74dd45",
             "nickName": "guest0.8461565085947156",
             "socketId": "oDtOFgPE6JQS5GCcAAAF",
             "extraInfo": {
                 "partnerKey": "1"
             }
         },
         {
             "userId": "03e3610d97d515d6ffd3a1522aff470a5da2901f117a5302c629c30bddd55253",
             "nickName": "guest0.6162310350692104",
             "socketId": "il7S09q-Er4kbp1SAAAH",
             "extraInfo": {
                 "partnerKey": "1"
             }
         }
     ],
     "userCount": 2
 }
 */
