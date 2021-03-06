//
//  NewsVC.swift
//  BoomBoom
//
//  Created by Hikmatillo Habibullaev on 9/11/19.
//  Copyright © 2019 Hikmatillo Habibullaev. All rights reserved.
//

import UIKit
import PeekPop
import SDWebImage

class NewsVC: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate, PeekPopPreviewingDelegate, UIScrollViewDelegate {
    
    var peekPop: PeekPop?
    
    @IBOutlet weak var starredCollectionV: UICollectionView!
    @IBOutlet weak var photoCollectionV: UICollectionView!
    let cellWidth = UIScreen.main.bounds.size.width/3
    let screenWidth = UIScreen.main.bounds.width
    
    var loadingView: UIView = UIView()
    var spinner = UIActivityIndicatorView(style: .whiteLarge)
    
    //data models
    var firstTop100Photo:Top100Account?
    var newAccounts:[NewAccount] = []
    var topPaidList:[NewAccount] = []
    //for 3d touch
    var chosenIndex = -1
    
    var refreshControl: UIRefreshControl?
    
    //static vars
    var token:String = UserDefaults.standard.value(forKey: "token") as! String
    let language:String = UserDefaults.standard.value(forKey: "language") as? String ?? "en"
    let baseURL = Constants.HTTP.PATH_URL
    
    var pageNo:CLong=0
    var isLastPage:Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        starredCollectionV.delegate = self
        starredCollectionV.dataSource = self
        photoCollectionV.delegate = self
        photoCollectionV.dataSource = self
        
        photoCollectionV.collectionViewLayout = MosaicLayout()
        
        peekPop = PeekPop(viewController: self)
        peekPop?.registerForPreviewingWithDelegate(self, sourceView: photoCollectionV)
        
        //настраиваем refreshControl
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
                
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Загрузка ...", attributes: attributes)
        
        refreshControl?.tintColor = UIColor.white
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.photoCollectionV?.addSubview(refreshControl!)
        
        getAllPhotos(token:token, lang: language, page: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    //MARK: - refreshing
//    var canRefresh = true
//
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//
//        if scrollView.contentOffset.y < -100 {
//
//            if canRefresh && !self.refreshControl!.isRefreshing {
//
//                self.canRefresh = false
//                self.refreshControl!.beginRefreshing()
//
//                self.refresh(sender: self)
//            }
//        }else if scrollView.contentOffset.y >= 0 {
//
//            self.canRefresh = true
//        }
//    }
    
    @objc func refresh(sender:AnyObject) {
        newAccounts.removeAll()
        topPaidList.removeAll()
        
        photoCollectionV?.reloadData()
        starredCollectionV.reloadData()
        pageNo = 0
        self.isLastPage = false
        getAllPhotos(token: token, lang: language, page: 0)
    }
    
    //MARK: - CollectionView dataSource and delegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == starredCollectionV {
            return topPaidList.count
        } else if newAccounts.count>0 {
            return newAccounts.count + 1
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == starredCollectionV {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.NAME_CELL.STARRED_NEWS_CELL, for: indexPath) as! StarredNewsCell
            cell.placeLbl.text = topPaidList[indexPath.row].cities.title
            cell.timeLbl.text = "\(topPaidList[indexPath.row].name), \(Utils.current.comuteAge(topPaidList[indexPath.row].dateBirth ))"
            if (topPaidList[indexPath.row].photos.count>0){
                let url = baseURL + "/" + topPaidList[indexPath.row].photos[0].pathURLPreview
                cell.userImgView?.sd_setImage(with: URL(string: url), placeholderImage: nil, options: .refreshCached)
            } else {
                cell.userImgView?.image = UIImage(named: "default_ava")
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.NAME_CELL.NEWS_PHOTO_CELL, for: indexPath) as! NewsPhotoCell
            if (indexPath.row == 0) {
                cell.photoImgView.frame.size = CGSize(width: cellWidth*2 + 1, height: cellWidth*2 + 1)
                if (firstTop100Photo != nil) {
                    let url = baseURL + "/" + (firstTop100Photo?.pathURLPreview ?? "")
                    cell.photoImgView?.sd_setImage(with: URL(string: url), placeholderImage: nil, options: .refreshCached)
                } else {
                    cell.photoImgView.image = UIImage(named: "default_ava")
                }
            } else {
                cell.photoImgView.frame.size = CGSize(width: cellWidth + 1, height: cellWidth + 1)
                let account = newAccounts[indexPath.row-1]
                if account.photos.count>0{
                    let url = baseURL + "/" + (account.photos[0].pathURLPreview )
                    cell.photoImgView?.sd_setImage(with: URL(string: url), placeholderImage: nil, options: .refreshCached)
                } else {
                    cell.photoImgView.image = UIImage(named: "default_ava")
                }
            }
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == starredCollectionV{
            guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "LikePhotoVC") as? LikePhotoVC else { return }
            detailVC.userID = topPaidList[indexPath.row].id
            show(detailVC, sender: self)
        } else {
            if indexPath.row == 0 {
                guard let top100VC = storyboard?.instantiateViewController(withIdentifier: "Top100VC") as? Top100VC else { return }
                show(top100VC, sender: self)
            } else {
                guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "LikePhotoVC") as? LikePhotoVC else { return }
                detailVC.userID = newAccounts[indexPath.row-1].id
    //            detailVC.modalPresentationStyle = .popover
    //            self.present(detailVC, animated: true, completion: nil)
                show(detailVC, sender: self)
            }
        }
    }
    
    //load new photos
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == self.photoCollectionV && indexPath.row != 0{
            let lastRow = indexPath.row
            if lastRow == newAccounts.count {
                if !isLastPage{
                    pageNo = pageNo + 1
                    getNewAccountPhotos(token: token, lang: language, page: pageNo)
                }
            }
        }
    }
    
    //for starred CollectionVeiw
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == starredCollectionV {
            return CGSize(width: screenWidth/5, height: 120.0)
        } else {
            return (collectionView.cellForItem(at: indexPath)?.frame.size)!
        }
    }
    
    
    //MARK: - 3d Touch
    func previewingContext(_ previewingContext: PreviewingContext, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = photoCollectionV?.indexPathForItem(at: location) else { return nil }
        if indexPath == IndexPath(item: 0, section: 0) {
            return nil
        }
        chosenIndex = indexPath.row
        guard let cell = photoCollectionV?.cellForItem(at: indexPath) as? NewsPhotoCell else { return nil }
        guard let preview = storyboard?.instantiateViewController(withIdentifier: "PreviewVC") as? PreviewVC else { return nil }
        previewingContext.sourceRect = cell.frame
        preview.img = cell.photoImgView.image
        
        return preview
    }
    
    func previewingContext(_ previewingContext: PreviewingContext, commitViewController viewControllerToCommit: UIViewController) {
         guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "LikePhotoVC") as? LikePhotoVC else { return }
        detailVC.userID = newAccounts[chosenIndex-1].id
        show(detailVC, sender: self)
