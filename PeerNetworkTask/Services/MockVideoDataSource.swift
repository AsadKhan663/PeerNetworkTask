//
//  MockVideoDataSource.swift
//  Peer Network Task
//
//  Created by Asad Khan on 6/24/25.
//

import Foundation

protocol VideoDataSourceProtocol {
    func fetchVideos(page: Int) async throws -> [Video]
    func toggleLike(videoId: String) async throws -> Video
}

class MockVideoDataSource: VideoDataSourceProtocol {
    private let pageSize = 20
    private var allVideos: [Video] = []
    private var requestCount = 0
    
    init() {
        loadVideosFromJSON()
    }
    
    func fetchVideos(page: Int) async throws -> [Video] {
        
        try await Task.sleep(for: .seconds(1))
        
        requestCount += 1
        
        // Simulate error every 3rd request
        if requestCount % 3 == 0 {
            throw NetworkError.requestFailed
        }
        
        // Return paginated results
        let startIndex = page * pageSize
        guard startIndex < allVideos.count else { return [] }
        
        let endIndex = min(startIndex + pageSize, allVideos.count)
        return Array(allVideos[startIndex..<endIndex])
    }
    
    func toggleLike(videoId: String) async throws -> Video {
        guard let index = allVideos.firstIndex(where: { $0.id == videoId }) else {
            throw NetworkError.videoNotFound
        }
        
        allVideos[index].isLiked.toggle()
        allVideos[index].likes += allVideos[index].isLiked ? 1 : -1
        
        return allVideos[index]
    }
    
    private func loadVideosFromJSON() {
        guard let url = Bundle.main.url(forResource: "videos", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load videos.json")
        }
        
        do {
            allVideos = try JSONDecoder().decode([Video].self, from: data)
        } catch {
            fatalError("Failed to decode videos.json: \(error)")
        }
    }
}

enum NetworkError: Error {
    case requestFailed
    case videoNotFound
}
