//
//  VideoRepository.swift
//  Peer Network Task
//
//  Created by Asad Khan on 6/24/25.
//

protocol VideoRepositoryProtocol {
    func fetchVideos(page: Int) async throws -> [Video]
    func toggleLike(videoId: String) async throws -> Video
}

class VideoRepository: VideoRepositoryProtocol {
    private let dataSource: VideoDataSourceProtocol
    
    init(dataSource: VideoDataSourceProtocol) {
        self.dataSource = dataSource
    }
    
    func fetchVideos(page: Int) async throws -> [Video] {
        try await dataSource.fetchVideos(page: page)
    }
    
    func toggleLike(videoId: String) async throws -> Video {
        try await dataSource.toggleLike(videoId: videoId)
    }
}
