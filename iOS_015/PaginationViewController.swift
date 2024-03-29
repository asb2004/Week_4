//
//  PaginationViewController.swift
//  iOS_015
//
//  Created by DREAMWORLD on 08/03/24.
//

import UIKit
import Alamofire
import SDWebImage
import AVKit

class PaginationViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startLoader: UIActivityIndicatorView!
    
    var postDataArray: [PostDataArray] = []
    var pageCounter = 1
    var totalPage = 3
    
    var loader: UIActivityIndicatorView!
    
    var currentIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Posts"

        tableView.delegate = self
        tableView.dataSource = self

        
//        loadData(pageNo: 1) { [weak self] (response) in
//            if response.status {
//                self?.postDataArray = response.data.postDataArray
//                DispatchQueue.main.async {
//                    self?.tableView.reloadData()
//                }
//            }
//        }
        
        startLoader.isHidden = false
        startLoader.startAnimating()
        loadNextData()
    }
    
    func loadNextData() {
        loadData(pageNo: pageCounter) { [weak self] (response) in
            if response.status {
                self?.postDataArray.append(contentsOf: response.data.postDataArray)
                DispatchQueue.main.async {
                    if self?.pageCounter == 2 {
                        self?.startLoader.isHidden = true
                        self?.startLoader.stopAnimating()
                    }
                    if response.currentPageItemCount == 0 {
                        self?.tableView.tableFooterView?.isHidden = true
                        self?.totalPage = response.currentPage
                        print("no data found")
                    }
                    self?.tableView.tableFooterView?.isHidden = false
                    self?.tableView.reloadData()
                }
            }
        }
        pageCounter += 1
        totalPage += 1
    }
    
    func loadData(pageNo: Int, completionHandler: @escaping (PostsResponse) -> Void) {
        let url = URL(string: "http://88.208.196.241/Staging/api/user_post_list_testing")!
        
        let perameter = ["post_page_no": pageNo, "post_page_item":10]
        let headers: HTTPHeaders = ["UserId": "12"]
        
        AF.request(url,
                   method: .post,
                   parameters: perameter,
                   encoding: URLEncoding.default,
                   headers: headers)
            .responseDecodable(of: PostsResponse.self) { (response) in
                switch response.result {
                case .success(let data):
                    completionHandler(data)
                case .failure(let error):
                    print(error)
                }
            }
    }

}

extension PaginationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell") as! PostTableViewCell
        cell.userName.text = "\(postDataArray[indexPath.row].postUserName) id: \(postDataArray[indexPath.row].postID)"
        cell.videoButton.isHidden = true
        if postDataArray[indexPath.row].postUserProfilePic == "" {
            cell.profilePic.image = UIImage(systemName: "person.fill")
        } else {
            let imageURL = URL(string: postDataArray[indexPath.row].postUserProfilePic)!
            cell.profilePic.sd_setImage(with: imageURL, placeholderImage: UIImage(systemName: "person.fill"))
        }
        
        cell.postDiscription.text = postDataArray[indexPath.row].postDesc
        
        if postDataArray[indexPath.row].imageData.count == 0 {
            cell.postImage.image = UIImage(named: "placeholder")
        } else {
            let postImageURL = URL(string: postDataArray[indexPath.row].imageData[0].postImage)!
            
            let fileName = postImageURL.lastPathComponent
            if fileName.components(separatedBy: ["."])[1] == "mp4" {
                cell.videoButton.isHidden = false
                if postDataArray[indexPath.row].imageData[0].videoThumb != "" {
                    let postVideoImageURL = URL(string: postDataArray[indexPath.row].imageData[0].videoThumb)!
                    cell.postImage.sd_setImage(with: postVideoImageURL, placeholderImage: UIImage(named: "placeholder"))
                    cell.isVideoCell = true
                    
                    cell.player = AVPlayer(url: postImageURL)
                    
                }
            } else {
                cell.isVideoCell = false
                cell.postImage.sd_setImage(with: postImageURL, placeholderImage: UIImage(named: "placeholder"))
            }
           // cell.postImage.sd_setImage(with: postImageURL, placeholderImage: UIImage(named: "placeholder"))
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let videoCell = cell as! PostTableViewCell
        if videoCell.isVideoCell {
            videoCell.player.pause()
            videoCell.playerLayer.removeFromSuperlayer()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
            guard let visibleIndexPaths = tableView.indexPathsForVisibleRows else { return }
            
            for indexPath in visibleIndexPaths {
                if let cell = tableView.cellForRow(at: indexPath) as? PostTableViewCell {
                    let intersectingRect = tableView.rectForRow(at: indexPath).intersection(tableView.bounds)
                    let visibleHeight = intersectingRect.height
                    
                    if visibleHeight == cell.bounds.height {
                        // Cell is fully visible, play video
                        if currentIndexPath != indexPath {
                            if cell.isVideoCell {
//                                currentIndexPath = indexPath
//                                let playerLayer = AVPlayerLayer(player: cell.player)
//                                playerLayer.videoGravity = .resizeAspect
//                                playerLayer.frame = cell.postImage.bounds
//                                cell.postImage.layer.addSublayer(playerLayer)
//                                cell.playerLayer = playerLayer
//                                cell.player.seek(to: .zero)
                                cell.player.play()
                                
//                                let reset = {
//                                    cell.player.pause()
//                                    cell.player.seek(to: .zero)
//                                    cell.player.play()
//                                }
//
//                                NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: cell.player.currentItem, queue: nil) { notification in
//                                    reset()
//                                }
                            }
                        }
                    } else {
                        // Cell is not fully visible, stop video
                        if cell.isVideoCell {
                            cell.player.pause()
                            currentIndexPath = nil
                        }
                    }
                }
            }
        }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let videoCell = cell as! PostTableViewCell
        if videoCell.isVideoCell {
            let playerLayer = AVPlayerLayer(player: videoCell.player)
            playerLayer.videoGravity = .resizeAspect
            playerLayer.frame = videoCell.postImage.bounds
            videoCell.postImage.layer.addSublayer(playerLayer)
            videoCell.playerLayer = playerLayer
            videoCell.player.seek(to: .zero)
            //videoCell.player.play()

            let reset = {
                videoCell.player.pause()
                videoCell.player.seek(to: .zero)
                videoCell.player.play()
            }

            NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: videoCell.player.currentItem, queue: nil) { notification in
                reset()
            }
        }
        
        if indexPath.row == postDataArray.count - 1 && totalPage >= pageCounter {
            loadNextData()
            loader = UIActivityIndicatorView()
            loader.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
            self.tableView.tableFooterView = loader
            self.tableView.tableFooterView?.isHidden = false
        } else {
            self.tableView.tableFooterView?.isHidden = true
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 550.0
    }
}
