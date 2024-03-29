//
//  AddUserViewController.swift
//  iOS_015
//
//  Created by DREAMWORLD on 04/03/24.
//

import UIKit
import Alamofire

class AddUserViewController: UIViewController {
    
    @IBOutlet var tfEmail: TextField!
    @IBOutlet var tfName: TextField!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var loader: UIActivityIndicatorView!
    
    var isImagePicked = false
    var passUser: ((AddedUser) -> Void)?
    
    var isExistingUser = false
    var user: User!
    var passUpdatedUser: ((UpdateUser) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImage.layer.cornerRadius = profileImage.frame.height / 2
        tfName.layer.cornerRadius = 10.0
        tfEmail.layer.cornerRadius = 10.0
        saveButton.layer.cornerRadius = 25.0
        
        
        profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileImageTapped)))
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
        loader.isHidden = true
        navigationController?.navigationBar.prefersLargeTitles = false
        profileImage.isUserInteractionEnabled = true
        
        if isExistingUser {
            saveButton.setTitle("Save Changes", for: .normal)
            saveButton.backgroundColor = .lightGray
            saveButton.isUserInteractionEnabled = false
            
            let imageURL = URL(string: user.profilePic)!
            let imageData = try? Data(contentsOf: imageURL)
            profileImage.image = UIImage(data: imageData!)
            tfName.text = user.name
            tfEmail.text = user.email
            isImagePicked = true
        } else {
            saveButton.setTitle("Save", for: .normal)
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        
        if let name = tfName.text, let email = tfEmail.text {
            if name.isEmpty {
                showAlert(message: "Please Enter Name")
            } else if email.isEmpty {
                showAlert(message: "Please Enter Email")
            } else if !isValidEmail(email) {
                showAlert(message: "Enter Valid Email Address")
            } else if !isImagePicked {
                showAlert(message: "Select Profile Image")
            } else {
                if isExistingUser {
                    let data = profileImage.image?.jpegData(compressionQuality: 0.8)
                    let updatedUser = UpdateUser(user_id: user.userID, name: name, email: email, profile_pic: data!)
                    self.startLoader()
                    updateData(updateUser: updatedUser)
                } else {
                    let data = profileImage.image?.jpegData(compressionQuality: 0.8)
                    self.startLoader()
                    addData(name: name, email: email, imageData: data!) { [weak self] (responseData) in
                        if responseData.status {
                            DispatchQueue.main.async {
//                                self?.passUser!(responseData.data!)
                                self?.stopLoader()
                                self?.navigationController?.popViewController(animated: true)
                            }
                        } else {
                            DispatchQueue.main.async {
                                self?.stopLoader()
                                self?.showAlert(message: "Email is Already Exists! Please enter new email address")
                            }
                        }
                    }
                }
                
                
            }
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func showAlert(message: String) {
        let avc = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        avc.addAction(UIAlertAction(title: "Okay", style: .cancel))
        self.present(avc, animated: true, completion: nil)
    }
    
    @objc func profileImageTapped() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc func viewTapped() {
        self.view.endEditing(true)
    }
    
    func addData(name: String, email: String, imageData: Data, completionHandler: @escaping (AddedData) -> Void) {
        let parameter = ["name": name, "email": email]
        
        let url = URL(string: "http://192.168.29.41/blog/api/add_user")!
        
        AF.upload(multipartFormData: { multipartFormData in
            for (key, value) in parameter {
                if let data = "\(value)".data(using: .utf8) {
                    multipartFormData.append(data, withName: key)
                }
            }
            multipartFormData.append(imageData, withName: "profile_pic", fileName: "image.jpg", mimeType: "image/jpeg")
            
        }, to: url).responseDecodable(of: AddedData.self) { response in
            switch response.result {
            case .success(let data):
                completionHandler(data)
            case .failure(let error):
                print("error : \(error)")
            }
        }
    }
    
    func updateData(updateUser: UpdateUser) {
        
        let url = URL(string: "http://192.168.29.41/blog/api/edit_user_details")!
        
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append("\(updateUser.user_id)".data(using: .utf8)!, withName: "user_id")
            multipartFormData.append("\(updateUser.name)".data(using: .utf8)!, withName: "name")
            multipartFormData.append("\(updateUser.email)".data(using: .utf8)!, withName: "email")
            multipartFormData.append(updateUser.profile_pic, withName: "profile_pic", fileName: "image.jpg", mimeType: "image/jpeg")
            
        }, to: url).response { (res) in
            print(res)
            self.stopLoader()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func startLoader() {
        loader.isHidden = false
        loader.startAnimating()
    }
    
    func stopLoader() {
        DispatchQueue.main.async {
            self.loader.isHidden = true
            self.loader.stopAnimating()
        }
    }
    
//    func addData(name: String, email: String, imageData: Data) {
//        let url = URL(string: "http://192.168.29.41/blog/api/add_user")!
//        var request = URLRequest(url: url)
//        let boundary = UUID().uuidString
//        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-type")
//        //request.setValue("application/json", forHTTPHeaderField: "Content-type")
//        request.httpMethod = "POST"
//
//        let parameters = ["name": name, "email": email, "profile_pic": imageData.base64EncodedString()]
//        //let data = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
//        let data = try? JSONEncoder().encode(parameters)
//        request.httpBody = data
//
//        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
//            if let error = error {
//                print(error)
//                return
//            }
//
//            if let response = response as? HTTPURLResponse{
//                if response.statusCode != 200 {
//                    print("not added")
//                    return
//                }
//            }
//
////            if let data = data {
////                if let jsonData = try? JSONDecoder().decode(Blog.self, from: data) {
////                    //print(jsonData.data[0].id)
////                }
////            }
//        })
//        task.resume()
//
//    }

}

extension AddUserViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        
        if isExistingUser {
            saveButton.backgroundColor = .link
            saveButton.isUserInteractionEnabled = true
        }
        
        guard let image = info[.editedImage] as? UIImage else { return }
        
        profileImage.image = image
        isImagePicked = true
    }
}

extension AddUserViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if isExistingUser {
            saveButton.backgroundColor = .lightGray
            saveButton.isUserInteractionEnabled = false
            if textField == tfName {
                if user.name == tfName.text {
                    return
                }
            } else {
                if user.email == tfEmail.text {
                    return
                }
            }
            saveButton.backgroundColor = .link
            saveButton.isUserInteractionEnabled = true
        }
    }
    
}
