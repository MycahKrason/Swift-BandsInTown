import Foundation

class RetrieveUpcomingTrackerBrain{
    
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
