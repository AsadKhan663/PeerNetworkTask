//
//  PeerNetworkTaskApp.swift
//  Peer Network Task
//
//  Created by Asad Khan on 6/23/25.
//

import SwiftUI

@main
struct PeerNetworkTaskApp: App {
    var body: some Scene {
        WindowGroup {
            VideoFeedView(viewModel: AppDependencies.makeVideoFeedViewModel())
        }
    }
}

class AppDependencies {
    @MainActor static func makeVideoFeedViewModel() -> VideoFeedViewModel {
        let dataSource = MockVideoDataSource()
        let repository = VideoRepository(dataSource: dataSource)
        let useCase = VideoUseCase(repository: repository)
        return VideoFeedViewModel(useCase: useCase)
    }
}
