//
//  CDTTodoReplicator.m
//  Project
//
//  Created by Michael Rhodes on 19/03/2014.
//  Copyright (c) 2014 Cloudant. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
//  except in compliance with the License. You may obtain a copy of the License at
//    http://www.apache.org/licenses/LICENSE-2.0
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.
//

#import "CDTTodoReplicator.h"

#import "CDTAppDelegate.h"


@interface CDTTodoReplicator ()

-(void)log:(NSString*)format, ...;
-(NSURL*)replicatorURL;
-(void)startAndFollowReplicator:(CDTReplicator*)replicator label:(NSString*)label;

@property (nonatomic, strong) CDTReplicator* pullReplicator;
@property (nonatomic, strong) CDTReplicator* pushReplicator;

@end

@implementation CDTTodoReplicator


-(NSURL*)replicatorURL {
    // Shared database for demo purposes -- anyone can put stuff here...
    NSString *username = @"iessidesseepromanownessi";
    NSString *password = @"Y1GFiXSJ0trIonovEj3dhvSK";
    NSString *db_name = @"shared_todo_sample";

    NSString *cleanURL = [NSString stringWithFormat:@"https://%@:*****@mikerhodescloudant.cloudant.com/%@",
                          username,
                          db_name];
    [self log:cleanURL];
    
    NSString *url = [NSString stringWithFormat:@"https://%@:%@@mikerhodescloudant.cloudant.com/%@",
                     username,
                     password,
                     db_name];
    return [NSURL URLWithString:url];
}

/**
 Sync by running first a pull then a push replication. This
 method runs synchronously.
 
 I chose this order arbitrarily -- I haven't yet worked
 out whether it's more efficient to run one or the other
 first.
 */
-(void)sync
{
    [self pullReplication];
    [self pushReplication];
}


-(void)pullReplication
{
    [self log:@"Starting pull replication"];

    NSURL *url = [self replicatorURL];

    CDTAppDelegate *delegate = (CDTAppDelegate *)[[UIApplication sharedApplication] delegate];
    CDTReplicatorFactory *factory = delegate.replicatorFactory;
    CDTPullReplication * replicationConfig = [CDTPullReplication replicationWithSource:url
                                                                                target:delegate.datastore];
    NSError *error;
    self.pullReplicator = [factory oneWay:replicationConfig error:&error];
    if (!self.pullReplicator) {
        [self log:@"Error creating pull replicator: %@", error];
    }
    else {
        [self startAndFollowReplicator:self.pullReplicator label:@"pull"];
    }
}

-(void)pushReplication
{
    [self log:@"Starting push replication"];

    NSURL *url = [self replicatorURL];

    CDTAppDelegate *delegate = (CDTAppDelegate *)[[UIApplication sharedApplication] delegate];
    CDTReplicatorFactory *factory = delegate.replicatorFactory;
    CDTPushReplication *replicationConfig = [CDTPushReplication replicationWithSource:delegate.datastore
                                                                               target:url];
    NSError *error;
    self.pushReplicator = [factory oneWay:replicationConfig error:&error];
    if (!self.pushReplicator) {
        [self log:@"Error creating push replicator: %@", error];
    }
    else {
        [self startAndFollowReplicator:self.pushReplicator label:@"push"];
    }
}
/**
 Starts a replication and sets self as the delegate
 
 In real apps, you'd probably use the replicatorDidComplete: and replicatorDidError:
 callbacks to do something useful, updating the UI or showing an error for example.
 */
-(void)startAndFollowReplicator:(CDTReplicator*)replicator label:(NSString*)label {

    NSString *state = [CDTReplicator stringForReplicatorState:replicator.state];
    [self log:@"%@ state: %@ (%d)", label, state, replicator.state];

    [replicator setDelegate:self];
    
    NSError *error;
    if (![replicator startWithError:&error]) {
        [self log:@"error starting %@ replicator: %@", label, error];
        state = [CDTReplicator stringForReplicatorState:replicator.state];
        [self log:@"%@ state: %@ (%d)", label, state, replicator.state];
        return;
    }

}

-(void)log:(NSString*)format, ... {
    va_list args;
    va_start(args, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);

    NSLog(@"%@", message);
}

#pragma mark CDTReplicatorDelegate

-(void)replicatorDidComplete:(CDTReplicator *)replicator
{
    NSString *label = @"pull";
    if (replicator == self.pushReplicator) {
        label = @"push";
    }
    
    [self log:@"%@ replicator complete", label];
}

-(void)replicatorDidError:(CDTReplicator *)replicator info:(NSError *)info
{
    NSString *label = @"pull";
    if (replicator == self.pushReplicator) {
        label = @"push";
    }
    
    [self log:@"%@ replicator error: %@", label, info];
}

-(void)replicatorDidChangeState:(CDTReplicator *)replicator
{
    NSString *label = @"pull";
    if (replicator == self.pushReplicator) {
        label = @"push";
    }
    
    NSString *state = [CDTReplicator stringForReplicatorState:replicator.state];
    [self log:@"%@ new state: %@ (%d)", label, state, replicator.state];
}

-(void)replicatorDidChangeProgress:(CDTReplicator *)replicator
{
    NSString *label = @"pull";
    if (replicator == self.pushReplicator) {
        label = @"push";
    }
    
    NSString *state = [CDTReplicator stringForReplicatorState:replicator.state];
    [self log:@"%@ changes total %ld. changes processed %ld. state: %@ (%d)", label,
     replicator.changesTotal, replicator.changesProcessed, state, replicator.state];
}

@end
