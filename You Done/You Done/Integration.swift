//
//  Integration.swift
//  You Done
//
//  Created by Piotr Galar on 08/12/2020.
//

import Foundation
import OAuth2
import SwiftyJSON
import SwiftUI

class IntegrationStore: ObservableObject {
    @Published var all: [Integration] = [
        GithubIntegration(),
        SlackIntegration()
    ]
    
    func all(forState state: Integration.State) -> [Integration] {
        all.filter { integration in integration.state == state }
    }
}

class Integration: OAuth2DataLoader, ObservableObject, Identifiable {
    let id = UUID()
    let name: String
    let baseURL: URL
    @Published var isAvailable: Bool
    @Published var isInstalled: Bool = false
    
    var state: State {
        isInstalled ? .installed : (
            isAvailable ? .available : .upcoming
        )
    }
    
    init(name: String,
         baseURI: String,
         authorizeURI: String,
         tokenURI: String,
         scopeList: [String] = [],
         secretInBody: Bool = false) {
        self.name = name
        self.baseURL = URL(string: baseURI)!
        
        let clientID: String? = Bundle.main.object(forInfoDictionaryKey: "\(name) Client ID") as? String
        let clientSecret: String? = Bundle.main.object(forInfoDictionaryKey: "\(name) Client Secret") as? String
        
        if let id = clientID, let secret = clientSecret {
            self.isAvailable = true
            super.init(oauth2: OAuth2CodeGrant(settings: [
                "client_id": id,
                "client_secret": secret ,
                "authorize_uri": authorizeURI,
                "token_uri": tokenURI,
                "scope": scopeList.joined(separator: " "),
                "redirect_uris": ["youdone://oauth2/\(name)"],
                "secret_in_body": secretInBody,
                "verbose": true,
                "keychain": true
            ]))
        } else {
            self.isAvailable = false
            super.init(oauth2: OAuth2CodeGrant(settings: [:]))
        }
        self.isInstalled = oauth2.clientConfig.accessToken != nil
    }
    
    enum State: String, CaseIterable {
        case installed = "Installed"
        case available = "Available"
        case upcoming = "Upcoming"
    }
    
    static let Notification = NSNotification.Name(rawValue: "OAuth2Notification")
    
    func request(forURL url: URL) -> URLRequest {
        oauth2.request(forURL: url)
    }
    
    func parseData(_ response: OAuth2Response) -> (Data?, Error?) {
        do {
            let data = try response.responseData()
            return (data, nil)
        } catch let error {
            return (nil, error)
        }
    }
    
    func parseSwiftyJSON(_ response: OAuth2Response) -> (JSON?, Error?) {
        do {
            let data = try response.responseData()
            let json = try JSON(data: data)
            return (json, nil)
        } catch let error {
            return (nil, error)
        }
    }
    
    func parseIdentity(_ response: OAuth2Response) -> OAuth2Response {
        return response
    }
    
    func parseJSONDecoder<T: Decodable>(_ type: T.Type) -> ((OAuth2Response) -> (T?, Error?)) {
        return { response in
            do {
                let data = try response.responseData()
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode(type, from: data)
                return (decodedData, nil)
            } catch let error {
                return (nil, error)
            }
        }
    }
    
    func request<DesiredResponse>(path: String,
                                  parse: @escaping ((OAuth2Response) -> DesiredResponse),
                                  callback: @escaping ((DesiredResponse) -> Void)) {
        let url = baseURL.appendingPathComponent(path)
        let req = request(forURL: url)
        
        perform(request: req) { response in
            DispatchQueue.main.async() {
                callback(parse(response))
            }
        }
    }
    
    func request(path: String, callback: @escaping ((OAuth2Response) -> Void)) {
        request(path: path, parse: parseIdentity, callback: callback)
    }
}

class GithubIntegration: Integration {
    init() {
        super.init(name: "GitHub",
                   baseURI: "https://api.github.com",
                   authorizeURI: "https://github.com/login/oauth/authorize",
                   tokenURI: "https://github.com/login/oauth/access_token",
                   scopeList: ["user", "repo"],
                   secretInBody: true)
    }
    
    override func request(forURL url: URL) -> URLRequest {
        var request = super.request(forURL: url)
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        return request
    }
    
    func user(callback: @escaping ((JSON?, Error?) -> Void)) {
        request(path: "user", parse: parseSwiftyJSON, callback: callback) // "name", "id", "login"
    }

    
    func events(date: Date = Date(), callback: @escaping (([Event]?, Error?) -> Void)) {
        let day = date.toDay()
        request(path: "users/gfjalar/events",
                parse: parseJSONDecoder([Event].self) >>> { eventListOpt, errorOpt in
                    if let eventList = eventListOpt {
                        let filteredEventList = eventList.filter { event in
                            event.toDate().toDay() == day && event.toString() != nil
                        }
                        return (filteredEventList, errorOpt)
                    } else {
                        return (eventListOpt, errorOpt)
                    }
                },
                callback: callback)
    }
    
    struct Event: Identifiable, Equatable, Codable {
        var id: String
        var type: String
        var created_at: String
        var payload: Payload
        
        struct Payload: Codable {
            var action: String?
            var pull_request: PullRequest?
            var review: Review?
            var commits: [Commit]?
        }

        struct PullRequest: Codable {
            var id: Int
            var title: String
        }
        
        struct Commit: Codable {
            var sha: String
            var message: String
        }
        
        struct Review: Codable {
            var state: String
        }
        
        func toString() -> String? {
            switch type {
            case "PullRequestEvent" where ["opened", "closed", "reopened"].contains(payload.action):
                return "\(payload.action!.capitalized) \(payload.pull_request!.title)"
            case "PullRequestReviewEvent" where ["created"].contains(payload.action):
                return "\(payload.review!.state.capitalized) \(payload.pull_request!.title)"
            case "PushEvent":
                return "Pushed \(payload.commits!.first!.message)"
            default:
                return nil
            }
        }
        
        func toDate() -> Date {
            return ISO8601DateFormatter().date(from: created_at)!
        }
        
        static func == (lhs: GithubIntegration.Event, rhs: GithubIntegration.Event) -> Bool {
            lhs.id == rhs.id
        }
    }
}

class ZoomIntegration: Integration {
    init() {
        super.init(name: "Zoom",
                   baseURI: "https://api.zoom.us/v2",
                   authorizeURI: "https://zoom.us/oauth/authorize",
                   tokenURI: "https://zoom.us/oauth/token")
    }
}

class SlackIntegration: Integration {
    init() {
        super.init(name: "Slack",
                   baseURI: "https://slack.com/api",
                   authorizeURI: "https://slack.com/oauth/v2/authorize",
                   tokenURI: "https://slack.com/api/oauth.v2.access",
                   secretInBody: true)
    }
}

class GoogleCalendarIntegration: Integration {
    init() {
        super.init(name: "Google Calendar",
                   baseURI: "https://www.googleapis.com",
                   authorizeURI: "https://accounts.google.com/o/oauth2/auth",
                   tokenURI: "https://www.googleapis.com/oauth2/v3/token",
                   scopeList: ["profile"])
    }
}
