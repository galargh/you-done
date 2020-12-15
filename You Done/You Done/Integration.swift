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
        SlackIntegration(),
        GoogleCalendarIntegration(),
        ZoomIntegration()
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
         secretInBody: Bool = false,
         host: String? = nil,
         redirectURIs: [String]? = nil) {
        self.name = name
        self.baseURL = URL(string: baseURI)!
        
        let clientID: String? = Bundle.main.object(forInfoDictionaryKey: "\(name) Client ID") as? String
        let clientSecret: String? = Bundle.main.object(forInfoDictionaryKey: "\(name) Client Secret") as? String
        
        if let id = clientID, let secret = clientSecret {
            self.isAvailable = true
            let oauth = OAuth2CodeGrant(settings: [
                "client_id": id,
                "client_secret": secret ,
                "authorize_uri": authorizeURI,
                "token_uri": tokenURI,
                "scope": scopeList.joined(separator: " "),
                "redirect_uris": redirectURIs ?? ["youdone://oauth2/\(name)"],
                "secret_in_body": secretInBody,
                "verbose": true,
                "keychain": true
            ])
            super.init(oauth2: oauth, host: host)
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

    func request(path: String) -> Future<OAuth2Response> {
        return Future { completion in
            let url = self.baseURL.appendingPathComponent(path)
            let req = self.request(forURL: url)
            self.perform(request: req) { response in
                completion(.success(response))
            }
        }
    }
    
    func pull(date: Date = Date()) -> Future<[Task]> {
        return Future { completion in
            completion(.success([]))
        }
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
    
    func user() -> Future<User> {
        return request(path: "user").map { response in
            let data = try response.responseData()
            let decoder = JSONDecoder()
            return try decoder.decode(User.self, from: data)
        }
    }
    
    struct User: Codable {
        var name: String
        var id: Int
        var login: String
    }

    
    func events(date: Date = Date()) -> Future<[Event]> {
        return user().flatMap { user in
            return self.request(path: "users/\(user.login)/events").map { response -> [Event] in
                let data = try response.responseData()
                let decoder = JSONDecoder()
                //print(JSON(data))
                return try decoder.decode([Event].self, from: data)
            }
        }.map { eventList in
            let day = date.toDay()
            return eventList.filter { event in
                event.toDate().toDay() == day && event.toString() != nil
            }
        }
    }
    
    override func pull(date: Date = Date()) -> Future<[Task]> {
        return events(date: date).map { eventList in
            return eventList.map { event in
                let text = event.toString()!
                return Task(id: text, text: text)
            }
        }
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
                return "Pushed \(payload.commits!.last!.message)"
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
                   tokenURI: "https://oauth2.googleapis.com/token",
                   scopeList: [
                    "https://www.googleapis.com/auth/calendar.readonly",
                    "https://www.googleapis.com/auth/calendar.events.readonly"
                   ],
                   host: "https://www.googleapis.com",
                   redirectURIs: ["urn:ietf:wg:oauth:2.0:oob"])
        self.alsoIntercept403 = true
    }
}
