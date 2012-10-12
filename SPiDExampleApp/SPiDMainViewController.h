//
// Created by mikaellindstrom on 9/17/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#include "SPiDClient.h"
#include "SPiDRequest.h"


@interface SPiDMainViewController : UIViewController

@property(strong, nonatomic) IBOutlet UILabel *userLabel;
@property(strong, nonatomic) IBOutlet UILabel *tokenLabel;
@property(strong, nonatomic) IBOutlet UILabel *oneTimeCodeLabel;

@end