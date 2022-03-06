//
//  ViewController.swift
//  BackgroundApp
//
//  Created by Cheng Peng on 2022-02-24.
//

import Cocoa
import AppKit

class ViewController: NSViewController {
    let defaults = UserDefaults.standard

    @IBOutlet weak var AccessKeyInput: NSTextField!
    
    @IBOutlet weak var SecretKeyInput: NSTextField!

    @IBOutlet weak var ProgressView: NSProgressIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ProgressView.startAnimation(nil)
        self.ProgressView.isHidden = true

        let accessKey = UserDefaults.standard.string(forKey: "AccessKey")
        
        if accessKey != nil{
            self.AccessKeyInput.stringValue = accessKey!
        }
        
        let secretKey = UserDefaults.standard.string(forKey: "SecretKey")
        
        if secretKey != nil{
            self.SecretKeyInput.stringValue = secretKey!
        }
    }

    @IBAction func ShuffleBackground(_ sender: Any) {
        self.ProgressView.isHidden = false
        // Prepare URL
        let url = URL(string: "https://api.unsplash.com/photos/random")
        guard let requestUrl = url else { fatalError() }
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
 
        request.addValue("Client-ID \(self.AccessKeyInput.stringValue)", forHTTPHeaderField: "Authorization")

        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                // Check for Error
            if error != nil {
                self.ProgressView.isHidden = true
                return
            }
            do{
                // Convert HTTP Response Data to a String
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print(dataString)
                    let json = dataString.data(using: .utf8)
                    let decoder = JSONDecoder()
                    let result  = try decoder.decode(ImageModel.self, from: json!)

                    let imagePath = "/Users/chengpeng/Downloads/BackgroundAppImages/\(Date()).jpg"
                    
                    self.download(url: result.links.download, toFile: imagePath) { err in
                        if err == nil{
                            self.setBackground(imagePath: imagePath)
                        }
                    }
                }
            } catch{
                DispatchQueue.main.async {
                    self.ProgressView.isHidden = true
                }
                print(error)
            }
        }
        task.resume()
    }
    
    
    private func download(url: String, toFile file: String, completion: @escaping (Error?) -> Void) {
        let link = URL(string: url)
        
        // Download the remote URL to a file
        let task = URLSession.shared.downloadTask(with: link!) {
            (tempURL, response, error) in
            // Early exit on error
            guard let tempURL = tempURL else {
                completion(error)
                return
            }

            do {
                
                let filePath = URL(fileURLWithPath: file)
                // Remove any existing document at file
                if FileManager.default.fileExists(atPath: filePath.path) {
                    try FileManager.default.removeItem(at: filePath)
                }

                // Copy the tempURL to file
                try FileManager.default.copyItem(
                    at: tempURL,
                    to: filePath
                )

                UserDefaults.standard.set(self.AccessKeyInput.stringValue, forKey: "AccessKey")
                UserDefaults.standard.set(self.SecretKeyInput.stringValue, forKey: "SecretKey")
                
                completion(nil)
            }

            // Handle potential file system errors
            catch{
                completion(error)
            }
        }

        // Start the download
        task.resume()
    }
    
    private func setBackground(imagePath: String){
        do {
            let imageURL = URL(fileURLWithPath: imagePath)
            if let screen = NSScreen.main {
                try NSWorkspace.shared.setDesktopImageURL(imageURL, for: screen, options: [:])
            }
            DispatchQueue.main.async {
                self.ProgressView.isHidden = true
            }
        } catch {
            DispatchQueue.main.async {
                self.ProgressView.isHidden = true
            }
            print(error)
        }
    }
}
