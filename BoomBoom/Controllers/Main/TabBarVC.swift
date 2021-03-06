//
//  TabBarVC.swift
//  BoomBoom
//
//  Created by Hikmatillo Habibullaev on 9/14/19.
//  Copyright © 2019 Hikmatillo Habibullaev. All rights reserved.
//

import UIKit
import SDWebImage
class TabBarVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.tabBarController?.hidesBottomBarWhenPushed = true
        
        //set token for image downloader
        let token = UserDefaults.standard.value(forKey: "token") ?? ""
        let downloader = SDWebImageDownloader.shared
        downloader.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        SocketManager.current.connect()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
