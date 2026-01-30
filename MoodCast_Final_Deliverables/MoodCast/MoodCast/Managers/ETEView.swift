//
//  ETEView.swift
//  MoodCast
//
//  Created by Jacob Lucas on 4/13/25.
//

import SwiftUI
import MapKit

struct ETEView: View {
    
    @State private var route: MKRoute?
    @State private var userDestination = ""
    @State private var selectedDestination: MKMapItem?
    @State private var isLoading = false
    
    @StateObject private var locationManager = LocationManager()
    @StateObject private var searchCompleter = SearchCompleter()
    
    @Binding var showMapView: Bool
    @Binding var showEmojiSelection: Bool
    
    @Environment(\.colorScheme) var colorScheme
    
    private var hasRoute: Bool { route != nil }
    
    var body: some View {
        NavigationView {
            ZStack {
                MapView(route: $route)
                    .edgesIgnoringSafeArea(.all)
                searchBar
                rideDetails
            }
            .animation(
                .spring(response: 0.5, dampingFraction: 0.75),
                value: hasRoute
            )
            .onChange(of: userDestination) { _, query in
                if !query.isEmpty {
                    searchCompleter.completer.queryFragment = query
                } else {
                    searchCompleter.completions = []
                }
            }
            .onSubmit(of: .search) {
                performSearch()
            }
            .onChange(of: locationManager.location) { (_, _) in
                if selectedDestination != nil {
                    calculateRoute()
                }
            }
        }
        .onAppear {
            locationManager.requestLocation()
        }
        .onChange(of: userDestination) { (_, query) in
            searchCompleter.updateQuery(query)
        }
        .statusBarHidden()
    }
    
    private func performSearch() {
        isLoading = true
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = userDestination
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let item = response?.mapItems.first else {
                print("Search error: \(error?.localizedDescription ?? "Unknown error")")
                isLoading = false
                return
            }
            selectedDestination = item
            calculateRoute()
        }
    }
    
    private func calculateRoute() {
        guard let userLocation = locationManager.location,
              let destination = selectedDestination else {
            print("Missing location or destination")
            return
        }
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation.coordinate))
        request.destination = destination
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let route = response?.routes.first else {
                print("Route calculation error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            self.route = route
            isLoading = false
        }
    }
}

#Preview {
    ETEView(
        showMapView: .constant(false),
        showEmojiSelection: .constant(false)
    )
}

extension ETEView {
    private var searchBar: some View {
        VStack {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16))
                ZStack(alignment: .leading) {
                    if userDestination.isEmpty {
                        Text("Where are you going?")
                            .font(.system(size: 15))
                    }
                    
                    TextField("", text: $userDestination)
                        .submitLabel(.search)
                        .onChange(of: userDestination) { _, query in
                            searchCompleter.completer.queryFragment = query
                        }
                        .onSubmit {
                            performSearch()
                        }
                }
                Spacer(minLength: 0)
                if isLoading {
                    ProgressView()
                        .tint(Color(.label))
                }
            }
            .padding(12)
            .background(.ultraThinMaterial)
            .cornerRadius(30)
            .overlay {
                Capsule()
                    .stroke(lineWidth: 1)
                    .fill(.white.opacity(0.1))
            }
            .padding()
            
            Spacer()
        }
    }
    
    private var rideDetails: some View {
        VStack {
            if let route = route {
                let travelMinutes = Int(route.expectedTravelTime / 60)
                let arrivalDate = Date().addingTimeInterval(route.expectedTravelTime)
                Spacer()
                VStack {
                    Capsule()
                        .frame(width: 50, height: 5)
                        .padding(.bottom, 8)
                    
                    Button {
                        withAnimation { self.route = nil }
                        showMapView = false
                        showEmojiSelection = true
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(route.name)
                                    .font(.system(size: 20, weight: .semibold))
                                Text("Arrival: \(arrivalDate.formatted(.dateTime.hour().minute())) — \(travelMinutes) min")
                                    .font(.system(size: 14))
                            }
                            Spacer(minLength: 0)
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 25))
                        }
                        .padding()
                        .buttonStyle(ButtonScaleStyle())
                        .background {
                            if colorScheme == .light {
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundStyle(.white)
                                    .shadow(color: .black.opacity(0.08), radius: 5)
                            } else {
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundStyle(Color(.systemGray6))
                            }
                        }
                         .padding()
                         .padding(.bottom)
                    }
                }
                .padding(.vertical)
                .buttonStyle(ButtonScaleStyle())
                .background(.ultraThinMaterial)
                .cornerRadius(30)
            }
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .edgesIgnoringSafeArea(.bottom)
    }
}
