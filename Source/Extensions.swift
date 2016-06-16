//
//  Copyright (c) 2016 Ricoh Company, Ltd. All Rights Reserved.
//  See LICENSE for more information
//

import Foundation

extension NSHTTPURLResponse {
    func isSucceeded() -> Bool {
        return (200..<300).contains(self.statusCode)
    }
}
