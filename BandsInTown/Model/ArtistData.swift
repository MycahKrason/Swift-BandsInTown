import Foundation

struct ArtistData: Decodable {
    var id : String
    var name : String
    var image_url : String
    var tracker_count : Int
    var upcoming_event_count : Int
    
    lazy var favorite_selected : Bool = false
}
