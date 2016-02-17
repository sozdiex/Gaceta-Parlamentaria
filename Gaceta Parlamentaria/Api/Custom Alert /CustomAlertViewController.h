

#import <UIKit/UIKit.h>

@interface CustomAlertViewController : UIViewController

@property (strong , nonatomic) NSString *text;
@property (strong , nonatomic) NSString *Selector;
@property BOOL alertQuestion;
@property BOOL alertVoto;

@property (strong, nonatomic) IBOutlet UIButton *btnAceptarFull;
@property (strong, nonatomic) IBOutlet UIButton *btnAceptar;
@property (strong, nonatomic) IBOutlet UIButton *btnCancelar;

@end
