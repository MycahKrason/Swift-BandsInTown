#import "ArtistDetailsViewController.h"

@interface ArtistDetailsViewController ()


@end

@implementation ArtistDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.bandName.text = self.bandNamePassed;
    self.trackerCount.text = self.trackerCountPassed;
    self.upcomingEventCount.text = self.upcomingEventCountPassed;
    self.profileImage.image = self.profileImageDataPassed;
    
    //make image a circle
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
    self.profileImage.clipsToBounds = true;
    self.bandInfoBox.layer.cornerRadius = 20;
    self.bandInfoBox.clipsToBounds = true;
     
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
