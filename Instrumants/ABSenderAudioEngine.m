//
//  ABSenderAudioEngine.m
//  Audiobus Samples
//
//  Created by Michael Tyson on 17/12/2013.
//  Copyright (c) 2011-2014 Audiobus. All rights reserved.
//

#import "ABSenderAudioEngine.h"

@implementation ABSenderAudioEngine

-(id)init {
    if ( !(self = [super init]) ) return nil;
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    // Set up variables for the audio graph
    OSStatus result = noErr;
    AUNode ioNode, mixerNode, samplerNode;
    
    // Specify the common portion of an audio unit's identify, used for all audio units
    // in the graph.
    AudioComponentDescription cd = {};
    cd.componentManufacturer     = kAudioUnitManufacturer_Apple;
    
    // Instantiate an audio processing graph
    result = NewAUGraph (&_processingGraph);
    NSCAssert (result == noErr, @"Unable to create an AUGraph object. Error code: %d '%.4s'", (int) result, (const char *)&result);
    // SAMPLER UNIT
    //Specify the Sampler unit, to be used as the first node of the graph
    cd.componentType = kAudioUnitType_MusicDevice;
    cd.componentSubType = kAudioUnitSubType_Sampler;
    
    // Create a new sampler note
    result = AUGraphAddNode (_processingGraph, &cd, &samplerNode);
    
    // Check for any errors
    NSCAssert (result == noErr, @"Unable to add the Sampler unit to the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    // IO UNIT
    // Specify the Output unit, to be used as the second and final node of the graph
    cd.componentType = kAudioUnitType_Output;
    cd.componentSubType = kAudioUnitSubType_RemoteIO;
    
    // Add the Output unit node to the graph
    result = AUGraphAddNode (_processingGraph, &cd, &ioNode);
    NSCAssert (result == noErr, @"Unable to add the Output unit to the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    // MIXER UNIT
    // Add the mixer unit to the graph
    cd.componentType = kAudioUnitType_Mixer;
    cd.componentSubType = kAudioUnitSubType_MultiChannelMixer;
    
    result = AUGraphAddNode (_processingGraph, &cd, &mixerNode);
    NSCAssert (result == noErr, @"Unable to add the Output unit to the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    
    // Open the graph
    result = AUGraphOpen (_processingGraph);
    NSCAssert (result == noErr, @"Unable to open the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    // Now that the graph is open get references to all the nodes and store
    // them as audio units
    
    // Get a reference to the sampler node and store it in the samplerUnit variable
    result = AUGraphNodeInfo (_processingGraph, samplerNode, 0, &_samplerUnit);
    NSCAssert (result == noErr, @"Unable to obtain a reference to the Sampler unit. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    // Load a soundfont into the mixer unit
    //[self loadSoundFont:@"gorts_filters" withPatch:1 withBank:kAUSampler_DefaultMelodicBankMSB withSampler:_samplerUnit];
    
    // Create a new mixer unit. This is necessary because if we want to have more than one
    // sampler outputting throught the speakers
    result = AUGraphNodeInfo (_processingGraph, mixerNode, 0, &_mixerUnit);
    NSCAssert (result == noErr, @"Unable to obtain a reference to the Sampler unit. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    // Obtain a reference to the I/O unit from its node
    result = AUGraphNodeInfo (_processingGraph, ioNode, 0, &_ioUnit);
    NSCAssert (result == noErr, @"Unable to obtain a reference to the I/O unit. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    // Define the number of input busses on the mixer unit
    UInt32 busCount   = 1;
    
    // Set the input channels property on the mixer unit
    result = AudioUnitSetProperty (
                                   _mixerUnit,
                                   kAudioUnitProperty_ElementCount,
                                   kAudioUnitScope_Input,
                                   0,
                                   &busCount,
                                   sizeof (busCount)
                                   );
    NSCAssert (result == noErr, @"AudioUnitSetProperty Set mixer bus count. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    // Connect the sampler unit to the mixer unit
    result = AUGraphConnectNodeInput(_processingGraph, samplerNode, 0, mixerNode, 0);
    
    // Set the volume of the channel
    AudioUnitSetParameter(_mixerUnit, kMultiChannelMixerParam_Volume, kAudioUnitScope_Input, 0, 1, 0);
    
    NSCAssert (result == noErr, @"Couldn't connect speech synth unit output (0) to mixer input (1). Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    // Connect the output of the mixer node to the input of he io node
    result = AUGraphConnectNodeInput (_processingGraph, mixerNode, 0, ioNode, 0);
    NSCAssert (result == noErr, @"Unable to interconnect the nodes in the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    // Print a graphic version of the graph
    CAShow(_processingGraph);
    
    // Start the graph
    result = AUGraphInitialize (_processingGraph);
    
    NSAssert (result == noErr, @"Unable to initialze AUGraph object. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    // Start the graph
    result = AUGraphStart (_processingGraph);
    NSAssert (result == noErr, @"Unable to start audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    
    // Play middle c on the sampler - sampler unit to send the command to, midi command i.e. note on, note number, velocity
    MusicDeviceMIDIEvent(_samplerUnit, 0x90, 60, 127, 0);
    

    
    
    
    
    
    // Create an Audiobus instance
    self.audiobusController = [[ABAudiobusController alloc] initWithApiKey:@"MTQwNTIwMTgwMyoqKkluc3RydW1hbnRzKioqaW5zdHJ1bWFudHMuYXVkaW9idXM6Ly8=:Hpy+DlSKk0FlCFYROBGINsx2r1HPLu/6YJnrtt81GEVqANLZA0a7Z7wyFhFJvLxiYQC6l2CTF4D6CX5EvQApIk6JE+5LZ20hzFbL/IFkXETFsCyUttSPNIDXRltlCmgx"];
    
    //MCoqKkFCIFNlbmRlcioqKmFic2VuZGVyLmF1ZGlvYnVzOi8v:cRQbpH4Id+tjCW/V6VXvXFXaci8buTx9mwKKEMU13C6TEPexxK/WrImoBzOQQ23cpynYdKOB97BH6OnPxNd5RdJj5ocGnGOpbqlkc+TwoQP07pbA396pI5gfdIQd7aQH
    // Create a sender port
    self.sender = [[ABSenderPort alloc] initWithName:@"Instrumants"
                                               title:NSLocalizedString(@"Instrumants", @"")
                           audioComponentDescription:(AudioComponentDescription) {
                               .componentType = kAudioUnitType_RemoteGenerator,
                               .componentSubType = 'aout', // Note single quotes
                               .componentManufacturer = 'DToX'}
                                           audioUnit:_ioUnit];
    
    [_audiobusController addSenderPort:_sender];
    

    return self;
}




#pragma mark - Events


#pragma mark - Rendering

#pragma mark - Inter-thread messaging

#pragma mark - Utils

@end
