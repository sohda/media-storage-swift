//
//  Copyright (c) 2016 Ricoh Company, Ltd. All Rights Reserved.
//  See LICENSE for more information
//

import Foundation
import RicohAPIAuth

public struct MediaInfo {
    
    public var id = ""
    public var contentType = ""
    public var bytes = 0
    public var createdAt = ""
    
}

public struct MediaIndex {
    
    public var id = ""
    
}

public struct Paging {
    
    public var next: String?
    public var previous: String?
    
}

public struct MediaList {
    
    public var mediaList = [MediaIndex]()
    public var paging = Paging()
    
}

public struct MediaContent {
    
    public var data = NSData()
    
}

public struct MediaMeta {

    public var exif = [String: String]()
    public var gpano = [String: String]()
    public var userMeta = [String: String]()

}

public struct MediaStorageError {
    
    public let statusCode: Int?
    public let message: String?
    
    public func isEmpty() -> Bool {
        return (statusCode == nil) && (message == nil)
    }
    
}

public class MediaStorage {
    var authClient: AuthClient
    var accessToken: String?
    
    let mstorageEndpoint = "https://mss.ricohapi.com/v1/media"
    let searchPath = "/search"
    let getContentPath = "/content"
    let getMetaPath = "/meta"
    let getUserMetaPath = "/meta/user"

    let metaExif = "exif"
    let metaGpano = "gpano"
    let metaUser = "user"

    let replaceUserMetaRegex = "^user\\.([A-Za-z0-9_\\-]{1,256})$"
    let firstGroupRegex = "$1"
    
    let maxUserMetaLength = 1024
    let minUserMetaLength = 1
    
    public init(authClient: AuthClient) {
        self.authClient = authClient
    }
    
    public func connect(completionHandler completionHandler: (AuthResult, AuthError) -> Void) {
        authClient.session(){result, error in
            self.accessToken = result.accessToken
            completionHandler(result, error)
        }
    }
    
    public func list(params: Dictionary<String, AnyObject> = [:], completionHandler: (MediaList, MediaStorageError) -> Void) {
        if accessToken == nil {
            completionHandler(MediaList(), MediaStorageError(statusCode: nil, message: "wrong usage: use the connect method to get an access token."))
            return
        }
        
        let afterRequest = {(data: NSData?, resp: NSURLResponse?, err: NSError?) -> Void in
            if err != nil {
                completionHandler(
                    MediaList(),
                    MediaStorageError(statusCode: nil, message: "request failed: \(err!.code): \(err!.domain)"))
                return
            }
            
            let httpresp = resp as! NSHTTPURLResponse
            let statusCode = httpresp.statusCode
            let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
            if !httpresp.isSucceeded() {
                completionHandler(
                    MediaList(),
                    MediaStorageError(statusCode: statusCode, message: "received error: \(dataString)")
                )
                return
            }
            
            do {
                let dataDic = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                
                let mediaDicArray = dataDic["media"]! as! [NSDictionary]
                var mediaStructArray = [MediaIndex]()
                for item in mediaDicArray {
                    let id = item["id"] as! String
                    mediaStructArray.append(MediaIndex(id: id))
                }
                
                let pagingDic = dataDic["paging"]! as! [String: AnyObject]
                let pagingNext = pagingDic["next"] as! String?
                let pagingPrevious = pagingDic["previous"] as! String?
                let paging = Paging(next: pagingNext, previous: pagingPrevious)
                
                completionHandler(
                    MediaList(mediaList: mediaStructArray, paging: paging),
                    MediaStorageError(statusCode: nil, message: nil)
                )
                
            } catch {
                completionHandler(
                    MediaList(),
                    MediaStorageError(statusCode: statusCode, message: "invalid response: \(dataString)")
                )
            }
        }
        
        if let query = params["filter"] {
            // POST /media/search
            var paging = params
            paging["filter"] = nil
            
            let searchParams: [String: AnyObject] = [
                "search_version": "2016-07-08",
                "query": query,
                "paging": paging
            ]
            
            let body: NSData
            do {
                body = try NSJSONSerialization.dataWithJSONObject(searchParams, options: NSJSONWritingOptions.init(rawValue: 0))
            } catch {
                completionHandler(
                    MediaList(),
                    MediaStorageError(statusCode: nil, message: "invalid parameter: \(params)")
                )
                return
            }
            MediaStorageRequest.post(
                url: "\(mstorageEndpoint)\(searchPath)",
                header: [
                    "content-type" : "application/json",
                    "Authorization" : "Bearer \(accessToken!)"
                ],
                body: body,
                completionHandler: afterRequest
            )
        } else {
            // GET /media
            MediaStorageRequest.get(
                url: mstorageEndpoint,
                queryParams: params,
                header: [
                    "Authorization" : "Bearer \(accessToken!)"
                ],
                completionHandler: afterRequest
            )
        }
    }
    
