//
//  VideoFeedView.swift
//  Peer Network Task
//
//  Created by Asad Khan on 6/25/25.
//

import SwiftUI

struct VideoFeedView: View {
    @StateObject var viewModel: VideoFeedViewModel
    
    var body: some View {
        ZStack {
            if viewModel.videos.isEmpty && !viewModel.isLoading {
                Text(AppStrings.Common.noVideosAvailable)
                    .font(.title)
                    .foregroundColor(.gray)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(viewModel.videos.enumerated()), id: \.element.id) { index, video in
                            VideoCellView(video: video, isLiked: $viewModel.videos[index].isLiked,
                                          likes: $viewModel.videos[index].likes, viewModel: viewModel)
                            .frame(height: UIScreen.main.bounds.height)
                            .id(video.id)
                            .onAppear {
                                viewModel.loadMoreContentIfNeeded(currentItem: video)
                            }
                        }
                        
                        if viewModel.isLoading {
                            ProgressView()
                                .padding()
                        }
                    }.scrollTargetLayout()
                }.scrollTargetBehavior(.paging)
                    .ignoresSafeArea(edges: .all)
            }
            
            if viewModel.showError {
                VStack {
                    Text(AppStrings.Common.errorLoadingVideos)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(8)
                    
                    Button(AppStrings.Common.retry) {
                        viewModel.retryLoading()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
        }
        .task {
            await viewModel.fetchVideos()
        }
    }
}
