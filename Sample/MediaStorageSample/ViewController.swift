//
//  Copyright (c) 2016 Ricoh Company, Ltd. All Rights Reserved.
//  See LICENSE for more information
//

import UIKit
import MediaStorage
import RicohAPIAuth

class ViewController: UIViewController {
    
    var authClient = AuthClient(
        clientId: "### enter your client ID ###",
        clientSecret: "### enter your client secret ###"
    )
    var mstorage: MediaStorage?
    
    @IBAction func tapHandler(sender: AnyObject) {
        authClient.setResourceOwnerCreds(
            userId: "### enter your user id ###",
            userPass: "### enter your user password ###"
        )
        mstorage = MediaStorage(authClient: authClient)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.mstorage!.connect(){result, error in
                if error.isEmpty() {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.resultTextField.text = "connect!"
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.resultTextField.text = "ERROR: \(error)"
                    })
                }
            }
        })
    }
    
    @IBOutlet weak var resultTextField: UITextField!
    
    @IBAction func getMediaIdButtonHandler(sender: AnyObject) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.mstorage!.list(){result, error in
                if error.isEmpty() {
                    var idArray = [String]()
                    let mediaList: Array = result.mediaList
                    for media in mediaList {
                        idArray.append(media.id)
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        self.mediaIdListTextView.text = idArray.joinWithSeparator("\n")
                        self.getMediaIdListResultTextField.text = "finished"
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.getMediaIdListResultTextField.text = "ERROR: \(error)"
                    })
                }
            }
        })
    }
    
    @IBOutlet weak var mediaIdListTextView: UITextView!
    
    @IBOutlet weak var getMediaIdListResultTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
