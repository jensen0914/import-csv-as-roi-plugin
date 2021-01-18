# import-csv-as-roi-plugin
A plugin for Horos or OsiriX for creating ROIs from points in CSV files.

To build, use Xcode 12.x or higher. NOTE: the build is signed to run locally so it will only run on the same workstation. It is up to the builder to change the signing if needed on other workstations.

To install, copy the ImportCSVAsROIPlugin.osirixplugin folder in the build output to your "$HOME/Library/Application Support/Horos/Plugins" directory.

To use, launch Horos, open a series in the viewer, and then use "Plugins->ROI Tools->Import CSV As ROI" to create ROIs on the series from points defined in a CSV file. The CSV file will have a format for each row:

X_CENTER,Y_CENTER,Z_CENTER,WIDTH,HEIGHT

where

X_CENTER, Y_CENTER are Z_CENTER are the centers of the ROI using zero-based indexes. 

WIDTH and HEIGHT are the size of the ROI in pixels. Set both to 0 or 1 if you want a point ROI, or higher if you want a rectangle ROI.
