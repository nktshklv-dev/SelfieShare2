//
//  ViewController.swift
//  SelfieShare-2
//
//  Created by Nikita  on 7/28/22.
//

import UIKit
import MultipeerConnectivity

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, MCSessionDelegate, MCBrowserViewControllerDelegate {

    var peerID = MCPeerID(displayName: UIDevice.current.name)
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCAdvertiserAssistant!
    
    var images = [UIImage]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
    let menu = UIMenu(title: "", children: [
                   UIAction(title: "Take a photo", image: UIImage(systemName: "camera"), handler: takePhoto),
                   UIAction(title: "Choose photo", image: UIImage(systemName: "photo.on.rectangle.angled"), handler: choosePhoto)])
    navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .add, menu: menu)
    navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showConnectionPrompt))
        
        
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        
        
    }
    
    @objc func showConnectionPrompt(){
        let ac = UIAlertController(title: "Connect to others", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Host a session", style: .default, handler: startHosting))
        ac.addAction(UIAlertAction(title: "Join a session", style: .default, handler: joinSession))
        ac.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    
    func startHosting(action: UIAlertAction){
        guard let mcSession = mcSession else {return}
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "hws-project25", discoveryInfo: nil, session: mcSession)
        mcAdvertiserAssistant.start()
        
        
    }
    func joinSession(action: UIAlertAction){
        guard let mcSession = mcSession else {return}
        let browser = MCBrowserViewController(serviceType: "hws-project25", session: mcSession)
        browser.delegate = self
        present(browser, animated: true)
        
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
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .notConnected:
            print("Not connected: \(peerID.displayName)")
        case .connecting:
            print("Connecting: \(peerID.displayName)")
        case .connected:
            print("Connected: \(peerID.displayName)")
        @unknown default:
            print("Unknown state")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            [weak self] in
            if let image = UIImage(data: data){
                self?.images.insert(image, at: 0)
                self?.collectionView.reloadData()
            }
        }
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {return}
        
        dismiss(animated: true, completion: nil)
        images.insert(image, at: 0)
        collectionView.reloadData()
        
        guard let mcSession = mcSession else {return}
        if mcSession.connectedPeers.count > 0{
            if let imageData = image.pngData(){
                do{
                    try mcSession.send(imageData, toPeers: mcSession.connectedPeers, with: .reliable)
                }
                catch{
                    let ac = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    present(ac, animated: true, completion: nil)
                }
            }
        }
        
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
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }


}

