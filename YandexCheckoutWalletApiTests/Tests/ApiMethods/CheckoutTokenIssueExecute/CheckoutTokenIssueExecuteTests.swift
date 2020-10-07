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

import typealias FunctionalSwift.Result
import OHHTTPStubs
import XCTest
@testable import YandexCheckoutWalletApi
import YandexMoneyTestInstrumentsApi

class CheckoutTokenIssueExecuteTests: ApiMethodTestCase {

    struct CheckoutTokenIssueExecuteAuthExpiredResponse: StubsResponse {}
    struct CheckoutTokenIssueExecuteAuthRequiredResponse: StubsResponse {}
    struct CheckoutTokenIssueExecuteSuccessResponse: StubsResponse {}

    func testCheckoutTokenIssueExecuteAuthExpiredResponse() {
        validate(CheckoutTokenIssueExecuteAuthExpiredResponse.self) {
            guard case .left(CheckoutTokenIssueExecuteError.authExpired) = $0 else {
                XCTFail("Wrong result")
                return
            }
        }
    }

    func testCheckoutTokenIssueExecuteAuthRequiredResponse() {
        validate(CheckoutTokenIssueExecuteAuthRequiredResponse.self) {
            guard case .left(CheckoutTokenIssueExecuteError.authRequired) = $0 else {
                XCTFail("Wrong result")
                return
            }
        }
    }

    func testCheckoutTokenIssueExecuteSuccessResponse() {
        validate(CheckoutTokenIssueExecuteSuccessResponse.self) {
            guard case .right(let response) = $0 else {
                XCTFail("Wrong result")
                return
            }
            XCTAssertEqual(response.accessToken, "string")
        }
    }
}

private extension CheckoutTokenIssueExecuteTests {
    func validate(_ stubsResponse: StubsResponse.Type,
                  verify: @escaping (Result<CheckoutTokenIssueExecute>) -> Void) {
        let method = CheckoutTokenIssueExecute.Method(
            merchantClientAuthorization: "",
            passportAuthorization: "",
            moneyCenterAuthorization: "",
            processId: ""
        )
        validate(method, stubsResponse, CheckoutTokenIssueExecuteTests.self, verify: verify)
    }
}
