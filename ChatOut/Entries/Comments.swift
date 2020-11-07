//
//  Comments.swift
//  ChatOut
//
//  Created by Cem Sertkaya on 20.04.2020.
//  Copyright © 2020 Cem Sertkaya. All rights reserved.
//

import UIKit;import Firebase

class Comments: UIViewController,UITableViewDataSource,UITableViewDelegate {
    

    @IBOutlet var comments: UITableView!
    var username = String()
    var chosenEntryId = String();var commentsObjectArray = [Comment]();var autoRowHeight = CGFloat()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        getComments()
        comments.dataSource = self;comments.delegate = self
        comments.rowHeight = UITableView.automaticDimension
        comments.estimatedRowHeight = 300
    
    }
    
    func getComments()
    {
        let fireStoreDatabase = Firestore.firestore()
        fireStoreDatabase.collection("entries").document(self.chosenEntryId).collection("comments").order(by: "time", descending: false).addSnapshotListener { (documentSnapshot, error) in
        if error != nil{print(error?.localizedDescription)
        }
        else
        {
            if  let document = documentSnapshot
            {
                self.commentsObjectArray.removeAll(keepingCapacity: false)
                for document in documentSnapshot!.documents
                {
                    let senderId  = document.get("sender") as! String
                    let senderUsername = document.get("senderUsername") as! String
                    let time = document.get("time") as! Timestamp
                    let commentMessage = document.get("commentMessage") as! String
                    let likesArray = document.get("likesArray") as! [String]
                    let dislikesArray = document.get("dislikesArray") as! [String]
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "HH:mm"
                    let comment = Comment(sender: senderId, time: dateFormatter.string(from: (time.dateValue())), senderUsername: senderUsername, commentMessage: commentMessage, likesArray: likesArray, dislikesArray: dislikesArray)
                    self.commentsObjectArray.append(comment)
                }
            self.comments.reloadData()
            }}}
    }

   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {return self.commentsObjectArray.count}
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let commentCell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
        commentCell.date.text = self.commentsObjectArray[indexPath.row].getTime()
        commentCell.commentLabel.text = self.commentsObjectArray[indexPath.row].getCommentMessage()
        commentCell.username.text = self.commentsObjectArray[indexPath.row].getSenderUsername()
        commentCell.likeButton.setTitle(String(self.commentsObjectArray[indexPath.row].getLikesArray().count), for: UIControl.State.normal)
        commentCell.dislikeButton.setTitle(String(self.commentsObjectArray[indexPath.row].getDislikesArray().count), for: UIControl.State.normal)
        return commentCell
    }
    //func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {return UITableView.automaticDimension}
    //func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {return UITableView.automaticDimension}
     
    @IBAction func addComment(_ sender: Any)
    {
       performSegue(withIdentifier: "toCreateComment", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
          if segue.identifier == "toCreateComment"
          {
               let destinationVC = segue.destination as! CreateComment
               destinationVC.chosenEntryId = self.chosenEntryId
               destinationVC.username = self.username
          }
    }
    
    
}

