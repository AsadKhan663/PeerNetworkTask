//
//  VideoFeedViewModel.swift
//  Peer Network Task
//
//  Created by Asad Khan on 6/24/25.
//

import Foundation

@MainActor
class VideoFeedViewModel: ObservableObject {
    @Published var videos: [Video] = []
    @Published var isLoading = false
    @Published var showError = false
    
    @Published var isShortVersion = true
    
    private let useCase: VideoUseCaseProtocol
    private var currentPage = 0
    
    @Published var currentlyPlayingID: String? = nil
    
    init(useCase: VideoUseCaseProtocol) {
        self.useCase = useCase
    }
    
    
    func handleVideoVisibility(videoID: String, isVisible: Bool) {
        if isVisible {
            currentlyPlayingID = videoID
        } else if currentlyPlayingID == videoID {
            currentlyPlayingID = nil
        }
    }
    
    func fetchVideos() async {
        guard !isLoading else { return }
        
        isLoading = true
        showError = false
        
        do {
            let newVideos = try await useCase.fetchVideos(page: currentPage)
            videos.append(contentsOf: newVideos)
            currentPage += 1
        } catch {
            showError = true
        }
        
        isLoading = false
    }
    
    func loadMoreContentIfNeeded(currentItem item: Video) {
        let thresholdIndex = videos.index(videos.endIndex, offsetBy: -5)
        if videos.firstIndex(where: { $0.id == item.id }) == thresholdIndex {
            Task { await fetchVideos() }
        }
    }
    
    func retryLoading() {
        Task { await fetchVideos() }
    }
    
    func toggleLike(for videoId: String) {
        if let index = videos.firstIndex(where: { $0.id == videoId }) {
            var updatedVideo = videos[index]
            updatedVideo.isLiked.toggle()
            updatedVideo.likes += updatedVideo.isLiked ? 1 : -1
            videos[index] = updatedVideo
        }
    }
}
