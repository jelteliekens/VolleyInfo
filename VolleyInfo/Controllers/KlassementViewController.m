//
//  KlassementViewController.m
//  VolleyInfo
//
//  Created by Jelte Liekens on 30/11/13.
//  Copyright (c) 2013 Jelte Liekens. All rights reserved.
//

#import "KlassementViewController.h"

@interface KlassementViewController ()

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation KlassementViewController

//Als view is geladen wordt er geprobeerd om te gaan naar de pagina.
//Zet delegate naar zichzelf (zie .h) zodat onderstaande methodes uitgevoerd kunnen worden.
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSURL *url = [NSURL URLWithString:@"http://www.volleyvvb.be/?page_id=1083#MENU"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    self.webView.delegate = self;
    [self.webView loadRequest:request];
}

//Delegate methode - Start spinner
-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.activityIndicator startAnimating];
}

//Delegate methode - Stop spinner
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.activityIndicator stopAnimating];
}

//Delegate methode - Foutboodschap als de pagina niet kan geladen worden
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.activityIndicator stopAnimating];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fout bij laden"
                                                    message:@"De pagina kan niet worden geladen."
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

@end
