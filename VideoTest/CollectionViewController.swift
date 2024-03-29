//
//  CollectionViewController.swift
//  VideoTest
//
//  Created by Krevetka Vsoyse on 06/06/2019.
//  Copyright © 2019 Krevetka Vsoyse. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation
import AVKit

class CollectionViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var controller = UIImagePickerController()
    let videoFileName = "/video.mp4"
    var videoPath: URL?
    var imageVideo: UIImage?
    var timeSecond: Double?
    let vc = AVPlayerViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            controller.sourceType = .camera
            controller.videoQuality = .typeIFrame1280x720
            controller.mediaTypes = [kUTTypeMovie as String]
            controller.delegate = self
            controller.videoMaximumDuration = 10
            present(controller, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Камера не найдена", message: "На этом устройстве нет камеры", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallerey() {
        controller.sourceType = .photoLibrary
        controller.delegate = self
        controller.mediaTypes = ["public.movie"]
        controller.videoQuality = .typeIFrame1280x720
        present(controller, animated: true, completion: nil)
    }
    
    func playVideo(url: URL) {
        vc.player = AVPlayer(url: url)
        self.present(vc, animated: true) { self.vc.player?.play() }
    }
    
    func uploadMedia(video: Data?, fileName: String){

        guard let url = URL(string: "http://devops.api.wd.trezub.ru/medicine/files/save_file/") else {return}
        var request = URLRequest(url: url)
        print(fileName)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX3JvbGVfdHlwZSI6MiwibGljZW5zZV92ZXJzaW9uIjoic3BlY2lhbGlzdCAxLjEiLCJqdGkiOiJmOGRmNTZjMjFmNjQ0ZTRmYjc0M2NhNDY3MDllMmI4NiIsImV4cCI6MTU2MjI1MzY5OCwidG9rZW5fdHlwZSI6ImFjY2VzcyIsImRkZGMiOjEsInVzZXJfcm9sZV9pZCI6MTQ1Nzc3LCJ1c2VyX2lkIjoxMDAzOH0.1Vh7_G1bQEjnr0_nGmVMEoyAkXjQ1dBtHCMyZV-yGrQ", forHTTPHeaderField: "Authorization")

        if let data = video {

            let json: [String: Any] = ["form-data": "mp4",
                                        "key": data.base64EncodedString(),
                                        "value": fileName]
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            request.httpBody = jsonData

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let dataa = data {
                    if let jsonString = String(data: dataa, encoding: .utf8) {
                        print(jsonString)
                    }
                }
            }.resume()
        }
    }
}

extension CollectionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 1
        if let selectedVideo: URL = (info[.mediaURL] as? URL) {
            // Save video to the main photo album
            let selectorToCall = #selector(CollectionViewController.videoSaved(_: didFinishSavingWithError:context:))
            
            // 2
            UISaveVideoAtPathToSavedPhotosAlbum(selectedVideo.relativePath, self, selectorToCall, nil)
            // Save the video to the app directory
            let videoData = try? Data(contentsOf: selectedVideo)
            let bcf = ByteCountFormatter()
            bcf.allowedUnits = [.useMB] // optional: restricts the units to MB only
            bcf.countStyle = .file
            let string = bcf.string(fromByteCount: Int64(videoData!.count))
            print("formatted result: \(string)")
        
            let paths = NSSearchPathForDirectoriesInDomains( .documentDirectory, .userDomainMask, true)
            var documentsDirectory: URL = URL(fileURLWithPath: paths[0])
            let dataPath = documentsDirectory.appendingPathComponent(videoFileName)
            print(dataPath)
            documentsDirectory.appendPathExtension(".mp4")
            try? videoData?.write(to: dataPath, options: [])
            uploadMedia(video: videoData, fileName: dataPath.absoluteString)
        }
        // 3
        picker.dismiss(animated: true)
    }
    @objc func videoSaved(_ video: String, didFinishSavingWithError error: NSError!, context: UnsafeMutableRawPointer) {
        if let theError = error {
            print("error saving the video = \(theError)")
        } else {
            DispatchQueue.main.async(execute: { () -> () in
                
                self.imageVideo = self.generateThumbnail(path: URL(fileURLWithPath: "file://\(video)"))
                self.collectionView.reloadData()
               // self.playVideo(url: URL(fileURLWithPath: "file://\(video)"))
            })
        }
    }
    
    
    func generateThumbnail(path: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: path, options: nil)
            timeSecond = asset.duration.seconds
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
}

extension CollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCell", for: indexPath) as? CollectionViewCell else { return UICollectionViewCell() }
        if indexPath.row == 0 {
            cell.imageView.image = #imageLiteral(resourceName: "placeholder-10")
        } else if indexPath.row == 1 {
            cell.imageView.image = imageVideo
            cell.imageTimerLabel.text = "0:\(timeSecond?.toInt() ?? 0)"
        } else {
            cell.imageView.backgroundColor = .black
            cell.imageTimerLabel.text = nil
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            openCamera()
        } else if indexPath.row == 1 {
            openGallerey()
        }
    }
}

extension CollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 3 - 1
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
}
extension Double {
    func toInt() -> Int? {
        if self >= Double(Int.min) && self < Double(Int.max) {
            return Int(self)
        } else {
            return nil
        }
    }
}
