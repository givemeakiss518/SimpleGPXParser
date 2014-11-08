//
//  ViewController.m
//  gpx-parser
//
//  Created by zhangchao on 14/8/17.
//  Copyright (c) 2014年 zhangchao. All rights reserved.
//

#import "ViewController.h"
#import "GPXParser.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_mStartParseButton setEnabled:false];
    [_mParserProgress setDoubleValue:0];
    [_mParserProgress setIndeterminate:NO];
    [_mParserProgress setUsesThreadedAnimation:NO];

    [_mParserCircleProgress setDoubleValue:0];
    [_mParserCircleProgress setIndeterminate:NO];
    [_mParserCircleProgress setUsesThreadedAnimation:NO];

    _numberOfRows = 0;
    _currentTrackPoints = [NSMutableArray array];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    // Update the view, if already loaded.
}

- (IBAction)openFileButtonPressed:(NSButton *)sender {
    NSLog(@"Button CLicked.");

    NSString *path = [self getFilePathFromDialog];
    if (path != nil) {
        // show path in Text Field.
        [_mPathTextField setStringValue:path];
        [_mParseStateInfoLabel setStringValue:@""];
    }
    mData = [self loadDataFromFile:path];
    if (mData != nil) [_mStartParseButton setEnabled:true];
}

- (IBAction)startParserButtonPressed:(NSButton *)sender {
//    [_currentTrackPoints removeAllObjects];
    [self removeAllObjectsOfTable];

    if (mData != nil) {
        GPXParser *gpxParser = [[GPXParser alloc] initWithData:mData];
        gpxParser.delegate = self;
        [gpxParser parserAllElements];
    }
}

- (NSData *)loadDataFromFile:(NSString *)path {
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    if (data == nil) {
        NSLog(@"loadDataFromFile data is NULL !!!");
    }
//    NSString *strData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"loadDataFromFile data is %@", strData);
    return data;
}

- (NSString *)getFilePathFromDialog {
    // Create the File Open Dialog class.
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
//    // Enable the selection of files in the dialog.
//    [openPanel setCanChooseFiles:YES];
//    // Multiple files not allowed
//    [openPanel setAllowsMultipleSelection:NO];
    // Can't select a directory
    [openPanel setCanChooseDirectories:NO];
    // set file type.
    [openPanel setAllowedFileTypes:[NSArray arrayWithObjects:@"gpx"/*, @"xml"*/, nil]];

    NSString *result = nil;

// single selection
    if ([openPanel runModal] == NSModalResponseOK) {
        result = [[openPanel URLs] objectAtIndex:0];
    }

    NSLog(@"getFilePathFromDialog Url: %@", result);
    return result;
}


- (void)rootCreatorDidParser:(NSString *)creator {
    NSLog(@"rootCreatorDidParser from GPXParserDelegate. %@", creator);
    [_mCreatorTextField setStringValue:creator];
}

- (void)rootVersionDidParser:(NSString *)version {
    NSLog(@"rootVersionDidParser from GPXParserDelegate. %@", version);
    [_mVersionTextField setStringValue:version];
}

- (void)onErrorWhenParser:(int)errorCode {
    NSLog(@"onErrorWhenParser from GPXParserDelegate, errorCode : %d", errorCode);
    [_mParseStateInfoLabel setStringValue:[NSString stringWithFormat:@"Error :%d", errorCode]];
}

- (void)onPercentageOfParser:(double)percentage {
//    NSLog(@"onPercentOfParser from GPXParserDelegate, percentage : %d", percentage);
    [_mParseStateInfoLabel setStringValue:[NSString stringWithFormat:@"%.2f%%", percentage]];
    [_mParserProgress setDoubleValue:percentage];
    [_mParserCircleProgress setDoubleValue:percentage];
}

