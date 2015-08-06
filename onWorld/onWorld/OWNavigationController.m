//
//  OWNavigationController.m
//  OnWorld
//
//  Created by Cuong Diep Chi on 4/26/13.
//  Copyright (c) 2013 Yestech. All rights reserved.
//

#import "OWNavigationController.h"

@interface OWNavigationController ()

@end

@implementation OWNavigationController

- (BOOL)shouldAutorotate
{
	return self.topViewController.shouldAutorotate;
}

- (NSUInteger)supportedInterfaceOrientations
{
	return self.topViewController.supportedInterfaceOrientations;
}

- (void)sendPoppedMessageToControllers:(NSArray *)controllers
{
	for (UIViewController *controller in controllers) {
		if ([controller respondsToSelector:@selector(viewWasPoppedOffStack)])
			[controller performSelector:@selector(viewWasPoppedOffStack)];
	}
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
	NSArray *controllers = [super popToRootViewControllerAnimated:animated];
	[self sendPoppedMessageToControllers:controllers];
	return controllers;
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	NSArray *controllers = [super popToViewController:viewController animated:animated];
	[self sendPoppedMessageToControllers:controllers];
	return controllers;
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
	UIViewController *controller = [super popViewControllerAnimated:animated];
	[self sendPoppedMessageToControllers:[NSArray arrayWithObject:controller]];
	return controller;
}

@end
