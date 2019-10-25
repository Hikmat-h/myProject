//
//  SocketAnswers.swift
//  BoomBoom
//
//  Created by Hikmatillo Habibullaev on 10/21/19.
//  Copyright © 2019 Hikmatillo Habibullaev. All rights reserved.
//

import Foundation
import RealmSwift

class Dog: Object {
    @objc dynamic var name = ""
    @objc dynamic var age = 0
}
class Person: Object {
    @objc dynamic var name = ""
    @objc dynamic var picture: Data? = nil // optionals supported
    let dogs = List<Dog>()
}



//MARK: - Realm obects
class RealmChat:Object{
    dynamic var photos = List<RealmChatPhoto>()
    @objc dynamic var name = ""
    @objc dynamic var online = false
    @objc dynamic var accountID = -1
    @objc dynamic var lastDateAddMessage: Int64 = 0
    @objc dynamic var chatID = -1
    @objc dynamic var message: RealmMessage? = nil
    @objc dynamic var favorite = false
    @objc dynamic var countNewMessages = 0
    @objc dynamic var typeAccount = ""
}

class RealmChatPhoto: Object{
    @objc dynamic var pathURLPreview: String? = nil
}

class RealmMessage:Object{
    @objc dynamic var accountID = -1
    @objc dynamic var message = ""
    @objc dynamic var dateSend: Int64 = 0
    @objc dynamic var chatMessageID = -1
    @objc dynamic var chatID = -1
    dynamic var chatMessageStatusList = List<RealmChatMessageStatus>()
}

class RealmChatMessageStatus:Object{
    @objc dynamic var id = -1
    @objc dynamic var accountID = -1
    @objc dynamic var delivered = false
    @objc dynamic var read = false
}

//MARK: - Socket Answers

struct AuthResult: Codable {
    let accountID: Int
    let status: String

    enum CodingKeys: String, CodingKey {
        case accountID = "accountId"
        case status
    }
}

// MARK: - SendMessageAnswer
struct SendMessageAnswer: Codable {
    let accountID, companionID: Int
    let message: String
    let dateSend: Int64
    let chatMessageID, chatID: Int
    let chatMessageStatusList: [ChatMessageStatusList]
    let typeMessage, accountName: String

    enum CodingKeys: String, CodingKey {
        case accountID = "accountId"
        case companionID = "companionId"
        case message, dateSend
        case chatMessageID = "chatMessageId"
        case chatID = "chatId"
        case chatMessageStatusList, typeMessage, accountName
    }
}

// MARK: - ChatMessageStatusList
struct ChatMessageStatusList: Codable {
    let id, accontID: Int
    let delivered, read: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case accontID = "accontId"
        case delivered, read
    }
}

// MARK: - GetChatListAnswer
struct GetChatListAnswer: Codable {
    let countNewMessages, countAllChats: Int
    let chats: [Chat]
}

// MARK: - Chat
struct Chat: Codable {
    let photo: [ChatPhoto]
    let name: String
    let online: Bool
    let accountID, chatID: Int
    let lastDateAddMessage: Int64
    let message: SocketMessage
    let favorite: Bool
    let countNewMessages: Int
    let typeAccount: String

    enum CodingKeys: String, CodingKey {
        case photo, name, online
        case accountID = "accountId"
        case lastDateAddMessage
        case chatID = "chatId"
        case message, favorite, countNewMessages, typeAccount
    }
}

// MARK: - Message
struct SocketMessage: Codable {
    let accountID: Int
    let message: String
    let dateSend: Int64
    let chatMessageID, chatID: Int
    let chatMessageStatusList: [ChatMessageStatusList]

    enum CodingKeys: String, CodingKey {
        case accountID = "accountId"
        case message, dateSend
        case chatMessageID = "chatMessageId"
        case chatID = "chatId"
        case chatMessageStatusList
    }
}

// MARK: - Photo
struct ChatPhoto: Codable {
    let pathURLPreview: String

    enum CodingKeys: String, CodingKey {
        case pathURLPreview = "pathUrlPreview"
    }
}