- (void)trackPointDidParser:(TrackPoint *)trackPoint {
    NSLog(@" zczc trackPointDidParser");
    [_currentTrackPoints addObject:trackPoint];
//    [_mGPXTableView reloadData];
//    [_mGPXTableView beginUpdates];

//    // 添加一个空行
//    [_mGPXTableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:0] withAnimation:NSTableViewAnimationEffectGap];
//    [_mGPXTableView editColumn:0 row:0 withEvent:nil select:YES];

//    [_mGPXTableView endUpdates];
}

- (void)trackSegmentDidParser:(TrackSegment *)segment {

}

- (void)trackDidParser:(Track *)track {
//    if (track == nil) return;
//    [_mLengthTextField setStringValue:[NSString stringWithFormat:@"%.2f", [track length]]];
    _numberOfRows += track.countOfPoints;
    [_mGPXTableView reloadData];
}

- (void)allTracksDidParser:(NSArray *)tracks {
    NSLog(@" zczc allTracksDidParser");
    _allTracks = [NSArray arrayWithArray:tracks];
    double length = 0;
    double elevationGain = 0;
    double totalTime = 0;
    for (Track *track in tracks) {
        length += track.length;
        elevationGain += track.elevationGain;
        totalTime += track.totalTime;
//        _numberOfRows += track.countOfPoints;
    }
    [_mLengthTextField setStringValue:[NSString stringWithFormat:@"%.2f", length]];
    [_mElevationGainTextField setStringValue:[NSString stringWithFormat:@"%.2f", elevationGain]];
    [_mTotalTimeTextField setStringValue:[NSString stringWithFormat:@"%.2f", totalTime]];

//    [_mGPXTableView reloadData];
}

- (void)removeAllObjectsOfTable {
    _numberOfRows = 0;
    [_mGPXTableView reloadData];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    // Get a new ViewCell
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];

    if ([tableColumn.identifier isEqualToString:@"trackID"]) {
        [[cellView textField] setStringValue:[NSString stringWithFormat:@"%ld", row + 1]];
        return cellView;
    } else if ([tableColumn.identifier isEqualToString:@"trackTime"]) {
        [[cellView textField] setStringValue:@"time"];
        return cellView;
    } else if ([tableColumn.identifier isEqualToString:@"trackLon"]) {
        [[cellView textField] setStringValue:@"lon"];
        return cellView;
    } else if ([tableColumn.identifier isEqualToString:@"trackLat"]) {
        [[cellView textField] setStringValue:@"lat"];
        return cellView;
    } else if ([tableColumn.identifier isEqualToString:@"trackEle"]) {
        [[cellView textField] setStringValue:@"ele"];
        return cellView;
    }

    return cellView;
}


//- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
//    // Get a new ViewCell
//    NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
//
//    long rowTemp = row;
//    long trackIndex = 0;
//    for (Track *track in _allTracks) {
//        if (rowTemp < [track countOfPoints]) {
//            break;
//        } else {
//            rowTemp = rowTemp - [track countOfPoints];
//        }
//        trackIndex++;
//    }
//
//    if ([tableColumn.identifier isEqualToString:@"trackID"]) {
//        [[cellView textField] setStringValue:[NSString stringWithFormat:@"%ld", row + 1]];
//        return cellView;
//    } else if ([tableColumn.identifier isEqualToString:@"trackTime"]) {
//        [[cellView textField] setStringValue:@"time"];
//        return cellView;
//    } else if ([tableColumn.identifier isEqualToString:@"trackLon"]) {
//        [[cellView textField] setStringValue:@"lon"];
//        return cellView;
//    } else if ([tableColumn.identifier isEqualToString:@"trackLat"]) {
//        [[cellView textField] setStringValue:@"lat"];
//        return cellView;
//    } else if ([tableColumn.identifier isEqualToString:@"trackEle"]) {
//        [[cellView textField] setStringValue:@"ele"];
//        return cellView;
//    }
//    return cellView;
//}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    NSLog(@" zczc numberOfRowsInTableView %ld", _numberOfRows);
    return _numberOfRows;
}

//- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
//{
//    NSLog(@" zczc objectValueForTableColumn row %ld", row);
//
//    return [NSString stringWithFormat:@"row %ld", row];
//}

@end
