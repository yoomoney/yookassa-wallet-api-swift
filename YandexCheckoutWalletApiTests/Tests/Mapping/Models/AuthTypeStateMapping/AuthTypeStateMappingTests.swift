import XCTest
@testable
import YandexCheckoutWalletApi
import YandexMoneyTestInstrumentsApi

final class AuthTypeStateMappingTests: MappingApiMethods {
    func testAuthTypeStateSms() {
        checkApiMethodsParameters(AuthTypeState.self, fileName: "AuthTypeState", index: 0)
    }

    func testAuthTypeStateTotp() {
        checkApiMethodsParameters(AuthTypeState.self, fileName: "AuthTypeState", index: 1)
    }

    func testAuthTypeStateSecurePassword() {
        checkApiMethodsParameters(AuthTypeState.self, fileName: "AuthTypeState", index: 2)
    }

    func testAuthTypeStateEmergency() {
        checkApiMethodsParameters(AuthTypeState.self, fileName: "AuthTypeState", index: 3)
    }

    func testAuthTypeStatePush() {
        checkApiMethodsParameters(AuthTypeState.self, fileName: "AuthTypeState", index: 4)
    }

    func testAuthTypeStateOauth() {
        checkApiMethodsParameters(AuthTypeState.self, fileName: "AuthTypeState", index: 5)
    }

    func testAuthTypeStateWithActiveSession() {
        checkApiMethodsParameters(AuthTypeState.self, fileName: "AuthTypeState", index: 6)
    }
}
