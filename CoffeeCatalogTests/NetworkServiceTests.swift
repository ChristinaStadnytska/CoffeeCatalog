//
//  NetworkServiceTests.swift
//  CoffeeCatalogTests
//

import Foundation
import Testing
@testable import CoffeeCatalog

/// Covers the production conformer of `NetworkServiceInterface`.
///
/// Serialized because `StubURLProtocol` registers globally against
/// `URLSession.shared`; Swift Testing parallelizes suites by default and
/// concurrent tests would overwrite each other's stubbed response.
@Suite(.serialized)
final class NetworkServiceTests {

    private let service = NetworkService()

    init() {
        StubURLProtocol.register()
    }

    deinit {
        StubURLProtocol.unregister()
    }

    // MARK: - Success

    @Test
    func fetchCoffeeList_success_decodesCoffees() async throws {
        StubURLProtocol.stub(json: """
        [
          {"title": "Black", "description": "Coffee served without cream or milk.",
           "ingredients": ["Coffee"], "image": "https://example.com/black.jpg", "id": 1},
          {"title": "Latte", "description": "Espresso with steamed milk.",
           "ingredients": ["Espresso", "Steamed Milk"], "image": "https://example.com/latte.jpg", "id": 2}
        ]
        """)

        let coffees = try await service.fetchCoffeeList(category: .hot)

        #expect(coffees.count == 2)
        #expect(coffees.map(\.title) == ["Black", "Latte"])
        #expect(coffees.map(\.serverId) == [1, 2])
        #expect(coffees[1].ingredients == ["Espresso", "Steamed Milk"])
    }

    /// The API's `id` is decoded into `serverId`; `id` is a locally generated
    /// `UUID`, so two coffees with the same server id are still distinct rows.
    @Test
    func fetchCoffeeList_success_assignsUniqueLocalIDs() async throws {
        StubURLProtocol.stub(json: """
        [{"title": "Black", "id": 1}, {"title": "Black", "id": 1}]
        """)

        let coffees = try await service.fetchCoffeeList(category: .hot)

        #expect(coffees.count == 2)
        #expect(coffees[0].id != coffees[1].id)
        #expect(coffees.allSatisfy { $0.serverId == 1 })
    }

    /// `favourite` is never sent by the server — it must always decode to
    /// `false` and be applied locally afterwards.
    @Test
    func fetchCoffeeList_success_defaultsFavouriteToFalse() async throws {
        StubURLProtocol.stub(json: #"[{"title": "Black", "id": 1, "favourite": true}]"#)

        let coffees = try await service.fetchCoffeeList(category: .hot)

        #expect(coffees.first?.favourite == false)
    }

    /// An empty category is a valid success response, not an error.
    @Test
    func fetchCoffeeList_emptyArray_returnsEmptyListWithoutThrowing() async throws {
        StubURLProtocol.stub(json: "[]")

        let coffees = try await service.fetchCoffeeList(category: .iced)

        #expect(coffees.isEmpty)
    }

    // MARK: - Contract edge cases

    /// `CoffeeModel` deliberately accepts `ingredients` as either an array or a
    /// bare string, because the upstream API returns both shapes.
    @Test
    func fetchCoffeeList_ingredientsAsSingleString_normalizesToArray() async throws {
        StubURLProtocol.stub(json: #"[{"title": "Espresso", "ingredients": "Coffee", "id": 7}]"#)

        let coffees = try await service.fetchCoffeeList(category: .hot)

        #expect(coffees.first?.ingredients == ["Coffee"])
    }

    /// Every field except `title` is optional, so a sparse row must still decode.
    @Test
    func fetchCoffeeList_onlyTitlePresent_decodesWithNilOptionals() async throws {
        StubURLProtocol.stub(json: #"[{"title": "Cortado"}]"#)

        let coffee = try #require(try await service.fetchCoffeeList(category: .hot).first)

        #expect(coffee.title == "Cortado")
        #expect(coffee.serverId == nil)
        #expect(coffee.description == nil)
        #expect(coffee.ingredients == nil)
        #expect(coffee.image == nil)
    }

    @Test(arguments: [CoffeeCategory.hot, .iced])
    func fetchCoffeeList_routesCategoryIntoRequestPath(_ category: CoffeeCategory) async throws {
        StubURLProtocol.stub(json: "[]")

        _ = try await service.fetchCoffeeList(category: category)

        #expect(StubURLProtocol.lastRequestURL?.path == "/coffee/\(category.rawValue)")
    }

    // MARK: - Failure paths

    @Test
    func fetchCoffeeList_serverError_throwsBadResponseWithStatusCode() async throws {
        StubURLProtocol.stub(statusCode: 500, json: #"{"message": "Internal Server Error"}"#)

        do {
            _ = try await service.fetchCoffeeList(category: .hot)
            Issue.record("Expected NetworkError.badResponse")
        } catch let error as NetworkError {
            guard case .badResponse(let statusCode) = error else {
                Issue.record("Expected .badResponse, got \(error)")
                return
            }
            #expect(statusCode == 500)
        }
    }

    /// `title` is the only non-optional field, so a row missing it is the
    /// realistic decoding failure for this endpoint.
    @Test
    func fetchCoffeeList_responseMissingTitle_throwsDecodingFailed() async throws {
        StubURLProtocol.stub(json: #"[{"description": "no title here", "id": 1}]"#)

        do {
            _ = try await service.fetchCoffeeList(category: .hot)
            Issue.record("Expected NetworkError.decodingFailed")
        } catch let error as NetworkError {
            guard case .decodingFailed(let underlying) = error else {
                Issue.record("Expected .decodingFailed, got \(error)")
                return
            }
            #expect(underlying is DecodingError)
        }
    }

    @Test
    func fetchCoffeeList_offline_throwsTransportWrappingURLError() async throws {
        StubURLProtocol.stub(failingWith: URLError(.notConnectedToInternet))

        do {
            _ = try await service.fetchCoffeeList(category: .hot)
            Issue.record("Expected NetworkError.transport")
        } catch let error as NetworkError {
            guard case .transport(let underlying) = error else {
                Issue.record("Expected .transport, got \(error)")
                return
            }
            #expect((underlying as? URLError)?.code == .notConnectedToInternet)
        }
    }
}
