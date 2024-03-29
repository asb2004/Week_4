//
//  Model.swift
//  iOS_015
//
//  Created by DREAMWORLD on 04/03/24.
//

import Foundation
import UIKit

struct Blog: Decodable {
    let data: [User]
}


struct User: Decodable {
    let userID: Int
    var name: String
    var email: String
    let profilePic: String
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case name, email
        case profilePic = "profile_pic"
    }
}

struct AddedData: Decodable {
    let status: Bool
    let statusCode: String
    let data: AddedUser?
}

struct AddedUser: Decodable {
    let name, email: String
    let profilePic: String
    let id: Int

    enum CodingKeys: String, CodingKey {
        case name, email
        case profilePic = "profile_pic"
        case id
    }
}

// model for update request

struct UpdateUser: Encodable {
    let user_id: Int
    let name: String
    let email: String
    let profile_pic: Data
}

