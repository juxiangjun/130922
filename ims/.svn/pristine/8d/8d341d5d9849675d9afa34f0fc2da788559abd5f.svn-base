//
//  TestViewController.m
//  Test
//
//  Created by Jose Luis Campaña on 08/01/13.
//  Copyright (c) 2013 Jose Luis Campaña. All rights reserved.
//

#import "TestViewController.h"


@interface TestViewController ()

@end

@implementation TestViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.speech = [[SpeechToTextModule alloc] initWithNoGUIAndLocale:kLANG_SPANISH];
        [self.speech setDelegate:self];
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.texto setText:nil];
    
    [self.btnRec setTitle:@"Mantener pulsado para hablar" forState:UIControlStateNormal];
    [self.btnRec setTitle:@"Soltar para dejar de hablar" forState:UIControlStateHighlighted];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Voice delegate
- (void)didRecognizeResponse:(NSString *)recognizedText
{
    NSLog(@"%@", recognizedText);
    [self.activityIndicator stopAnimating];
    [self.texto setText:recognizedText];
}
- (void)speechStartRecording
{
    NSLog(@"REC...");
}
- (void)speechStopRecording
{
    NSLog(@"STOP");
}

- (void)viewDidUnload
{

    [self setTexto:nil];
    [self setActivityIndicator:nil];
    [super viewDidUnload];
}
- (IBAction)push:(id)sender
{
    [self.texto setText:nil];
    [self.speech beginRecording];
    
}

- (IBAction)pop:(id)sender
{
    [self.speech stopRecording:YES];
    [self.activityIndicator startAnimating];
}


@end
