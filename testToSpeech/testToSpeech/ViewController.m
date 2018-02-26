//
//  ViewController.m
//  testToSpeech
//
//  Created by Jeff on 17/4/12.
//  Copyright © 2017年 Jeff. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVSpeechSynthesis.h>


@interface ViewController ()<AVSpeechSynthesizerDelegate,UITextViewDelegate>
{
    AVSpeechSynthesizer *speechSynthesizer;
    AVSpeechUtterance *speechUtterance;
    AVSpeechSynthesisVoice *speechSynthesisVoice;
}
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *speechOrStop;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
    speechSynthesizer.delegate = self;
    
    speechUtterance = [[AVSpeechUtterance alloc] initWithString:_textView.text];
    speechUtterance.rate = 0.4;
    speechUtterance.pitchMultiplier = 2;
    
    speechSynthesisVoice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
    NSLog(@"%@",AVSpeechSynthesisVoice.speechVoices);
    NSLog(@"---->%@,%@,%@,%ld",speechSynthesisVoice.name,speechSynthesisVoice.identifier,speechSynthesisVoice.language,(long)speechSynthesisVoice.quality);
}
- (IBAction)buttonClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    speechUtterance.voice= speechSynthesisVoice;
    
    [speechSynthesizer speakUtterance:speechUtterance];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [_textView resignFirstResponder];
    speechUtterance = [[AVSpeechUtterance alloc] initWithString:_textView.text];
    speechUtterance.rate = 0.4;
    speechUtterance.pitchMultiplier = 0.7;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
