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

class EventConfiguration: ObservableObject {
    var name: String
    var field: String
    @Published var pattern: String
    @Published var template: String
    
    init(name: String, field: String, pattern: String, template: String) {
        self.name = name
        self.field = field
        self.pattern = UserDefaults.standard.string(forKey: "Pattern: \(name)") ?? pattern
        self.template = UserDefaults.standard.string(forKey: "Template: \(name)") ?? template
    }
    
    func validate() throws {
        try NSRegularExpression(pattern: pattern)
        let groupsInPattern = try pattern.matches(of: NSRegularExpression.forGroupInPattern.pattern).map { match in
            String(pattern[Range(match.range(at: 1), in: pattern)!])
        }
        let groupsInTemplate = try template.matches(of: NSRegularExpression.forGroupInTemplate.pattern).map { match in
            var group = String(template[Range(match.range(at: 1), in: template)!])
            group.removeAll(where: { ["{", "}"].contains($0) })
            return group
        }.filter { Int($0) == nil }
        let diff = Set(groupsInTemplate).subtracting(Set(groupsInPattern))
        if (!diff.isEmpty) {
            throw NSError(domain: NSCocoaErrorDomain, code: NSFormattingError, userInfo: ["NSInvalidValue": template])
        }
        
    }
    
    func commit() {
        UserDefaults.standard.setValue(pattern, forKey: "Pattern: \(name)")
        UserDefaults.standard.setValue(template, forKey: "Template: \(name)")
    }
    
    func parse(_ string: String) throws -> String? {
        return try string.firstMatch(of: pattern, as: template)
    }
}

class Integration: OAuth2DataLoader, ObservableObject, Identifiable {
    let id = UUID()
    let name: String
    let baseURL: URL
    var eventConfigurationList: [EventConfiguration] = []
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
        self.isInstalled = oauth2.clientConfig.accessToken != nil || oauth2.clientConfig.refreshToken != nil
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

