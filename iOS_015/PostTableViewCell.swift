//
//  PostTableViewCell.swift
//  iOS_015
//
//  Created by DREAMWORLD on 08/03/24.
//

import UIKit
import AVFoundation
import AVKit

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var postView: UIView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var postDiscription: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    
    var isVideoCell = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.postView.layer.cornerRadius = 10.0
        self.profilePic.layer.cornerRadius = profilePic.frame.height / 2
        
        postImage.isUserInteractionEnabled = true
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(imagePinch(_:)))
        postImage.addGestureRecognizer(pinchGesture)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    @objc func imagePinch(_ sender: UIPinchGestureRecognizer) {
        if sender.state == .ended || sender.state == .changed {

            if sender.state == .changed {
                let currentScale = postImage.frame.size.width / postImage.bounds.size.width
                var newScale = currentScale * sender.scale
                
                // Limit zooming to a certain range
                if newScale < 1 {
                    newScale = 1
                }
                if newScale > 3 {
                    newScale = 3
                }
                
                let transform = CGAffineTransform(scaleX: newScale, y: newScale)
                postImage.transform = transform
                sender.scale = 1
            }

        }
    }

    @IBAction func playVideoTapped(_ sender: UIButton) {
//        player?.play()
        print("start")
    }
}
