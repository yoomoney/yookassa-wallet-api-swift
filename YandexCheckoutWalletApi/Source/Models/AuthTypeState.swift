/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2017 NBCO Yandex.Money LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

/// Output format description of user authorization status
public struct AuthTypeState: Decodable, Encodable {

    /// Specific description by type of authorization
    public let specific: Specific

    /// Description of the active session.
    /// - note: `nil` - if no active session.
    public let activeSession: ActiveSession?

    /// Whether it is possible to produce the type of authorization
    public let canBeIssued: Bool

    /// A sign that the type of authorization available to the user
    public let enabled: Bool

    /// A sign that for authentication type requires creation of a session
    public let isSessionRequired: Bool

    public init(specific: Specific,
                activeSession: ActiveSession?,
                canBeIssued: Bool,
                enabled: Bool,
                isSessionRequired: Bool) {
        self.specific = specific
        self.activeSession = activeSession
        self.canBeIssued = canBeIssued
        self.enabled = enabled
        self.isSessionRequired = isSessionRequired
    }

    // MARK: - Decodable

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let specific = try Specific(from: decoder)
        let hasActiveSession = try container.decode(Bool.self, forKey: .hasActiveSession)
        let canBeIssued = try container.decode(Bool.self, forKey: .canBeIssued)
        let enabled = try container.decode(Bool.self, forKey: .enabled)
        let isSessionRequired = try container.decode(Bool.self, forKey: .isSessionRequired)

        let activeSession: ActiveSession?

        if hasActiveSession {
            activeSession = try ActiveSession(from: decoder)
        } else {
            activeSession = nil
        }

        self.init(specific: specific,
                  activeSession: activeSession,
                  canBeIssued: canBeIssued,
                  enabled: enabled,
                  isSessionRequired: isSessionRequired)
    }

    // MARK: - Encodable

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try specific.encode(to: encoder)

        try container.encode(activeSession != nil, forKey: .hasActiveSession)
        if let activeSession = activeSession {
            try activeSession.encode(to: encoder)
        }

        try container.encode(canBeIssued, forKey: .canBeIssued)
        try container.encode(enabled, forKey: .enabled)
        try container.encode(isSessionRequired, forKey: .isSessionRequired)
    }

    private enum CodingKeys: String, CodingKey {
        case canBeIssued
        case enabled
        case hasActiveSession
        case isSessionRequired
    }

    // MARK: - Support structures

    /// Description of the active session
    public struct ActiveSession: Decodable, Encodable {

        /// The total number of attempts
        public let attemptsCount: Int

        /// The remaining number of code entry attempts
        public let attemptsLeft: Int

        public init(attemptsCount: Int, attemptsLeft: Int) {
            self.attemptsCount = attemptsCount
            self.attemptsLeft = attemptsLeft
        }
    }

    /// Specific description by type of authorization
public enum Specific: Decodable, Encodable {

        /// By sms
        case sms(SmsDescription?)

        /// By time one token password
        case totp(TotpDescription?)

        /// By secure password
        case securePassword

        /// By emergency code
        case emergency(EmergencyDescription?)

        /// By push notification
        case push(PushDescription?)

        /// By OAuth token
        case oauthToken

        /// The authorization type
        public var type: AuthType {
            switch self {
            case .sms:
                return .sms
            case .totp:
                return .totp
            case .securePassword:
                return .securePassword
            case .emergency:
                return .emergency
            case .push:
                return .push
            case .oauthToken:
                return .oauthToken
            }
        }

        // MARK: - Decodable

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            let type = try container.decode(AuthType.self, forKey: .type)
            switch type {
            case .sms:
                let smsDescription: SmsDescription?
                do {
                    smsDescription = try SmsDescription(from: decoder)
                } catch {
                    smsDescription = nil
                }
                self = .sms(smsDescription)
            case .totp:
                let totpDescription: TotpDescription?
                do {
                    totpDescription = try TotpDescription(from: decoder)
                } catch {
                    totpDescription = nil
                }
                self = .totp(totpDescription)
            case .securePassword:
                self = .securePassword
            case .emergency:
                let emergencyDescription: EmergencyDescription?
                do {
                    emergencyDescription = try EmergencyDescription(from: decoder)
                } catch {
                    emergencyDescription = nil
                }
                self = .emergency(emergencyDescription)
            case .push:
                let pushDescription: PushDescription?
                do {
                    pushDescription = try PushDescription(from: decoder)
                } catch {
                    pushDescription = nil
                }
                self = .push(pushDescription)
            case .oauthToken:
                self = .oauthToken
            }
        }

        // MARK: - Encodable

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(type, forKey: .type)
            switch self {
            case .sms(let smsDescription):
                try smsDescription?.encode(to: encoder)
            case .totp(let totpDescription):
                try totpDescription?.encode(to: encoder)
            case .securePassword:
                break
            case .emergency(let emergencyDescription):
                try emergencyDescription?.encode(to: encoder)
            case .push(let pushDescription):
                try pushDescription?.encode(to: encoder)
            case .oauthToken:
                break
            }
        }

        private enum CodingKeys: String, CodingKey {
            case type
        }
    }
}

// MARK: - Authorization description structures
extension AuthTypeState.Specific {

    /// Description of authorization by sms
    public struct SmsDescription: Encodable, Decodable {

        /// The number of code symbols that must be entered by the user
        public let codeLength: Int

        /// The remaining number of sessions
        public let sessionsLeft: Int

        /// The remaining number of seconds before the expiration of the lifetime of the session.
        public let sessionTimeLeft: Int?

        /// The remaining number of seconds before the opportunity to create a new session.
        public let nextSessionTimeLeft: Int?

        public init(codeLength: Int,
                    sessionsLeft: Int,
                    sessionTimeLeft: Int?,
                    nextSessionTimeLeft: Int?) {
            self.codeLength = codeLength
            self.sessionsLeft = sessionsLeft
            self.sessionTimeLeft = sessionTimeLeft
            self.nextSessionTimeLeft = nextSessionTimeLeft
        }
    }

    /// Description of authorization by push notification
    public struct PushDescription: Decodable, Encodable {

        /// The remaining number of seconds before the expiration of the lifetime of the session.
        public let sessionTimeLeft: Int?
    }

    /// Description of authorization by emergency code
    public struct EmergencyDescription: Decodable, Encodable {

        /// The remaining number of emergency codes
        public let codesLeft: Int

        public let codeLength: Int

        public init(codesLeft: Int, codeLength: Int) {
            self.codesLeft = codesLeft
            self.codeLength = codeLength
        }
    }

    /// Description of authorization by totp code
    public struct TotpDescription: Decodable, Encodable {

        /// The number of code symbols that must be entered by the user
        public let codeLength: Int

        public init(codeLength: Int) {
            self.codeLength = codeLength
        }
    }
}
