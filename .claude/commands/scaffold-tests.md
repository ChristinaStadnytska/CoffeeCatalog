---
description: Generate a Swift Testing test file + mock for a given protocol
argument-hint: <ProtocolName>
---

Generate unit tests for the protocol `$ARGUMENTS` in this project.

Steps:

1. Locate the protocol definition and its production implementation in the
   codebase.
2. If a mock (e.g. `Mock$ARGUMENTS`) doesn't already exist, create one that
   conforms to the protocol and lets each method's return value / thrown
   error be configured per test — follow the existing style of
   `MockNetworkService`.
3. Create a test file using **Swift Testing** (`@Test`, `#expect`) covering:
   - the success path
   - at least one realistic failure path (not a generic placeholder error)
   - one edge case that is specific to this protocol's actual contract
4. Do not write a test for a case that cannot actually occur given the
   protocol's contract — flag that instead of padding the coverage number.

Output the mock and the test file as separate code blocks, named
consistently with the existing test file naming already used in the project.
