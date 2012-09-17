//
// Created by mikaellindstrom on 9/17/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#include "SPiDClient.h"
#include "SPiDRequest.h"


@interface SPiDLogoutViewController : UIViewController

@property(strong, nonatomic) IBOutlet UILabel *tokenLabel;
@property(strong, nonatomic) IBOutlet UILabel *userLabel;

@end