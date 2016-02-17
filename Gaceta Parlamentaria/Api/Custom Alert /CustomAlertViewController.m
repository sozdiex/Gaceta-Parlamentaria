

#import "CustomAlertViewController.h"

@interface CustomAlertViewController () <UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning>

@property (strong, nonatomic) IBOutlet UILabel *txtMessage;

@property (nonatomic, weak) IBOutlet UIView* alertView;
@end

@implementation CustomAlertViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.btnAceptar setTitle:NSLocalizedString(@"Aceptar", nil) forState:UIControlStateNormal];
    [self.btnAceptarFull setTitle:NSLocalizedString(@"Aceptar", nil) forState:UIControlStateNormal];
    [self.btnCancelar setTitle:NSLocalizedString(@"Cancelar", nil) forState:UIControlStateNormal];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:YES] forKey:@"firstName"];
    [defaults synchronize];
    
    //self.alertView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.alertView.layer.borderWidth = 0;
    self.alertView.layer.cornerRadius = 8;
    //[self.txtMessage setText:self.text];
    self.txtMessage.text = self.text;
    
    if(self.alertQuestion){
        self.btnAceptar.hidden = NO;
        self.btnAceptarFull.hidden = YES;
        self.btnCancelar.hidden = NO;
    }else{
        self.btnAceptar.hidden = YES;
        self.btnAceptarFull.hidden = NO;
        self.btnCancelar.hidden = YES;
    }
    
    UIInterpolatingMotionEffect* m1 =
    [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    m1.maximumRelativeValue = @10.0;
    m1.minimumRelativeValue = @-10.0;
    UIInterpolatingMotionEffect* m2 =
    [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    m2.maximumRelativeValue = @10.0;
    m2.minimumRelativeValue = @-10.0;
    UIMotionEffectGroup* g = [UIMotionEffectGroup new];
    g.motionEffects = @[m1,m2];
    //[self.alertView addMotionEffect:g];

}

- (IBAction)btnAceptar:(id)sender {
  //  NSUserDefaults.standardUserDefaults().setObject(false, forKey: "alertActiva")
    //NSUserDefaults.standardUserDefaults().synchronize()
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:NO] forKey:@"firstName"];
    [defaults synchronize];
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:self.Selector object:nil userInfo:nil];
    }];
}

- (IBAction) doDismiss: (id) sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:NO] forKey:@"firstName"];
    [defaults synchronize];
    
    if (self.alertVoto){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"alertAcceptedVoto" object:nil userInfo:nil];
    }
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


// ==========

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}

// ========

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.25;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController* vc1 =
    [transitionContext viewControllerForKey:
     UITransitionContextFromViewControllerKey];
    UIViewController* vc2 =
    [transitionContext viewControllerForKey:
     UITransitionContextToViewControllerKey];
    UIView* con = [transitionContext containerView];
    UIView* v1 = vc1.view;
    UIView* v2 = vc2.view;
    
    if (vc2 == self) { // presenting
        [con addSubview:v2];
        v2.frame = v1.frame;
        self.alertView.transform = CGAffineTransformMakeScale(1.6,1.6);
        v2.alpha = 0;
        v1.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
        [UIView animateWithDuration:0.25 animations:^{
            v2.alpha = 1;
            self.alertView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    } else { // dismissing
        [UIView animateWithDuration:0.25 animations:^{
            self.alertView.transform = CGAffineTransformMakeScale(0.5,0.5);
            v1.alpha = 0;
        } completion:^(BOOL finished) {
            v2.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
            [transitionContext completeTransition:YES];
        }];
    }
}


@end
