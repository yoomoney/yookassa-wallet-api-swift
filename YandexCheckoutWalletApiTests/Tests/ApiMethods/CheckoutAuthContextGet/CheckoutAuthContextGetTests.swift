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

import typealias FunctionalSwift.Result
import OHHTTPStubs
import XCTest
import YandexMoneyTestInstrumentsApi
@testable import YandexCheckoutWalletApi

class CheckoutCheckoutAuthContextGetTests: ApiMethodTestCase {

    struct CheckoutAuthContextGetErrorResponse: StubsResponse {}
    struct CheckoutAuthContextGetSuccessResponse: StubsResponse {}

    func testCheckoutAuthContextGetErrorResponse() {
        validate(CheckoutAuthContextGetErrorResponse.self) {
            guard case .left(CheckoutAuthContextGetError.invalidContext) = $0 else {
                XCTFail("Wrong result")
                return
            }
        }
    }

    func testCheckoutAuthContextGetSuccessResponse() {
        validate(CheckoutAuthContextGetSuccessResponse.self) {
            guard case .right(let authContext) = $0 else {
                XCTFail("Wrong result")
                return
            }
            XCTAssertEqual(authContext.defaultAuthType, .sms, "Wrong defaultAuthType")
            guard let type = authContext.authTypes.first,
                authContext.authTypes.count == 1 else {
                    XCTFail("Wrong authTypes")
                    return
            }

            XCTAssertEqual(type.specific.type, .sms, "Wrong type")

            guard case .sms(let smsDescription) = type.specific else {
                XCTFail("Wrong specific")
                return
            }

            XCTAssertEqual(smsDescription.codeLength, 6, "Wrong codeLength")
            XCTAssertEqual(smsDescription.sessionsLeft, 13, "Wrong sessionsLeft")
            XCTAssertEqual(smsDescription.sessionTimeLeft, 20, "Wrong sessionTimeLeft")
            XCTAssertEqual(smsDescription.nextSessionTimeLeft, 30, "Wrong nextSessionTimeLeft")

            guard let activeSession = type.activeSession else {
                XCTFail("Wrong active session")
                return
            }

            XCTAssertEqual(activeSession.attemptsCount, 10, "Wrong attemptsCount")
            XCTAssertEqual(activeSession.attemptsLeft, 11, "Wrong attemptsLeft")

            XCTAssertEqual(type.canBeIssued, false, "Wrong canBeIssued")
            XCTAssertEqual(type.enabled, true, "Wrong enabled")
            XCTAssertEqual(type.isSessionRequired, true, "Wrong isSessionRequired")
        }
    }
}

private extension CheckoutCheckoutAuthContextGetTests {
    func validate(_ stubsResponse: StubsResponse.Type,
                  verify: @escaping (Result<CheckoutAuthContextGet>) -> Void) {
        let method = CheckoutAuthContextGet.Method(passportAuthorization: "",
                                                   merchantClientAuthorization: "",
                                                   authContextId: "")
        validate(method, stubsResponse, CheckoutCheckoutAuthContextGetTests.self, verify: verify)
    }
}
