//
//  EntryHomeViewController.swift
//  ChatOut
//
//  Created by Cem Sertkaya on 19.04.2020.
//  Copyright © 2020 Cem Sertkaya. All rights reserved.
//

import UIKit;import Firebase

class EntryHomeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate
{
   
    
    let user = Auth.auth().currentUser
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    var chosenEntryId = String();var isPremium = false;var username = "";var isSearchActive = false
    var blockedArray = [String](); var blockedByArray = [String]();var followings = [String]();var entryArray = [Entry]();var followingsEntryArray = [Entry]();var searchArray = [Entry]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        getData();getEntries();getFollowingsEntries()
        searchBar.delegate = self
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(rgb: 0xBF0505)]
        segmentedControl.setTitleTextAttributes(titleTextAttributes, for: UIControl.State.selected)
        tableView.delegate = self;tableView.dataSource = self
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(swipeRight)
        self.view.addGestureRecognizer(swipeLeft)
        
    }
    
    func getData()//snapshot ile data kontrolü
    {

        let fireStoreDatabase2 = Firestore.firestore()
        fireStoreDatabase2.collection("users").document(self.user!.uid).addSnapshotListener { (documentSnapshot, error) in
        if error != nil{print(error?.localizedDescription)}
        else
        {
            if  let document = documentSnapshot
            {
                self.isPremium = document.get("isPremium") as! Bool
                self.username = document.get("username") as! String
                self.blockedByArray = document.get("blockedByArray") as! [String]
                self.blockedArray = document.get("blockedArray") as! [String]
                self.followings = document.get("followings") as! [String]
            }
        }}
        
    }
    
    func getEntries()
    {
         let fireStoreDatabase = Firestore.firestore()
         fireStoreDatabase.collection("entries").addSnapshotListener
         {
                 (snapshot, error) in
                 if error != nil{print(error?.localizedDescription)}
                 else
                 {
                     if snapshot?.isEmpty != true && snapshot != nil
                     {
                         self.entryArray.removeAll(keepingCapacity: false)
                         for document in snapshot!.documents
                         {
                                 let documentId = document.documentID
                                 let creatorUid = document.get("creatorUid") as! String
                                 if !self.blockedByArray.contains(creatorUid) && !self.blockedArray.contains(creatorUid)
                                 {
                                    let commentCount = String(fireStoreDatabase.collection("entries").document(documentId).collection("comments").accessibilityElementCount())
                                    let time = document.get("time") as! Timestamp
                                    let title = document.get("title") as! String
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "dd-MM-yyyy"
                                    //let commentCount = "1000"
                                    let entry = Entry(id: documentId, time: dateFormatter.string(from: (time.dateValue())), title:title,commentCount: commentCount)
                                    self.entryArray.append(entry)
                                 }
                         }
                         self.tableView.reloadData()
                     }
                 }
        }
    }
    
    func getFollowingsEntries()
    {
        let fireStoreDatabase = Firestore.firestore()
         fireStoreDatabase.collection("entries").addSnapshotListener
         {
                 (snapshot, error) in
                 if error != nil{print(error?.localizedDescription)}
                 else
                 {
                     if snapshot?.isEmpty != true && snapshot != nil
                     {
                         self.followingsEntryArray.removeAll(keepingCapacity: false)
                         for document in snapshot!.documents
                         {
                                 let documentId = document.documentID
                                 let creatorUid = document.get("creatorUid") as! String
                                 if self.followings.contains(creatorUid)
                                 {
                                    let time = document.get("time") as! Timestamp
                                    let title = document.get("title") as! String
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "dd-MM-yyyy"
                                    let commentCount = "1000"
                                    let entry = Entry(id: documentId, time: dateFormatter.string(from: (time.dateValue())), title:title,commentCount: commentCount)
                                    self.followingsEntryArray.append(entry)
                                 }
                         }
                         self.tableView.reloadData()
                     }
                 }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        var count = Int()
        if isSearchActive
        {
            count = self.searchArray.count
        }
        else
        {
            if segmentedControl.selectedSegmentIndex == 0
            {
                count = self.entryArray.count

            }
            else if segmentedControl.selectedSegmentIndex  == 1
            {
                count = self.followingsEntryArray.count
            }
        }
        return count
    }
       
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let entryCell = tableView.dequeueReusableCell(withIdentifier: "EntryHomeCell", for: indexPath) as! EntryHomeCell
        if isSearchActive
        {
            entryCell.title.text = self.searchArray[indexPath.row].getTitle()
            entryCell.commentCount.text = self.searchArray[indexPath.row].getCommentCount()
            entryCell.date.text = self.searchArray[indexPath.row].getTime()
            self.chosenEntryId = self.searchArray[indexPath.row].getId()
        }
        else
        {
            if segmentedControl.selectedSegmentIndex == 0
            {
                entryCell.title.text = self.entryArray[indexPath.row].getTitle()
                entryCell.commentCount.text = self.entryArray[indexPath.row].getCommentCount()
                entryCell.date.text = self.entryArray[indexPath.row].getTime()
                self.chosenEntryId = self.entryArray[indexPath.row].getId()
                
            }
            else if segmentedControl.selectedSegmentIndex == 1
            {
                entryCell.title.text = self.followingsEntryArray[indexPath.row].getTitle()
                entryCell.commentCount.text = self.followingsEntryArray[indexPath.row].getCommentCount()
                entryCell.date.text = self.followingsEntryArray[indexPath.row].getTime()
                self.chosenEntryId = self.followingsEntryArray[indexPath.row].getId()
            }
        }
        return entryCell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        performSegue(withIdentifier: "toComment1", sender: nil)
    }
    
    
    //Search Bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        if searchText.isEmpty{isSearchActive = false;self.tableView.reloadData();return}
        else
        {
            isSearchActive = true
            switch segmentedControl.selectedSegmentIndex
            {
                case 0:searchArray = entryArray.filter{ entries in return  entries.getTitle().lowercased().contains(searchText.lowercased())}
                case 1:searchArray = followingsEntryArray.filter{ entries in return  entries.getTitle().lowercased().contains(searchText.lowercased())}
                default:
                   break
            }
            self.tableView.reloadData()
        }
        
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer)
    {

        if let swipeGesture = gesture as? UISwipeGestureRecognizer
        {
            switch swipeGesture.direction
            {
            case UISwipeGestureRecognizer.Direction.right:
                segmentedControl.selectedSegmentIndex = 1
                getEntries()
            case UISwipeGestureRecognizer.Direction.left:
                segmentedControl.selectedSegmentIndex = 0
                getFollowingsEntries()
                default:
                    break
            }
        }
    }
    
    @IBAction func segmentChange(_ sender: Any)
    {
        switch segmentedControl.selectedSegmentIndex
        {
            case 0:getEntries()
            case 1:getFollowingsEntries()
            default:
                break
        }
    }
    
    @IBAction func createEntryButton(_ sender: Any)//PREMİUM KONTROLÜ
    {
         self.performSegue(withIdentifier: "toCreate", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
       if segue.identifier == "toComment1"
       {
            let destinationVC = segue.destination as! Comments; destinationVC.chosenEntryId = self.chosenEntryId
                destinationVC.username = self.username
       }
    }
    
    
    
}

import UIKit
class EntryHomeCell: UITableViewCell
{
    @IBOutlet var title: UILabel!
    @IBOutlet var date: UILabel!
    @IBOutlet var commentCount: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}

