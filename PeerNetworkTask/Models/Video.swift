//
//  Video.swift
//  Peer Network Task
//
//  Created by Asad Khan on 6/23/25.
//

import Foundation

struct Video: Decodable, Identifiable, Equatable {
    let id: String
    let creator: Creator
    let shortVideoURL: String
    let fullVideoURL: String
    let description: String
    var likes: Int
    var comments: Int
    var isLiked: Bool
    
    static func == (lhs: Video, rhs: Video) -> Bool {
        return lhs.id == rhs.id
    }
}
