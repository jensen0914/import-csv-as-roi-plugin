//
//  ImportCSVAsROIFilter.m
//

#import "ImportCSVAsROIFilter.h"

@implementation ImportCSVAsROIFilter

- (void) initPlugin
{
}

- (long) filterImage : (NSString*) menuName
{
	DCMPix* firstPix = [ [ viewerController pixList ] objectAtIndex : 0 ];
	unsigned int maxX = [ firstPix pwidth ];
	unsigned int maxY = [ firstPix pheight ];
	unsigned int maxZ = [ [ viewerController roiList ] count ];
	
	// Let the user select the ROI file to import.
	//
	NSOpenPanel* openDlg = [ NSOpenPanel openPanel ];

	// Enable the selection of files but not directories in the dialog.
	//
	// +TODO+ Add filter back in, not working in build with latest SDK.
	//
	//NSMutableArray *allowedTypes = [ NSMutableArray arrayWithCapacity : 0 ];
	//[ allowedTypes addObject : @".csv" ];
	//[ allowedTypes addObject : @".txt" ];
	//[ openDlg setAllowedFileTypes : allowedTypes ];
	//[ openDlg setAllowsOtherFileTypes : NO ];
	[ openDlg setCanChooseFiles : YES ];
	[ openDlg setCanChooseDirectories : NO ];
	[ openDlg setAllowsMultipleSelection : NO ];
	[ openDlg setTitle : @"ROI Import - Select ROI File" ];

	// Display the dialog.  If the OK button was pressed, process the selected file.
	//
	if ( [ openDlg runModalForDirectory : nil file : nil ] == NSOKButton )
	{
		// Get an array containing the full filename of file selected.
		//
		NSArray* files = [ openDlg filenames ];
		unsigned int i = 0;
		if ( [ files count ] > 0 )
		{
			NSString* fileName = [ files objectAtIndex : 0 ];
			NSString *roiDefinesStr = [ NSString stringWithContentsOfFile : fileName encoding : NSUTF8StringEncoding error : NULL ];
			NSArray* roiDefines = [ roiDefinesStr componentsSeparatedByString : @"\n" ];
			
			// Parse each line in file and add a new rectangle ROI...
			//
			if ( [ roiDefines count ] > 0 )
			{
				for ( i = 0; i < [ roiDefines count ]; i++ )
				{
					NSString* roiDefine = [ roiDefines objectAtIndex : i ];
					
					// X_center,Y_center,Z_center,W,H
					//
					NSArray* parsedROIDefine = [ roiDefine componentsSeparatedByString : @"," ];
					
					if ( [ parsedROIDefine count ] > 4 )
					{
						NSString* tmpStr = [ parsedROIDefine objectAtIndex : 3 ];
						unsigned int w = [ tmpStr intValue ];
						tmpStr = [ parsedROIDefine objectAtIndex : 4 ];
						unsigned int h = [ tmpStr intValue ];
						tmpStr = [ parsedROIDefine objectAtIndex : 0 ];
						unsigned int x = [ tmpStr intValue ] - ( w / 2 );
						tmpStr = [ parsedROIDefine objectAtIndex : 1 ];
						unsigned int y = [ tmpStr intValue ] - ( h / 2 );
						tmpStr = [ parsedROIDefine objectAtIndex : 2 ];
						unsigned int z = [ tmpStr intValue ];
						
						ROI *newROI;
						if ( ( h > 1 ) && ( w > 1 ) )
						{
							// Add a rectangle ROI.
							//
							newROI = [ viewerController newROI : tROI ];
							NSRect irect;
							irect.origin.x = x;
							irect.origin.y = y;
							irect.size.width = w;
							irect.size.height = h;
							[ newROI setROIRect : irect ];
							[ newROI setName : @"ROI Import" ];
							[ [ viewerController imageView ] roiSet : newROI ];
						}
						else
						{
							// Add a point ROI.
							//
							newROI = [ viewerController newROI : t2DPoint ];
							NSRect irect;
							irect.origin.x = x;
							irect.origin.y = y;
							irect.size.width = 0;
							irect.size.height = 0;
							[ newROI setROIRect : irect ];
							[ newROI setName : @"ROI Import" ];
							[ [ viewerController imageView ] roiSet : newROI ];
						}

						// Add the new ROI to the ROI list
						//
						if ( ( x < maxX ) && ( y < maxY ) && ( z < maxZ ) )
						{
							[ [ [ viewerController roiList ] objectAtIndex : z ] addObject : newROI ];

							[ [ NSNotificationCenter defaultCenter ] postNotificationName : @"roiChange" object : newROI userInfo : 0L ];
							
							NSRunInformationalAlertPanel( @"Added ROI:", roiDefine, nil, nil, nil );
						}
						else
						{
							NSRunInformationalAlertPanel( @"Could not add ROI:", roiDefine, nil, nil, nil );
						}
					}
				}
			}
			else
			{
				NSRunInformationalAlertPanel( @"Error", @"No ROI definitions found in file.", nil, nil, nil );
			}
		}
		else
		{
			NSRunInformationalAlertPanel( @"Error", @"No file selected.", nil, nil, nil );
		}
	}
	
	return 0L;
}

@end
