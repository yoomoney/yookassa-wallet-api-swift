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

import Foundation
import YandexMoneyCoreApi

/// Wallet-Auth API response error
public enum WalletAuthApiError: WalletErrorApiResponse, JsonApiResponse, Decodable, Encodable {

    // MARK: - 400: The query with the specified parameters cannot be performed.

    /// The broken syntax of the query, the query cannot be parsed.
    case syntaxError

    /// Part of the request parameters is missing or has an invalid value.
    /// - Parameter _: The list of names that contain invalid values.
    case illegalParameters([String])

    /// Part of HTTP request headers is missing or has an invalid value.
    /// - Parameter _: The list of names that contain invalid values.
    case illegalHeaders([String])

    // MARK: - 401: Error client authentication or verification of the sufficiency of the authorization request.

    /// Missing or invalid Basic-authorization headers.
    case invalidCredentials

    /// Missing or invalid OAuth2 authorization wallet.
    case invalidToken

    /// Missing or invalid electronic signature request.
    case invalidSignature

    // MARK: - 403: The client requested an operation which is not allowed.

    /// Specified authorization of the wallet does not have sufficient rights for performing this operation.
    case invalidScope

    /// Requested operation forbidden
    case forbidden

    // MARK: - 500: Technical error.

    /// Technical error. The result of the query is unknown.
    /// - note: The client should repeat the request with the same arguments after the recommended retry time.
    case technicalError

    /// Service temporary unavailable.
    case serviceUnavailable

    // MARK: - Decodable

    // swiftlint:disable cyclomatic_complexity
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let errorContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .error)
        let errorCode = try errorContainer.decode(ErrorCode.self, forKey: .type)

        switch errorCode {
        case .syntaxError:
            self = .syntaxError
        case .illegalParameters:
            var parameterNames = try errorContainer.nestedUnkeyedContainer(forKey: .parameterNames)
            var names: [String] = []
            names.reserveCapacity(parameterNames.count ?? 0)
            while parameterNames.isAtEnd == false {
                let name = try parameterNames.decode(String.self)
                names.append(name)
            }
            self = .illegalParameters(names)
        case .illegalHeaders:
            var headerNames = try errorContainer.nestedUnkeyedContainer(forKey: .headerNames)
            var names: [String] = []
            names.reserveCapacity(headerNames.count ?? 0)
            while headerNames.isAtEnd == false {
                let name = try headerNames.decode(String.self)
                names.append(name)
            }
            self = .illegalHeaders(names)
        case .invalidCredentials:
            self = .invalidCredentials
        case .invalidToken:
            self = .invalidToken
        case .invalidSignature:
            self = .invalidSignature
        case .invalidScope:
            self = .invalidScope
        case .forbidden:
            self = .forbidden
        case .technicalError:
            self = .technicalError
        case .serviceUnavailable:
            self = .serviceUnavailable
        }
    }
    // swiftlint:enable cyclomatic_complexity

    enum DecodingError: Error {
        case unknownErrorType
    }

    // MARK: - Encodable

    // swiftlint:disable cyclomatic_complexity
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var errorContainer = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .error)

        let errorCode: ErrorCode

        switch self {
        case .syntaxError:
            errorCode = .syntaxError
        case .illegalParameters(let parameters):
            errorCode = .illegalParameters
            var parametersContainer = errorContainer.nestedUnkeyedContainer(forKey: .parameterNames)
            for parameter in parameters {
                try parametersContainer.encode(parameter)
            }
        case .illegalHeaders(let headers):
            errorCode = .illegalHeaders
            var headersContainer = errorContainer.nestedUnkeyedContainer(forKey: .headerNames)
            for header in headers {
                try headersContainer.encode(header)
            }
        case .invalidCredentials:
            errorCode = .invalidCredentials
        case .invalidToken:
            errorCode = .invalidToken
        case .invalidSignature:
            errorCode = .invalidSignature
        case .invalidScope:
            errorCode = .invalidScope
        case .forbidden:
            errorCode = . forbidden
        case .technicalError:
            errorCode = .technicalError
        case .serviceUnavailable:
            errorCode = .serviceUnavailable
        }

        try errorContainer.encode(errorCode, forKey: .type)
    }
    // swiftlint:enable cyclomatic_complexity

    private enum CodingKeys: String, CodingKey {
        case error
        case type
        case parameterNames
        case headerNames
    }

    private enum ErrorCode: String, Decodable, Encodable {
        case syntaxError = "SyntaxError"
        case illegalParameters = "IllegalParameters"
        case illegalHeaders = "IllegalHeaders"
        case invalidCredentials = "InvalidCredentials"
        case invalidToken = "InvalidToken"
        case invalidSignature = "InvalidSignature"
        case invalidScope = "InvalidScope"
        case forbidden = "Forbidden"
        case technicalError = "TechnicalError"
        case serviceUnavailable = "ServiceUnavailable"
    }
}
