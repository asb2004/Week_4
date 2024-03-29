//
//  ViewController.swift
//  iOS_015
//
//  Created by DREAMWORLD on 04/03/24.
//

import UIKit
import SDWebImage

class ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var loaderView: UIActivityIndicatorView!
    
    private var imageCash = NSCache<AnyObject, UIImage>()
    
    var users: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        title = "Users Data"
        navigationController?.navigationBar.prefersLargeTitles = true
        
//        self.startLoader()
//
//        getData() { [weak self] (users) in
//            self?.users = users
//            DispatchQueue.main.async {
//                self?.tableView.reloadData()
//            }
//        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("will appear")
        self.startLoader()
        
        getData() { [weak self] (users) in
            self?.users.removeAll()
            self?.users = users
            DispatchQueue.main.async {
                self?.stopLoader()
                self?.tableView.reloadData()
            }
        }
    }
    
    @IBAction func addUserView(_ sender: UIBarButtonItem) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "AddUserViewController") as! AddUserViewController
//        vc.passUser = { (newUserData) in
//            self.users.insert(User(userID: newUserData.id,
//                                   name: newUserData.name,
//                                   email: newUserData.email,
//                                   profilePic: newUserData.profilePic),
//                              at: 0)
//            self.tableView.reloadData()
//        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func PageViewButtonTapped(_ sender: UIBarButtonItem) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "PaginationViewController") as! PaginationViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func getData(completionHandler: @escaping ([User]) -> Void) {
        let url = URL(string: "http://192.168.29.41/blog/api/get_user_list")!
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            
            self.stopLoader()
            
            if let error = error {
                print(error)
                return
            }
            
            if let jsonData = data {
                if let userData = try? JSONDecoder().decode(Blog.self, from: jsonData) {
                    completionHandler(userData.data)
                }
            }
            
        })
        
        task.resume()
    }
    
    func deleteData(id: Int, completionHandler: @escaping (Bool) -> Void) {
        let url = URL(string: "http://192.168.29.41/blog/api/delete_user")!
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        let parameters: [String: Int] = ["user_id": id]
        let data = try? JSONEncoder().encode(parameters)
        request.httpBody = data
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if let error = error {
                print(error)
                return
            }
            
            if let response = response as? HTTPURLResponse, 200 == response.statusCode {
                completionHandler(true)
                
            } else {
                completionHandler(false)
            }
        })
        task.resume()
    }


}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CustomTableViewCell
        cell.nameLabel.text = users[indexPath.row].name
        cell.emailLabel.text = users[indexPath.row].email
        
        let imageURL = URL(string: users[indexPath.row].profilePic)!
        cell.profileImage.sd_setImage(with: imageURL, placeholderImage: UIImage(systemName: "person"))
        
        //cell.profileImage.loadImage(imageURL: imageURL)

//        let imageData = try? Data(contentsOf: imageURL)
//        cell.profileImage.image = UIImage(data: imageData!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteButton = UIContextualAction(style: .destructive, title: "Delete", handler: { (action, view, handler) in
            
            self.startLoader()
            
            self.deleteData(id: self.users[indexPath.row].userID) { [weak self] (status) in
                if status {
                    self?.users.remove(at: indexPath.row)
                    DispatchQueue.main.async {
                        self?.stopLoader()
                        self?.tableView.reloadData()
                    }
                } else {
                    print("not deleted")
                }
            }
        })
        
        return UISwipeActionsConfiguration(actions: [deleteButton])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "AddUserViewController") as! AddUserViewController
        vc.isExistingUser = true
        vc.user = users[indexPath.row]
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func startLoader() {
        loaderView.isHidden = false
        loaderView.startAnimating()
    }
    
    func stopLoader() {
        DispatchQueue.main.async {
            self.loaderView.isHidden = true
            self.loaderView.stopAnimating()
        }
    }
}

class TextField: UITextField {

    let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}