    public func upload(data data: NSData!, completionHandler: (MediaInfo, MediaStorageError) -> Void) {
        if accessToken == nil {
            completionHandler(MediaInfo(), MediaStorageError(statusCode: nil, message: "wrong usage: use the connect method to get an access token."))
            return
        }
        
        MediaStorageRequest.upload(
            url: mstorageEndpoint,
            header: [
                "content-type" : "image/jpeg",
                "Authorization" : "Bearer \(accessToken!)"
            ],
            data: data
        ){(data, resp, err) in
            if err != nil {
                completionHandler(MediaInfo(), MediaStorageError(statusCode: nil, message: "request failed: \(err!.code): \(err!.domain)"))
                return
            }
            
            let httpresp = resp as! NSHTTPURLResponse
            let statusCode = httpresp.statusCode
            let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
            if !httpresp.isSucceeded() {
                completionHandler(
                    MediaInfo(),
                    MediaStorageError(statusCode: statusCode, message: "received error: \(dataString)")
                )
                return
            }
            
            do {
                let dataDic = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                
                let id = dataDic["id"] as! String
                let contentType = dataDic["content_type"] as! String
                let bytes = dataDic["bytes"] as! Int
                let createdAt = dataDic["created_at"] as! String
                
                completionHandler(
                    MediaInfo(id: id, contentType: contentType, bytes: bytes, createdAt: createdAt),
                    MediaStorageError(statusCode: nil, message: nil)
                )
                
            } catch {
                completionHandler(
                    MediaInfo(),
                    MediaStorageError(statusCode: statusCode, message: "invalid response: \(dataString)")
                )
            }
            
        }
    }
    
    public func download(mediaId mediaId: String, completionHandler: (MediaContent, MediaStorageError) -> Void) {
        if accessToken == nil {
            completionHandler(MediaContent(),
                              MediaStorageError(statusCode: nil, message: "wrong usage: use the connect method to get an access token."))
            return
        }
        
        MediaStorageRequest.download(
            url: "\(mstorageEndpoint)/\(mediaId)\(getContentPath)",
            header: [
                "content-type" : "image/jpeg",
                "Authorization" : "Bearer \(accessToken!)"
            ]
        ){(data, resp, err) in
            if err != nil {
                completionHandler(MediaContent(),
                                  MediaStorageError(statusCode: nil, message: "request failed: \(err!.code): \(err!.description as String)"))
                return
            }
            
            let httpresp = resp as! NSHTTPURLResponse
            if !httpresp.isSucceeded() {
                completionHandler(
                    MediaContent(),
                    MediaStorageError(statusCode: httpresp.statusCode, message: "download failure: \((httpresp.URL?.absoluteString)! as String)")
                )
                return
            }
            
            let imageData = NSData(contentsOfURL: data!)!
            completionHandler(MediaContent(data: imageData), MediaStorageError(statusCode: nil, message: nil))
        }
    }
    
    public func addMeta(mediaId mediaId: String, userMeta: Dictionary<String, String>, completionHandler: MediaStorageError -> Void) {
        if accessToken == nil {
            completionHandler(
                MediaStorageError(statusCode: nil, message: "wrong usage: use the connect method to get an access token.")
            )
            return
        }
        
        if userMeta.isEmpty {
            completionHandler(
                MediaStorageError(statusCode: nil, message: "userMeta is empty: nothing to request.")
            )
        }
        
        for (key, value) in userMeta {
            let userMetaKey = replaceUserMeta(key)
            if userMetaKey.isEmpty || !isValidValue(value) {
                completionHandler(
                    MediaStorageError(statusCode: nil, message: "invalid parameter: [\(key): \(value)]")
                )
            }
            
            MediaStorageRequest.put(
                url: "\(mstorageEndpoint)/\(mediaId)\(getUserMetaPath)/\(userMetaKey)",
                header: [
                    "content-type" : "text/plain",
                    "Authorization" : "Bearer \(accessToken!)"
                ],
                data: value
            ){(data, resp, err) in
                if err != nil {
                    completionHandler(
                        MediaStorageError(statusCode: nil, message: "request failed: \(err!.code): \(err!.description as String)")
                    )
                    return
                }
                
                let httpresp = resp as! NSHTTPURLResponse
                if !httpresp.isSucceeded() {
                    completionHandler(
                        MediaStorageError(statusCode: httpresp.statusCode, message: "add user meta failure: \((httpresp.URL?.absoluteString)! as String)")
                    )
                    return
                }
                
                completionHandler(
                    MediaStorageError(statusCode: nil, message: nil)
                )
            }
        }
    }
    
