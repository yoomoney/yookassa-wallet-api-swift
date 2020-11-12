import XCTest
@testable
import YooKassaWalletApi
import YooMoneyTestInstrumentsApi

class WalletAuthApiErrorMappingTests: MappingApiMethods {
    func testWalletAuthApiErrorSyntaxError() {
        checkApiMethodsParameters(WalletAuthApiError.self, fileName: "WalletAuthApiError", index: 2)
    }

    func testWalletAuthApiErrorIllegalParameters() {
        checkApiMethodsParameters(WalletAuthApiError.self, fileName: "WalletAuthApiError", index: 0)
    }

    func testWalletAuthApiErrorIllegalHeaders() {
        checkApiMethodsParameters(WalletAuthApiError.self, fileName: "WalletAuthApiError", index: 1)
    }

    func testWalletAuthApiErrorInvalidCredentials() {
        checkApiMethodsParameters(WalletAuthApiError.self, fileName: "WalletAuthApiError", index: 7)
    }

    func testWalletAuthApiErrorInvalidToken() {
        checkApiMethodsParameters(WalletAuthApiError.self, fileName: "WalletAuthApiError", index: 8)
    }

    func testWalletAuthApiErrorInvalidSignature() {
        checkApiMethodsParameters(WalletAuthApiError.self, fileName: "WalletAuthApiError", index: 9)
    }

    func testWalletAuthApiErrorTechnicalError() {
        checkApiMethodsParameters(WalletAuthApiError.self, fileName: "WalletAuthApiError", index: 5)
    }

    func testWalletAuthApiErrorServiceUnavailable() {
        checkApiMethodsParameters(WalletAuthApiError.self, fileName: "WalletAuthApiError", index: 6)
    }
}
