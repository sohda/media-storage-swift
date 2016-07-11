# Ricoh Media Storage for Swift

This open-source library allows you to integrate Ricoh Media Storage into your Swift app.

Learn more at http://docs.ricohapi.com/

## Requirements

* Swift 2.2+
* Xcode 7.3.1+

You'll also need

* Ricoh API Client Credentials (client_id & client_secret)
* Ricoh ID (user_id & password)

If you don't have them, please register yourself and your client from [THETA Developers Website](http://contest.theta360.com/).

## Dependencies
* [Ricoh Auth Client for Swift](https://github.com/ricohapi/auth-swift) 1.0+

## Installation
This section shows you two different methods to install Ricoh Media Storage for Swift in your application.  
See [Media Storage Sample](https://github.com/ricohapi/media-storage-swift/tree/master/Sample#media-storage-sample) to try out a sample of Ricoh Media Storage for Swift.

### CocoaPods
* If it is your first time to use [CocoaPods](https://cocoapods.org/), run the following commands to set it up.
```sh
$ gem install cocoapods
$ pod setup
```

* Go to your project directory.
* Create a Podfile by running `pod init` ( if you do not have one yet ), and specify `RicohAPIMStorage` as follows:
```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target 'YourAppName' do
  pod 'RicohAPIMStorage', '~> 2.0.0'
end
```
* Run `pod install` to install `RicohAPIMStorage`.
* Open your project's workspace.
* Choose your application scheme and run it to load the RicohAPIMStorage module.
* Install completed! See [Sample Flow](https://github.com/ricohapi/media-storage-swift#sample-flow) for a coding example.

### Manually
* Clone Ricoh Media Storage for Swift by running the following commands:
```sh
$ git clone --recursive https://github.com/ricohapi/media-storage-swift.git
```
* Open the new `media-storage-swift` directory, and drag `RicohAPIMStorage.xcodeproj` into the Project Navigator of your project.

    > It should appear nested underneath your application's blue project icon.
    > Whether it is above or below all the other Xcode groups does not matter.

* Choose RicohAPIAuth scheme at the scheme menu of Xcode and run it.
* Choose your application scheme and run it to load the RicohAPIMStorage module.
* Install completed! See [Sample Flow](https://github.com/ricohapi/media-storage-swift#sample-flow) for a coding example.

## Sample Flow
```swift
// Import
import RicohAPIAuth
import RicohAPIMStorage

// Set your Ricoh API Client Credentials
var authClient = AuthClient(
    clientId: "<your_client_id>",
    clientSecret: "<your_client_secret>"
)

@IBAction func uploadButtonTapped(sender: AnyObject) {
    // Set your resource owner credentials (Ricoh ID)
    authClient.setResourceOwnerCreds(
        userId: "<your_user_id>",
        userPass: "<your_password>"
    )

    // Initialize a MediaStorage object with the AuthClient object
    let mstorage = MediaStorage(authClient: authClient)

    // Connect to the server
    mstorage.connect(){result, error in

        //Prepare an NSData object in your way
        let mediaUrl = NSBundle.mainBundle().URLForResource("<your_media_name>", withExtension: "jpg")
        let mediaData = NSData(contentsOfURL: mediaUrl!)!

        // Upload
        mstorage.upload(data: mediaData){result, error in
            if !error.isEmpty() {
                print("status code: \(error.statusCode)")
                print("error message: \(error.message)")
            } else {
                print("media id : \(result.id)")
                print("media contentType : \(result.contentType)")
                print("media bytes : \(result.bytes)")
                print("created at : \(result.createdAt)")
            }
        }
    }
}
```

## SDK API Samples

### AuthClient
```swift
var authClient = AuthClient(
    clientId: "<your_client_id>",
    clientSecret: "<your_client_secret>"
)
authClient.setResourceOwnerCreds(
    userId: "<your_user_id>",
    userPass: "<your_password>"
)
```

### Constructor
```swift
var mstorage = MediaStorage(authClient: authClient)
```

### Connect to the server
```swift
mstorage.connect(){result, error in
    if error.isEmpty() {
        var accessToken: String = result.accessToken
        // do something
    }
}
```

### Upload
```swift
let data: NSData = ...
mstorage.upload(data){result, error in
    if error.isEmpty() {
        var id: String = result.id
        var contentType: String = result.contentType
        var bytes: Int = result.bytes
        var createdAt: String = result.createdAt
        // do something
    }
}
```

### Download
```swift
mstorage.download("<media_id>"){result, error in
    if error.isEmpty() {
        var data: NSData = result.data
        // do something
    }
}
```

### List media ids
```swift
mstorage.list(){result, error in
    if error.isEmpty() {
        var mediaList: Array = result.mediaList
        for media in mediaList {
            var id: String = media.id
        }
        var pagingNext: String? = result.paging.next
        var pagingPrevious: String? = result.paging.previous
        // do something
    }
}
// You can also use a Dictionary object for listing options as follows.
// The available options are "limit", "after" and "before".
mstorage.list(["limit": "25", "after": "<media_id>"]){result, error in
    // do something
}
```

### Delete
```swift
mstorage.delete("<media_id>"){ error in
    if error.isEmpty() {
        // do something
    }
}
```

### Get media information
```swift
mstorage.info("<media_id>"){result, error in
    if error.isEmpty() {
        var id: String = result.id
        var contentType: String = result.contentType
        var bytes: Int = result.bytes
        var createdAt: String = result.createdAt
        // do something
    }
}
```

### Get media metadata
```swift
mstorage.meta("<media_id>"){result, error in
    if error.isEmpty() {
        var exif: [String: String] = result.exif
        var gpano: [String: String] = result.gpano
        // do something
    }
}
```

## References
* [Media Storage REST API](https://github.com/ricohapi/media-storage-rest/blob/master/media.md)
