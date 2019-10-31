import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, BandsCellDelegate {
    
    @IBOutlet weak var pageTitle: UILabel!
    @IBOutlet weak var bandsResultTable: UITableView!
    @IBOutlet weak var artistFavoritesSegmentDisplay: UISegmentedControl!
    @IBOutlet weak var searchInput: UITextField!
    
    //This will be used to hide the search bar
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    
    var artistArray : [SearchArtistData] = [SearchArtistData]()
    var favoritesArray : [FavoriteArtist] = [FavoriteArtist]()
    
    var sendUpcomingEvents : String = ""
    
    
    //Context for Core Data
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up Delegates
        bandsResultTable.delegate = self
        bandsResultTable.dataSource = self
        searchInput.delegate = self
        
        //register Band Cell
        bandsResultTable.register(UINib(nibName: "BandsTableViewCell", bundle: nil), forCellReuseIdentifier: "bandsTableViewCell")
        
        //Set Initial state
        bandsResultTable.rowHeight = 60
        pageTitle.text = "Artists"
        tableViewTopConstraint.constant = 50
        artistFavoritesSegmentDisplay.selectedSegmentIndex = 0
        
        //Set Font colors of Segment
        let selectedSegmentAttribute = [NSAttributedString.Key.foregroundColor: UIColor.white]
        artistFavoritesSegmentDisplay.setTitleTextAttributes(selectedSegmentAttribute, for: .selected)
        let normalSegmentAttribute = [NSAttributedString.Key.foregroundColor: UIColor.systemBlue]
        artistFavoritesSegmentDisplay.setTitleTextAttributes(normalSegmentAttribute, for: .normal)
        
        //Change Return to Send on the keyboard and Add Magnifying glass to search bar
        searchInput.returnKeyType = UIReturnKeyType.search
        searchInput.placeholder =  "\u{1F50D}Search"
        
        //Set up tap gesture
        hideKeyboardWhenTappedAround()
        
        //Load the saved Favorite Artists
        loadFavoriteArtistFromCD()
        
    }
    
    //Press search in the text field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
       
        //Search the the Artist list
        if let safeSearch = searchInput.text?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed){
            SearchArtistsBrain().searchArtist(safeSearch: safeSearch, completion: { error, result in
                
                if error != ""{
                    
                    //This is triggered if you aren't connected to the internet
                    DispatchQueue.main.async {
                        self.alertUser(message: error)
                    }
                    
                }else{
                   
                    if result.isEmpty{
                        
                        DispatchQueue.main.async {
                            self.alertUser(message: "Unable to find Artist")
                        }
                        
                    }else{
                        
                        self.artistArray = result
                        
                        DispatchQueue.main.async {
                            self.bandsResultTable.reloadData()
                        }
                        
                    }
                }
            })
        }
        
        return true
        
    }
    
    //Save to Core Data
    func saveFavoriteArtistToCD(){
        do {
            try context.save()
        } catch  {
            print("Error Saving Coontent to Core Data")
        }
    }
    
    //Load from Core Data
    func loadFavoriteArtistFromCD(){
        let request : NSFetchRequest<FavoriteArtist> = FavoriteArtist.fetchRequest()
        
        do {
            favoritesArray = try context.fetch(request)
        } catch  {
            print("Unable to Load Saved Favorite Artists - \(error)")
        }
    }

    
    //******//
    //Tables//
    //******//
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if artistFavoritesSegmentDisplay.selectedSegmentIndex == 0{
            return artistArray.count
        }else{
            return favoritesArray.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Set up custom cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "bandsTableViewCell", for: indexPath) as! BandsTableViewCell
        
        //Set Delegate
        cell.delegate = self
        
        if artistFavoritesSegmentDisplay.selectedSegmentIndex == 0{
            //SEARCHED TABLE
            
            //Check the artist to see if it is liked or not
            for favs in favoritesArray{
                if favs.id == artistArray[indexPath.row].id{
                    
                    artistArray[indexPath.row].favorite_selected = true
                    
                }
            }
            
            //Set Artist name and image
            cell.bandName.text = artistArray[indexPath.row].name
            cell.profileImage.imageFromServerURL(artistArray[indexPath.row].image_url, placeHolder: UIImage(systemName: "person.circle"))
            
            if artistArray[indexPath.row].favorite_selected == true{
                cell.likeButton.image = UIImage(systemName: "star.fill")
            }else{
                cell.likeButton.image = UIImage(systemName: "star")
            }
                
        }else{
            //FAVORITES TABLE
            
            if favoritesArray.count != 0{
                
                //Set Band Name
                cell.bandName.text = favoritesArray[indexPath.row].name
                
                //Set Artist Image
                cell.profileImage.imageFromServerURL(favoritesArray[indexPath.row].image_url!, placeHolder: UIImage(systemName: "person.circle"))
                
                cell.likeButton.image = UIImage(systemName: "star.fill")
                
            }
            
        }
        
        return cell
        
    }
    
    //Set a segue to go to the Artist description page
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var safeSearch: String = ""
        
        if artistFavoritesSegmentDisplay.selectedSegmentIndex == 0{
            
            safeSearch = artistArray[indexPath.row].name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            
            
        }else{
            
            safeSearch = favoritesArray[indexPath.row].name!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        }
    
        //Retrieve the Upcoming Tracker Number
        SearchArtistsBrain().getUpcomingTrackerNumber(safeSearch: safeSearch, completion: { error, result in
            
            if error != ""{
                
                DispatchQueue.main.async {
                    self.alertUser(message: error)
                }
                
            }else{
                
                self.sendUpcomingEvents = result
                
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "toArtistDetails", sender: self)
                }
                
            }
            
        })
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toArtistDetails"{
            
            if let indexPath = bandsResultTable.indexPathForSelectedRow{
                
                let destVC = segue.destination as! ArtistDetailsViewController
                
                //Check the Segment controller to see which Array we are pulling data from
                if artistFavoritesSegmentDisplay.selectedSegmentIndex == 0{
                    
                    destVC.bandNamePassed = artistArray[indexPath.row].name
                    destVC.trackerCountPassed = String(artistArray[indexPath.row].tracker_count)
                
                    destVC.upcomingEventCountPassed = sendUpcomingEvents
                  
                }else{
                    
                    destVC.bandNamePassed = favoritesArray[indexPath.row].name!
                    destVC.trackerCountPassed = favoritesArray[indexPath.row].tracker_count!
                    
                    destVC.upcomingEventCountPassed = sendUpcomingEvents
                   
                }
                
                //Grab the image from the cell to avoid having to reach out to the network or check the cache
                let cell = bandsResultTable.cellForRow(at: indexPath) as! BandsTableViewCell
                if let safeImage = cell.profileImage.image{
                    destVC.profileImageDataPassed = safeImage
                }
                
            }
        }
    }
    
    //Alert the user when unable to locate Artist, or connect to the internet
    func alertUser(message: String){
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(alertController, animated: true)
    }
    
    
    //*******//
    //Buttons//
    //*******//
    @IBAction func artistFavoritesSegmentChanged(_ sender: UISegmentedControl) {
        
        bandsResultTable.reloadData()
        
        if artistFavoritesSegmentDisplay.selectedSegmentIndex == 0{
            
            pageTitle.text = "Artists"
            tableViewTopConstraint.constant = 50
            searchInput.isHidden = false
            
        }else{

            pageTitle.text = "Favorites"
            tableViewTopConstraint.constant = 0
            searchInput.isHidden = true
            
        }
        
    }
    
    func favoriteBtnSelected(cell: UITableViewCell) {
        let indexPathClickedOn = bandsResultTable.indexPath(for: cell)
        
        //SEARCH
        if artistFavoritesSegmentDisplay.selectedSegmentIndex == 0{
            
            if favoritesArray.count != 0{
                
                print("Favorites is not equal to 0")
                
                //Check to see if the Searched Artist is already in the Favorites Array
                var favoriteMatch : Bool = false
                var removeAtIndex : Int?
                for (index, favs) in favoritesArray.enumerated(){

                    if favs.id == artistArray[indexPathClickedOn![1]].id{

                        favoriteMatch = true
                        removeAtIndex = index
                        
                        break

                    }else{
                        //print("NO Match")
                    }

                }
                
                if favoriteMatch == true{
                    //If safeFavoriteMatch is true - then there is already a favorite, and you don't want to add another - but should instead delete it

                    artistArray[indexPathClickedOn![1]].favorite_selected = false

                    if let safeRemoveAtIndex = removeAtIndex{

                        context.delete(favoritesArray[safeRemoveAtIndex])
                        favoritesArray.remove(at: safeRemoveAtIndex)
                        saveFavoriteArtistToCD()

                    }
                }else{

                    //if safeFavoriteMatch is false - then there is no favorite and we need to add it to the list
                    if let safeIndexPathClickedOn = indexPathClickedOn{
                       addSearchedArtistToFavorites(indexPath: safeIndexPathClickedOn)
                    }

                }

            }else{
                
                //if there is nothing in the Favorites array, then this artist is a new entry and should be added
                if let safeIndexPathClickedOn = indexPathClickedOn{
                   addSearchedArtistToFavorites(indexPath: safeIndexPathClickedOn)
                }
               
            }
                
        }else{
            
            //FAVORITES
            if favoritesArray.count != 0{
                
                //From Above - use this as a model
                var artistMatch : Bool = false
                var removeAtIndex : Int?
                for (index, searchedArtist) in artistArray.enumerated(){

                    if searchedArtist.id == favoritesArray[indexPathClickedOn![1]].id{

                        artistMatch = true
                        removeAtIndex = index
                        
                        break

                    }else{
                        //print("NO Match")
                    }

                }
                  
                if artistMatch == true{
                    
                    if let safeUnFavoriteArtist = removeAtIndex{
                        
                        artistArray[safeUnFavoriteArtist].favorite_selected = false
                        
                    }
                    
                }
                  
                context.delete(favoritesArray[indexPathClickedOn![1]])
                favoritesArray.remove(at: indexPathClickedOn![1])
                saveFavoriteArtistToCD()
                
            }
            
        }
        
        bandsResultTable.reloadData()
    }
    
    func addSearchedArtistToFavorites(indexPath: IndexPath){
        
        artistArray[indexPath[1]].favorite_selected = true
        
        print(artistArray[indexPath[1]].name)
        
        let favoriteArtist = FavoriteArtist(context: context)
        
        favoriteArtist.id = artistArray[indexPath[1]].id
        favoriteArtist.name = artistArray[indexPath[1]].name
        favoriteArtist.image_url = artistArray[indexPath[1]].image_url
        favoriteArtist.tracker_count = String(artistArray[indexPath[1]].tracker_count)
        
        saveFavoriteArtistToCD()
        favoritesArray.append(favoriteArtist)
    }

}

    
    

 
