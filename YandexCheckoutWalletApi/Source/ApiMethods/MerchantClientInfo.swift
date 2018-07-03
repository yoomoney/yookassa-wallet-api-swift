/*
 * The MIT License
 *
 * Copyright (c) 2007—2018 NBCO Yandex.Money LLC
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

import YandexMoneyCoreApi

/// Get information about the merchant's customer, such as a mobile app.
public struct MerchantClientInfo: Decodable, Encodable {

    /// The name of the client merchant.
    public let shopName: String

    /// Creates instance of StoreCard.
    ///
    /// - Parameters:
    ///     - shopName: The name of the client merchant.
    public init(shopName: String) {
        self.shopName = shopName
    }

    /// API method for MerchantClientInfo.
    public struct Method: Decodable, Encodable {

        /// Merchant client key, issued in merchant's personal account, in the format " Basic [data]"
        public let merchantClientAuthorization: String

        /// Creates instance of MerchantClientInfo.Method.
        ///
        /// - Parameters:
        ///     - merchantClientAuthorization:  Merchant client key, issued in merchant's
        ///                                     personal account, in the format " Basic [data]"
        public init(merchantClientAuthorization: String) {
            self.merchantClientAuthorization = merchantClientAuthorization
        }

        // MARK: - Decodable

        public init(from decoder: Decoder) throws {
            _ = try decoder.container(keyedBy: CodingKeys.self)

            self.init(merchantClientAuthorization: "")
        }

        // MARK: - Encodable

        public func encode(to encoder: Encoder) throws {
            _ = encoder.container(keyedBy: CodingKeys.self)
        }

        private enum CodingKeys: CodingKey {
            var stringValue: String {
                return ""
            }

            init?(stringValue: String) {
                return nil
            }

            var intValue: Int? {
                return nil
            }

            init?(intValue: Int) {
                return nil
            }
        }
    }

    // MARK: - Decodable

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _ = try container.decode(Status.self, forKey: .status)
        let resultContainer = try container.nestedContainer(keyedBy: ResultCodingKeys.self, forKey: .result)
        let shopName = try resultContainer.decode(String.self, forKey: .shopName)

        self.init(shopName: shopName)
    }

    // MARK: - Encodable

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Status.success, forKey: .status)
        var resultContainer = container.nestedContainer(keyedBy: ResultCodingKeys.self, forKey: .result)
        try resultContainer.encode(shopName, forKey: .shopName)
    }

    private enum CodingKeys: String, CodingKey {
        case status
        case result
    }

    private enum ResultCodingKeys: String, CodingKey {
        case shopName
    }

    private enum Status: String, Encodable, Decodable {
        case success = "Success"
    }
}

// MARK: - JsonApiResponse

extension MerchantClientInfo: JsonApiResponse {}

// MARK: - WalletApiResponse

extension MerchantClientInfo: WalletApiResponse {}

// MARK: - ApiMethod

extension MerchantClientInfo.Method: ApiMethod {

    public typealias Response = MerchantClientInfo

    public var hostProviderKey: String {
        return Constants.walletApiMethodsKey
    }

    public var httpMethod: HTTPMethod {
        return .post
    }

    public var parametersEncoding: ParametersEncoding {
        return JsonParametersEncoder()
    }

    public func urlInfo(from hostProvider: HostProvider) throws -> URLInfo {
        return .components(host: try hostProvider.host(for: hostProviderKey),
                           path: "/api/wallet-auth/v1/merchant-client-info")
    }

    public var headers: Headers {
        return Headers([
            AuthorizationConstants.merchantClientAuthorization: AuthorizationConstants.basicAuthorizationPrefix
                + merchantClientAuthorization,
        ])
    }
}
