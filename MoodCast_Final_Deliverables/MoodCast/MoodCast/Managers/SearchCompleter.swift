//
//  SearchCompleter.swift
//  MoodCast
//
//  Created by Jacob Lucas on 4/13/25.
//

import MapKit
import Combine

class SearchCompleter: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    let completer = MKLocalSearchCompleter()
    @Published var completions: [MKLocalSearchCompletion] = []
    private var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()
        completer.delegate = self
    }

    func updateQuery(_ query: String) {
        if query.trimmingCharacters(in: .whitespaces).isEmpty {
            completions = []
            return
        }
        Publishers.CombineLatest(
            Just(query),
            $completions
        )
        .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
        .sink { query, _ in
            self.completer.queryFragment = query
        }
        .store(in: &cancellables)
    }
}
