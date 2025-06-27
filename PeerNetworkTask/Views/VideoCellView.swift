//
//  VideoCellView.swift
//  Peer Network Task
//
//  Created by Asad Khan on 6/25/25.
//

import SwiftUI

struct VideoCellView: View {
    let video: Video
    @Binding var isLiked: Bool
    @Binding var likes: Int
    @ObservedObject var viewModel: VideoFeedViewModel
    @State var showHeart = false
    @State var showRetryButton = false
    @State var cellVisibility: CGFloat = 0
    @State var showPlayPauseIcon = false
    @State var isVideoPlaying = false
    
    private var shouldPlay: Bool {
        cellVisibility >= 50 && viewModel.currentlyPlayingID == video.id
    }
    
    var body: some View {
        ZStack {
            // 1. Video Player Layer
            GeometryReader { geometry in
                VideoPlayerView(
                    videoURL: viewModel.isShortVersion ? video.shortVideoURL : video.fullVideoURL,
                    isPlaying: $isVideoPlaying,
                    showRetryButton: $showRetryButton,
                    isShortVersion: $viewModel.isShortVersion,
                    showPlayPauseIcon: $showPlayPauseIcon
                ).id(viewModel.isShortVersion)
                    .edgesIgnoringSafeArea(.all)
                    .frame(
                        width: UIScreen.main.bounds.width,
                        height: UIScreen.main.bounds.height
                    )
                    .background(
                        Color.clear
                            .preference(
                                key: VisibilityPreferenceKey.self,
                                value: calculateVisibility(geometry: geometry)
                            )
                    )
                    .onChange(of: shouldPlay) { _, newValue in
                        isVideoPlaying = newValue
                    }
            }
            .onPreferenceChange(VisibilityPreferenceKey.self) { visibility in
                cellVisibility = visibility
                viewModel.handleVideoVisibility(
                    videoID: video.id,
                    isVisible: visibility >= 50
                )
                isVideoPlaying = visibility >= 50 && viewModel.currentlyPlayingID == video.id
            }
            
            // 2. Retry Button
            if showRetryButton {
                VStack {
                    Button(AppStrings.Common.retry) {
                        showRetryButton = false
                        viewModel.currentlyPlayingID = video.id
                        isVideoPlaying = true
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
            
            // 3. UI Overlay
            VStack {
                // Header
                HStack {
                    AsyncImage(url: URL(string: video.creator.avatarURL)) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    
                    Text(video.creator.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button {
                        viewModel.isShortVersion = !viewModel.isShortVersion
                    } label: {
                        Image(systemName: viewModel.isShortVersion ? AppImages.fullVideoMode : AppImages.smallVideoMode)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                .padding(.top, safeAreaInsets().top)
                .padding(.horizontal)
                
                Spacer()
                
                // Action Buttons
                HStack {
                    Spacer()
                    VStack(spacing: 20) {
                        Button {
                            viewModel.toggleLike(for: video.id)
                            
                        } label: {
                            VStack {
                                Image(systemName: video.isLiked ? AppImages.heartFill : AppImages.heart)
                                    .foregroundColor(video.isLiked ? .red : .white)
                                    .font(.system(size: 30))
                                Text("\(video.likes)")
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Button {
                            // Comment action
                        } label: {
                            VStack {
                                Image(systemName: AppImages.comment)
                                    .foregroundColor(.white)
                                    .font(.system(size: 30))
                                Text("\(video.comments)")
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Button {
                            // Share action
                        } label: {
                            Image(systemName: AppImages.share)
                                .foregroundColor(.white)
                                .font(.system(size: 30))
                        }
                    }
                    .padding(.bottom, safeAreaInsets().bottom)
                    .padding()
                }
                
                // Description
                HStack {
                    Text(video.description)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding()
                    Spacer()
                }.padding()
            }
            
            // Heart Animation
            if showHeart {
                Image(systemName: AppImages.heartFill)
                    .font(.system(size: 100))
                    .foregroundColor(.white)
                    .opacity(showHeart ? 1 : 0)
                    .scaleEffect(showHeart ? 1.5 : 0.5)
                    .animation(.easeInOut(duration: 0.5), value: showHeart)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showHeart = false
                        }
                    }
            }
            
            // Play/Pause Icon
            if showPlayPauseIcon {
                Image(systemName: isVideoPlaying ? AppImages.pauseIcon : AppImages.playIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.white)
                    .opacity(showPlayPauseIcon ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: showPlayPauseIcon)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            showPlayPauseIcon = false
                        }
                    }
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .frame(
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.height
        )
        .onDisappear {
            if viewModel.currentlyPlayingID == video.id {
                viewModel.currentlyPlayingID = nil
                isVideoPlaying = false
            }
        }
        .onTapGesture(count: 2) {
            if !video.isLiked {
                showHeart = true
            }
            viewModel.toggleLike(for: video.id)
        }
        .onTapGesture(count: 1) {
            if viewModel.currentlyPlayingID == video.id {
                isVideoPlaying.toggle()
                showPlayPauseIcon = true
            }
        }
    }
    
    private func calculateVisibility(geometry: GeometryProxy) -> CGFloat {
        let frame = geometry.frame(in: .global)
        let visibleHeight = min(frame.maxY, UIScreen.main.bounds.height) - max(frame.minY, 0)
        return (visibleHeight / frame.height) * 100
    }
    
    private func safeAreaInsets() -> UIEdgeInsets {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return .zero
        }
        return window.safeAreaInsets
    }
}


// Helper for visibility tracking
private struct VisibilityPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
