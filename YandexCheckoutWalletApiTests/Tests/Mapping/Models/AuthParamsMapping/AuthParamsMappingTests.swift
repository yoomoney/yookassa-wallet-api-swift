import XCTest
@testable
import YandexMoneyTestInstrumentsApi
import YandexCheckoutWalletApi

final class AuthParamsMappingTests: MappingApiMethods {
    func testAuthParamsSecret() {
        checkApiMethodsParameters(AuthParams.self, fileName: "AuthParams", index: 0)
    }

    func testAuthParamsSignature() {
        checkApiMethodsParameters(AuthParams.self, fileName: "AuthParams", index: 1)
    }
}
