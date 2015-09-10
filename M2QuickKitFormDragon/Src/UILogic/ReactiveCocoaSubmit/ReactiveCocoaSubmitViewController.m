//
//  ReactiveCocoaSubmitViewController.m
//  M2QuickKitFormDragon
//
//  Created by thatsoul on 15/9/10.
//  Copyright (c) 2015年 chenms.m2. All rights reserved.
//

#import "ReactiveCocoaSubmitViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "ProgressHUDHelper.h"
#import "TextHUDHelper.h"

@interface ReactiveCocoaSubmitViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (nonatomic) ProgressHUDHelper *progressHUDHelper;
@property (weak, nonatomic) IBOutlet UISwitch *showPasswordSwitch;
@end

@implementation ReactiveCocoaSubmitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.progressHUDHelper = [[ProgressHUDHelper alloc] initWithView:self.view];


    // 用户名
    RACSignal *validateUserSignal = [self.userTextField.rac_textSignal
                                     map:^id(id value) {
                                         return @([self validateUser]);
                                     }];
    RAC(self.userTextField, backgroundColor) = [validateUserSignal
                                                map:^id(NSNumber *userValid) {
                                                    return ([userValid boolValue] ? [UIColor greenColor] : [UIColor clearColor]);
                                                }];

    // 密码
    self.passwordTextField.secureTextEntry = YES;
    RACSignal *validatePasswordSignal = [self.passwordTextField.rac_textSignal
                                         map:^id(id value) {
                                             return @([self validatePassword]);
                                         }];
    RAC(self.passwordTextField, backgroundColor) = [validatePasswordSignal
                                                    map:^id(NSNumber *passwordValid) {
                                                        return ([passwordValid boolValue] ? [UIColor greenColor] : [UIColor clearColor]);
                                                    }];

    // 提交
    self.submitButton.enabled = NO;
    RACSignal *submitEnabledSignal = [RACSignal combineLatest:@[validateUserSignal, validatePasswordSignal]
                                                       reduce:^id(NSNumber *userValid, NSNumber *passwordValid){
                                                           return @([userValid boolValue] && [passwordValid boolValue]);
                                                       }];
    [submitEnabledSignal subscribeNext:^(NSNumber *submitEnabled) {
        self.submitButton.enabled = [submitEnabled boolValue];
    }];
}

#pragma mark - validate input
- (BOOL)validateUser {
    return [self.userTextField.text length] > 0;
}

- (BOOL)validatePassword {
    return [self.passwordTextField.text length] > 0;
}

#pragma mark - user event
- (IBAction)onShowPasswordSwitchValueChaged:(UISwitch *)sender {
    self.passwordTextField.secureTextEntry = !sender.isOn;

    dispatch_async(dispatch_get_main_queue(), ^{
        DDLogError(@"[%@]", self.passwordTextField.text);
    });
}

- (IBAction)onTapSubmit:(id)sender {
    [self.view endEditing:YES];
    [self.progressHUDHelper show];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.progressHUDHelper hide];
        BOOL success = (arc4random() % 2 == 0);
        NSString *message = (success ? @"请求成功" : @"请求失败");
        [[TextHUDHelper sharedInstance] showText:message];
    });
}

@end
