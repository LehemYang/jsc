//
//  ViewController.m
//  jsc
//
//  Created by Lehem on 2022/7/26.
//

#import "ViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <WebKit/WebKit.h>
#import <WebKit/WKWebView.h>

#import "MyJit.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UITextField *counttf;
@property (weak, nonatomic) IBOutlet WKWebView *webview;

@property (weak, nonatomic) IBOutlet UITextField *jittf;
@property (weak, nonatomic) IBOutlet UILabel *jitResult;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.counttf endEditing:YES];
    [self.jittf endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.counttf endEditing:YES];
    [self.jittf endEditing:YES];
    
    return NO;
}

- (IBAction)runclick:(id)sender {
    NSInteger count = self.counttf.text.integerValue;
    
    JSVirtualMachine *vm = [[JSVirtualMachine alloc] init];
    
    JSContext *context  = [[JSContext alloc] initWithVirtualMachine:vm];
    
    //    NSString *script = @"function fibonacci(num, memo) {memo = memo || {}; if (memo[num]) return memo[num]; if (num <= 1) return 1;return memo[num] = fibonacci(num - 1, memo) + fibonacci(num - 2, memo);} function time (t) {const last = new Date().getTime();fibonacci(t, {});const now = new Date().getTime();return now - last;}";
    
    //    NSString *script = @"function fibonacci(num) {if (num <= 1) return 1;return fibonacci(num - 1) + fibonacci(num - 2);}function time(t) {const last = new Date().getTime();for (let i = 0; i < 5; i++) {fibonacci(t);}const now = new Date().getTime();return now - last;}";
    
    
    NSString *script = @"function fibonacci (num) {if (num <= 1) return 1;return fibonacci(num - 1) + fibonacci(num - 2);} function time (t) {const last = new Date().getTime();fibonacci(t);const now = new Date().getTime();return now - last;}";
    
    [context evaluateScript:script];
    JSValue *m = context[@"time"];
    JSValue *time = [m callWithArguments:@[@(count)]];
    
    //    for (int i = 0; i < 5; i++) {
    //        [context evaluateScript:script];
    //        JSValue *m = context[@"time"];
    //        JSValue *time = [m callWithArguments:@[@(count)]];
    //        NSLog(@"time is %@", [time toNumber]);
    //    }
    
    NSLog(@"time is %@", [time toNumber]);
    self.time.text = [time toString];
}


- (IBAction)webviewjs:(id)sender {
    NSInteger count = self.counttf.text.integerValue;
    
    NSString *script = [NSString stringWithFormat:@"time(%@);", @(count)];
    
    [self.webview evaluateJavaScript:script completionHandler:^(id _Nullable time, NSError * _Nullable error) {
        NSLog(@"time is %@", time);
        self.time.text = [time stringValue];
    }];
}


- (IBAction)refershclick:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://172.23.166.77:3000"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webview loadRequest:request];
}

- (IBAction)runJit:(id)sender {
    MyJit * m = [MyJit new];
    
    long input = self.jittf.text.integerValue;
    long result = [m jit:input];
    self.jitResult.text = [NSString stringWithFormat:@"%@", @(result)];
}

@end
