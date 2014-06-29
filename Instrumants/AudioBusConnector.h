//
//  AudioBusConnector.h
//  Instrumants
//
//  Created by Damien Le Troher on 25/06/2014.
//  Copyright (c) 2014 Damien Le Troher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Audiobus.h"


@interface AudioBusConnector : NSObject {
    AUGraph _processingGraph;
    
    // An io unit is responsible for sending sound to the iPhone speakers
    AudioUnit _ioUnit;
    
    // A mixer unit mixes a number of channels into one
    AudioUnit _mixerUnit;
    
    AudioUnit _samplerUnit;
}

@property (strong, nonatomic) ABAudiobusController *audiobusController;
@property (strong, nonatomic) ABSenderPort *sender;
@end
