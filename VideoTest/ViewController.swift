//
//  ViewController.swift
//  VideoTest
//
//  Created by Krevetka Vsoyse on 06/06/2019.
//  Copyright © 2019 Krevetka Vsoyse. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class ViewController: UIViewController {
    
    
    let vc = AVPlayerViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func openVideoPicker(_ sender: Any) {
        
    }
    
    @IBAction func getVideo(_ sender: Any) {
        let url = URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")!
        playVideo(url: url)
    }
    
    func playVideo(url: URL) {
        vc.player = AVPlayer(url: url)
        self.present(vc, animated: true) { self.vc.player?.play() }
    }
//    func uploadMedia(video: Data?, fileName: String){
//
//        guard let url = URL(string: "http://devops.api.wd.trezub.ru/medicine/files/save_file/") else {return}
//        var request = URLRequest(url: url)
//
//        request.httpMethod = "POST"
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        request.setValue("", forHTTPHeaderField: "Authorization")
//
//        if let data = video {
//
//            let json : [String: Any] = ["form-data": "mp4",
//                                        "key": data.base64EncodedString(),
//                                        "value": fileName]
//            let jsonData = try? JSONSerialization.data(withJSONObject: json)
//            request.httpBody = jsonData
//
//            URLSession.shared.dataTask(with: request) { data, response, error in
//                if let data = data {
//                    if let jsonString = String(data: data, encoding: .utf8) {
//                        print(jsonString)
//                    }
//                }
//                }.resume()
//        }
//    }
}

