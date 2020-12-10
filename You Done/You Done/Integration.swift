//
//  Integration.swift
//  You Done
//
//  Created by Piotr Galar on 08/12/2020.
//

import Foundation
import OAuth2

class Integration: Identifiable {
    let id = UUID()
    let name: String
    let authorizeURI: String
    let tokenURI: String
    let scopeList: [String]
    let secretInBody: Bool
    
    lazy var clientID: String? = Bundle.main.object(forInfoDictionaryKey: "\(name) Client ID") as? String
    lazy var clientSecret: String? = Bundle.main.object(forInfoDictionaryKey: "\(name) Client Secret") as? String
    lazy var oauth2: OAuth2CodeGrant? = {
        if let id = clientID, let secret = clientSecret {
            return OAuth2CodeGrant(settings: [
                "client_id": id,
                "client_secret": secret,
                "authorize_uri": authorizeURI,
                "token_uri": tokenURI,
                "scope": scopeList.joined(separator: " "),
                "redirect_uris": ["youdone://oauth2/\(name)"],
                "secret_in_body": secretInBody,
                "verbose": true,
                "keychain": false
            ])
        } else {
            return nil
        }
    }()
    
    var state: State {
        clientID == nil || clientSecret == nil ? .upcoming : .available
    }
    
    init(name: String,
         authorizeURI: String,
         tokenURI: String,
         scopeList: [String] = [],
         secretInBody: Bool = false) {
        self.name = name
        self.authorizeURI = authorizeURI
        self.tokenURI = tokenURI
        self.scopeList = scopeList
        self.secretInBody = secretInBody
    }
    
    enum State: String, CaseIterable {
        case installed = "Installed"
        case available = "Available"
        case upcoming = "Upcoming"
    }
}

class GithubIntegration: Integration {
    init() {
        super.init(name: "GitHub",
                   authorizeURI: "https://github.com/login/oauth/authorize",
                   tokenURI: "https://github.com/login/oauth/access_token",
                   scopeList: ["user", "repo"],
                   secretInBody: true)
    }
}

class ZoomIntegration: Integration {
    init() {
        super.init(name: "Zoom",
                   authorizeURI: "https://zoom.us/oauth/authorize",
                   tokenURI: "https://zoom.us/oauth/token")
    }
}

class SlackIntegration: Integration {
    init() {
        super.init(name: "Slack",
                   authorizeURI: "https://slack.com/oauth/v2/authorize",
                   tokenURI: "https://slack.com/api/oauth.v2.access",
                   secretInBody: true)
    }
}

class GoogleCalendarIntegration: Integration {
    init() {
        super.init(name: "Google Calendar",
                   authorizeURI: "https://accounts.google.com/o/oauth2/auth",
                   tokenURI: "https://www.googleapis.com/oauth2/v3/token",
                   scopeList: ["profile"])
    }
}
