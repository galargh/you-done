//
//  Integration.swift
//  You Done
//
//  Created by Piotr Galar on 08/12/2020.
//

import Foundation
import OAuth2

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
    
    func request(path: String, callback: @escaping ((OAuth2JSON?, Error?) -> Void)) {
        let url = baseURL.appendingPathComponent(path)
        let req = request(forURL: url)
        
        perform(request: req) { response in
            do {
                let dict = try response.responseJSON()
                DispatchQueue.main.async() {
                    callback(dict, nil)
                }
            }
            catch let error {
                DispatchQueue.main.async() {
                    callback(nil, error)
                }
            }
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
