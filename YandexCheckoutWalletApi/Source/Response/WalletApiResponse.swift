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
import typealias FunctionalSwift.Result

public protocol WalletApiResponse: ApiResponse {}

extension WalletApiResponse {
    public static func process(response: HTTPURLResponse?, data: Data?, error: Error?) -> Result<Self> {
        var result: Result<Self>

        if let response = response,
           let data = data,
           let error = WalletAuthApiError.makeResponse(response: response, data: data) {
            result = .left(error)
        } else if let response = response,
                  let data = data,
                  let error = self.makeSpecificError(response: response, data: data) {
            result = .left(error)
        } else if let response = response,
                  let data = data,
                  let serializedData = self.makeResponse(response: response, data: data) {
            result = .right(serializedData)
        } else if let error = error {
            result = .left(error)
        } else {
            result = .left(WalletApiError.mappingError)
        }

        return result
    }
}