    func request(path: String, parameters: [String:String] = [:]) -> Future<OAuth2Response> {
        return Future { completion in
            let url = self.baseURL.appendingPathComponent(path)
            var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            urlComponents.queryItems = parameters.map { name, value in
                URLQueryItem(name: name, value: value)
            }
            let req = self.request(forURL: urlComponents.url!)
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
    static let OpenedPR = EventConfiguration(name: "Opened PR", field: "title", pattern: "(?<title>.*)", template: "Opened $title")
    static let ClosedPR = EventConfiguration(name: "Closed PR", field: "title", pattern: "(?<title>.*)", template: "Closed $title")
    static let ApprovedPR = EventConfiguration(name: "Approved PR", field: "title", pattern: "(?<title>.*)", template: "Approved $title")
    static let DiscussedPR = EventConfiguration(name: "Discussed PR", field: "title", pattern: "(?<title>.*)", template: "Discussed $title")
    static let RejectedPR = EventConfiguration(name: "Rejected PR", field: "title", pattern: "(?<title>.*)", template: "Requested changes from $title")
    // THIS DOESN'T WORK!
    static let PushedCommit = EventConfiguration(name: "Pushed Commit", field: "message", pattern: "Merge pull request (?<pr_info>.*)", template: "Merged $pr_info")
    
    init() {
        super.init(name: "GitHub",
                   baseURI: "https://api.github.com",
                   authorizeURI: "https://github.com/login/oauth/authorize",
                   tokenURI: "https://github.com/login/oauth/access_token",
                   scopeList: ["user", "repo"],
                   secretInBody: true)
        self.eventConfigurationList = [GithubIntegration.OpenedPR, GithubIntegration.ClosedPR, GithubIntegration.ApprovedPR, GithubIntegration.DiscussedPR, GithubIntegration.RejectedPR, GithubIntegration.PushedCommit]
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
            return(1...10).map { page in
                return self.request(path: "users/\(user.login)/events", parameters: ["page": "\(page)"]).map { response -> [Event] in
                    let data = try response.responseData()
                    let decoder = JSONDecoder()
                    return try decoder.decode([Event].self, from: data)
                }
            }.flatten().map { $0.reduce([], +) }
        }.map { eventList in
            let day = date.toDay()
            return try eventList.filter { event in
                try event.toDate().toDay() == day && event.toString() != nil
            }
        }
    }
    
    override func pull(date: Date = Date()) -> Future<[Task]> {
        return events(date: date).map { eventList in
            return try eventList.map { event in
                return try Task(id: event.toID(), text: event.toString()!)
            }
        }
    }
    
    struct Event: Codable {
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
        
        func toString() throws -> String? {
            switch type {
            case "PullRequestEvent" where payload.action == "opened":
                return try GithubIntegration.OpenedPR.parse(payload.pull_request!.title)
            case "PullRequestEvent" where payload.action == "closed":
                return try GithubIntegration.ClosedPR.parse(payload.pull_request!.title)
            case "PullRequestReviewEvent" where payload.action == "created" && payload.review!.state == "approved":
                return try GithubIntegration.ApprovedPR.parse(payload.pull_request!.title)
            case "PullRequestReviewEvent" where payload.action == "created" && payload.review!.state == "commented":
                return try GithubIntegration.DiscussedPR.parse(payload.pull_request!.title)
            case "PullRequestReviewEvent" where payload.action == "created" && payload.review!.state == "changes_requested":
                return try GithubIntegration.RejectedPR.parse(payload.pull_request!.title)
            case "PushEvent":
                return try GithubIntegration.PushedCommit.parse(payload.commits!.last!.message)
            default:
                return nil
            }
        }

        func toID() -> String {
            switch type {
            case "PullRequestEvent":
                return "\(payload.action!.capitalized)\(type)(\(payload.pull_request!.id)"
            case "PullRequestReviewEvent":
                let state = payload.review!.state.split(separator: "_").map { $0.capitalized }.joined(separator: "")
                return "\(state)\(type)(\(payload.pull_request!.id)"
            case "PushEvent":
                return "\(type)(\(id))"
            default:
                return id
            }
        }
        
        func toDate() -> Date {
            return ISO8601DateFormatter().date(from: created_at)!
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
    private var email: String?
    
    static let CreatedEvent = EventConfiguration(name: "Created Event", field: "summary", pattern: "(?<summary>.*)", template: "Attended $summary event as a creator")
    static let OrganizedEvent = EventConfiguration(name: "Organized Event", field: "summary", pattern: "(?<summary>.*)", template: "Attended $summary event as an organiser")
    static let AttendedEvent = EventConfiguration(name: "Attended Event", field: "summary", pattern: "(?<summary>.*)", template: "Attended $summary event")

    
    init() {
        super.init(name: "Google Calendar",
                   baseURI: "https://www.googleapis.com",
                   authorizeURI: "https://accounts.google.com/o/oauth2/auth",
                   tokenURI: "https://oauth2.googleapis.com/token",
                   scopeList: [
                    "https://www.googleapis.com/auth/calendar.readonly",
                    "https://www.googleapis.com/auth/userinfo.email"
                   ],
                   host: "https://www.googleapis.com",
                   redirectURIs: ["urn:ietf:wg:oauth:2.0:oob"])
        self.alsoIntercept403 = true
        self.eventConfigurationList = [GoogleCalendarIntegration.CreatedEvent, GoogleCalendarIntegration.OrganizedEvent, GoogleCalendarIntegration.AttendedEvent]
    }
    
    func user() -> Future<User> {
        return request(path: "oauth2/v1/userinfo").map { response in
            let data = try response.responseData()
            let decoder = JSONDecoder()
            return try decoder.decode(User.self, from: data)
        }
    }
    
    func calendarList() -> Future<CalendarList> {
        /*return request(path: "calendar/v3/users/me/calendarList").map { response in
            let data = try response.responseData()
            let decoder = JSONDecoder()
            return try decoder.decode(CalendarList.self, from: data)
        }*/
        return Future { completion in completion(.success(CalendarList(items: [CalendarListEntry(id: "primary")]))) }
    }
    
    struct CalendarList: Codable {
        var items: [CalendarListEntry]
    }
    
    struct CalendarListEntry: Codable {
        var id: String
    }
    
    func events(date: Date = Date()) -> Future<[Event]> {
        return user().flatMap { user -> Future<CalendarList> in
            self.email = user.email
            return self.calendarList()
        }.flatMap { calendarList in
            return calendarList.items.map { calendarListEntry in
                return self.request(
                    path: "calendar/v3/calendars/\(calendarListEntry.id)/events",
                    parameters: [
                        "singleEvents": "true",
                        "orderBy": "startTime",
                        "timeMin": ISO8601DateFormatter().string(from: date.toDay()),
                        "timeMax": ISO8601DateFormatter().string(from: date)
                    ]
                ).map { response -> Events in
                    let data = try response.responseData()
                    let decoder = JSONDecoder()
                    return try decoder.decode(Events.self, from: data)
                }
            }.flatten().map { $0.map { $0.items } }.map { $0.reduce([], +) }
        }.map { eventList in
            return try eventList.filter { event in
                try event.toString(email: self.email!) != nil
            }
        }
    }
    
    override func pull(date: Date = Date()) -> Future<[Task]> {
        return events(date: date).map { eventList in
            return try eventList.map { event in
                let text = try event.toString(email: self.email!)!
                return Task(id: text, text: text)
            }
        }
    }
    
    struct Events: Codable {
        var items: [Event]
    }
    
    struct Event: Codable {
        var id: String
        var status: String
        var summary: String
        var creator: User
        var organizer: User
        var attendees: [Attendee]?
        
        func toString(email: String) throws -> String? {
            if creator.email == email {
                return try GoogleCalendarIntegration.CreatedEvent.parse(summary)
            } else if organizer.email == email {
                return try GoogleCalendarIntegration.OrganizedEvent.parse(summary)
            } else if (attendees?.contains { attendee in attendee.email == email && attendee.responseStatus == "accepted" } ?? false) {
                return try GoogleCalendarIntegration.AttendedEvent.parse(summary)
            } else {
                return nil
            }
        }
    }
    
    struct User: Codable {
        var email: String
    }
    
    struct Attendee: Codable {
        var email: String
        var responseStatus: String
    }
}
