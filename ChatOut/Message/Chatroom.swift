//
//  Chatroom.swift
//  ChatOut
//
//  Created by Cem Sertkaya on 8.04.2020.
//  Copyright © 2020 Cem Sertkaya. All rights reserved.
//

import UIKit
import Firebase
import MessageKit
import InputBarAccessoryView



class Chatroom: MessagesViewController,MessagesDisplayDelegate,MessagesLayoutDelegate,UINavigationControllerDelegate
{
    var chosenChatId = "";var chatType = String(); var username = String()
    var messageObject = Message();var messageArray = [MessageIn]()
    let user = Auth.auth().currentUser;var isFromCreate = false
    public struct Sender: SenderType{public let senderId: String;public let displayName: String}
    public struct MessageIn: MessageType{public var sender: SenderType;public var messageId: String;public var sentDate: Date;public var kind: MessageKind}
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white,NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13)]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        messageInputBar.inputTextView.placeholder = "Send a message"
        DispatchQueue.global(qos: .default).sync {
            DispatchQueue.main.async { [weak self] in
            self?.messagesCollectionView.scrollToBottom(animated: true)
            }}
        getData();getMessages()
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesDataSource = self
        messageInputBar.delegate = self
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        {
            layout.attributedTextMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.attributedTextMessageSizeCalculator.incomingAvatarSize = .zero
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.textMessageSizeCalculator.incomingAvatarSize = .zero
            layout.setMessageIncomingCellTopLabelAlignment(.init(textAlignment: .left, textInsets: .zero))
            layout.setMessageIncomingCellBottomLabelAlignment(.init(textAlignment: .left, textInsets: .zero))
            layout.setMessageOutgoingCellTopLabelAlignment(.init(textAlignment: .right, textInsets: .zero))
            layout.setMessageOutgoingCellBottomLabelAlignment(.init(textAlignment: .right, textInsets: .zero))
        }
        if isFromCreate
        {
            self.navigationController?.isToolbarHidden = true
            addBackButton()
        }
    }
    
   func addBackButton() {
      
       let btnLeftMenu: UIButton = UIButton()
       let image = UIImage(named: "backButtonImage");
       btnLeftMenu.setImage(image, for: .normal)
       btnLeftMenu.setTitle("Back", for: .normal);
       btnLeftMenu.sizeToFit()
       btnLeftMenu.addTarget(self, action: #selector (backButtonClick(sender:)), for: .touchUpInside)
       let barButton = UIBarButtonItem(customView: btnLeftMenu)
       self.navigationItem.leftBarButtonItem = barButton
   }

    @objc func backButtonClick(sender : UIButton) {
        self.navigationController?.popToRootViewController(animated: true);
   }

    
   
    @IBAction func leaveButtonPress(_ sender: Any)
    {
        //Step : 1
        let alert = UIAlertController(title: "Oops", message: "Chat'den ayrılmak isteğinize emin misiniz ?", preferredStyle: UIAlertController.Style.alert )
        let attributedStringTitle = NSAttributedString(string: "Oops", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15),NSAttributedString.Key.foregroundColor : UIColor.white])
        let attributedStringMessage = NSAttributedString(string: "Chat'den ayrılmak isteğinize emin misiniz ?", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13),NSAttributedString.Key.foregroundColor : UIColor.white])
        alert.setValue(attributedStringTitle, forKey: "attributedTitle")
        alert.setValue(attributedStringMessage, forKey: "attributedMessage")
        // Accessing alert view backgroundColor :
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor  =  UIColor(rgb: 0xBF0505)
        // Accessing buttons tintcolor :
        alert.view.tintColor = UIColor.white
        //Cancel action
        let cancel = UIAlertAction(title: "Vazgeç", style: .default) { (alertAction) in }
        alert.addAction(cancel)
        //Step : 2
        let out = UIAlertAction(title: "Sohbetten Çık", style: .default) { (alertAction) in
            let firestoreDatabase = Firestore.firestore()
            firestoreDatabase.collection("chats").document(self.chosenChatId).updateData(["peopleInChat" :FieldValue.arrayRemove([self.user!.uid])])
            firestoreDatabase.collection("users").document(self.user!.uid).updateData(["activeChat":""])
            self.performSegue(withIdentifier: "toMainFromMessage", sender: nil)
        }
        alert.addAction(out)
        self.present(alert, animated:true, completion: nil)
    }
    
    func getData()
    {
        let fireStoreDatabase2 = Firestore.firestore()
        fireStoreDatabase2.collection("chats").document(self.chosenChatId).addSnapshotListener { (documentSnapshot, error) in
                    if error != nil{print(error?.localizedDescription)}
                    else
                    {
                        if  let document = documentSnapshot{self.navigationItem.title = document.get("title") as! String}
                        
            }}
    }
        
    func getMessages()
    {
        let fireStoreDatabase = Firestore.firestore()
        fireStoreDatabase.collection("chats").document(self.chosenChatId).collection("messages").order(by: "time", descending: false).addSnapshotListener { (documentSnapshot, error) in
        if error != nil{print(error?.localizedDescription)
        }
        else
        {
            if  let document = documentSnapshot
            {
                self.messageObject.messages.removeAll(keepingCapacity: false)
                for document in documentSnapshot!.documents
                {
                    let senderId  = document.get("sender") as! String
                    let senderUsername = document.get("senderUsername") as! String
                    let sender = Sender(senderId: senderId, displayName: senderUsername)
                    let time = document.get("time") as! Timestamp
                    let message = document.get("message") as! String
                    let  kit = MessageIn(sender: sender, messageId: document.documentID, sentDate: time.dateValue(), kind:MessageKind.text(message))
                    self.messageObject.messages.append(kit)
                }
            self.messagesCollectionView.reloadData()
            }}}
    }
}

extension Chatroom: MessagesDataSource
{

    func currentSender() -> SenderType {return Sender(senderId: self.user!.uid, displayName: self.username)}
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int{return self.messageObject.messages.count}

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {return self.messageObject.messages[indexPath.section]}
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        if message.sender.senderId == self.user!.uid  {return UIColor.red}//Bf0505yap
        else {return UIColor.lightGray}
    }
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        let font = UIFont.systemFont(ofSize: 14)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let attributed = NSAttributedString.init(string:  name, attributes: attributes)
        return attributed
    }
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {return 20}
    
    
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let date = message.sentDate
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let font = UIFont.systemFont(ofSize: 11)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let attributed = NSAttributedString.init(string:  dateFormatter.string(from: (date)), attributes: attributes)
        return attributed
    }
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {return 20}

}

extension Chatroom: InputBarAccessoryViewDelegate
{
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String)
    {
        if messageInputBar.inputTextView.text != ""
        {
            let uuid  = UUID().uuidString
            let time = Date()
            Firestore.firestore().collection("chats").document(self.chosenChatId).collection("messages").document(uuid).setData(["sender" : self.user?.uid,"time":time,"senderUsername":self.username,"message":messageInputBar.inputTextView.text!])
            // Send button activity animation
            messageInputBar.sendButton.startAnimating()
            messageInputBar.inputTextView.placeholder = "Sending..."
            DispatchQueue.global(qos: .default).async {
                // fake send request task
                sleep(UInt32(0.5))
                DispatchQueue.main.async { [weak self] in
                    self?.messageInputBar.sendButton.stopAnimating()
                    self?.messageInputBar.inputTextView.placeholder = "Send a message"
                    self?.messageInputBar.inputTextView.text = ""
                    self?.messagesCollectionView.scrollToBottom(animated: true)
                }
            }
        }
    }
}


