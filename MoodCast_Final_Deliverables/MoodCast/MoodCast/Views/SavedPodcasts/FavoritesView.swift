//
//  FavoritesView.swift
//  MoodCast
//
//  Created by Jacob Lucas on 4/12/25.
//


import SwiftUI

//struct FavoritesView: View {
//    
//    @Binding var episodes: [EpisodeModel]
//    
//    @State var showScreen: Bool = false
//    @State private var showingDeleteMessage = false
//    @State private var episodeToDelete: IndexSet? = nil
//    
//    @Environment(\.dismiss) var dismiss
//
//    var body: some View {
//        ZStack {
//            Color(red: 38/255, green: 50/255, blue: 56/255)
//                .ignoresSafeArea()
//
//            VStack(alignment: .leading, spacing: 0) {
//                ZStack {
//                    Text("Favorites")
//                        .font(.title2)
//                        .fontWeight(.bold)
//                        .foregroundColor(.white)
//                    HStack(spacing: 95) {
//                        Button {
//                            dismiss()
//                        } label: {
//                            Image(systemName: "chevron.left")
//                                .font(.headline)
//                                .fontWeight(.bold)
//                                .foregroundStyle(.white)
//                        }
//                        .buttonStyle(ButtonScaleStyle())
//                        
//                        Spacer()
//                    }
//                }
//                .padding([.horizontal, .bottom])
//
//                List {
//                    ForEach(episodes, id: \.id) { episode in
//                        NavigationLink {
//                            PodcastView(episode: episode)
//                        } label: {
//                            HStack(spacing: 16) {
//                                if let image = episode.image {
//                                    Image(uiImage: image)
//                                        .resizable()
//                                        .frame(width: 60, height: 60)
//                                        .cornerRadius(8)
//                                } else {
//                                    RoundedRectangle(cornerRadius: 8)
//                                        .fill(Color.black)
//                                        .frame(width: 60, height: 60)
//                                }
//
//                                VStack(alignment: .leading, spacing: 4) {
//                                    if let name = episode.name {
//                                        Text(name)
//                                            .font(.headline)
//                                            .foregroundColor(.black)
//                                            .lineLimit(1)
//                                    }
//                                }
//
//                                Spacer()
//                            }
//                        }
//                        .buttonStyle(ButtonScaleStyle())
//                        .listRowBackground(Color.clear)
//                        .listStyle(PlainListStyle())
//                        .padding()
//                        .background(Color(red: 207/255, green: 230/255, blue: 233/255))
//                        .cornerRadius(16)
//                    }
//                    .onDelete { IndexSet in
//                        episodeToDelete = IndexSet
//                        showingDeleteMessage = true
//                    }
//                }
//                .listStyle(.plain)
//                .scrollContentBackground(.hidden)
//                .foregroundStyle(.black)
//                .background(Color(red: 38/255, green: 50/255, blue: 56/255))
//            }
//            .padding(.top)
//            .alert("Delete Episode?", isPresented: $showingDeleteMessage, actions:{
//                Button("Confirm", role: .destructive) {
//                    
//                    if let indexSet = episodeToDelete {
//                        if let index = indexSet.first {
//                            let episode = episodes[index]
//                            
//                            guard let eid = episode.episodeId else { return }
//                            episodes.remove(atOffsets: indexSet)
//                            let dataService = DataService.shared
//                            Task {
//                                do {
//                                    try await dataService.removeEpisode(episodeId: eid)
//                                } catch {
//                                    print("Failed to remove episode: \(error)")
//                                }
//                            }
//                        }
//                    }
//                }
//                Button("Cancel", role: .cancel) {
//                    episodeToDelete = nil
//                    
//                }
//            }, message: {
//                Text("This episode will be removed from favorites.")
//            })
//        }
//        .navigationBarBackButtonHidden()
//    }
//    
//    private func delete(at offsets: IndexSet) {
//        episodes.remove(atOffsets: offsets)
//    }
//}
//
