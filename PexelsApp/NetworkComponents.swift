//
//  NetworkComponents.swift
//  PexelsApp
//
//  Created by Daniel Bell on 5/1/22.
//

import Foundation
//API Documentation:
//https://www.pexels.com/api/documentation/
//
struct PexelsURLBuilder {
    enum Path: String {
        case search = "/v1/search"
        case curated = "/v1/curated"
    }

    let scheme = "https"
    let host = "api.pexels.com"
    let path: Path

    var urlComponents = URLComponents()
    var url: URL? {
        urlComponents.url
    }

    init(path: Path, pageResults: Int? = nil, additionalQuery queryitems: [URLQueryItem]? = nil) {
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = path.rawValue
        self.path = path

        var baseQueryItems = [URLQueryItem]()

        if let pageValue = pageResults {
            let perpageItem = URLQueryItem(name: "per_page", value: "30")
            baseQueryItems.append(perpageItem)
            let pageItem = URLQueryItem(name: "page", value: "\(pageValue)")
            baseQueryItems.append(pageItem)
        }

        if let queryitems = queryitems {
            baseQueryItems.append(contentsOf: queryitems)
        }

        urlComponents.queryItems = baseQueryItems
    }
}

struct PexelsCuratedImages {
    enum SearchError: Error {
        case dataIsInFlight
    }

    var page = 0
    static var maxPage = 1
    static var inFlight = false
    var photos: [PexelsPhoto]?

    func nextResults() async throws -> PexelsCuratedImages {
        //API Documentation:
        //https://www.pexels.com/api/documentation/
        //

        guard !Self.inFlight else { throw SearchError.dataIsInFlight }

        guard let url = PexelsURLBuilder(path: .curated, pageResults: page).url, page <= Self.maxPage else {
            var result = PexelsCuratedImages()
            result.page = page
            return result
        }

        do {
            Self.inFlight = true
            let queryResult: PexelsPhotoQuery = try await PexelsNetworkRequstor.shared.data(for: url)
            Self.maxPage = queryResult.totalResults/queryResult.perPage
            var result = PexelsCuratedImages()
            result.page = page + 1
            if queryResult.page <= result.page {
                Self.inFlight = false
            }
            result.photos = queryResult.photos
            return result
        } catch {
            var result = PexelsCuratedImages()
            result.page = page
            return result
        }
    }
}

class PexelsImageSearch {
    enum SearchError: Error {
        case dataIsInFlight
    }

    let query: String
    var page = 0
    var maxPage = 1
    var inFlight = false

    private let whitespaceCharacterSet = CharacterSet.whitespaces

    init?(query: String) {

        let strippedString = query.trimmingCharacters(in: whitespaceCharacterSet)
        let searchItems = strippedString.components(separatedBy: " ").filter { !$0.isEmpty }
        let queryParsed = searchItems.joined(separator: " ")
        guard !searchItems.isEmpty else {
            return nil
        }
        self.query = queryParsed
    }

    func nextResults() async throws -> [PexelsPhoto] {
        //API Documentation:
        //https://www.pexels.com/api/documentation/
        //

        guard page <= maxPage else { return [] }
        guard !inFlight else { throw SearchError.dataIsInFlight }
        let queryItem = URLQueryItem(name: "query", value: query)
        let urlBuilder = PexelsURLBuilder(path: .search, pageResults: page, additionalQuery: [queryItem])
        guard let url = urlBuilder.url else { return [] }

        do {
            inFlight = true
            let queryResult: PexelsPhotoQuery = try await PexelsNetworkRequstor.shared.data(for: url)
            maxPage = queryResult.totalResults/queryResult.perPage
            page += 1
            if queryResult.page <= page {
                inFlight = false
            }
            return queryResult.photos
        } catch {
            return []
        }
    }
}

struct PexelsNetworkRequstor {
    static var shared: PexelsNetworkRequstor = PexelsNetworkRequstor()
    var urlSession: URLSession
    private init() {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = false
        urlSession = URLSession(configuration: config, delegate: nil, delegateQueue: nil)
    }
    public func data<T: Decodable>(for url:URL) async throws -> T {
        print(url.absoluteString)
        var request = URLRequest(url: url)
        request.addValue("APIKEY", forHTTPHeaderField: "Authorization")
        let (data, _) = try await urlSession.data(for: request, delegate: nil)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