    public func info(mediaId mediaId: String!, completionHandler: (MediaInfo, MediaStorageError) -> Void) {
        if accessToken == nil {
            completionHandler(MediaInfo(), MediaStorageError(statusCode: nil, message: "wrong usage: use the connect method to get an access token."))
            return
        }
        
        MediaStorageRequest.get(
            url: "\(mstorageEndpoint)/\(mediaId)",
            queryParams: [String: String](),
            header: [
                "Authorization" : "Bearer \(accessToken!)"
            ]
        ){(data, resp, err) in
            if err != nil {
                completionHandler(MediaInfo(), MediaStorageError(statusCode: nil, message: "request failed: \(err!.code): \(err!.domain)"))
                return
            }
            
            let httpresp = resp as! NSHTTPURLResponse
            let statusCode = httpresp.statusCode
            let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
            if !httpresp.isSucceeded() {
                completionHandler(
                    MediaInfo(),
                    MediaStorageError(statusCode: statusCode, message: "received error: \(dataString)")
                )
                return
            }
            
            do {
                let dataDic = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                
                let id = dataDic["id"] as! String
                let contentType = dataDic["content_type"] as! String
                let bytes = dataDic["bytes"] as! Int
                let createdAt = dataDic["created_at"] as! String
                
                completionHandler(
                    MediaInfo(id: id, contentType: contentType, bytes: bytes, createdAt: createdAt),
                    MediaStorageError(statusCode: nil, message: nil)
                )
                
            } catch {
                completionHandler(
                    MediaInfo(),
                    MediaStorageError(statusCode: statusCode, message: "invalid response: \(dataString)")
                )
            }
            
        }
    }
    
    public func delete(mediaId mediaId: String!, completionHandler: MediaStorageError -> Void) {
        if accessToken == nil {
            completionHandler(MediaStorageError(statusCode: nil, message: "wrong usage: use the connect method to get an access token."))
            return
        }
        
        MediaStorageRequest.delete(
            url: "\(mstorageEndpoint)/\(mediaId)",
            header: [
                "Authorization" : "Bearer \(accessToken!)"
            ]
        ){(data, resp, err) in
            if err != nil {
                completionHandler(MediaStorageError(statusCode: nil, message: "request failed: \(err!.code): \(err!.domain)"))
                return
            }
            
            let httpresp = resp as! NSHTTPURLResponse
            let statusCode = httpresp.statusCode
            let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
            if !httpresp.isSucceeded() {
                completionHandler(
                    MediaStorageError(statusCode: statusCode, message: "received error: \(dataString)")
                )
                return
            }
            
            completionHandler(
                MediaStorageError(statusCode: nil, message: nil)
            )
        }
    }

