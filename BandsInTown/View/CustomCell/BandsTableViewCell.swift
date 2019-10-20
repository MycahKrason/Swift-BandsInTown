import UIKit

protocol BandsCellDelegate{
    //Add functions for the view controller
    func favoriteBtnSelected(cell: UITableViewCell)
}

class BandsTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var bandName: UILabel!
    @IBOutlet weak var likeButton: UIImageView!
    
    var favoriteSelectedState = false
    var delegate: BandsCellDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //make image a circle
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2;
        profileImage.clipsToBounds = true;
    }

    
    
    @IBAction func favoriteBtn(_ sender: UIButton) {
        
        delegate?.favoriteBtnSelected(cell: self)
       
    }
    
}
