//
//  ViewController.swift
//  Liyana New Project
//
//  Created by LIYANA on 26/11/18.
//  Copyright © 2018 LIYANA. All rights reserved.
//

import UIKit

class ViewController: UIViewController , UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var appTableView: UITableView!
    var appDataArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let  urlString = "https://rss.itunes.apple.com/api/v1/us/ios-apps/top-free/all/5/explicit.json"
        getAppDetails(AppStoreURL: urlString, onSuccess:{ (data) in
            if let recievedData = data as? NSArray {
                if recievedData.count > 0 {
                    self.appDataArray.addObjects(from: recievedData as! [Any])
                    DispatchQueue.main.async {
                        self.appTableView.reloadData()
                    }
                }
            }
        }) {(error) in
            print(error.localizedDescription)
        }
    }
    func getAppDetails(AppStoreURL:String, onSuccess:@escaping ((Any)->Void), onFailure:@escaping ((Error)->Void)){
        let url = URL(string: AppStoreURL)
        let urlRequest = URLRequest(url: url!)
        let dataTask = URLSession.shared.dataTask(with: urlRequest as URLRequest){data,response,error in
            if (data != nil) {
                do {
                    let dataResponse = try JSONSerialization.jsonObject(with: data!, options: [])
                    let receivedData = (((dataResponse as! NSDictionary).value(forKey: "feed") as! NSDictionary).value(forKey: "results"))
                    onSuccess(receivedData  ?? NSArray() )
                } catch let error {
                    onFailure(error)
                    print(error.localizedDescription)
                }
            }
        }
        dataTask.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.appDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = appTableView.dequeueReusableCell(withIdentifier: "tableCell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "tableCell")
        }
        
        if let appDict = self.appDataArray.object(at: indexPath.row) as? NSDictionary {
            cell?.textLabel?.text = appDict.value(forKey: "artistName") as? String
            
            let  imageUrl = URL(string: appDict.value(forKey: "artworkUrl100") as! String)
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: imageUrl!)
                if let data = data {
                    let  image = UIImage(data: data)
                    DispatchQueue.main.async {
                        cell?.imageView?.image = image
                    }
                }
            }
        } else {
            cell?.textLabel?.text = "Not found"
            cell?.imageView?.image = nil
        }
        
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