//        detailVC.modalPresentationStyle = .popover
//        self.present(detailVC, animated: true, completion: nil)
    }
    
    //MARK: - API calls
    func getAllPhotos(token:String, lang:String, page:Int){
        if !(self.refreshControl?.isRefreshing ?? false){
            showActivityIndicator(loadingView: loadingView, spinner: spinner)
        }
        self.getTop(token: token, lang: lang)
        NewsService.current.getFirstTop100Photo(token: token, lang: lang) { (photoModel, error) in
            DispatchQueue.main.async {
                self.getNewAccountPhotos(token: token, lang: lang, page: page)
                if error == nil {
                    self.firstTop100Photo = photoModel?.first
                } else if error?.code == 401 {
                    let domain = Bundle.main.bundleIdentifier!
                    UserDefaults.standard.removePersistentDomain(forName: domain)
                    UserDefaults.standard.synchronize()
                    //self.performSegue(withIdentifier: "showAuth", sender: self)
                    self.setNewRootController(nameController: "AuthorizationVC")
                } else {
                    self.hideActivityIndicator(loadingView: self.loadingView, spinner: self.spinner)
                    self.showErrorWindow(errorMessage: error?.domain ?? "")
                }
            }
        }
    }
    
    func getNewAccountPhotos(token:String, lang:String, page:Int){
        NewsService.current.getNewAccounts(token: token, lang: lang, page: page) { (photoListModel, error) in
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
                self.hideActivityIndicator(loadingView: self.loadingView, spinner: self.spinner)
                if error == nil {
                    if ((photoListModel?.count ?? 0) > 0){
                        self.isLastPage = false
                        self.newAccounts = self.newAccounts + (photoListModel ?? [])
                        self.photoCollectionV.reloadData()
                    } else {
                        self.hideActivityIndicator(loadingView: self.loadingView, spinner: self.spinner)
                        self.isLastPage = true
                    }
                } else if error?.code == 401 {
                    let domain = Bundle.main.bundleIdentifier!
                    UserDefaults.standard.removePersistentDomain(forName: domain)
                    UserDefaults.standard.synchronize()
                    //self.performSegue(withIdentifier: "showAuth", sender: self)
                    self.setNewRootController(nameController: "AuthorizationVC")
                } else {
                    self.showErrorWindow(errorMessage: error?.domain ?? "")
                }
            }
        }
    }
    
    func getTop(token:String, lang:String){
        NewsService.current.getTopPaid(token: token, lang: lang) { (accountsList, error) in
            DispatchQueue.main.async {
                if error == nil {
                    self.topPaidList = accountsList ?? []
                    self.starredCollectionV.reloadData()
                } else if error?.code == 401 {
                    let domain = Bundle.main.bundleIdentifier!
                    UserDefaults.standard.removePersistentDomain(forName: domain)
                    UserDefaults.standard.synchronize()
                   // self.performSegue(withIdentifier: "showAuth", sender: self)
                    self.setNewRootController(nameController: "AuthorizationVC")
                } else {
                    self.showErrorWindow(errorMessage: error?.domain ?? "")
                }
            }
        }
    }
}
