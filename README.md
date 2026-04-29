# NetworkKit

NetworkKit is a CocoaPods network abstraction library based on Moya.

The goal is to hide Moya behind stable app-facing types, so app modules do not depend on `MoyaProvider`, `TargetType`, or `PluginType` directly.

## Public API

- `NetworkKit.shared`
- `NetworkKit.configure(...)`
- `NetworkClient`
- `APIEndpoint`
- `BaseURLProvider`
- `AccessTokenProvider`
- `UnauthorizedHandler`
- `NetworkPlugin`
- `NetworkTimeoutConfiguration`
- `NetworkError`

## Local Pod

```ruby
pod 'NetworkKit', :path => './NetworkKit'
```

For the current local example:

```ruby
pod 'NetworkKit', :path => '..'
```

## App Startup

Configure NetworkKit once when the app starts:

```swift
import NetworkKit

NetworkKit.configure(
    baseURLProvider: AppBaseURLProvider(),
    tokenProvider: AppTokenProvider(),
    unauthorizedHandler: AppUnauthorizedHandler(),
    timeout: NetworkTimeoutConfiguration(request: 15, resource: 60),
    plugins: [AppNetworkLoggerPlugin()],
    decoder: JSONDecoder()
)
```

All parameters are optional. If no timeout is provided, NetworkKit uses:

```swift
NetworkTimeoutConfiguration(
    request: 60,
    resource: 7 * 24 * 60 * 60
)
```

## Base URL

Business APIs usually only define a path:

```swift
enum DeviceAPI {
    static var list: APIEndpoint {
        APIEndpoint(path: "/devices")
    }
}
```

The domain is provided by the app:

```swift
final class AppBaseURLProvider: BaseURLProvider {
    func baseURL(for key: BaseURLKey) -> URL {
        switch key {
        case .api:
            return URL(string: "https://api.example.com")!
        case .upload:
            return URL(string: "https://upload.example.com")!
        case .device:
            return URL(string: "https://device.example.com")!
        case .billing:
            return URL(string: "https://billing.example.com")!
        default:
            return URL(string: "https://api.example.com")!
        }
    }
}
```

If an endpoint does not specify `baseURLKey`, it uses `.default`.

```swift
APIEndpoint(path: "/posts")
```

This is equivalent to:

```swift
APIEndpoint(path: "/posts", baseURLKey: .default)
```

For special domains:

```swift
APIEndpoint(path: "/avatar", baseURLKey: .upload, method: .post)
```

Full URL endpoints are still supported:

```swift
APIEndpoint(url: URL(string: "https://api.example.com/devices")!)
```

## Requests

GET is the default method:

```swift
let posts = try await NetworkKit.shared.request(DeviceAPI.list, as: [Post].self)
```

POST JSON:

```swift
let endpoint = APIEndpoint(
    path: "/login",
    method: .post,
    task: .json([
        "phone": phone,
        "password": password
    ])
)

let user = try await NetworkKit.shared.request(endpoint, as: User.self)
```

Raw response:

```swift
let response = try await NetworkKit.shared.request(endpoint)
```

## Token

NetworkKit does not own user state. The app provides token access:

```swift
final class AppTokenProvider: AccessTokenProvider {
    func accessToken() async -> String? {
        UserSession.shared.accessToken
    }
}
```

NetworkKit adds the token to the request header:

```text
Authorization: Bearer <token>
```

When the user switches accounts or logs in again, update `UserSession.shared.accessToken`. NetworkKit reads the latest token before each request.

## Unauthorized

When the server returns `401`, NetworkKit:

- calls `UnauthorizedHandler.didReceiveUnauthorized()`
- throws `NetworkError.unauthorized`

Example:

```swift
final class AppUnauthorizedHandler: UnauthorizedHandler {
    func didReceiveUnauthorized() {
        UserSession.shared.accessToken = nil
        AppRouter.shared.showLogin()
    }
}
```

## Errors

NetworkKit maps common low-level errors to stable app-facing errors:

```swift
NetworkError.noInternet
NetworkError.timeout
NetworkError.secureConnectionFailed
NetworkError.unauthorized
NetworkError.server(statusCode:data:)
NetworkError.decoding
NetworkError.underlying
```

Business code can handle them with `do/catch`:

```swift
do {
    posts = try await NetworkKit.shared.request(DeviceAPI.list, as: [Post].self)
} catch NetworkError.noInternet {
    message = "Network unavailable"
} catch NetworkError.timeout {
    message = "Request timed out"
} catch NetworkError.secureConnectionFailed {
    message = "Secure connection failed"
} catch NetworkError.unauthorized {
    message = "Login expired"
} catch {
    message = "Request failed"
}
```

## Plugins

Use `NetworkPlugin` for logging, analytics, request tracing, or debug tools:

```swift
struct AppNetworkLoggerPlugin: NetworkPlugin {
    func willSend(_ request: URLRequest) {
        print("Request:", request.url?.absoluteString ?? "")
    }

    func didReceive(_ response: NetworkResponse) {
        print("Status:", response.statusCode)
    }

    func didFail(_ error: NetworkError) {
        print("Error:", error)
    }
}
```

## Boundary

App modules should not import:

- `Moya`
- `TargetType`
- `PluginType`
- `MoyaProvider`

App modules should use:

```swift
try await NetworkKit.shared.request(endpoint, as: Model.self)
```

Tests can replace the shared client:

```swift
NetworkKit.use(MockNetworkClient())
```

## Objective-C

The current public API is Swift-first:

- `async/await`
- `Decodable`
- Swift `Error`

Objective-C pages can be supported later by adding a thin `ObjCBridge` layer that exposes callback-based APIs with `NSData`, `NSDictionary`, and `NSError`.

## Example App

The Example project lives at:

```text
Example/NetworkKitExample.xcworkspace
```

Install pods before opening it in Xcode:

```bash
cd Example
pod install
open NetworkKitExample.xcworkspace
```

The current example uses:

```swift
URL(string: "https://jsonplaceholder.typicode.com")!
```

and requests:

```swift
APIEndpoint(path: "/posts")
```

## Validation

Quick podspec validation:

```bash
pod lib lint NetworkKit.podspec --quick --allow-warnings
```

Full CocoaPods validation:

```bash
pod lib lint NetworkKit.podspec --allow-warnings
```