    public func meta(mediaId mediaId: String!, completionHandler: (MediaMeta, MediaStorageError) -> Void) {
        if accessToken == nil {
            completionHandler(MediaMeta(), MediaStorageError(statusCode: nil, message: "wrong usage: use the connect method to get an access token."))
            return
        }

        MediaStorageRequest.get(
            url: "\(mstorageEndpoint)/\(mediaId)\(getMetaPath)",
            queryParams: [String: String](),
            header: [
                "Authorization" : "Bearer \(accessToken!)"
            ]
        ){(data, resp, err) in
            if err != nil {
                completionHandler(MediaMeta(), MediaStorageError(statusCode: nil, message: "request failed: \(err!.code): \(err!.domain)"))
                return
            }

            let httpresp = resp as! NSHTTPURLResponse
            let statusCode = httpresp.statusCode
            let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
            if !httpresp.isSucceeded() {
                completionHandler(
                    MediaMeta(),
                    MediaStorageError(statusCode: statusCode, message: "received error: \(dataString)")
                )
                return
            }

            do {
                let dataDic = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)

                let exif = dataDic["exif"] as! [String:String]
                let gpano = dataDic["gpano"] as! [String:String]
                let userMeta = dataDic["user"] as! [String:String]

                completionHandler(
                    MediaMeta(exif: exif, gpano: gpano, userMeta: userMeta),
                    MediaStorageError(statusCode: nil, message: nil)
                )

            } catch {
                completionHandler(
                    MediaMeta(),
                    MediaStorageError(statusCode: statusCode, message: "invalid response: \(dataString)")
                )
            }

        }
    }

    public func meta(mediaId mediaId: String!, fieldName: String!, completionHandler: (Dictionary<String, String>, MediaStorageError) -> Void) {
        if accessToken == nil {
            completionHandler(Dictionary<String, String>(), MediaStorageError(statusCode: nil, message: "wrong usage: use the connect method to get an access token."))
            return
        }
        var isUserKey = false
        var url : String
        var userMetaKey = ""
        if fieldName == nil {
            completionHandler(Dictionary<String, String>(), MediaStorageError(statusCode: nil, message: "invalid parameter: nil"))
            return
        } else if fieldName == metaExif || fieldName == metaGpano || fieldName == metaUser {
            // GET /media/{id}/meta/exif, /media/{id}/meta/gpano, /media/{id}/meta/user
            url = "\(mstorageEndpoint)/\(mediaId)\(getMetaPath)/\(fieldName)"
        } else {
            userMetaKey = replaceUserMeta(fieldName)
            if userMetaKey == "" {
                completionHandler(Dictionary<String, String>(), MediaStorageError(statusCode: nil, message: "invalid parameter: \(fieldName)"))
                return
            } else {
                // GET /media/{id}/meta/user/{key}
                url = "\(mstorageEndpoint)/\(mediaId)\(getUserMetaPath)/\(userMetaKey)"
                isUserKey = true
            }
        }

        MediaStorageRequest.get(
            url: url,
            queryParams: [String: String](),
            header: [
                "Authorization" : "Bearer \(accessToken!)"
            ]
        ){(data, resp, err) in
            if err != nil {
                completionHandler(Dictionary<String, String>(), MediaStorageError(statusCode: nil, message: "request failed: \(err!.code): \(err!.domain)"))
                return
            }

            let httpresp = resp as! NSHTTPURLResponse
            let statusCode = httpresp.statusCode
            let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
            if !httpresp.isSucceeded() {
                completionHandler(
                    Dictionary<String, String>(),
                    MediaStorageError(statusCode: statusCode, message: "received error: \(dataString)")
                )
                return
            }

            var dataDic = Dictionary<String, String>()
            if isUserKey {
                dataDic[userMetaKey] = dataString

            } else  {
                do {
                    dataDic = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! [String : String]
                } catch {
                    completionHandler(
                        Dictionary<String, String>(),
                        MediaStorageError(statusCode: statusCode, message: "invalid response: \(dataString)")
                    )
                }

            }

            completionHandler(
                dataDic,
                MediaStorageError(statusCode: nil, message: nil)
            )

        }
    }

    public func removeMeta(mediaId mediaId: String!, fieldName: String!, completionHandler: MediaStorageError -> Void) {
        if accessToken == nil {
            completionHandler(MediaStorageError(statusCode: nil, message: "wrong usage: use the connect method to get an access token."))
            return
        }

        var url : String
        var userMetaKey = ""
        if fieldName == nil {
            completionHandler(MediaStorageError(statusCode: nil, message: "invalid parameter: \(fieldName)"))
            return
        } else if fieldName == metaUser {
            // DELETE /media/{id}/meta/user
            url = "\(mstorageEndpoint)/\(mediaId)\(getUserMetaPath)"
        } else {
            userMetaKey = replaceUserMeta(fieldName)
            if userMetaKey.isEmpty {
                completionHandler(MediaStorageError(statusCode: nil, message: "invalid parameter: \(fieldName)"))
                return
            } else {
                // DELETE /media/{id}/meta/user/{key}
                url = "\(mstorageEndpoint)/\(mediaId)\(getUserMetaPath)/\(userMetaKey)"
            }
        }
        MediaStorageRequest.delete(
            url: url,
            header: [
                "Authorization" : "Bearer \(accessToken!)"
            ]
        ){(data, resp, err) in
            if err != nil {
                completionHandler(MediaStorageError(statusCode: nil, message: "request failed: \(err!.code): \(err!.domain)"))
                return
            }

            let httpresp = resp as! NSHTTPURLResponse
            let statusCode = httpresp.statusCode
            let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
            if !httpresp.isSucceeded() {
                completionHandler(
                    MediaStorageError(statusCode: statusCode, message: "received error: \(dataString)")
                )
                return
            }

            completionHandler(
                MediaStorageError(statusCode: nil, message: nil)
            )
        }
    }

    private func replaceUserMeta (userMeta: String!) -> String{
        let replacedString = userMeta.stringByReplacingOccurrencesOfString(replaceUserMetaRegex, withString: firstGroupRegex, options: NSStringCompareOptions.RegularExpressionSearch, range: nil)

        return replacedString == userMeta ? "" : replacedString

    }
    
    private func isValidValue(value: String) -> Bool{
        return (value.characters.count >= minUserMetaLength && value.characters.count <= maxUserMetaLength)
    }
    
}
