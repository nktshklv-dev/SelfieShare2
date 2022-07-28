//
//  ViewController.swift
//  SelfieShare-2
//
//  Created by Nikita  on 7/28/22.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    
    var images = [UIImage]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
    let menu = UIMenu(title: "", children: [
                   UIAction(title: "Take a photo", image: UIImage(systemName: "camera"), handler: takePhoto),
                   UIAction(title: "Choose photo", image: UIImage(systemName: "photo.on.rectangle.angled"), handler: choosePhoto)])
    navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .add, menu: menu)
        
        
    }
    
    
    
    func choosePhoto(_ action: UIAction){
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func takePhoto(_ action: UIAction){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        present(picker, animated: true)
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {return}
        
        dismiss(animated: true, completion: nil)
        images.insert(image, at: 0)
        collectionView.reloadData()
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageView", for: indexPath)
           if let imageView = cell.viewWithTag(1000) as? UIImageView{
               imageView.image = images[indexPath.item]
               
           }
           return cell
       }
  
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }


}

