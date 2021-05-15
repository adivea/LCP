# R scripts to calculate least cost paths in the Mediterranean and Kazanlak

Scripts from ucloud and worker2 show least-cost path calculation with the gdistance package at the scale of the Mediterranean after the download of the SRTM tiles that cover the area of the Roman Empire (without Britannia). Accummulated cost surface is generated for the entire area and then travel times calculated from each cell within the territory of the Roman Provinces to the nearest town that contain 1000 and more inhabitants and the rest of the terrain within the empire.

movecost_Kaz script shows the application of the movecost() package run locally, using the Kazanlak Aster and SRTM imagery to showcase the functionality of this package with its extra functions.

Need: apply moveost at the level of the empire among towns with more than 5000 inhabitants.  