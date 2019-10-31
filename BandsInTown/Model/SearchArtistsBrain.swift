import Foundation

class SearchArtistsBrain{
    
    func searchArtist(safeSearch: String, completion: @escaping (_ error: String, _ artistArray: [SearchArtistData]) -> ()){
        
        var returnArray : [SearchArtistData] = [SearchArtistData]()
            
        let arrayOfGenres = ["jazz", "rock", "pop", "country"]
        var typeOfSearch = "term"
        
        if arrayOfGenres.contains(safeSearch){
            typeOfSearch = "genre"
        }
        
        let url = URL(string: "https://search.bandsintown.com/search?query=%7B%22\(typeOfSearch)%22%3A%22\(safeSearch)%22%2C%22entities%22%3A%5B%7B%22type%22%3A%22artist%22%7D%5D%7D")
        
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("\(GlobalValues().key)", forHTTPHeaderField: "x-api-key")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil{

                print(error as Any)
                
                    completion("Please connect to the internet", [])

                return

            }
            
            guard let jsonData = data else {return}
            
            do{
                if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any] {
                   
                    if let artistList = json["artists"] as? Array<Dictionary<String, Any>>{
                        
                        for artist in artistList{
                            
                            let safeId: Int = artist["id"] as! Int
                            let saferId : String = String(safeId)
                            let safeName: String = artist["name"] as! String
                            
                            var safeImage : String = ""
                            if artist["image_url"] != nil{
                                safeImage = artist["image_url"] as! String
                            }
                            
                            let safeTracker: Int = artist["tracker_count"] as! Int
                            
                            let searchedArtistData = SearchArtistData(id: saferId, name: safeName, image_url: safeImage, tracker_count: safeTracker)
                            
                            returnArray.append(searchedArtistData)
                                                            
                        }
                        
                    }else{
                        
                        completion("Unable to find Artist", [])
                            
                    }
                    
                }
                
            }catch let error{
                print(error)
                completion("Unable to find Artist", [])
                
            }
            
            completion("", returnArray)
           
        }
        
        task.resume()
          
    }
    
    
    func getUpcomingTrackerNumber(safeSearch: String, completion: @escaping (_ error: String, _ upcomingTracker: String) -> ()){
        
        //Reach out to the Second Public endpoint to retrieve the Upcoming Event Count
        let url = URL(string: "https://rest.bandsintown.com/artists/\(safeSearch)?app_id=test")

        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("\(GlobalValues().key)", forHTTPHeaderField: "x-api-key")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if error != nil{

                completion("Please connect to the internet", "")
                return

            }
            
            if let safeData = data{
                
                let decoder = JSONDecoder()

                do{
                    let decodedData = try decoder.decode(ArtistData.self, from: safeData)
                    if let safeEventCount = decodedData.upcoming_event_count{
                        completion("", String(safeEventCount))
                    }else{
                        completion("There is no upcoming event count", "")
                    }
                    

                }catch let error{
                
                    print("There is a problem - \(error)")

                }

            }

        }

        task.resume()
        
    }
    
}
