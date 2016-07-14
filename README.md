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
mstorage.upload(data: data){result, error in
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
mstorage.download(mediaId: "<media_id>"){result, error in
    if error.isEmpty() {
        var data: NSData = result.data
        // do something
    }
}
```

### List media ids
* Without options

You'll get a default list if you set nothing or an empty `Dictionary` object on the first parameter.

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
```

* With options

You can also use a `Dictionary` object for listing options as follows.
The available options are `limit`, `after` and `before`.

```swift
mstorage.list(["limit": "25", "after": "<media_id>"]){result, error in
    // do something
}
```

* Search

You can add another `Dictionary` object with `filter` key into the listing options to search by user metadata.

```swift
mstorage.list(["limit": "25", "after": "<media_id>",
    "filter": ["meta.user.<key1>": "<value1>", "meta.user.<key2>": "<value2>"]]){result, error in
    // do something
}
```

### Delete media
```swift
mstorage.delete(mediaId: "<media_id>"){error in
    if error.isEmpty() {
        // do something
    }
}
```

### Get media information
```swift
mstorage.info(mediaId: "<media_id>"){result, error in
    if error.isEmpty() {
        var id: String = result.id
        var contentType: String = result.contentType
        var bytes: Int = result.bytes
        var createdAt: String = result.createdAt
        // do something
    }
}
```

### Attach media metadata
You can define your original metadata as a 'user metadata'.
Existing metadata value for the same key will be overwritten. Up to 10 user metadata can be attached to a media data. 

```swift
mstorage.addMeta(mediaId: "<media_id>", userMeta: ["user.<key1>": "<value1>", "user.<key2>": "<value2>"]){error in
    if error.isEmpty() {
        // do something
    }
}
```

### Get media metadata
* All
```swift
mstorage.meta(mediaId: "<media_id>"){result, error in
    if error.isEmpty() {
        var exif: [String: String] = result.exif
        var gpano: [String: String] = result.gpano
        var userMeta: [String: String] = result.userMeta
        // do something
    }
}
```

* Exif
```swift
mstorage.meta(mediaId: "<media_id>", fieldName: "exif"){result, error in
    if error.isEmpty() {
        var exif: [String: String] = result
        // do something
    }
}
```

* Google Photo Sphere XMP
```swift
mstorage.meta(mediaId: "<media_id>", fieldName: "gpano"){result, error in
    if error.isEmpty() {
        var gpano: [String: String] = result
        // do something
    }
}
```

* User metadata (all)
```swift
mstorage.meta(mediaId: "<media_id>", fieldName: "user"){result, error in
    if error.isEmpty() {
        var userMeta: [String: String] = result
        // do something
    }
}
```

* User metadata (with a key)
```swift
mstorage.meta(mediaId: "<media_id>", fieldName: "user.<key>"){result, error in
    if error.isEmpty() {
        var value: String = result["<key>"]
        // do something
    }
}
```

### Delete media metadata
* User metadata (all)
```swift
mstorage.removeMeta(mediaId: "<media_id>", fieldName: "user"){error in
    if error.isEmpty() {
        // do something
    }
}
```

* User metadata (with a key)
```swift
mstorage.removeMeta(mediaId: "<media_id>", fieldName: "user.<key>"){error in
    if error.isEmpty() {
        // do something
    }
}
```

## References
* [Media Storage REST API](https://github.com/ricohapi/media-storage-rest/blob/master/media.md)
