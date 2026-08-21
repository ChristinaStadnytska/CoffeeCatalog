//
//  StubURLProtocol.swift
//  CoffeeCatalogTests
//

import Foundation

/// Intercepts requests made through `URLSession.shared` so `NetworkService`
/// can be tested without touching the real network.
///
/// `NetworkService` uses `URLSession.shared` directly rather than an injected
/// session, so this has to be registered globally via `URLProtocol.registerClass`.
/// That is process-wide mutable state — any suite using it must be `.serialized`.
final class StubURLProtocol: URLProtocol {

    /// Configured per test. Return the response/body to serve, or throw to
    /// simulate a transport failure.
    nonisolated(unsafe) static var requestHandler: (@Sendable (URLRequest) throws -> (URLResponse, Data))?

    /// URL of the most recent intercepted request, for asserting routing.
    nonisolated(unsafe) private(set) static var lastRequestURL: URL?

    static func register() {
        URLProtocol.registerClass(StubURLProtocol.self)
    }

    static func unregister() {
        requestHandler = nil
        lastRequestURL = nil
        URLProtocol.unregisterClass(StubURLProtocol.self)
    }

    // MARK: - Convenience configuration

    /// Serve an HTTP response with the given status code and body.
    static func stub(statusCode: Int = 200, body: Data) {
        requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!,
                                           statusCode: statusCode,
                                           httpVersion: "HTTP/1.1",
                                           headerFields: ["Content-Type": "application/json"])!
            return (response, body)
        }
    }

    static func stub(statusCode: Int = 200, json: String) {
        stub(statusCode: statusCode, body: Data(json.utf8))
    }

    /// Fail the request before any response is produced.
    static func stub(failingWith error: Error) {
        requestHandler = { _ in throw error }
    }

    // MARK: - URLProtocol

    override class func canInit(with request: URLRequest) -> Bool { true }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        Self.lastRequestURL = request.url

        guard let handler = Self.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.resourceUnavailable))
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
