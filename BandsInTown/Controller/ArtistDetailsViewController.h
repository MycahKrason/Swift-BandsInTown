#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ArtistDetailsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *bandName;
@property (weak, nonatomic) IBOutlet UILabel *trackerCount;
@property (weak, nonatomic) IBOutlet UILabel *upcomingEventCount;
@property (weak, nonatomic) IBOutlet UIView *bandInfoBox;

@property (strong, nonatomic) NSString* bandNamePassed;
@property (strong, nonatomic) NSString* trackerCountPassed;
@property (strong, nonatomic) NSString* upcomingEventCountPassed;
@property (strong, nonatomic) UIImage* profileImageDataPassed;

@end

NS_ASSUME_NONNULL_END
