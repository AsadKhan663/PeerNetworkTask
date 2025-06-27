//
//  VideoUseCase.swift
//  Peer Network Task
//
//  Created by Asad Khan on 6/24/25.
//

protocol VideoUseCaseProtocol {
    func fetchVideos(page: Int) async throws -> [Video]
    func toggleLike(videoId: String) async throws -> Video
}

class VideoUseCase: VideoUseCaseProtocol {
    private let repository: VideoRepositoryProtocol
    
    init(repository: VideoRepositoryProtocol) {
        self.repository = repository
    }
    
    func fetchVideos(page: Int) async throws -> [Video] {
        try await repository.fetchVideos(page: page)
    }
    
    func toggleLike(videoId: String) async throws -> Video {
        try await repository.toggleLike(videoId: videoId)
    }
}
