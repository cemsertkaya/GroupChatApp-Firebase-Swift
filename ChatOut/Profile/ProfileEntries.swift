//
//  ProfileEntries.swift
//  ChatOut
//
//  Created by Cem Sertkaya on 1.05.2020.
//  Copyright © 2020 Cem Sertkaya. All rights reserved.
//

import UIKit;import Firebase
class ProfileEntries: UIViewController,UITableViewDelegate,UITableViewDataSource
{
    @IBOutlet var segmentControl: UISegmentedControl!
    @IBOutlet var tableView: UITableView!
    var createdEntriesArray = [Entry]();var commentedEntriesArray = [Entry]();var commentedEntries = [String]();var createdEntries = [String]()
    let user = Auth.auth().currentUser;var followings = [String]()
    let firestoreDatabase = Firestore.firestore()
    var chosenUserId = String()
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        getData()
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(rgb: 0xBF0505)]
        segmentControl.setTitleTextAttributes(titleTextAttributes, for: UIControl.State.selected)
        tableView.delegate = self; tableView.dataSource = self
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(swipeRight)
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    func getData()//snapshot ile data kontrolü
    {
       let docRef = Firestore.firestore().collection("users").document(chosenUserId)
       docRef.getDocument
        {
           (document, error) in
           if let document = document, document.exists
           {
               let dataDescription = document.data()
               self.commentedEntries = dataDescription?["commentedEntries"] as! [String]
               self.createdEntries = dataDescription?["createdEntries"] as! [String]
               self.commentedEntriesArray.removeAll(keepingCapacity: false)
               self.createdEntriesArray.removeAll(keepingCapacity: false)
                for commentedEntry in self.commentedEntries
                   {
                       let docRef = Firestore.firestore().collection("entries").document(commentedEntry)
                       docRef.getDocument
                        {
                           (document, error) in
                           if let document = document, document.exists
                           {
                               let dataDescription = document.data()
                               let title = dataDescription?["title"] as! String
                               let time = dataDescription?["time"] as! Timestamp
                               let commentCount = "100"
                               let dateFormatter = DateFormatter()
                               dateFormatter.dateFormat = "dd-MM-yyyy"
                               let entry = Entry(id: commentedEntry, time: dateFormatter.string(from: (time.dateValue())), title:title,commentCount: commentCount)
                               self.commentedEntriesArray.append(entry)
                           }
                            self.tableView.reloadData()
                        }
                   }
                for createdEntry in self.createdEntries
                   {
                       let docRef = Firestore.firestore().collection("entries").document(createdEntry)
                       docRef.getDocument
                        {
                           (document, error) in
                           if let document = document, document.exists
                           {
                               let dataDescription = document.data()
                               let title = dataDescription?["title"] as! String
                               let time = dataDescription?["time"] as! Timestamp
                               let commentCount = "100"
                               let dateFormatter = DateFormatter()
                               dateFormatter.dateFormat = "dd-MM-yyyy"
                               let entry = Entry(id: createdEntry, time: dateFormatter.string(from: (time.dateValue())), title:title,commentCount: commentCount)
                               self.createdEntriesArray.append(entry)
                           }
                            self.tableView.reloadData()
                        }
                    
                   }
           }
            
        }
    }
    
   
    @IBAction func segmentChange(_ sender: Any){getData()}
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        var number = Int()
        if segmentControl.selectedSegmentIndex == 0
        {
            number = commentedEntriesArray.count
        }
        else if segmentControl.selectedSegmentIndex == 1
        {
            number = createdEntriesArray.count
            print(number)
        }
        return number
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let entryCell = tableView.dequeueReusableCell(withIdentifier: "EntryHomeCell", for: indexPath) as! EntryHomeCell
        if segmentControl.selectedSegmentIndex == 0
        {
            entryCell.title.text = self.commentedEntriesArray[indexPath.row].getTitle()
            entryCell.commentCount.text = self.commentedEntriesArray[indexPath.row].getCommentCount()
            entryCell.date.text = self.commentedEntriesArray[indexPath.row].getTime()
            //self.chosenEntryId = self.commentedEntriesArray[indexPath.row].getId()
            
        }
        else if segmentControl.selectedSegmentIndex == 1
        {
            entryCell.title.text = self.createdEntriesArray[indexPath.row].getTitle()
            entryCell.commentCount.text = self.createdEntriesArray[indexPath.row].getCommentCount()
            entryCell.date.text = self.createdEntriesArray[indexPath.row].getTime()
            //self.chosenEntryId = self.followingsEntryArray[indexPath.row].getId()
        }
        return entryCell
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer)
    {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer
        {
            switch swipeGesture.direction
            {
            case UISwipeGestureRecognizer.Direction.right:
                segmentControl.selectedSegmentIndex = 1
                segmentChange(self)
            case UISwipeGestureRecognizer.Direction.left:
                segmentControl.selectedSegmentIndex = 0
                segmentChange(self)
                
                default:
                    break
            }
        }
    }
    
    
    

   

}

